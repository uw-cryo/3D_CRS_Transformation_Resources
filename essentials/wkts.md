
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

Lines 2-4 identifies that this CRS uses a specific WGS84 {term}`realization`, line 9 again identifies this is still a 2D ellipsoidal CRS, and the final line always reports the EPSG code.

## Compound 3D CRS

Here we combine a horizontal and vertical reference to create an effective 3D CRS

```bash
projinfo EPSG:9055+5703 -o WKT2:2019
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

Lines 2-4 identifies that this CRS uses a specific WGS84 {term}`realization`. Note that the {term}`frame epoch` is 2016.0 (see also @wgs_epsg) Line 9 identifies that this is a 3D CRS.


## Projected CRS (UTM)

The EPSG database also contains 3D definitions, eliminating the need for compound specifications:

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

## Custom CRS

EPSG Codes are hugely convenient, but sometimes you'd like to represent a CRS that is not in the EPSG database. For example:
