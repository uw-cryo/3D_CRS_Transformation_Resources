# Quickstart

:::{attention}
GeoPandas is a great tool for reprojecting geospatial vector data, but historically it was developed to work with 2D data in a projected cartesian CRS. Be sure to set 3D geometries and 3D CRS when reprojecting:
:::

```python
# Fake some 3D data but with epsg:4326
gf_orig = gpd.GeoDataFrame(geometry=gpd.points_from_xy([-120.4], [48.6], [1400]), crs='EPSG:4326')

# override 4326 with 3D CRS and do a 3D transform (uses pyproj under the hood):
gf_new = gf.set_crs(epsg=7912, allow_override=True)

gf_new.to_crs(epsg="2927+5703")
```
