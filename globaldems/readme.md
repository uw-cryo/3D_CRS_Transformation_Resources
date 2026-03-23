# Global CRS Essentials

This section focuses on working with digital elevation models with global extent.

:::{tip} Learning Goals
* Understand what is meant by different "realizations" of WGS
* Understand the relation between WGS and ITRF
* Know common EPSG database codes for CRS definitions commonly used with global elevation data
:::

What if the data provider does not state the specific datum realization used? A reasonable assumption is to use the most recent published realization compared to the data acquisition date. This is because GNSS positioning uses the currently available WGS84 or ITRF realization.

For example, the Copernicus DEM is a mosaic of TanDEM-X measurements acquired between (01/01/2011 - 07/01/2015). So the earliest acquisitions in 2011 would have used geolocation that relied on measurements relative to the WGS G1150 datum, and would might make sense to use a consistent CRS with that datum as subsequent acquisitions were made.

However, because the original positions can be transformed into more recent reference frames, it is also important to pay attention to dataset processing dates! Ultimately, it may be necessary to compare measurements against independent well-defined measurements (like GNSS station positions) to ascertain the correct CRS to use.


## WGS84 and ITRF Realizations

:::{table} WGS and ITRF equivalence
:label: wgs_vs_itrf

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

:::

Source: https://www.e-education.psu.edu/geog862/node/1804

Modern realizations are time-dependent to account for changes to mass/gravity distribution from moving plates and large earthquakes. So "standard" epochs are used to indicate the point in time for a given realization.

:::{tip}
WGS (G1762) Compares to ITRF08 and ITRF2014 within 1cm Root Mean Square (RMS) overall if the epochs are the same
:::

### WGS84 EPSG

:::{table} EPSG codes for various WGS84 realizations
:label: wgs_epsg

| Valid From | Realization | Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1997-01-29 | WGS84 (G873)  | 1997.0 | 9054 | 7659 | 7658 |
| 2002-01-20 | WGS84 (G1150) | 2001.0 | 9055 | 7661 | 7660 |
| 2012-02-08 | WGS84 (G1674) | 2005.0 | 9056 | 7663 | 7662 |
| 2013-10-16 | WGS84 (G1762) | 2005.0 | 9057 | 7665 | 7664 |
| 2021-01-03 | WGS84 (G2139) | 2016.0 | 9755 | 9754 | 9753 |
| 2024-01-07 | WGS84 (G2296) | 2024.0 | 10606 | 10605 | 10604 |

:::

### ITRF EPSG

:::{table} EPSG codes for various ITRF realizations
:label: itrf_epsg

| Valid From | Realization | Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1999-05-01 | ITRF1997 | 1997.0 | 8996 | 7908 | 4918 |
| 2001-03-19 | ITRF2000 | 1997.0 | 8997 | 7909 | 4919 |
| 2006-10-05 | ITRF2005 | 2000.0 | 8998 | 7910 | 4896 |
| 2010-05-31 | ITRF2008 | 2005.0 | 8999 | 7911 | 5332 |
| 2016-01-22 | ITRF2014 | 2010.0 | 9000 | 7912 | 7789 |
| 2022-04-19 | ITRF2020 | 2015.0 | 9990 | 9989 | 9988 |

:::

:::{tip}
ITRF uses a slightly different ellipsoid "GRS90" compared to WGS84.
:::

### Common Global Geoid Models:

Orthometric Heights are relative to the *geoid* rather than idealized {term}`ellipsoid`. So the vertical axis of a CRS related to geoid heights will often use the following EPSG Codes:

* **EGM1996: EPSG:5773**
* **EGM2008: EPSG:3855**

## Compound CRS
A "CompoundCRS" can combine a 2D Geographic CRS with a 1D Vertical CRS to form a 3D Geodetic CRS, For example: EPSG:7661+3855. This is handy as way to indicate that 2D Rasters storing elevation values can instead be treated as 3D Coordinate values relative to a specific reference surface (like the geoid defined by EGM2008).

## Dynamic versus Static CRS

A CRS is "dynamic" if coordinates change over time with respect to the origin. This is typical for modern global reference frames that have an origin of the Earth's center of mass rather than tied to a moving point on the surface (due to plate tectonics)

Conversely coordinates in a "static" CRS like NAD83 which is tied to the North American plate no not change significantly over time.

This is an extremely important when comparing data recorded using different CRS. For example, positions in NAD83 move approximately 10 millimeters per year in relation to the positions in the ITRF and WGS84 reference frames. Here is a nice video explaining this concept:

:::{iframe} https://www.youtube.com/embed/IKM-bR6SwVs?si=BOQ8-4dNXvVTvYY6
:width: 100%
Static versus dynamic CRS
:::

:::{important}
NAD83 (2011) and WGS84 (G1764) positions can differ up to one or two meters within the continental United States b/c NAD83 is not geocentric! Read more about NAD [here](../regionaldems/readme.md)
:::
