# How to build and deploy the docker container

If you build the docker container, it will fetch and build:
* ASAGI latest github revision
* ImpalaJIT latest github revision
* PROJ version 4.9.3
* SCOREC latest github revision
* SeisSol latest github revision
* easi latest github revision
* eigen3 version 3.4.0
* gmsh version 4.8.4
* hdf5 version 1.10.7
* libxsmm version 1.16.1
* netcdf version 4.7.4
* parmetis version 4.0.3
* pumgen latest github revision
* rconv lateste github revision

## Prerequisites
* docker installation
* private copy of parmetis-4.0.3.tar.gz (their github repo is kind of broken and they have a rather restrictive licence)
* dockerhub account with write access to `alicegabriel` or `seissol`

## How to build
* `docker login`: Enter your username and password.
* `docker build --tag seissol/seissol-training -f ./Dockerfile`: If any problems occur during the build, adapt `Dockerfile`.
* `docker run -p 53155:53155 seissol/seissol-training` (optional, for testing)
* `docker push seissol/seissol-training:latest`
* commit changes to the docker file and push to github. In particular change the SeisSol commit hash in `README.md`.



