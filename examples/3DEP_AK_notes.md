# North Slope 3DEP lidar processing
Notes on processing 3DEP lidar data from July/September 2018 over Utqiagvik (Alaska State Plane Zone 4)

https://portal.opentopography.org/usgsDataset?dsid=AK_NorthSlope_B3_2018  
https://portal.opentopography.org/usgsDataset?dsid=AK_NorthSlope_B7_2018

https://noaa-nos-coastal-lidar-pds.s3.amazonaws.com/laz/geoid12b/9198/index.html

Delivered in "NAD_1983_2011_StatePlane_Alaska_6_FIPS_5006_Feet" [ESRI:102394](https://spatialreference.org/ref/esri/102394/)

Vertical CRS for NAVD88 with units of feet is [EPSG:6360](https://spatialreference.org/ref/epsg/6360/)

`wget https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/OPR/Projects/AK_NorthSlopeBorough_2018_B18/AK_NorthSlope_B7_2018/TIFF/USGS_OPR_AK_NorthSlopeBorough_2018_B18_bh_NSB6_0619.tif`

```
gdalinfo -stats USGS_OPR_AK_NorthSlopeBorough_2018_B18_bh_NSB6_0619.tif
Driver: GTiff/GeoTIFF
Files: USGS_OPR_AK_NorthSlopeBorough_2018_B18_bh_NSB6_0619.tif
Size is 501, 500
Coordinate System is:
PROJCRS["NAD_1983_2011_StatePlane_Alaska_6_FIPS_5006_Feet",
    BASEGEOGCRS["NAD83(2011)",
        DATUM["NAD83 (National Spatial Reference System 2011)",
            ELLIPSOID["GRS 1980",6378137,298.257222101,
                LENGTHUNIT["metre",1,
                    ID["EPSG",9001]]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433,
                ID["EPSG",9122]]]],
    CONVERSION["Transverse Mercator",
        METHOD["Transverse Mercator",
            ID["EPSG",9807]],
        PARAMETER["Latitude of natural origin",54,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8801]],
        PARAMETER["Longitude of natural origin",-158,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8802]],
        PARAMETER["Scale factor at natural origin",0.9999,
            SCALEUNIT["unity",1],
            ID["EPSG",8805]],
        PARAMETER["False easting",500000,
            LENGTHUNIT["metre",1],
            ID["EPSG",8806]],
        PARAMETER["False northing",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8807]]],
    CS[Cartesian,2],
        AXIS["easting",east,
            ORDER[1],
            LENGTHUNIT["US survey foot",0.304800609601219,
                ID["EPSG",9003]]],
        AXIS["northing",north,
            ORDER[2],
            LENGTHUNIT["US survey foot",0.304800609601219,
                ID["EPSG",9003]]]]
Data axis to CRS axis mapping: 1,2
Origin = (1763999.999999966705218,6251999.999999993480742)
Pixel Size = (2.999999999986987,-2.999999999986962)
Metadata:
  AREA_OR_POINT=Area
  DataType=Generic
Image Structure Metadata:
  COMPRESSION=LZW
  INTERLEAVE=BAND
  PREDICTOR=3
Corner Coordinates:
Upper Left  ( 1764000.000, 6252000.000) (156d57'30.54"W, 71d 5'49.98"N)
Lower Left  ( 1764000.000, 6250500.000) (156d57'31.32"W, 71d 5'35.23"N)
Upper Right ( 1765503.000, 6252000.000) (156d56'44.95"W, 71d 5'49.73"N)
Lower Right ( 1765503.000, 6250500.000) (156d56'45.74"W, 71d 5'34.98"N)
Center      ( 1764751.500, 6251250.000) (156d57' 8.14"W, 71d 5'42.48"N)
Band 1 Block=256x256 Type=Float32, ColorInterp=Gray
  Description = Layer_1
  Min=17.503 Max=34.952
  Minimum=17.503, Maximum=34.952, Mean=28.485, StdDev=3.543
  NoData Value=-3.402823e+38
  Overviews: 251x250, 126x125, 63x63, 32x32, 16x16
  Metadata:
    LAYER_TYPE=athematic
    SourceBandIndex=0
    STATISTICS_COVARIANCES=12.55477372395136
    STATISTICS_MAXIMUM=34.951766967773
    STATISTICS_MEAN=28.485348343773
    STATISTICS_MEDIAN=0
    STATISTICS_MINIMUM=17.502546310425
    STATISTICS_MODE=0
    STATISTICS_SKIPFACTORX=1
    STATISTICS_SKIPFACTORY=1
    STATISTICS_STDDEV=3.5432716130649
```


## 3D CRS Transformation

### Creation
Want to transform to match WorldView stereo DEM output. ITRF realization used by Maxar to derive camera models is unknown, but acquisition date was April 2022.  
Output from ASP point2dem is UTM Zone 4N projection using WGS84 ellipsoid (EPSG:4326 ensemble), height above WGS84 ellipsoid (like G2139) - see [ESRI:115885](https://spatialreference.org/ref/esri/115885/)
To enable proper PROJ transformation (including Helmert for offset between NAD83(2011) and WGS84 ellipsoid), need well-defined WGS84 realization.  

Using EPSG:32604+7912 does not work as mixing WGS84/GRS80.  Using EPSG:32604+ESRI:115885 is valid, but WGS84 Ensemble uncertainty (~2.0 m) is propagated to the Compound CRS from the UTM projection definition, and Helmert transform is not applied.

Had to create a custom WKT2 text file combining relevant portions of:
* [EPSG:32604](https://spatialreference.org/ref/epsg/32604/) projection and definitions, but using well-defined WGS84 CRS (not ensemble)
* 3D ellipsoidal CRS (lat/lon, not cartesian) options:
  * ITRF2014 [EPSG:7912](https://spatialreference.org/ref/epsg/7912/)
  * WGS84 (G2139) [EPSG:9754](https://spatialreference.org/ref/epsg/9754/)

See files:
  * UTM_4N_ITRF2014_3D.wkt
  * UTM_4N_WGS84_G2139_3D.wkt

```
PROJCRS["WGS 84 (G2139) / UTM 4N",
    BASEGEOGCRS["WGS 84 (G2139)",
    DYNAMIC[
        FRAMEEPOCH[2016]],
    DATUM["World Geodetic System 1984 (G2139)",
        ELLIPSOID["WGS 84",6378137,298.257223563,
            LENGTHUNIT["metre",1]]],
    PRIMEM["Greenwich",0,
        ANGLEUNIT["degree",0.0174532925199433]],
	ID["EPSG",9754]],
   CONVERSION["UTM zone 4N",
        METHOD["Transverse Mercator",
            ID["EPSG",9807]],
        PARAMETER["Latitude of natural origin",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8801]],
        PARAMETER["Longitude of natural origin",-159,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8802]],
        PARAMETER["Scale factor at natural origin",0.9996,
            SCALEUNIT["unity",1],
            ID["EPSG",8805]],
        PARAMETER["False easting",500000,
            LENGTHUNIT["metre",1],
            ID["EPSG",8806]],
        PARAMETER["False northing",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8807]]],
    CS[Cartesian,3],
        AXIS["(E)",north,
            MERIDIAN[90,
                ANGLEUNIT["degree", 0.0174532925199433]],
            ORDER[1],
            LENGTHUNIT["metre",1]],
        AXIS["(N)",north,
            MERIDIAN[0,
                ANGLEUNIT["degree", 0.0174532925199433]],
            ORDER[2],
            LENGTHUNIT["metre",1]],
        AXIS["ellipsoidal height (h)",up,
            ORDER[3],
            LENGTHUNIT["metre",1,
                ID["EPSG",9001]]]]
```

### Application

PROJ accepts compound CRS with mixed authorities `ESRI:102394+EPSG:6360`:

`projinfo -s ESRI:102394+EPSG:6360 -t "$(cat UTM_4N_WGS84_G2139_3D.wkt)" -o PROJ --hide-ballpark --spatial-test intersects`

```
Operation No. 1:                                                                                                                                                                                                                   [27/3144]

unknown id, Inverse of NAD_1983_2011_StatePlane_Alaska_6_FIPS_5006_Feet + Conversion from NAVD88 height (ftUS) to NAVD88 height + Inverse of NAD83(2011) to NAVD88 height (2) + Conversion from NAD83(2011) (geog3D) to NAD83(2011) (geocent
ric) + Inverse of ITRF2014 to NAD83(2011) (1) + Inverse of WGS 84 (G2139) to ITRF2014 (1) + Conversion from WGS 84 (G2139) (geocentric) to WGS 84 (G2139) (geog3D) + UTM zone 4N, 0.03 m, United States (USA) - Alaska.

PROJ string:
+proj=pipeline
  +step +proj=unitconvert +xy_in=us-ft +xy_out=m
  +step +inv +proj=tmerc +lat_0=54 +lon_0=-158 +k=0.9999 +x_0=500000.000000001
        +y_0=0 +ellps=GRS80
  +step +proj=unitconvert +z_in=us-ft +z_out=m
  +step +proj=vgridshift +grids=us_noaa_g2012ba0.tif +multiplier=1
  +step +proj=cart +ellps=GRS80
  +step +inv +proj=helmert +x=1.0053 +y=-1.90921 +z=-0.54157 +rx=0.02678138
        +ry=-0.00042027 +rz=0.01093206 +s=0.00036891 +dx=0.00079 +dy=-0.0006
        +dz=-0.00144 +drx=6.667e-05 +dry=-0.00075744 +drz=-5.133e-05                                                                                                                                                                                +ds=-7.201e-05 +t_epoch=2010 +convention=coordinate_frame
  +step +inv +proj=cart +ellps=WGS84
  +step +proj=utm +zone=4 +ellps=WGS84
```

This provides ~0.02-0.03 m uncertainty, as expected. 

gdalwarp does not accept `ESRI:102394+EPSG:6360`, but does accept [OGC URN string](https://www.ogc.org/about-ogc/policies/ogc-urn-policy/) `urn:ogc:def:crs,crs:ESRI::102394,crs:EPSG::6360` :

`gdalwarp $gdal_opt -s_srs "urn:ogc:def:crs,crs:ESRI::102394,crs:EPSG::6360" -t_srs ~/UTM_4N_WGS84_G2139_3D.wkt USGS_OPR_AK_NorthSlopeBorough_2018_B18_bh_NSB6_0619.tif test.tif --debug ON `

This appears to do all of the necessary transformations correctly, and output stats look good:

```
gdalinfo test.tif -stats
Driver: GTiff/GeoTIFF
Files: test.tif
       test.tif.aux.xml
Size is 509, 508
Coordinate System is:
PROJCRS["WGS 84 (G2139) / UTM 4N",
    BASEGEOGCRS["WGS 84 (G2139)",
        DYNAMIC[
            FRAMEEPOCH[2016]],
        DATUM["World Geodetic System 1984 (G2139)",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        ID["EPSG",9754]],
    CONVERSION["UTM zone 4N",
        METHOD["Transverse Mercator",
            ID["EPSG",9807]],
        PARAMETER["Latitude of natural origin",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8801]],
        PARAMETER["Longitude of natural origin",-159,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8802]],
        PARAMETER["Scale factor at natural origin",0.9996,
            SCALEUNIT["unity",1],
            ID["EPSG",8805]],
        PARAMETER["False easting",500000,
            LENGTHUNIT["metre",1],
            ID["EPSG",8806]],
        PARAMETER["False northing",0,
            LENGTHUNIT["metre",1],
            ID["EPSG",8807]]],
    CS[Cartesian,3],
        AXIS["(E)",north,
            MERIDIAN[90,
                ANGLEUNIT["degree",0.0174532925199433]],
            ORDER[1],
            LENGTHUNIT["metre",1]],
        AXIS["(N)",north,
            MERIDIAN[0,
                ANGLEUNIT["degree",0.0174532925199433]],
            ORDER[2],
            LENGTHUNIT["metre",1]],
        AXIS["ellipsoidal height (h)",up,
            ORDER[3],
            LENGTHUNIT["metre",1,
                ID["EPSG",9001]]]]
Data axis to CRS axis mapping: 1,2,3
Coordinate epoch: 2022.4
Origin = (573802.361719039850868,7889490.534406480379403)
Pixel Size = (0.914172649211317,-0.914172649211317)
Metadata:
  DataType=Generic
Image Structure Metadata:
  COMPRESSION=LZW
  INTERLEAVE=BAND
Corner Coordinates:
Upper Left  (  573802.362, 7889490.534) (156d57'30.66"W, 71d 5'50.21"N)
Lower Left  (  573802.362, 7889026.135) (156d57'32.22"W, 71d 5'35.23"N)
Upper Right (  574267.676, 7889490.534) (156d56'44.36"W, 71d 5'49.70"N)
Lower Right (  574267.676, 7889026.135) (156d56'45.93"W, 71d 5'34.72"N)
Center      (  574035.019, 7889258.335) (156d57' 8.29"W, 71d 5'42.47"N)
Band 1 Block=256x256 Type=Float32, ColorInterp=Gray
  Description = Layer_1
  Minimum=3.125, Maximum=8.444, Mean=6.474, StdDev=1.080
  NoData Value=-3.402823e+38
  Metadata:
    LAYER_TYPE=athematic
    SourceBandIndex=0
    STATISTICS_MAXIMUM=8.4444904327393
    STATISTICS_MEAN=6.4743127268158
    STATISTICS_MINIMUM=3.1249737739563
    STATISTICS_STDDEV=1.0803329066908
    STATISTICS_VALID_PERCENT=96.69
```

## Epoch support
### projinfo
https://proj.org/en/9.3/apps/projinfo.html  

Various tests with epoch specification using `EPSG:9754@2022.4` format failed

### gdalwarp
https://gdal.org/programs/gdalwarp.html#cmdoption-gdalwarp-s_coord_epoch  
https://gdal.org/user/coordinate_epoch.html#support-in-utilities

gdalwarp with `-s_coord_epoch 2010.0 -t_coord_epoch 2022.4` also failed (requires PROJ 9.4)
