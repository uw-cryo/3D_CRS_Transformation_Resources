# WA DNR LiDAR products
The Washington Department of Natural Resources maintains an excellent lidar portal with subsetting of standardized DSM and DTM products, as well as download of the lidar point clouds.  See here: https://lidarportal.dnr.wa.gov/

### Combining separate lidar tiles in a vrt
Your selected area of interest on the DNR portal may cross the boundaries of the original tiled lidar data.  So you will get multiple small DSM/DTM tiles. You can combine these in a virtual raster (vrt) using the `gdalbuildvrt` command (https://gdal.org/programs/gdalbuildvrt.html):
`gdalbuildvrt out_raster.vrt tile1.tif tile2.tif tile3.tif`

Check with gdalinfo: `gdalinfo out_raster.vrt`

Output dimensions and geographic extent should be larger than any individual tile.

Note: To combine multiple point cloud tiles (las/laz), you can use PDAL merge command (https://pdal.io/en/2.6.0/apps/merge.html):
`pdal merge tile1.laz tile2.laz tile3.laz out_merged.laz`

### Coordinate system transformation
All products are distributed using one of two default CRS: either WA State Plane North or WA State Plane South, both using the NAD83(HARN) horizontal datum and the NAVD88 vertical datum (unsure if geoid2012 or geoid2018?), with all horizontal and vertical units in U.S. Survey Feet. There are historical reasons for these choices
* EPSG:2926 - NAD83(HARN) / Washington North (ftUS), https://www.spatialreference.org/ref/epsg/2926/
* EPSG:2927 - NAD83(HARN) / Washington South (ftUS), https://www.spatialreference.org/ref/epsg/2927/
* EPSG:6360 - NAVD88 height (ftUS)

PROJ information about conversion from these coordinate systems to UTM Zone 10N WGS84 with height in meters above the ellipsoid:

`projinfo -s EPSG:2927+6360 -t EPSG:32610+4979 -o PROJ --hide-ballpark --spatial-test intersects | less`
```
Candidate operations found: 17
-------------------------------------
Operation No. 1:

unknown id, Inverse of SPCS83 Washington South zone (US Survey feet) + Conversion from NAVD88 height (ftUS) to NAVD88 height + Inverse of NAD83(HARN) to NAVD88 height (1) + NAD83(H
ARN) to WGS 84 (3) + UTM zone 10N, 1.05 m, United States (USA) - CONUS onshore north of 41°N and west of 112°W - Oregon and Washington; California and Nevada north of 41°N; Utah no
rth of 41°N and west of 112°W; Idaho and Montana west of 112°W.

PROJ string:
+proj=pipeline
  +step +proj=unitconvert +xy_in=us-ft +xy_out=m
  +step +inv +proj=lcc +lat_0=45.3333333333333 +lon_0=-120.5
        +lat_1=47.3333333333333 +lat_2=45.8333333333333 +x_0=500000.0001016
        +y_0=0 +ellps=GRS80
  +step +proj=unitconvert +z_in=us-ft +z_out=m
  +step +proj=vgridshift +grids=us_noaa_g1999u01.tif +multiplier=1
  +step +proj=cart +ellps=GRS80
  +step +proj=helmert +x=-0.991 +y=1.9072 +z=0.5129 +rx=-0.0257899075194932
        +ry=-0.0096500989602704 +rz=-0.0116599432323421 +s=0
        +convention=coordinate_frame
  +step +inv +proj=cart +ellps=WGS84
  +step +proj=utm +zone=10 +ellps=WGS84
```

There are 17 different possible operations, with subtle differences (and uncertainty) depending on the NAD83 and NAVD88 definitions and offset grids used. To be more precise, we should also unambiguously define the WGS84 realization (not just "WGS84"), but there are no convenient EPSG codes for UTM projections using "WGS 84 (G1762)", so we will need to create a custom WKT CRS (to be done later).

Sample gdalwarp command to transform sample WA DNR LiDAR product for Island County, WA, with output CRS of:

#### WGS84 UTM 10N with height in meters above the WGS84 ellipsoid, and output posting of 1 m:

`gdalwarp -s_srs EPSG:2927+6360 -t_srs EPSG:32610+4979 -tr 1.0 1.0 -r cubic -dstnodata -9999 -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER island_2014_dsm_13.tif island_2014_dsm_13_UTM10N_wgs84.tif`

#### NAD83(2011) UTM 10N with height in meters above the NAD83(2011) ellipsoid, and output posting of 1 m
`gdalwarp -s_srs EPSG:2927+6360 -t_srs EPSG:6339+6319 -tr 1.0 1.0 -r cubic -dstnodata -9999 -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER island_2014_dsm_13.tif island_2014_dsm_13_UTM10N_nad83_2011.tif`

Check output CRS with gdalinfo: `gdalinfo island_2014_dsm_13_UTM10N_nad83_2011.tif`

Should have the horizontal CRS and a vertical CRS defined with units of meters.
