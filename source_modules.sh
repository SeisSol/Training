#!/bin/sh

# source this file to load the modules to run the paraview and jupyter notebook in frontera VNC 

echo "TACC: unloading xalt"
module unload xalt

echo "MNMN: install python libraries"
ml gcc/9
ml swr/21.2.5 qt5/5.14.2 oneapi_rk/2021.4.0
ml paraview/5.11
module load python3/3.9.2


export PATH="$PATH:$HOME/.local"
# pip install --user obspy cartopy

# urllib compatibility
pip uninstall -y urllib3
pip install --user 'urllib3<2.0'
pip install --user vtk pyvista
pip install --user --update gmsh
pip install --user scipy matplotlib pyproj

echo "MNMN: load appatainer module"
module load tacc-apptainer


#
SHARED_PATH="/your/path/to/container/"
SIF_NAME="training_latest.sif"

if [ ! -f $SIF_NAME ]; then
    if [ ! -f $SHARED_PATH/$SIF_NAME ]; then
        # load the image if no image exists in the shared directory
        echo "MNMN: pull the appatainer image"
        apptainer pull -F docker://seissol/training:latest
    else
        # create symlink to the shared directory
        echo "MNMN: create symlink to the shared directory"
        ln -s $SHARED_PATH/$SIF_NAME $SIF_NAME
    fi
fi


echo "To run jupyter notebook:"
echo "swr -p 1 jupyter notebook"
