# 3D CRS Transformation Resources

A centralized repository for resources, documentation and code samples to help the community navigate the confusing, complex, but very important topic of 3D coordinate reference system (CRS) transformations when combining datasets for precise geodetic analysis.

This repository was initially created for an improptu community tutorial session led by David Shean and Scott Henderson at the 2023 UW/NASA [ICESat-2 Hackweek event](https://icesat-2-2023.hackweek.io/). We are continuing to review and update materials, including new recipes and examples for commonly used 3D datasets.

## Background
* Awesome ICESat-2 Hackweek 2022 Tutorial from Tyler, Hannah and Scott: https://icesat-2-2022.hackweek.io/tutorials/geospatial/geospatial-advanced.html?highlight=datum
* NSIDC notebook on `iceflow` tool (Kevin Beam) for combining (ICESat, Operation IceBridge and ICESat-2): https://github.com/nsidc/NSIDC-Data-Tutorials/blob/main/notebooks/iceflow/corrections.ipynb
* David's GDA module on CRS and projections: https://uwgda-jupyterbook.readthedocs.io/en/latest/modules/04_Vector1_Geopandas_CRS_Proj/04_Vector1_Geopandas_CRS_Proj_prep.html

### More resources specific to North America
* https://geodesy.noaa.gov/corbin/class_description/NGS_Video_Library.shtml
   * What are Geodetic Datums?
   * How Were Geodetic Datums Established?
   * What Is the Status of Today’s Geodetic Datums?
   * What’s Next for Geodetic Datums?
* https://www.meted.ucar.edu/oceans/navy_geodesy/
* PSU Course GPS and GNSS for Geospatial Professionals (Lesson 5): https://www.e-education.psu.edu/geog862/node/1669
* https://www.dnr.wa.gov/publications/eng_plso_state_plane_coord_refresher.pdf
* https://www.uvm.edu/giv/resources/WGS84_NAD83.pdf

### Why is this so complicated!?
* The Earth's surface/shape is constantly changing
* Our ability to measure the Earth's surface/shape and locations on the surface continues to improve (Thanks GNSS!)
* The systems used to define coordinate systems and datums continues to evolve
* The support for these systems in open-source tools continue to evolve, with a lot of confusing and/or outdated documentation out there on the web
* There is a long (fascinating) history of surveying approaches, measurements, correction approaches, and definitions
* Many legacy datasets use older CRS definitions
* Many datasets have missing CRS information in metadata, sometimes incorrect information
* The acronyms used for different CRS and datums can feel like alphabet soup: NAD83, WGS84, GRS80, NAVD88, EGM, ITRF

### What is a CRS?
#### How are they defined?
* https://uwgda-jupyterbook.readthedocs.io/en/latest/modules/04_Vector1_Geopandas_CRS_Proj/04_Vector1_Geopandas_CRS_Proj_demo.html#crs-and-projections
* Emerging json definitions (in parallel with WKT): https://github.com/opengeospatial/CRS-JSON-Encoding
#### EPSG codes vs. proj strings vs WKT
### Horizontal CRS
#### Ellipsoid models
* https://proj.org/en/9.2/_images/general_ellipsoid.png
### Vertical CRS
#### Geoid models
### Projections
### ITRF Realizations
### epochs, time and plate deformation models
* Plate motion ~1-8 cm/yr
### Specific notes for North America
* https://geodesy.noaa.gov/datums/index.shtml
* https://geodesy.noaa.gov/datums/newdatums/background.shtml
* There is hope! https://geodesy.noaa.gov/datums/newdatums/index.shtml
  * https://xkcd.com/2920/

### Transformations
* Allows you to go back and forth between different CRS
* You've all done this - convert from cartesian to polar coordiantes (high school math)
* Can be 2D or 3D
* Most open-source packages depend on PROJ library (https://proj.org/) for CRS support and transformations
### Vector
* `pyproj`: Python interface for PROJ
* `GeoPandas` uses pyproj under the hood for CRS transformations, with support for compound 3D CRS
### Raster
* `gdalwarp` with proper CRS definitions (and available vertical offset grids) should work

## Common datasets and CRS definitions
### ICESat-2
### Raster DEMs
#### ArcticDEM/REMA/EarthDEM products from PGC
* These are distributed as 2D projected CRS (EPSG:3031 or EPSG:3413), without a vertical datum definition
* Elevation values are "height above the WGS84 ellipsoid" - but no details about specific realization used by vendor (Maxar) providing source stereo imagery
* Most of the Maxar data were acquired and delivered after 2008, so should be using more modern realizations of ITRF (2008, 2014, 2020), which are similar
* Can likely assume ITRF2014 for most of the available DEM products
* Can use custom WKT2 definintions for these 3D CRS:
    * Antarctica: https://github.com/ICESat2-SlideRule/sliderule/blob/cb8ead40d761c8d637397a28e7b6d53fcf1de3c4/plugins/pgc/plugin/ITRF2014_3031.wkt
    * Arctic: https://github.com/ICESat2-SlideRule/sliderule/blob/cb8ead40d761c8d637397a28e7b6d53fcf1de3c4/plugins/pgc/plugin/ITRF2014_3413.wkt
#### Copernicus 30 m DEM
* EPSG:9518 (WGS84 + EGM2008)
### Point clouds and altimetry
#### 3DEP lidar
* NAD83(2011) horizontal with NAVD88 vertical datum
* Projection is Local UTM Zone
* EPSG:6339+5703 (example for UTM Zone 10N with NAVD88 datum, https://epsg.io/6339)
    * Note: this is not the same as EPSG:32610 (WGS84) or EPSG:26910 (NAD83), because we are using NAD83(2011) realization
#### WA DNR
* EPSG:2926+5703 (WA state plane N)
* EPSG:2927+5703 (WA state plane S)
* NAVD88 model should be geoid2012 (I think, need to confirm)

## :warning: Setup
1. `conda install gdal pdal geopandas` or `conda update gdal pdal geopandas`
    * Make sure you are using latest PROJ (>9.2 required for improved North American datum support)
2. Retrieve the vertical datum offset grids for your area of interest with https://proj.org/en/9.2/apps/projsync.html
`projsync --all`

## Examples
### Check your dataset metadata
* `gdalinfo`
* Review documentation, lidar reports, etc.

### ICESat-2 to other CRS
```
# Fake some 3D data but with epsg:4326
gf_orig = gpd.GeoDataFrame(geometry=gpd.points_from_xy([-120.4], [48.6], [1400]), crs='EPSG:4326')

# override 4326 with 3D CRS and do a 3D transform (uses pyproj under the hood):
gf_new = gf.set_crs(epsg=7912, allow_override=True)

gf_new.to_crs(epsg="2927+5703")
```
### Other CRS to ICESat-2

## Testing and validation
### vdatum (https://vdatum.noaa.gov/)
### `cs2cs`
`echo -120.4 48.6 1400 | PROJ_DEBUG=2 PROJ_NETWORK=ON cs2cs -f "%.3f" -r epsg:7912 epsg:2927+5703`
### `projinfo`
`projinfo -s EPSG:7912 -t EPSG:2927+5703 -o PROJ --hide-ballpark --spatial-test intersects`
```
    Candidate operations found: 5
-------------------------------------
Operation No. 1:
unknown id, Inverse of Conversion from ITRF2014 (geocentric) to ITRF2014 (geog3D) + ITRF2014 to NAD83(2011) (1) + Inverse of Conversion from NAD83(2011) (geog3D) to NAD83(2011) (geocentric) + NAD83(2011) to NAVD88 height (3) + Inver
se of NAD83(HARN) to NAD83(2011) (NADCON5, CONUS) + SPCS83 Washington South zone (US Survey feet), 0.105 m, United States (USA) - CONUS onshore - Alabama; Arizona; Arkansas; California; Colorado; Connecticut; Delaware; Florida; Geor
gia; Idaho; Illinois; Indiana; Iowa; Kansas; Kentucky; Louisiana; Maine; Maryland; Massachusetts; Michigan; Minnesota; Mississippi; Missouri; Montana; Nebraska; Nevada; New Hampshire; New Jersey; New Mexico; New York; North Carolina
; North Dakota; Ohio; Oklahoma; Oregon; Pennsylvania; Rhode Island; South Carolina; South Dakota; Tennessee; Texas; Utah; Vermont; Virginia; Washington; West Virginia; Wisconsin; Wyoming.
PROJ string:
+proj=pipeline
  +step +proj=axisswap +order=2,1
  +step +proj=unitconvert +xy_in=deg +xy_out=rad
  +step +proj=cart +ellps=GRS80
  +step +proj=helmert +x=1.0053 +y=-1.90921 +z=-0.54157 +rx=0.02678138
        +ry=-0.00042027 +rz=0.01093206 +s=0.00036891 +dx=0.00079 +dy=-0.0006
        +dz=-0.00144 +drx=6.667e-05 +dry=-0.00075744 +drz=-5.133e-05
        +ds=-7.201e-05 +t_epoch=2010 +convention=coordinate_frame
  +step +inv +proj=cart +ellps=GRS80
  +step +inv +proj=vgridshift +grids=us_noaa_g2018u0.tif +multiplier=1
  +step +inv +proj=gridshift +no_z_transform
        +grids=us_noaa_nadcon5_nad83_2007_nad83_2011_conus.tif
  +step +inv +proj=gridshift +no_z_transform
        +grids=us_noaa_nadcon5_nad83_fbn_nad83_2007_conus.tif
  +step +inv +proj=gridshift +no_z_transform
        +grids=us_noaa_nadcon5_nad83_harn_nad83_fbn_conus.tif
  +step +proj=lcc +lat_0=45.3333333333333 +lon_0=-120.5 +lat_1=47.3333333333333
        +lat_2=45.8333333333333 +x_0=500000.0001016 +y_0=0 +ellps=GRS80
  +step +proj=unitconvert +xy_in=m +xy_out=us-ft
  ```
* Note the 0.105 m uncertainty

## WA DNR LiDAR products
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

## Gotchas and other notes
* There is no perfect transformation approach, and all transformations have some uncertainty
   * https://vdatum.noaa.gov/docs/est_uncertainties.html
* There are many possible ways to go from one CRS to another, the PROJ pipelines allow you to control this
* Many CRS (esp compound or 3D CRS) don't have EPSG codes - you can define the CRS with machine-readable, well-known text (use WKT2)

## Other resources
* Comparison of values with different versions of the NAVD88 geoid (geoid2018 vs geoid2012): https://gist.github.com/scottyhq/bf13033a9655f302e8f9dc9235daf9fc
