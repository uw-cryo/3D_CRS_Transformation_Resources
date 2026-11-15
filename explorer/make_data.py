"""Write the geoid grids used by the explorer (explorer/index.html).

Reads the NGA EGM96 and EGM2008 geoid grids from PROJ-data and writes them as
PNG files that the page decodes in the browser:

    data/egm96.png    EGM96, 15' grid (all nodes), 1440 x 721
    data/egm2008.png  EGM2008, 2.5' grid thinned to 7.5' (every third node), 2880 x 1441

Each pixel holds the geoid height above WGS 84 in centimetres, as an unsigned
16-bit value (height_cm + 32768) split into red (high byte) and green (low
byte). Rows run from 90 N to 90 S and columns from 180 W eastward; values are
at the grid nodes (pixel-is-point), as in the source grids.

Run from this directory:

    curl -LO https://raw.githubusercontent.com/OSGeo/PROJ-data/master/us_nga/us_nga_egm96_15.tif
    curl -LO https://raw.githubusercontent.com/OSGeo/PROJ-data/master/us_nga/us_nga_egm08_25.tif
    python make_data.py

Needs numpy, pillow and tifffile (pip install numpy pillow tifffile imagecodecs).
The coastline file data/countries-50m.json is copied unchanged from the
world-atlas npm package, version 2.0.2 (Natural Earth 1:50m).
"""
from pathlib import Path

import numpy as np
import tifffile
from PIL import Image

HERE = Path(__file__).resolve().parent
GRIDS = [
    # source grid, thinning step, output
    ("us_nga_egm96_15.tif", 1, "egm96.png"),
    ("us_nga_egm08_25.tif", 3, "egm2008.png"),
]


def encode(heights_m: np.ndarray) -> np.ndarray:
    cm = np.round(heights_m.astype("f8") * 100).astype(np.int32)
    assert cm.min() > -32768 and cm.max() < 32768
    u = (cm + 32768).astype(np.uint16)
    rgb = np.zeros(u.shape + (3,), np.uint8)
    rgb[..., 0] = u >> 8
    rgb[..., 1] = u & 255
    return rgb


def main() -> None:
    (HERE / "data").mkdir(exist_ok=True)
    for src, step, out in GRIDS:
        grid = tifffile.imread(HERE / src)[::step, ::step]
        rgb = encode(grid)
        Image.fromarray(rgb, "RGB").save(HERE / "data" / out, optimize=True)
        back = ((rgb[..., 0].astype(np.int32) << 8) | rgb[..., 1]) - 32768
        assert np.array_equal(back, np.round(grid.astype("f8") * 100).astype(np.int32))
        print(f"{out}: {grid.shape[1]} x {grid.shape[0]}, {grid.min():.2f} to {grid.max():.2f} m")


if __name__ == "__main__":
    main()
