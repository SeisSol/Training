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

To run the Northridge scenario, you should:

```
cd seissol-training/northridge
mpirun apptainer run ~/my-training.sif pumgen -s msh2 mesh_northridge.msh
apptainer run ~/my-training.sif rconv -i northridge_resampled.srf -o northridge_resampled.nrf -x visualization.xdmf -m "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440 +axis=enu"
OMP_NUM_THREADS=28 mpirun -n 2 apptainer run ~/my-training.sif seissol parameters.par
```
You can change `seissol` to `SeisSol_Release_dhsw_4_viscoelastic2` if you want to account for attenuation (https://seissol.readthedocs.io/en/latest/attenuation.html) instead of assuming a fully elastic rheology.

In Section `Interacting with Frontera from local machine`, we will also show how you may interact with Frontera from your local machine with a Jupyter Lab.

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

## Interacting with Frontera from local machine
We present a workflow for running a Jupyter Lab remotely on Frontera, while interacting with it on your local machine.

You can take the following steps:

Step 1: change `SHARED_PATH="/your/path/to/container/"` in line 75 of `job.jupyter` to the path where your sigularity container is built.
Step 2: Run
```
sbatch -A <your_project> job.jupyter
```
Step 3: Check the job status with
```
squeue -u $USER
```
Step 4: Once the status changes from `PD` to `R`, you will find the job output in a generated file `jupyter.out`.
Step 5: Check the last few lines with
```
tail -f jupyter.out
```
wait a few seconds until you get in `jupyter.out` something like:
```
TACC: got login node jupyter port 60320
TACC: created reverse ports on Frontera logins
TACC: Your jupyter notebook server is now running at https://frontera.tacc.utexas.edu:60320/?token=2e0fade1f8b1ce00b303a7e97dd962c5cd10c17f03a245e8c761ca7e1d5e1597
```
(and then Ctrl+C to stop monitoring the contents of `jupyter.out`)
Step 6: Paste the link to your local browser, you will have access to the Frontera environment on your local machine.
```
https://frontera.tacc.utexas.edu:60320/?token=2e0fade1f8b1ce00b303a7e97dd962c5cd10c17f03a245e8c761ca7e1d5e1597
```

## Visualization

You can directly visualize the results on Frontera:

1. Open a VNC connection to Frontera
2. `module load swr qt5 ospray paraview`
3. `swr -p 1 paraview`
4. In the paraview GUI, open `output/tpv13-fault.xdmf`.



