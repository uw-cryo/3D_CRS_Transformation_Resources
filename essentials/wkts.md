
# WKT representations of CRS

You'll find Well Known Text (WKT) representations of a CRS in a lot of software (GDAL, QGIS, PROJ) because it is a standard format, human readable. Let's look at a few common CRSs to understand them, below we highlight several lines of the WKT representation.

## WGS84 ensemble

```{tip}
If you know the name of a CRS, but not the EPSG code, you can search for it on several websites like https://spatialreference.org
```

```bash
projinfo EPSG:4326 -o WKT2:2019
```

```{code} python
:linenos: true
:emphasize-lines: 2,16,27

GEOGCRS["WGS 84",
    ENSEMBLE["World Geodetic System 1984 ensemble",
        MEMBER["World Geodetic System 1984 (Transit)"],
        MEMBER["World Geodetic System 1984 (G730)"],
        MEMBER["World Geodetic System 1984 (G873)"],
        MEMBER["World Geodetic System 1984 (G1150)"],
        MEMBER["World Geodetic System 1984 (G1674)"],
        MEMBER["World Geodetic System 1984 (G1762)"],
        MEMBER["World Geodetic System 1984 (G2139)"],
        MEMBER["World Geodetic System 1984 (G2296)"],
        ELLIPSOID["WGS 84",6378137,298.257223563,
            LENGTHUNIT["metre",1]],
        ENSEMBLEACCURACY[2.0]],
    PRIMEM["Greenwich",0,
        ANGLEUNIT["degree",0.0174532925199433]],
    CS[ellipsoidal,2],
        AXIS["geodetic latitude (Lat)",north,
            ORDER[1],
            ANGLEUNIT["degree",0.0174532925199433]],
        AXIS["geodetic longitude (Lon)",east,
            ORDER[2],
            ANGLEUNIT["degree",0.0174532925199433]],
    USAGE[
        SCOPE["Horizontal component of 3D system."],
        AREA["World."],
        BBOX[-90,-180,90,180]],
    ID["EPSG",4326]]
```

Line 2 identifies that this CRS uses the WGS84 {term}`ensemble`, line 16 identifies this is a 2D ellipsoidal CRS, and the final line always reports an EPSG code if present.

:::{note} Axis order
Lines 17–22 say that EPSG:4326 lists latitude first and longitude second. Most GIS software and file formats (GeoJSON, shapefiles, GeoTIFF) instead store longitude first, as x/y. Since PROJ 6 and GDAL 3, libraries follow the order the CRS definition gives unless told otherwise, so the same coordinates can come back swapped. In pyproj, pass `always_xy=True` to `Transformer.from_crs()` to get longitude/latitude order; in the GDAL API, set `OAMS_TRADITIONAL_GIS_ORDER` on the spatial reference. The GDAL command-line tools already use the traditional GIS order.
:::

