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

cp /work2/10000/jwjeremy/share/libgmsh.so.4.11.1  ~/.local/lib/libgmsh.so.4.11

echo "MNMN: load appatainer module"
module load tacc-apptainer

#
SHARED_PATH="/your/path/to/container/"
SIF_NAME="$HOME/my-training.sif"

if [ ! -f $SIF_NAME ]; then
    if [ ! -f $SHARED_PATH/training_latest.sif ]; then
        # load the image if no image exists in the shared directory
        echo "MNMN: pull the appatainer image"
        apptainer pull -F docker://seissol/training:latest
        echo "MNMN: create symlink to the shared directory"
        ln -sf $SHARED_PATH/training_latest.sif $SIF_NAME
    else
        # create symlink to the shared directory
        echo "MNMN: create symlink to the shared directory"
        ln -sf $SHARED_PATH/training_latest.sif $SIF_NAME
    fi
fi


echo "To run jupyter notebook:"
echo "swr -p 1 jupyter notebook"
