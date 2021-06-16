# Training

Welcome to the SeisSol training.
This repository contains a Dockerfile to build a Docker container.
The Docker container contains an interactive learning environment (Jupyter) which includes meshing tools, SeisSol, and visualiation.

## Installation

Please install [Docker](https://docs.docker.com/engine/install/) and run
```bash
docker pull uphoffc/seissol-training
```

## Training

After installation, run
```bash
docker run -p 8888:8888 uphoffc/seissol-training
```
or run the [start.sh](start.sh) script.

After some time you should see
```bash
http://127.0.0.1:8888/lab?token=some5cryptic8hash123
```
Click on that link or enter the link in the address bar of your favourite web browser.
Then use the navigation bar to open the exercises (e.g. [tpv13/tpv13.ipynb](tpv13/tpv13.ipynb)).

## Tools

You can also use the tools in the Docker container for creating input files or running SeisSol on your local computer.
To this end, you need to mount your local drive within the Docker container with the following command:
```bash
docker run -v $(pwd):/shared/ -u $(id -u):$(id -g) uphoffc/seissol-training <some command>
```
As this command is rather long, we provide the wrapper script [tool.sh](tool.sh).

The following tools are currently included:
- PUMGen
- GMSH (cli only)
- rconv
- SeisSol O4

I.e.
```
./tool.sh pumgen <args>
./tool.sh gmsh <args>
./tool.sh rconv <args>
./tool.sh seissol <args>
```
