# Choosing and checking a transformation

To compare elevation data, every dataset has to end up in the same, fully specified 3D CRS. This page shows why the choice of target CRS matters, how to choose one, and how to check which transformation PROJ will actually use.

(ensemble-target)=
## Don't transform into the WGS84 ensemble


The WGS84 {term}`ensemble` (see [WKT representations of CRS](wkts.md)) is only defined to about 2 m (`ENSEMBLEACCURACY[2.0]`). PROJ therefore treats all its realizations as interchangeable within those 2 m, and any route into the ensemble counts as good enough. This applies to `EPSG:4326`, to its 3D version `EPSG:4979`, and to every `WGS 84 / UTM` code such as `EPSG:32610`. Which operation you get then depends on which CRS your input coordinates are in, not on which operation is correct.

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

(choose-target)=
## Choose a specific realization

For comparisons, transform into a specific {term}`realization` of a frame, not the ensemble. PROJ then has to use a transformation that actually reaches that frame, with published parameters and a stated accuracy, as in row 1. Pick the frame of the data you are comparing against, for example:

* ITRF2014 (`EPSG:7912`) for ICESat-2 releases up to 006;
* ITRF2020 (`EPSG:9989`) for ICESat-2 release 007;
* WGS 84 (G2139) (`EPSG:9754`) for data in that realization, such as the post-eruption stereo DEMs in the [Mauna Loa notebook](../3dep/hawaii-mauna-loa.ipynb).

EPSG codes for the other WGS84 and ITRF realizations are listed in [](#wgs_epsg) and [](#itrf_epsg). These are geographic CRSs (latitude, longitude and ellipsoidal height). For UTM coordinates on one of them, build a projected [custom CRS](#custom-crs), since EPSG has no such codes. These frames are dynamic, so also give the coordinate epoch.

(check-operation)=
## Check the operation PROJ will use

Before transforming, check which operation PROJ will use with `projinfo -s <input CRS> -t <target CRS> --summary` (as in the dropdown above). The first operation listed is the one PROJ uses if its grids are available, followed by its accuracy. Be suspicious if it says `noop` (nothing is changed) or reports an accuracy of 1 m or more.
