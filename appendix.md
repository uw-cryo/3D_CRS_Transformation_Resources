# Appendix

:::{warning}
This page contains a somewhat disorganized dump of notes from an improptu community tutorial session led by David Shean and Scott Henderson at the 2023 UW/NASA [ICESat-2 Hackweek event](https://icesat-2-2023.hackweek.io/).
:::


## Curated list of additional resources

* Awesome ICESat-2 Hackweek 2022 Tutorial from Tyler, Hannah and Scott: https://icesat-2-2022.hackweek.io/tutorials/geospatial/geospatial-advanced.html?highlight=datum
* NSIDC notebook on `iceflow` tool (Kevin Beam) for combining (ICESat, Operation IceBridge and ICESat-2): https://github.com/nsidc/NSIDC-Data-Tutorials/blob/main/notebooks/iceflow/corrections.ipynb
* David's GDA module on CRS and projections: https://uwgda-jupyterbook.readthedocs.io/en/latest/modules/04_Vector1_Geopandas_CRS_Proj/04_Vector1_Geopandas_CRS_Proj_prep.html

### Specific to North America
* https://geodesy.noaa.gov/corbin/class_description/NGS_Video_Library.shtml
   * What are Geodetic Datums (https://geodesy.noaa.gov/datums/index.shtml)?
   * How Were Geodetic Datums Established?
   * What Is the Status of Today’s Geodetic Datums?
   * What’s Next for Geodetic Datums (https://geodesy.noaa.gov/datums/newdatums/index.shtml)?

* https://www.meted.ucar.edu/oceans/navy_geodesy/
* PSU Course GPS and GNSS for Geospatial Professionals (Lesson 5): https://www.e-education.psu.edu/geog862/node/1669
* https://www.dnr.wa.gov/publications/eng_plso_state_plane_coord_refresher.pdf
* https://www.uvm.edu/giv/resources/WGS84_NAD83.pdf


## What is a CRS?

* https://uwgda-jupyterbook.readthedocs.io/en/latest/modules/04_Vector1_Geopandas_CRS_Proj/04_Vector1_Geopandas_CRS_Proj_demo.html#crs-and-projections
* Common geospatial CRS definitions are recorded in the EPSG database, stored as WKT format, or as JSON (https://github.com/opengeospatial/CRS-JSON-Encoding)

### Ellipsoid models
![](https://proj.org/en/9.2/_images/general_ellipsoid.png)


## Transformations
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



## Always check your dataset metadata!
* `gdalinfo`
* Review documentation, lidar reports, etc.

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
   * https://vdatum.noaa.gov/docs/est_uncertainties.html
* There are many possible ways to go from one CRS to another, the PROJ pipelines allow you to control this
* Many CRS (esp compound or 3D CRS) don't have EPSG codes - you can define the CRS with machine-readable, well-known text (use WKT2)
