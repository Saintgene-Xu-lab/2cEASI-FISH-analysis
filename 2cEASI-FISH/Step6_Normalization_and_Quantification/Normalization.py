#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Normalize FISH signal intensities by local neighborhood density and average cell volume.

This script:
1. Loads FISH measurement data and neighborhood statistics.
2. Computes mean 'Eef2' per slice to represent local neighborhood density.
3. Calculates average cell volume across 5 volume channels.
4. Normalizes gene expression columns (columns 12–41) by:
   normalized_value = raw_value / (neighborhood_density * avg_volume)
5. Saves the normalized dataset to CSV.
"""

import pandas as pd
from pathlib import Path

# Input paths
FISH_DATA_PATH = "/mnt/nas10g/Users/lxl/Analysis_basedata/FISH_result_250423.csv"
NEIGHBOR_DATA_PATH = "/mnt/nas10g/Users/lxl/Analysis_basedata/Neighbor.csv"

# Output path
OUTPUT_PATH = "/mnt/nas10g/Users/lxl/Analysis_basedata/allFISH_divided_avgVolume.csv"

# Column configuration
VOLUME_COLUMNS = [f"Volume{i}" for i in range(1, 6)]  # Volume1 to Volume5
GENE_START_COL_IDX = 12
GENE_END_COL_IDX = 42  # exclusive (columns 12 to 41 inclusive)

def main() -> None:
    # Load data
    df = pd.read_csv(FISH_DATA_PATH)
    df_neighbor = pd.read_csv(NEIGHBOR_DATA_PATH)

    # Compute mean Eef2 per slice as neighborhood density proxy
    eef2_by_slice = (
        df_neighbor[["Eef2", "Slice"]]
        .groupby("Slice")["Eef2"]
        .mean()
        .rename("neighborhood_density")
    )
    df["neighborhood_density"] = df["Slice"].map(eef2_by_slice)

    # Create a copy for normalization
    df_normalized = df.copy()

    # Compute average cell volume
    df_normalized["avg_Volume"] = df_normalized[VOLUME_COLUMNS].mean(axis=1)

    # Compute normalization factor: neighborhood_density * avg_Volume
    norm_factor = df_normalized["neighborhood_density"] * df_normalized["avg_Volume"]

    # Normalize gene expression columns (12 to 41 inclusive)
    gene_columns = df_normalized.columns[GENE_START_COL_IDX:GENE_END_COL_IDX]
    df_normalized[gene_columns] = df_normalized[gene_columns].div(norm_factor, axis=0)

    # Save result
    output_dir = Path(OUTPUT_PATH).parent
    output_dir.mkdir(parents=True, exist_ok=True)
    df_normalized.to_csv(OUTPUT_PATH, index=False)


if __name__ == "__main__":
    main()