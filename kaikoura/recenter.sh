#!/bin/sh

## Note the coordinate array of the Training setup has been recentered, to be usable with single precision
## This was done using the following commands (uncomment)

#python TuSeisSolScripts/onHdf5/moveGeomHdf5.py meshes/NZmicro_up_to_SJF_with_hope.puml.h5 --coords 6200000.0 -3900000 0.0

for myf in NZ_asagi.nc NZ_asagi_att.nc
do
    #python TuSeisSolScripts/onNetcdf/moveGeomNc.py $myf --coords 6200000.0 -3900000
done

