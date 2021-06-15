#!/bin/bash
set -o errexit
ulimit -Ss unlimited

if [ -z $1 ]
then
    cd /home/training
    set -x
    export DISPLAY=:99.0
    export PYVISTA_OFF_SCREEN=true
    export PYVISTA_USE_IPYVTK=true
    which Xvfb
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    sleep 3
    set +x
    jupyter lab --allow-root --port=8888 --no-browser --ip=0.0.0.0
    exit
fi

case "$1" in
    gmsh|pumgen|rconv)
        exec "$@"
    ;;
    seissol)
        set -- SeisSol_Release_dhsw_4_elastic "${@:2}"
        exec "$@"
    ;;
    *)
        echo "Unknown command: $1"
    ;;
esac