:::{seealso}
[WGS 84: I don't know, I don't care](https://www.youtube.com/watch?v=M2ck3cAGvhg): Javier Jiménez Shaw's short FOSS4G Europe 2024 talk on the WGS84 ensemble, its realizations, and why mixing them can introduce apparent offsets.
:::

(ensemble-target)=
### Don't transform into the ensemble when comparing data

The ensemble is only defined to about 2 m (`ENSEMBLEACCURACY[2.0]`). PROJ therefore treats all its realizations as interchangeable within those 2 m, and any route into the ensemble counts as good enough. This applies to `EPSG:4326`, to its 3D version `EPSG:4979`, and to every `WGS 84 / UTM` code such as `EPSG:32610`. Which operation you get then depends on which CRS your input coordinates are in, not on which operation is correct.

For example, take one point in Atlanta, at NAD83(2011) latitude 33.637°N, longitude 84.428°W, with a NAVD88 height of 250 m, at epoch 2009.975, using PROJ 9.7.1. The same point can be given in two ways:

* as NAD83(2011) latitude and longitude with a NAVD88 height: the compound CRS `EPSG:6318+5703`, where 6318 is NAD83(2011) 2D and 5703 is NAVD88 height;
* as a NAD83(2011) ellipsoidal height (220.533 m): the 3D CRS `EPSG:6319`.

| From | To | Operation PROJ picks (accuracy) | Ellipsoidal height |
| - | - | - | - |
| NAD83(2011) + NAVD88 (`EPSG:6318+5703`) | ITRF2014 3D (`EPSG:7912`) | GEOID18, then the time-dependent NAD83(2011) to ITRF2014 Helmert (0.015 m) | 219.165 m |
| NAD83(2011) + NAVD88 (`EPSG:6318+5703`) | WGS 84 ensemble 3D (`EPSG:4979`) | NAD83(HARN) + GEOID99 + `NAD83(HARN) to WGS 84 (3)` (1.14 m) | 219.179 m |
| NAD83(2011) 3D (`EPSG:6319`) | WGS 84 ensemble 3D (`EPSG:4979`) | `+proj=noop`, from `NAD83(2011) to WGS 84 (1)`: zero shift (2.0 m) | 220.533 m |

::::{dropdown} Commands to reproduce the table
`projinfo` shows which operation PROJ ranks first for this area. The output lines below are wrapped at each `+` step and shortened after the accuracy:

```bash
projinfo -s EPSG:6318+5703 -t EPSG:7912 \
    --bbox -84.5,33.6,-84.4,33.7 --spatial-test intersects \
    --hide-ballpark --summary
```
```
Candidate operations found: 7
unknown id, Inverse of NAD83(2011) to NAVD88 height (3)
  + Conversion from NAD83(2011) (geog3D) to NAD83(2011) (geocentric)
  + Inverse of ITRF2014 to NAD83(2011) (1)
  + Conversion from ITRF2014 (geocentric) to ITRF2014 (geog3D), 0.015 m, …
```

```bash
projinfo -s EPSG:6318+5703 -t EPSG:4979 \
    --bbox -84.5,33.6,-84.4,33.7 --spatial-test intersects \
    --hide-ballpark --summary
```
```
Candidate operations found: 14
unknown id, Inverse of NAD83(HARN) to NAD83(2011) (NADCON5, CONUS)
  + Inverse of NAD83(HARN) to NAVD88 height (7)
  + NAD83(HARN) to WGS 84 (3), 1.14 m, …
```

```bash
projinfo -s EPSG:6319 -t EPSG:4979 \
    --bbox -84.5,33.6,-84.4,33.7 --spatial-test intersects \
    --hide-ballpark --summary
```
```
Candidate operations found: 1
DERIVED_FROM(EPSG):9774, NAD83(2011) to WGS 84 (1), 2.0 m, …
```

`cs2cs` transforms the point. Input is latitude, longitude, height and coordinate epoch (decimal year), in the axis order these CRSs define. Without the epoch, PROJ uses the transformation's reference epoch, 2010.0. `-d 7` prints enough decimals to show the horizontal shift as well: 0.0000066° of latitude is about 0.7 m. Set `PROJ_NETWORK=ON` if the geoid grids are not installed locally.

```bash
echo "33.637 -84.428 250 2009.975" | cs2cs -d 7 EPSG:6318+5703 EPSG:7912
echo "33.637 -84.428 250 2009.975" | cs2cs -d 7 EPSG:6318+5703 EPSG:4979
echo "33.637 -84.428 220.533 2009.975" | cs2cs -d 7 EPSG:6319 EPSG:4979
```
```
33.6370066	-84.4280063 219.1645830 2009.975
33.6370062	-84.4280041 219.1788117 2009.975
33.6370000	-84.4280000 220.5330000 2009.975
```
::::

Row 1 is the correct result. The two ensemble rows differ from it by 1.4 cm and 1.37 m in height (and 0.2 m and 0.9 m horizontally). The only difference between those two rows is the input CRS. The small error in row 2 is a coincidence: PROJ's route uses GEOID99 and an older NAD83(HARN) to WGS 84 shift, which happens to land close to ITRF2014 in Atlanta. In the [WA DNR lidar example](../lidar/readme.md), similar ensemble routes are 0.3 m off.

For comparisons, transform into a specific {term}`realization` of a frame, not the ensemble. PROJ then has to use a transformation that actually reaches that frame, with published parameters and a stated accuracy, as in row 1. Pick the frame of the data you are comparing against: for example ITRF2014 (`EPSG:7912`) for ICESat-2 releases up to 006, ITRF2020 (`EPSG:9989`) for release 007, or WGS 84 (G2139) (`EPSG:9754`). These are geographic CRSs (latitude, longitude and ellipsoidal height). For UTM coordinates on one of them, build a projected [custom CRS](#custom-crs), since EPSG has no such codes. These frames are dynamic, so also give the coordinate epoch.

Before transforming, check which operation PROJ will use with `projinfo -s <input CRS> -t <target CRS> --summary` (as in the dropdown above). The first operation listed is the one PROJ uses if its grids are available, followed by its accuracy. Be suspicious if it says `noop` (nothing is changed) or reports an accuracy of 1 m or more.

## Specific WGS84 realization

```bash
projinfo EPSG:9055 -o WKT2:2019
```

```{code} python
:linenos: true
:emphasize-lines: 2-4,9,20

GEOGCRS["WGS 84 (G1150)",
    DYNAMIC[
        FRAMEEPOCH[2001]],
    DATUM["World Geodetic System 1984 (G1150)",
        ELLIPSOID["WGS 84",6378137,298.257223563,
            LENGTHUNIT["metre",1]]],
    PRIMEM["Greenwich",0,
        ANGLEUNIT["degree",0.0174532925199433]],
    CS[ellipsoidal,2],
        AXIS["geodetic latitude (Lat)",north,
            ORDER[1],
            ANGLEUNIT["degree",0.0174532925199433]],
        AXIS["geodetic longitude (Lon)",east,
            ORDER[2],
            ANGLEUNIT["degree",0.0174532925199433]],
    USAGE[
        SCOPE["Geodesy. Navigation and positioning using GPS satellite system."],
        AREA["World."],
        BBOX[-90,-180,90,180]],
    ID["EPSG",9055]]
```

Lines 2-4 identify that this CRS uses a specific WGS84 {term}`realization`, line 9 again identifies this is still a 2D ellipsoidal CRS, and the final line always reports the EPSG code.

## Compound 3D CRS

Here we combine a horizontal and vertical reference to create an effective 3D CRS

```bash
projinfo EPSG:9055+3855 -o WKT2:2019
```

```{code} python
:linenos: true
:emphasize-lines: 1-2,22-23

COMPOUNDCRS["WGS 84 (G1150) + EGM2008 height",
    GEOGCRS["WGS 84 (G1150)",
        DYNAMIC[
            FRAMEEPOCH[2001]],
        DATUM["World Geodetic System 1984 (G1150)",
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        CS[ellipsoidal,2],
            AXIS["geodetic latitude (Lat)",north,
                ORDER[1],
                ANGLEUNIT["degree",0.0174532925199433]],
            AXIS["geodetic longitude (Lon)",east,
                ORDER[2],
                ANGLEUNIT["degree",0.0174532925199433]],
        USAGE[
            SCOPE["Geodesy. Navigation and positioning using GPS satellite system."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        ID["EPSG",9055]],
    VERTCRS["EGM2008 height",
        VDATUM["EGM2008 geoid"],
        CS[vertical,1],
            AXIS["gravity-related height (H)",up,
                LENGTHUNIT["metre",1]],
        USAGE[
            SCOPE["Geodesy."],
            AREA["World."],
            BBOX[-90,-180,90,180]],
        ID["EPSG",3855]]]
```

Line 1 identifies this as a `COMPOUNDCRS` consisting of a 2D horizontal and 1D vertical datum definition. Line 2 identifies the 2D datum and lines 22-23 identify the vertical datum.

## 3D Geodetic CRS

The EPSG database also contains 3D definitions, eliminating the need for compound specifications:

```bash
projinfo EPSG:9754 -o WKT2:2019
```

```{code} python
:linenos: true
:emphasize-lines: 2-4,9

GEOGCRS["WGS 84 (G2139)",
    DYNAMIC[
        FRAMEEPOCH[2016]],
    DATUM["World Geodetic System 1984 (G2139)",
        ELLIPSOID["WGS 84",6378137,298.257223563,
            LENGTHUNIT["metre",1]]],
    PRIMEM["Greenwich",0,
        ANGLEUNIT["degree",0.0174532925199433]],
    CS[ellipsoidal,3],
        AXIS["geodetic latitude (Lat)",north,
            ORDER[1],
            ANGLEUNIT["degree",0.0174532925199433]],
        AXIS["geodetic longitude (Lon)",east,
            ORDER[2],
            ANGLEUNIT["degree",0.0174532925199433]],
        AXIS["ellipsoidal height (h)",up,
            ORDER[3],
            LENGTHUNIT["metre",1]],
    USAGE[
        SCOPE["Geodesy. Navigation and positioning using GPS satellite system."],
        AREA["World."],
        BBOX[-90,-180,90,180]],
    ID["EPSG",9754]]
```

Lines 2-4 identify that this CRS uses a specific WGS84 {term}`realization`. Note that the {term}`frame epoch` is 2016.0 (see also @wgs_epsg) Line 9 identifies that this is a 3D CRS.


## Projected CRS (UTM)

Projected CRSs are built on a base geographic CRS. Familiar codes like EPSG:32610 (WGS 84 / UTM zone 10N) use the WGS84 *ensemble* as their base, so they carry the same ~2 m uncertainty as EPSG:4326:

```bash
projinfo EPSG:32610 -o WKT2:2019
```

```{code} python
:linenos: true
:emphasize-lines: 3

PROJCRS["WGS 84 / UTM zone 10N",
    BASEGEOGCRS["WGS 84",
        ENSEMBLE["World Geodetic System 1984 ensemble",
            MEMBER["World Geodetic System 1984 (Transit)"],
            MEMBER["World Geodetic System 1984 (G730)"],
            MEMBER["World Geodetic System 1984 (G873)"],
            MEMBER["World Geodetic System 1984 (G1150)"],
            MEMBER["World Geodetic System 1984 (G1674)"],
            MEMBER["World Geodetic System 1984 (G1762)"],
            MEMBER["World Geodetic System 1984 (G2139)"],
            MEMBER["World Geodetic System 1984 (G2296)"],
            ELLIPSOID["WGS 84",6378137,298.257223563,
                LENGTHUNIT["metre",1]],
            ENSEMBLEACCURACY[2.0]],
        PRIMEM["Greenwich",0,
            ANGLEUNIT["degree",0.0174532925199433]],
        ID["EPSG",4326]],
    CONVERSION["UTM zone 10N",
        METHOD["Transverse Mercator",
            ID["EPSG",9807]],
        PARAMETER["Latitude of natural origin",0,
            ANGLEUNIT["degree",0.0174532925199433],
            ID["EPSG",8801]],
        PARAMETER["Longitude of natural origin",-123,
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
    CS[Cartesian,2],
        AXIS["(E)",east,
            ORDER[1],
            LENGTHUNIT["metre",1]],
        AXIS["(N)",north,
            ORDER[2],
            LENGTHUNIT["metre",1]],
    USAGE[
        SCOPE["Navigation and medium accuracy spatial referencing."],
        AREA["Between 126°W and 120°W, northern hemisphere between equator and 84°N, onshore and offshore. Canada - British Columbia (BC); Northwest Territories (NWT); Nunavut; Yukon. United States (USA) - Alaska (AK)."],
        BBOX[0,-126,84,-120]],
    ID["EPSG",32610]]
```

(custom-crs)=
## Custom CRS

EPSG Codes are hugely convenient, but sometimes you'd like to represent a CRS that is not in the EPSG database. For example: UTM coordinates on a specific WGS84 {term}`realization` instead of the ensemble, with ellipsoidal heights. EPSG:32610 (above) sits on the ensemble, and compound codes such as `EPSG:32610+7912` are rejected because the 3D geographic part (ITRF2014) is not the base CRS of the projection.

You can write such a CRS yourself by editing the WKT2 of the closest EPSG definitions:

1. Start from the projected CRS, e.g. `projinfo EPSG:32610 -o WKT2:2019`.
2. Replace its `BASEGEOGCRS` with the realization you want, e.g. WGS 84 (G2139) from `projinfo EPSG:9754 -o WKT2:2019` (3D) or `EPSG:9755` (2D).
3. For a 3D CRS, change `CS[Cartesian,2]` to `CS[Cartesian,3]` and add an ellipsoidal height axis:

```{code} python
:linenos: true

    CS[Cartesian,3],
        AXIS["(E)",east,
            ORDER[1],
            LENGTHUNIT["metre",1]],
        AXIS["(N)",north,
            ORDER[2],
            LENGTHUNIT["metre",1]],
        AXIS["ellipsoidal height (h)",up,
            ORDER[3],
            LENGTHUNIT["metre",1]]]
```

Complete examples are in the [3dep](https://github.com/uw-cryo/3D_CRS_Transformation_Resources/tree/main/3dep) folder, for instance [UTM_10N_WGS84_G2139_3D.wkt](../3dep/UTM_10N_WGS84_G2139_3D.wkt) and its 2D counterpart [UTM_10N_WGS84_G2139_2D.wkt](../3dep/UTM_10N_WGS84_G2139_2D.wkt).

GDAL accepts the file name directly, and PROJ tools take the text:

```bash
gdalsrsinfo UTM_10N_WGS84_G2139_3D.wkt
projinfo -s EPSG:7912 -t "$(cat UTM_10N_WGS84_G2139_3D.wkt)" -o PROJ --hide-ballpark
gdalwarp -t_srs UTM_10N_WGS84_G2139_3D.wkt input.tif output.tif
```

(custom-crs-geotiff)=
### Saving a custom CRS in a GeoTIFF

GeoTIFF stores a CRS as a set of keys (GeoKeys), and those keys cannot describe a projected CRS with a third (height) axis. With GDAL 3.12.3:

* **3D projected CRS** (a custom 3D WKT, or even `EPSG:32610+4979`): GDAL writes the whole CRS to a sidecar file, `output.tif.aux.xml`, and **nothing** to the TIFF itself. This is the same for the GTiff and COG drivers, and with `-co GEOTIFF_VERSION=1.1`. If the TIFF is copied or shared without the `.aux.xml`, or opened by software that does not read it, it has no CRS at all.
* **2D projected CRS** (e.g. [UTM_10N_WGS84_G2139_2D.wkt](../3dep/UTM_10N_WGS84_G2139_2D.wkt)): the CRS is stored in the GeoKeys, including the WGS 84 (G2139) realization (`GeographicTypeGeoKey` 9755), and no sidecar is written.

You can check which case you have by turning off GDAL's sidecar reading:

```bash
gdalwarp -t_srs UTM_10N_WGS84_G2139_3D.wkt input.tif output.tif
gdalinfo output.tif                       # Files: output.tif output.tif.aux.xml
GDAL_PAM_ENABLED=NO gdalinfo output.tif   # no "Coordinate System is:" section
```

```{warning}
If a GeoTIFF will be shared, write it with a 2D CRS so the horizontal CRS travels inside the file, and record the vertical reference (e.g. "heights above the WGS 84 (G2139) ellipsoid") separately, in the file name, band description or accompanying metadata. If you use a 3D CRS, always keep the `.aux.xml` with the TIFF.
```
