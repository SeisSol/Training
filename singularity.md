# How to run as singularity container on frontera?

Copy `singularity.def` to your home directory on frontera.
Then execute: 

```
module load tacc-apptainer
singularity pull docker://seissol/training:latest
singularity build -f my-training.sif singularity.def
singularity run my-training.sif
```


