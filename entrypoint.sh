#!/bin/bash
set -o errexit
ulimit -Ss unlimited

if [ -z $1 ]
then
    if grep "docker/containers" /proc/self/mountinfo -qa; then
        cd /home/training
    elif [[ $container == "podman" ]]; then
        cd /home/training
    else
        # it is not in docker, thus singularity
        mkdir -p $(pwd)/seissol-training
        cp -r /home/training/* $(pwd)/seissol-training
        cd $(pwd)/seissol-training
    fi
    set -x
    export DISPLAY=:99.0
    export PYVISTA_OFF_SCREEN=true
    export PYVISTA_USE_IPYVTK=true
    which Xvfb
    Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
    sleep 3
    set +x
    jupyter lab --allow-root --port=53155 --no-browser --ip=0.0.0.0
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
    seissol_viscoelastic)
        set -- SeisSol_Release_dhsw_4_viscoelastic2 "${@:2}"
        exec "$@"
    ;;
    *)
        exec "$@"
    ;;
esac
