#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Split 4D (C, Z, Y, X) microscopy images into per-channel 3D TIF files.

Supported formats:
- .czi: loaded via aicsimageio as CZYX (T=0 assumed)
- .tif: must be 4D array with shape (C, Z, Y, X)

Only processes files where the second underscore-separated token starts with 'Z'
'Overview' represents the overview single plane image.
(e.g., "sample_Z123.czi").

"""

from pathlib import Path
from typing import Union

import tifffile as tf
from aicsimageio import AICSImage


def read_czi_as_czyx(img_path: Union[str, Path]) -> tf.TiffFile:
    """Load .czi file and return as 4D (C, Z, Y, X) array (T=0)."""
    img = AICSImage(img_path)
    data = img.get_image_dask_data("CZYX", T=0).compute()
    if data.ndim != 4:
        raise ValueError(f"CZI file {img_path} did not yield 4D (C,Z,Y,X) data. Got shape: {data.shape}")
    return data


def split_image(img_path: Union[str, Path], out_dir: Union[str, Path]) -> None:
    """
    Split a 4D (C, Z, Y, X) image into individual 3D channel TIFs.
    
    Raises
    ------
    ValueError
        If input is not 4D.
    """
    img_path = Path(img_path)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    if img_path.suffix.lower() == ".czi":
        img = read_czi_as_czyx(img_path)
    elif img_path.suffix.lower() in (".tif", ".tiff"):
        img = tf.imread(img_path)
        if img.ndim != 4:
            raise ValueError(f"TIF file {img_path} must be 4D (C, Z, Y, X). Got shape: {img.shape}")
    else:
        raise ValueError(f"Unsupported file extension: {img_path.suffix}")

    # Final shape check
    if img.ndim != 4:
        raise RuntimeError(f"Unexpected image dimensionality: {img.ndim}D")

    stem = img_path.stem
    n_channels = img.shape[0]
    for ch in range(n_channels):
        ch_data = img[ch]  # shape (Z, Y, X) — 3D
        out_path = out_dir / f"{stem}_ch{ch}.tif"
        tf.imwrite(out_path, ch_data)


def should_process_file(filename: str) -> bool:
    """Check if filename matches pattern: *_Z*.*"""
    parts = filename.split("_")
    return len(parts) >= 2 and parts[1].startswith("Z")


def main():
    raw_dir = Path("/mnt/nas10g/Users/lxl/raw/")
    out_dir = Path("/mnt/nas10g/Users/lxl/split/")

    for root, _, files in raw_dir.walk():  # Python 3.9+; use os.walk for older versions
        for file in files:
            if file.lower().endswith((".czi", ".tif", ".tiff")) and should_process_file(file):
                file_path = root / file
                print(f"Processing: {file_path}")
                try:
                    split_image(file_path, out_dir)
                except Exception as e:
                    print(f"Error processing {file_path}: {e}")


if __name__ == "__main__":
    main()