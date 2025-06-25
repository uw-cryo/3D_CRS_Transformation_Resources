# Software

Example code in this repository relies heavily on the following open source libraries. This page contains a few useful notes and links, but if you're new to these libraries, spend some time reviewing each project's documentation (links in table below).

| Software | Summary | Citation |
| - | - | - |
| [GDAL](https://gdal.org) | Foundational C++ library for geospatial operations and format conversions | [@cite_gdal] |
| [PROJ](https://proj.org) | Foundational C++ library for CRS handling and reprojection | [@cite_proj] |
| [GeoPandas](https://geopandas.org) | Python library to work with geospatial vector data | [@cite_geopandas] |
| [RioXarray](https://corteva.github.io) | Python library for geosptial raster data | [@cite_rioxarray] |

In general it's easiest to install these libraries using [conda-forge](https://conda-forge.org) package distributions:

You can recreate the software environment that we use to run all the examples in this online book with [Pixi](https://pixi.sh/latest/installation/):
```
git clone https://github.com/uw-cryo/3D_CRS_Transformation_Resources
cd 3D_CRS_Transformation_Resources
pixi shell
gdalinfo --version
```
```
GDAL 3.10.3, released 2025/04/01
```

## PROJ

If you're working with vertical datum offset grids regularly or offline the [projsync](https://proj.org/en/stable/apps/projsync.html) command is your friend (`projsync --all`).
