#!/bin/bash
docker run -v $(pwd):/shared/ -u $(id -u):$(id -g) alicegabriel/seissol-training "$@"
