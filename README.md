# Training

This repository contains a Dockerfile to build a Docker container which contains some useful tools for learning SeisSol.

Currently included:
- PUMGen
- GMSH (cli only)
- rconv
- SeisSol O4 elastic + plastic

Usage:
```
docker pull uphoffc/seissol-training
./training.sh pumgen <args>
./training.sh gmsh <args>
./training.sh rconv <args>
./training.sh seissol <args>
./training.sh seissol_plasticity <args>
```
