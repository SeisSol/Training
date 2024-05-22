# How to run as singularity container on frontera?

## Setup
Copy `singularity.def` to your home directory on frontera.

Then get an interactive session on a compute node. For example for a 30 min session:
```
idev -m 30 -N 1 --tasks-per-node 2 -p development
```

You can then pull and use the automatically generated container from the ci workflow:

```
module load tacc-apptainer
apptainer pull -F docker://seissol/training:latest
ln -sf $(realpath latest.sif) ~/my-training.sif
apptainer run ~/my-training.sif
```

Alternatively, you can build and use the container with:

```
module load tacc-apptainer
apptainer build -f my-training.sif singularity.def
ln -sf $(realpath my-training.sif) ~/my-training.sif
apptainer run ~/my-training.sif
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
OMP_NUM_THREADS=26 mpirun -n 2 apptainer run ~/my-training.sif seissol parameters.par
```

To run the Northridge scenario, you should:

```
cd seissol-training/northridge
mpirun apptainer run ~/my-training.sif pumgen -s msh2 mesh_northridge.msh
apptainer run ~/my-training.sif rconv -i northridge_resampled.srf -o northridge_resampled.nrf -x visualization.xdmf -m "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440 +axis=enu"
OMP_NUM_THREADS=26 mpirun -n 2 apptainer run ~/my-training.sif seissol parameters.par
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

Step 1: pull the docker and create the symbolic link to ~/my-training.sif as described above

Step 2: submit a VNC job on https://tap.tacc.utexas.edu/jobs/ (e.g. 1 node, 1 task)

Step 3: Wait till job status: running and click on Connect.

Step 4: open a terminal on the remote desktop, and `source setup_modules_Frontera_vnc.sh`

Step 5: Run `swp -p 1 jupyter notebook` as suggested by the script. The jupyterlab should open.


## Visualization

You can directly visualize the results on Frontera:

1. Open a VNC connection to Frontera
2. `module load swr qt5 ospray paraview`
3. `swr -p 1 paraview`
4. In the paraview GUI, open `output/tpv13-fault.xdmf`.



