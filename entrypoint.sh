#!/bin/bash
set -o errexit

case "$1" in
    gmsh|pumgen|rconv)
        exec "$@"
    ;;
    seissol)
        set -- SeisSol_Release_dhsw_4_elastic "${@:2}"
        exec "$@"
    ;;
    seissol_plasticity)
        set -- SeisSol_Release_dhsw_4_elastic_plasticity "${@:2}"
        exec "$@"
    ;;
    *)
        echo "Unknown command: $1"
    ;;
esac
