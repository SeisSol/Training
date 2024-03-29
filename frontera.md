# How to run as singularity container on frontera?

## Setup
Copy `singularity.def` to your home directory on frontera.
Then execute: 

```
module load tacc-apptainer
singularity pull -F docker://seissol/training:latest
singularity build -f my-training.sif singularity.def
singularity run my-training.sif
```

You can abort the jupyter lab with Ctrl-C, confirm with `y`.
Now you should see a directory `seissol-training`.
This folder should contain four directories for different scenarios.

## Execution

To run the TPV13 scenario, you should:

```
cd seissol-training/tpv13
mpirun singularity run ~/my-training.sif gmsh -3 tpv13_training.geo
mpirun singularity run ~/my-training.sif pumgen -s msh2 tpv13_training.msh
OMP_NUM_THREADS=56 mpirun singularity run ~/my-training.sif seissol parameters.par
```

## Expected runtimes

On one node of Frontera:

Scenario                | runtime
------------------------|---------
Kaikoura LSW            | 15 min
Kaikoura RS             | 11 min
Northridge elastic      | 3 min
Northridge viscoelastic | 5 min
Sulawesi LSW            | 13 min
Sulawesi RS             | 16 min
TPV13                   | 1 min

## Visualization

You can directly visualize the results on Frontera:

1. Open a VNC connection to Frontera
2. `module load swr qt5 ospray paraview`
3. `swr -p 1 paraview`
4. In the paraview GUI, open `output/tpv13-fault.xdmf`.



