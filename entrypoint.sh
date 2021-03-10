#!/bin/bash
set -o errexit

case "$1" in
    gmsh|pumgen|rconv)
        exec "$@"
    ;;
    seissol)
        ulimit -Ss unlimited
        set -- SeisSol_Release_dhsw_4_elastic "${@:2}"
        exec "$@"
    ;;
    seissol_plasticity)
        ulimit -Ss unlimited
        set -- SeisSol_Release_dhsw_4_elastic_plasticity "${@:2}"
        exec "$@"
    ;;
    *)
        echo "Unknown command: $1"
    ;;
esac
