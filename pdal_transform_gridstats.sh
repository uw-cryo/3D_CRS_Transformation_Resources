#! /bin/bash

#Simple script with notes on processing point clouds from WA DNR or USGS 3DEP
#Requires PDAL, GDAL and PROJ9
#Must have CDN grids stored locally (projsync) or network access enabled

#David Shean
#November 2023

#Print commands and exit on error
set -e -x

#Input laz filename
#laz_fn=USGS_LPC_WA_KingCounty_2021_B21_King_UW_campus.laz
laz_fn=$1
laz_out_fn=${laz_fn%.*}_pdal.laz

#Assuming input coordinate system is properly defined in the lidar point clouds or raster
#May need to define if CRS is not 3D, or vertical datum not defined

#Define output projected coordinate system 
#out_crs=""
#NAD83(2011) UTM 10 N, NAVD88, meters
#out_crs="6339+5703"
#NAD83(2011) UTM 10 N, ellipsoid height, meters
out_crs="6339+6319"

#Define bounds
bounds=""
#Copied from QGIS: "550725.5861 5277239.5698 553620.2589 5279030.06"
#Reformatted for PDAL "([xmin, xmax], [ymin, ymax])"
#UW campus bounds meters UTM 10N
#bounds="([550725.5861, 553620.2589], [5277239.5698, 5279030.06])"

#Thinning - sample point cloud every X m
#pdal translate sample --filters.sample.radius=0.2 --writers.las.forward=all
sample_rad_m=0.2

pdal_filters=""

#Thin point cloud
if [ ! -z "$sample_rad_m" ] ; then
    laz_out_fn=${laz_out_fn%.*}_${sample_rad_m}m.laz
    pdal_filters+=" -f filters.sample --filters.sample.radius=$sample_rad_m --writers.las.forward=all"
fi

#Transform point cloud to out CRS
if [ ! -z "$out_crs" ] ; then
    laz_out_fn=${laz_out_fn%.*}_${out_crs}.laz
    pdal_filters+=" -f filters.reprojection --filters.reprojection.out_srs=EPSG:$out_crs"
fi

#If bounds are unspecified, transform entire point cloud
if [ ! -z "$bounds" ] ; then
    laz_out_fn=${laz_out_fn%.*}_crop.laz
    #pdal translate -i $laz_fn -o $laz_out_fn -f filters.reprojection --filters.reprojection.out_srs=EPSG:$out_crs -f filters.crop --filters.crop.bounds="$bounds"
    pdal_filters+=" -f filters.crop --filters.crop.bounds=\"${bounds}\""
fi

#Run combined PDAL command
eval pdal translate -i $laz_fn -o $laz_out_fn $pdal_filters

#Create rasters
#Define output grid resolution (meters)
res=1
tif_out_fn=${laz_out_fn%.*}_${res}m.tif
pdal translate -i $laz_out_fn -o ${tif_out_fn%.*}.tif --writers.gdal.resolution=$res --writers.gdal.output_type="all" --writers.gdal.data_type="float32" --writers.gdal.gdalopts="COMPRESS=LZW,TILED=YES,BIGTIFF=IF_SAFER" 

pdal_bands="1 2 3 4 5 6"
pdal_stats="min max mean idw count stddev"
#Extract individual statistics
parallel --delay 1 --link -v "gdal_translate $gdal_opt -b {1} ${tif_out_fn%.*}.tif ${tif_out_fn%.*}_{2}.tif" ::: $pdal_bands ::: $pdal_stats

#Shaded relief
hs.sh ${tif_out_fn%.*}_{max,min,mean,idw}.tif 
