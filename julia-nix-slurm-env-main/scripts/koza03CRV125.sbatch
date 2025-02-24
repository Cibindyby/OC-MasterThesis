#!/usr/bin/env bash
#SBATCH --partition=cpu
#SBATCH --time=4-0
#SBATCH --array=1-50
#SBATCH --output=/data/oc-compute03/ebertzci/OC-MasterThesis/output/%x-%A-%a.txt
#SBATCH --mem=12000
#SBATCH -c 4


echo "SLURM_JOB_ID=${SLURM_JOB_ID}"
echo hostname=$(hostname)


# Circumvent weird bug because of XDG_RUNTIME_DIR pointing to unwritable folder.
# Default mode of `srun` is to make all env vars available to the process so
# this is made available to `nix develop`.
export XDG_RUNTIME_DIR=~/XDG_RUNTIME_DIR
srun nix develop --impure --command bash -c "
    just justfilefunc /data/oc-compute03/ebertzci/OC-MasterThesis/symbolicRegression/kozaMain.jl 1 0 3 0 0.125 0 $SLURM_ARRAY_TASK_ID
"
            