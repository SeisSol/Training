# How to build and deploy the docker container
Normally, the container would be built in a github action and automatically deployed.
During a pull request, the github action will build and deploy the image `seissol/training:pr-<id>`, where `id` is the id of the pull request on github.
After a merge, the CI will build and push `seissol/training:master`.
Once a tag in the form `v1.2.3` is released on github, the pipeline will push to `seissol/training:v1.2.3` and to `seissol/training:latest`.

During build time of the container, it will fetch and build:
* ASAGI latest github revision
* ImpalaJIT latest github revision
* PROJ version 4.9.3
* SCOREC latest github revision
* SeisSol 80a266e
* easi latest github revision
* eigen3 version 3.4.0
* gmsh version 4.8.4
* hdf5 version 1.10.7
* libxsmm version 1.16.1
* lua version 5.3.6
* netcdf version 4.7.4
* parmetis version 4.0.3
* pumgen latest github revision
* rconv same commit as SeisSol

# Manual build
Although everything should be handled by the github actions, you might want to build and test the docker container locally:

## Prerequisites
* docker installation
* dockerhub account with write access to `alicegabriel` or `seissol`

## How to manually build
* `docker build --tag seissol/training -f ./Dockerfile`: If any problems occur during the build, adapt `Dockerfile`.
* `docker run -p 53155:53155 seissol/training` (optional, for testing)



