# Training

Welcome to the SeisSol training. Please clone this repository with git (using the command line) or download it directly from the browser.
This repository contains a Dockerfile to build a Docker container.
The Docker container contains an interactive learning environment (Jupyter) which includes meshing tools, SeisSol, and visualiation tools.


## [Quakeworx](https://quakeworx.org)

In addition to the base notebook, of the "standard" SeisSol training repository, the repository also contains notebooks specifically adapted for seamless integration with the Quakeworx science gateway for seismic simulations. These notebooks are identified by the _qwx.ipynb suffix. More details can be found at the Quakeworx Kick-off: [Advancing Earthquake Science and Cybertraining in Seismology workshop page](https://quakeworx.org/events/quakeworx-kick-off-workshop).

The simplest way to access the input files for the Gateway is by running ``git clone https://github.com/SeisSol/Training.git`` from your terminal locally. Make sure to navigate into the Training folder when uploading the input files to the SeisSol App from the Gateway.


## Installation

Please install [Docker](https://docs.docker.com/engine/install/), launch the Docker Desktop and then run

```bash
docker pull seissol/training
```

## Training

After installation, we recommend assigning at least 8 GB of memory to Docker so all simulations run smoothly. Run
```bash
docker run --memory=8g -p 53155:53155 seissol/training
```
or run the [start.sh](start.sh) script.

After some time you should see
```bash
http://127.0.0.1:53155/lab?token=some5cryptic8hash123
```
Click on that link or enter the link in the address bar of your favourite web browser.

Then use the navigation bar to open the exercises (e.g., [tpv13/tpv13.ipynb](tpv13/tpv13.ipynb)).

## Tools

You can also use the tools in the Docker container for creating input files or running SeisSol on your local computer.
To this end, you need to mount your local drive within the Docker container with the following command:
```bash
docker run -v $(pwd):/shared/ -u $(id -u):$(id -g) seissol/training <some command>
```
As this command is rather long, we provide the wrapper script [tool.sh](tool.sh).

The following tools are currently included:
- PUMGen (mesh generation for SeisSol, https://github.com/SeisSol/PUMGen, see also SeisSol's documentation https://seissol.readthedocs.io/en/latest/meshing-with-pumgen.html)
- GMSH (open source 3D finite element mesh generator, client only, https://gmsh.info)
- rconv (tool to describe point and finite source models in SeisSol's NetCDF Rupture Format, https://seissol.readthedocs.io/en/latest/standard-rupture-format.html#how-to-use-rconv)
- SeisSol O4 (pre-compiled SeisSol with 4th order space-time accuracy for elastic and viscoelastic materials, https://seissol.readthedocs.io). We use the SeisSol `v1.0.1`. See the first lines of the SeisSol output to get the exact commit hash.

The SeisSol binaries in the container use new binary naming (e.g., `seissol-cpu-elastic-p4-f64` and `seissol-cpu-viscoelastic-3-p4-f64`).


I.e.
```
./tool.sh pumgen <args>
./tool.sh gmsh <args>
./tool.sh rconv <args>
./tool.sh seissol <args>
```
