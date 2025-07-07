# Regional CRS Essentials

## NAD83
USGS 3DEP uses NAD83 + NAVD88 Heights. **This is not a global system and rather focuses on CONUS and US Territories**. Here we focus on the continental US (CONUS) where NAD83 defines a coordinate system that moves with the North American plate. *It's referred to as 'static' because to an observer measuring positions on the plate, the plate is not moving :)*

Just like WGS and ITRF, there are different, increasingly accurate "realizations" of the NAD83 datum over time:

| Valid From | Realization | Epoch | 2D Geographic | 3D Geodetic | 3D Geocentric |
| - | - | - | - | - | - |
| 1986 | NAD83(1986)       | 1984.0 | 4269 |  -   |  -   |
| 1993 | NAD83(HARN)       | 1991.0 | 4152 | 4957 | 4956 |
| 1998 | NAD83(CORS96)     | 2002.0 | 6783 | 6782 | 6781 |
| 2007 | NAD83(NSRS2007)   | 2002.0 | 4759 | 4893 | 4892 |
| 2012-06-12 | NAD83(2011) | 2010.0 | 6318 | 6319 | 6317 |
| unreleased | NATRF2022   | 2020.0 |  -   |   -  |   -  |

### NAVD88 (EPSG: 5703)

To be updated ~2025: with  geopotential datum will be called North American-Pacific Geopotential Datum of 2022 (NAPGD2022). The most prominent of these products will be a time-dependent model of the geoid, provided in three regions (the first covering the entirety of North and Central America, Hawaii, Alaska, Greenland, and the Caribbean; the second covering American Samoa; and the third covering Guam and the Commonwealth of the Mariana Islands). The name of this model will be GEOID2022. Read more: https://www.ngs.noaa.gov/datums/newdatums

:::{tip}
A great reference: https://vdatum.noaa.gov/docs/datums.html#geodetic
:::

## Projected CRS

:::{tip}
A wonderful reference on projected CRSs: https://www.e-education.psu.edu/geog862/book/export/html/1644
:::

### Universal Transverse Mercator

UTM is a cylindrical map projection that divides the Earth into 60 zones, each spanning 6 degrees longitude.Each UTM zone will have a corresponding CRS for the northern and southern hemispheres. Polar regions use universal polar stereographic (UPS) projections, as UTM projections become distorted above 84°N and below 80°S.

* **Northern Hemisphere EPSG = prefix 326 + zone #**
* **Southern Hemisphere EPSG = prefix 327 + zone #**

To figure out a UTM Zone for any location, take the longitude add 180°, divide by 6, and round up! For example, Seattle, WA is at (-122.3°, 47.6°), so it's UTM zone is 10N (EPSG:32610)

:::{warning}
Unfortunately all UTM EPSGs reference EPSG:4326 as the base CRS...
:::

### Polar Stereographic

https://nsidc.org/data/user-resources/help-center/guide-nsidcs-polar-stereographic-projection

* **Southern Hemisphere: EPSG:3976**
* **Northern Hemisphere: EPSG:3413**

:::{warning}
Unfortunately these both reference EPSG:4326, the uncertain datum ensemble...
:::
