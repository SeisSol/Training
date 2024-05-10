# How to run as singularity container on frontera?

## Setup
Copy `singularity.def` to your home directory on frontera.

Then get an interactive session on a compute node. For example for a 30 min session:
```
idev -m 30 -N 1 --tasks-per-node 2 -p development
```

Then execute: 

```
module load tacc-apptainer
apptainer pull -F docker://seissol/training:latest
apptainer build -f my-training.sif singularity.def
apptainer run my-training.sif
```

You can also use the automatically generated container after pulling the docker container 

```
module load tacc-apptainer
apptainer pull -F docker://seissol/training:latest
apptainer run training_latest.sif
```

You can abort the jupyter lab with Ctrl-C, confirm with `y`.
Now you should see a directory `seissol-training`.
This folder should contain four directories for different scenarios.

## Execution

To run the TPV13 scenario, you should:

```
cd seissol-training/tpv13
mpirun apptainer run ~/my-training.sif gmsh -3 tpv13_training.geo
mpirun apptainer run ~/my-training.sif pumgen -s msh2 tpv13_training.msh
OMP_NUM_THREADS=28 mpirun -n 2 apptainer run ~/my-training.sif seissol parameters.par
```

To run the northridge scenario, you should:

```
cd seissol-training/northridge
mpirun apptainer run ~/my-training.sif pumgen -s msh2 mesh_northridge.msh
mpirun apptainer run ~/my-training.sif rconv -i northridge_resampled.srf -o northridge_resampled.nrf -x visualization.xdmf -m "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440 +axis=enu"
OMP_NUM_THREADS=28 mpirun -n 2 apptainer run ~/my-training.sif seissol parameters.par
```
You can change `seissol` to `SeisSol_Release_dhsw_4_viscoelastic2` if you want to run visco-elastic simulation instead of the default elastic one.

## Expected runtimes

On one node of Frontera:

Scenario                | runtime
------------------------|---------
Kaikoura LSW            | 9 min
Kaikoura RS             | 7 min
Northridge elastic      | 3 min
Northridge viscoelastic | 5 min
Sulawesi LSW            | 6 min
Sulawesi RS             | 6 min
TPV13                   | 12 s

## Visualization

You can directly visualize the results on Frontera:

1. Open a VNC connection to Frontera
2. `module load swr qt5 ospray paraview`
3. `swr -p 1 paraview`
4. In the paraview GUI, open `output/tpv13-fault.xdmf`.



