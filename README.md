# 3D_CRS_Transformation_Resources

A centralized repository for resources, documentation and code samples to help people navigate the infinitely confusing, complex, but very important topic of 3D coordinate reference system (CRS) transformations.  Specifically those involving ICESat-2 data.

## Background

### Why is this so complicated!?
* The Earth's surface/shape is constantly changing
* Our ability to measure the Earth's surface/shape and locations on the surface continues to improve (Thanks GNSS!)
* The systems used to define coordinate systems and datums continues to evolve
* The support for these systems in open-source tools continue to change, with a lot of confusing and/or outdated docuemntation out there on the web
* There is a long (fascinating) history of surveying approaches, measurements, correction approaches, and definitions
* Many legacy datasets use older CRS definitions
* Many datasets have missing CRS information in metadata, sometimes incorrect information
* The acronyms used for different CRS and datums can feel like alphabet soup: NAD83, WGS84, GRS80, NAVD88, EGM, ITRF

### What is a CRS?
#### How are they defined?
#### EPSG codes vs. proj strings vs WKT
### Horizontal CRS
#### Ellipsoid models
* https://proj.org/en/9.2/_images/general_ellipsoid.png
### Vertical CRS
#### Geoid models
### Projections
### ITRF Realizations
### epochs, time and plate deformation models
### Specific notes for North America
* https://geodesy.noaa.gov/datums/index.shtml
* https://geodesy.noaa.gov/datums/newdatums/background.shtml
* There is hope! https://geodesy.noaa.gov/datums/newdatums/index.shtml

### Transformations
Going back and forth between different CRS

## Resources
* PROJ (https://proj.org/)
* pyproj
* GeoPandas uses pyproj under the hood for CRS transformations

## ICESat-2 CRS definitions
## Common datasets combined with ICESat-2
### Raster DEMs
#### ArcticDEM/REMA/EarthDEM products from PGC
#### Copernicus 30 m DEM
### Point clouds and altimetry
#### 3DEP lidar
#### WA DNR

## Examples

### Setup
1. Updated to latest PROJ (>9.2 required for improved North American datum support)
2. Retrieve the vertical datum offset grids for your area of interest with https://proj.org/en/9.2/apps/projsync.html
`projsync --all`

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

## Gotchas and other notes
* There is no perfect transformation approach, and all transformations have some uncertainty
* There are many possible ways to go from one CRS to another, the PROJ pipelines allow you to control this
* Many CRS (esp compound or 3D CRS) don't have EPSG codes - you can define the CRS with machine-readable, well-known text (use WKT2)

## Other resources
* Comparison of values with different versions of the NAVD88 geoid (geoid2018 vs geoid2012): https://gist.github.com/scottyhq/bf13033a9655f302e8f9dc9235daf9fc
