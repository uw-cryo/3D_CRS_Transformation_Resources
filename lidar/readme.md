# WA DNR LiDAR products
The Washington Department of Natural Resources maintains an excellent lidar portal with subsetting of standardized DSM and DTM products, as well as download of the lidar point clouds.  See here: https://lidarportal.dnr.wa.gov/

### Combining separate lidar tiles in a vrt
Your selected area of interest on the DNR portal may cross the boundaries of the original tiled lidar data.  So you will get multiple small DSM/DTM tiles. You can combine these in a virtual raster (vrt) using the `gdalbuildvrt` command (https://gdal.org/programs/gdalbuildvrt.html):
`gdalbuildvrt out_raster.vrt tile1.tif tile2.tif tile3.tif`

Check with gdalinfo: `gdalinfo out_raster.vrt`

Output dimensions and geographic extent should be larger than any individual tile.

Note: To combine multiple point cloud tiles (las/laz), you can use PDAL merge command (https://pdal.io/en/stable/apps/merge.html):
`pdal merge tile1.laz tile2.laz tile3.laz out_merged.laz`

### Coordinate system transformation
All products are distributed using one of two default CRS: either WA State Plane North or WA State Plane South, both using the NAD83(HARN) horizontal datum and the NAVD88 vertical datum (the geoid model used varies by project; see the warning below), with all horizontal and vertical units in U.S. Survey Feet. There are historical reasons for these choices
* EPSG:2926 - NAD83(HARN) / Washington North (ftUS), https://spatialreference.org/ref/epsg/2926/
* EPSG:2927 - NAD83(HARN) / Washington South (ftUS), https://spatialreference.org/ref/epsg/2927/
* EPSG:6360 - NAVD88 height (ftUS)

PROJ information about conversion to UTM Zone 10N WGS84 with height in meters above the ellipsoid, for the Island County example used below (Island County is in the Washington North zone):

`projinfo -s EPSG:2926+6360 -t EPSG:32610+4979 -o PROJ --hide-ballpark --spatial-test intersects | less`
```
Candidate operations found: 19
-------------------------------------
Operation No. 1:

unknown id, Inverse of SPCS83 Washington North zone (US survey foot) + Conversion from NAVD88 height (ftUS) to NAVD88 height + Inverse of NAD83(HARN) to NAVD88 height (1) + NAD83(HARN) to WGS 84 (3) + UTM zone 10N, 1.05 m, United States (USA) - CONUS onshore north of 41°N and west of 112°W - Oregon and Washington; California and Nevada north of 41°N; Utah north of 41°N and west of 112°W; Idaho and Montana west of 112°W.

PROJ string:
+proj=pipeline
  +step +proj=unitconvert +xy_in=us-ft +xy_out=m
  +step +inv +proj=lcc +lat_0=47 +lon_0=-120.833333333333 +lat_1=48.7333333333333
        +lat_2=47.5 +x_0=500000.0001016 +y_0=0 +ellps=GRS80
  +step +proj=unitconvert +z_in=us-ft +z_out=m
  +step +proj=vgridshift +grids=us_noaa_g1999u01.tif +multiplier=1
  +step +proj=cart +ellps=GRS80
  +step +proj=helmert +x=-0.991 +y=1.9072 +z=0.5129 +rx=-0.0257899075194932
        +ry=-0.0096500989602704 +rz=-0.0116599432323421 +s=0
        +convention=coordinate_frame
  +step +inv +proj=cart +ellps=WGS84
  +step +proj=utm +zone=10 +ellps=WGS84
```

There are 19 different possible operations, with subtle differences (and uncertainty) depending on the NAD83 and NAVD88 definitions and offset grids used. To be more precise, we should also unambiguously define the WGS84 realization (not just "WGS84"), but there are no convenient EPSG codes for UTM projections using "WGS 84 (G1762)", so we will need to create a custom WKT CRS (see [Custom CRS](#custom-crs)).

:::{warning} Check the horizontal datum step, not just the geoid
The top-ranked operation above (Operation No. 1, still first with PROJ 9.7.1) applies **GEOID99** (`us_noaa_g1999u01.tif`) and the `NAD83(HARN) to WGS 84 (3)` Helmert transformation, with 1.05 m accuracy. The `gdalwarp` commands below use whatever operation PROJ ranks first.

WA DNR projects were flown over many years with different geoid models (for example GEOID03, GEOID09, GEOID12B or GEOID18), so check the project's report or metadata on the lidar portal. The Island County 2014 example used **GEOID09**. Here the geoid choice hardly matters: GEOID99, GEOID09 and GEOID18 agree to within 1 cm in Island County. What matters is how each operation gets from NAD83 to WGS84. For a NAVD88 height of 100 m in Island County (48.22°N, 122.69°W), with PROJ 9.7.1:

| Route | Ellipsoidal height |
| - | - |
| Operation No. 1 (GEOID99 + `NAD83(HARN) to WGS 84 (3)` Helmert) | 77.276 m |
| Operations No. 5 and 8 (GEOID09, then a zero-shift NAD83 to WGS84 step, 2.1 m accuracy) | 77.607 m |
| NAD83(2011) to ITRF2014 at epoch 2014.2, via the second command below | 77.300 m |

So picking an operation only because its geoid matches can make the result worse: the GEOID09 operations treat NAD83 and WGS84 as identical and land 0.31 m above ITRF2014. Across the 19 candidates the heights span more than 0.5 m.

The target `EPSG:32610+4979` uses the WGS84 {term}`ensemble`, which is only defined to about 2 m in all three axes, so PROJ is free to pick any of these routes (see [Don't transform into the WGS84 ensemble](#ensemble-target)). For comparison with ITRF-based data such as ICESat-2, use the NAD83(2011) command below, then apply the time-dependent NAD83(2011) to ITRF2014 transformation, as in the [3DEP 10 m seamless notebook](../3dep/10m-seamless.ipynb). That notebook uses the transformation's 2010 reference epoch; pass the data's own epoch to `gdalwarp` with `-t_coord_epoch` when horizontal motion matters (NAD83 moves 1–2 cm per year against ITRF in the contiguous US). Or target a specific realization with a [custom CRS](#custom-crs).
:::

Sample gdalwarp command to transform sample WA DNR LiDAR product for Island County, WA, with output CRS of:

#### WGS84 UTM 10N with height in meters above the WGS84 ellipsoid, and output posting of 1 m:

`gdalwarp -s_srs EPSG:2926+6360 -t_srs EPSG:32610+4979 -tr 1.0 1.0 -r cubic -dstnodata -9999 -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER island_2014_dsm_13.tif island_2014_dsm_13_UTM10N_wgs84.tif`

#### NAD83(2011) UTM 10N with height in meters above the NAD83(2011) ellipsoid, and output posting of 1 m
`gdalwarp -s_srs EPSG:2926+6360 -t_srs EPSG:6339+6319 -tr 1.0 1.0 -r cubic -dstnodata -9999 -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER island_2014_dsm_13.tif island_2014_dsm_13_UTM10N_nad83_2011.tif`

Check output CRS with gdalinfo: `gdalinfo island_2014_dsm_13_UTM10N_nad83_2011.tif`

Should have the horizontal CRS and a vertical CRS defined with units of meters.
