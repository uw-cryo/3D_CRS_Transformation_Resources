# Brief overview of CRSs used for global datasets

What if the data provider does not state the specific datum realization used? A reasonable assumption is to use the most recent published realization compared to the data acquisition date. This is because GNSS positioning uses the currently available WGS84 or ITRF realization.

For example, the Copernicus DEM is a mosaic of TanDEM-X measurements acquired between (01/01/2011 - 07/01/2015). So the earliest acquisitions in 2011 would have used geolocation that relied on measurements relative to the WGS G1150 datum, and would might make sense to use a consistent CRS with that datum as subsequent acquisitions were made.

However, because the original positions can be transformed into more recent reference frames, it is also important to pay attention to dataset processing dates! Ultimately, it may be necessary to compare measurements against independent well-defined measurements (like GNSS station positions) to ascertain the correct CRS to use.

## Dynamic CRS

## WGS84 and ITRF Realizations

| Realization | Approximately equivalent to |
| - | - |
| WGS84 (ORIG)| NAD83 (1986)** |
| WGS (G730)| ITRF91/92 |
| WGS (G873)| ITRF94/96 |
| WGS (G1150) | ITRF00 |
| WGS (G1674) | ITRF08 |
| WGS (G1762) | ITRF08 |
| WGS (G2139) | ITRF2014 |
| WGS (G2296) | ITRF2020 |

Source: https://www.e-education.psu.edu/geog862/node/1804

Modern realizations are time-dependent to account for changes to mass/gravity distribution from moving plates and large earthquakes. So 'standard' epochs are used to indicate the point in time for a given realization.

** NAD83 (2011) and WGS84 (G1764) positions can differ up to one or two meters within the continental United States b/c NAD83 is not geocentric! Furthermore, NAD83 is 'static' in that it is fixed to the North American plate, which moves ('static' = moving is admittedly a bit confusing)! Consequently, positions in NAD83 move approximately 10 millimeters per year in relation to the positions in the ITRF and WGS84 reference frames. Here is a nice video explaining this concept:

* https://www.youtube.com/watch?v=IKM-bR6SwVs

*** WGS (G1762) Compares to ITRF08 and ITRF2014 within 1cm Root Mean Square (RMS) overall if the epochs are the same

### WGS84 EPSG

A table of EPSG codes for various WGS84 realizations

Source: https://epsg.org

| Valid From | Realization | Std. Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1997-01-29 | WGS84 (G873)  | 1997.0 | 9054 | 7659 | 7658 |
| 2002-01-20 | WGS84 (G1150) | 2001.0 | 9055 | 7661 | 7660 |
| 2012-02-08 | WGS84 (G1674) | 2005.0 | 9056 | 7663 | 7662 |
| 2013-10-16 | WGS84 (G1762) | 2005.0 | 9057 | 7665 | 7664 |
| 2021-01-03 | WGS84 (G2139) | 2016.0 | 9755 | 9754 | 9753 |
| 2024-01-07 | WGS84 (G2296) | 2024.0 | 10606 | 10605 | 10604 |

### ITRF EPSG

A table of selec EPSG codes for various ITRF realizations

Source: https://epsg.org

| Valid From | Realization | Std. Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1999-05-01 | ITRF1997 | 1997.0 | 8996 | 7908 | 4918 |
| 2001-03-19 | ITRF2000 | 1997.0 | 8997 | 7909 | 4919 |
| 2006-10-05 | ITRF2005 | 2000.0 | 8998 | 7910 | 4896 |
| 2010-05-31 | ITRF2008 | 2005.0 | 8999 | 7911 | 5332 |
| 2016-01-22 | ITRF2014 | 2010.0 | 9000 | 7912 | 7789 |
| 2022-04-19 | ITRF2020 | 2015.0 | 9990 | 9989 | 9988 |

NOTE: ITRF uses a slightly different ellipsoid "GRS
90" compared to WGS84.

### Common Global Geoid Models:

Orthometric Heights are relative to the *geoid* rather than idealized ellipsoid. So the vertical axis of a CRS related to geoid heights will often use the following EPSG Codes:

* **EGM1996: EPSG:5773**
* **EGM2008: EPSG:3855**

## Compound CRS
A "CompoundCRS" can combine a 2D Geographic CRS with a 1D Vertical CRS to form a 3D Geodetic CRS, For example: EPSG:7661+3855. This is handy as way to indicate that 2D Rasters storing elevation values can instead be treated as 3D Coordinate values relative to a specific reference surface (like the geoid defined by EGM2008).

## Static CRS

USGS 3DEP uses NAD83 + NAVD88 Heights. This is not a global system and rather focuses on CONUS. The coordinate system moves with the North American plate. *It's refered to as 'static' because to an observer measuring positions on the plate, the plate is not moving :)*

Just like WGS and ITRF, there are different, increasingly accurate 'realizations' of the NAD83 datum over time:

| Valid From | Realization | Std. Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1986 | NAD83(1986) | 1984.0 | 4269 | ? | ? |
| ? | NAD83(HARN) | ? | 4152 | 4957 | 4956 |
| 2012-06-12 | NAD83(2011) | 2010.0 | 6318 | 6319 | 6317 |

Geoid Model:
* **Vertical Coordinates: NAVD88 [EPSG: 5703]**

To be updated soon!
https://www.ngs.noaa.gov/datums/newdatums/release.shtml


## Projected CRS

A wonderful reference on projected CRSs: https://www.e-education.psu.edu/geog862/book/export/html/1644


### Universal Transverse Mercator

UTM is a cylindrical map projection that divides the Earth into 60 zones, each spanning 6 degrees longitude.Each UTM zone will have a corresponding CRS for the northern and southern hemispheres. Polar regions use universal polar stereographic (UPS) projections, as UTM projections become distorted above 84°N and below 80°S.

* **Northern Hemisphere EPSG = prefix 326 + zone #**
* **Southern Hemisphere EPSG = prefix 327 + zone #**

To figure out a UTM Zone for any location, take the longitude add 180°, divide by 6, and round up! For example, Seattle, WA is at (-122.3°, 47.6°), so it's UTM zone is 10N (EPSG:32610)

Unfortunately all UTM EPSGs reference EPSG:4326 as the base CRS...


### Polar Stereographic

https://nsidc.org/data/user-resources/help-center/guide-nsidcs-polar-stereographic-projection

* **Southern Hemisphere: EPSG:3976**
* **Northern Hemisphere: EPSG:3413**

Unfortunately these both reference EPSG:4326, the uncertain datum ensemble...

