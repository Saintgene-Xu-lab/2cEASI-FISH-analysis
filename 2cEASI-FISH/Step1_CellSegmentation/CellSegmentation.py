#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Cellpose-based 3D segmentation pipeline for downsampled channel-0 TIF images.

Processes all `*_ch0.tif` files in a given directory using the Cellpose 'cyto2' model,
applies trilinear downsampling, performs 3D segmentation, smooths the mask with a 3D median filter,
and upsamples the result back to original resolution.

Outputs: {original_name}_smoothmask.tif

"""

import logging
import os
from pathlib import Path
from typing import Union
import cellpose
import numpy as np
import scipy.signal
import tifffile as tf
import torch
import torch.nn.functional as F
from cellpose import models

# Configure logging
logging.basicConfig(
    filename="error_log.txt",
    level=logging.ERROR,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def cellpose_czi_ds(
    filepath: Union[str, Path],
    out_dir: Union[str, Path],
    filename: str
) -> None:
    """
    Perform 3D cell segmentation on a single-channel TIF image using Cellpose.

    Parameters
    ----------
    filepath : str or Path
        Path to input TIF file (expected shape: (Z, Y, X)).
    out_dir : str or Path
        Directory to save the smoothed segmentation mask.
    filename : str
        Original filename (used to construct output name).
    """
    filepath = Path(filepath)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Load image data
    data = tf.imread(filepath)
    if data.ndim != 3:
        raise ValueError(f"Input must be 3D (Z, Y, X), got shape: {data.shape}")

    # Initialize Cellpose model (GPU enabled)
    model = models.Cellpose(gpu=torch.cuda.is_available(), model_type='cyto2')

    # Convert to float32 tensor and add batch/channel dims for interpolation
    d_tensor = torch.from_numpy(data.astype(np.float32))
    scale = 0.5  # downsample by 2x in all axes

    # Downsample using trilinear interpolation
    data_ds = F.interpolate(
        d_tensor[None, None, ...],  # shape: (1, 1, Z, Y, X)
        scale_factor=scale,
        mode='trilinear',
        align_corners=False
    ).squeeze()  # back to (Z_ds, Y_ds, X_ds)

    # Run Cellpose 3D segmentation
    channels = [0, 0]  # grayscale input: [cyto, nucleus] = [0, 0]
    masks, _, _, _ = model.eval(
        data_ds.numpy(),
        diameter=140,
        flow_threshold=0.4,
        cellprob_threshold=1.0,
        channels=channels,
        do_3D=True,
        min_size=10,
        anisotropy=4.3
    )

    # Smooth mask with 3D median filter
    mask_smooth = scipy.signal.medfilt(masks, kernel_size=3)

    # Upsample back to original resolution
    mask_tensor = torch.from_numpy(mask_smooth.astype(np.float32))
    upsampled = F.interpolate(
        mask_tensor[None, None, ...],
        size=data.shape,
        mode='nearest'
    ).squeeze()

    # Save result
    stem = Path(filename).stem
    out_path = out_dir / f"{stem}_smoothmask.tif"
    tf.imwrite(out_path, upsampled.astype(np.int16))


def main() -> None:
    input_root = Path("/mnt/nas10g/lxl/split/")
    output_dir = Path("/mnt/nas10g/lxl/mask/")

    for root, _, files in os.walk(input_root):
        for file in files:
            if file.endswith("ch0.tif"):
                filepath = Path(root) / file
                print(f"Processing: {filepath}")
                try:
                    cellpose_czi_ds(filepath, output_dir, file)
                except Exception as e:
                    error_msg = f"Failed to process {filepath}: {e}"
                    logging.error(error_msg)
                    print(f"{error_msg}. See error_log.txt for details.")


if __name__ == "__main__":
    main()