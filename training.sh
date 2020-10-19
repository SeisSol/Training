#!/bin/bash
docker run -v $(pwd):/shared/ -u $(id -u):$(id -g) uphoffc/seissol-training $@
