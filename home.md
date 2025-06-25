# Getting Started

## Who is this for?

:::{attention} If you're interested in the following topics, this resource is for you!

   * How do I compare my orthometric height data to an global elevation model that uses ellipsoid heights?
   * How do I use open source software (GDAL, PROJ, GeoPandas, Xarray) to reproject data to various coordinate reference systems
   * How to digest the alphabet soup of CRS abbreviations: NAD83, WGS84, GRS80, NAVD88, EGM, ITRF
   * What’s next for geodetic datums?
:::

## What will you *not* find here?

This guide focuses on *practical examples* of using open source software to perform coordinate transforms necessary to compare elevation measurements collected over time by different sensors. It does not delve into much theory, but does provide links to more thorough references. If you're interested in more history and theory, we recommend reviewing the excellent free material from [Penn State's *GPS and GNSS for Geospatial Professionals (Lesson 5: Geodetic Datums)*](https://www.e-education.psu.edu/geog862/node/1669)


## Learning goals

1. Understand this fantastic cartoon :)
![](https://imgs.xkcd.com/comics/survey_marker.png)

1. Efficiently intercompare various common global elevation datasets like SRTM, COPDEM, ICESat-2

1. Convert between local projected coordinate systems and lontitude,latitude,elevation


## Why is this important?

In brief if you are comparing elevation data collected over decades for maximum accuracy and precision you must ensure the data is properly converted to a common reference frame. **It's very easy to be off by 10s of meters if improperly accounting for the CRS**. Here is a great short primer on this from NOAA's National Ocean Service that focuses on mapping in the United States:

:::{iframe} https://www.youtube.com/embed/J3_SVXm0Fio?si=NOyMdWRe6LOOPfz1
:width: 100%
Explanation of datums and their importance
:::

## Why is this so complicated?!

* The Earth's surface/shape is constantly changing
* Our ability to measure the Earth's surface/shape and locations on the surface continues to improve (Thanks GNSS!)
* The systems used to define coordinate systems and datums continues to evolve
* The support for these systems in open-source tools continue to evolve, with a lot of confusing and/or outdated documentation out there on the web
* There is a long (fascinating) history of surveying approaches, measurements, correction approaches, and definitions
* Many legacy datasets use older CRS definitions
* Many datasets have missing CRS information in metadata, sometimes incorrect information
