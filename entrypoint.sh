#!/bin/bash
set -o errexit

case "$1" in
    gmsh|pumgen|rconv)
        exec "$@"
    ;;
    seissol|SeisSol)
        set -- SeisSol_Release_dhsw_4_elastic_plasticity "${@:2}"
        exec "$@"
    ;;
    *)
        echo "Unknown command: $1"
    ;;
esac
