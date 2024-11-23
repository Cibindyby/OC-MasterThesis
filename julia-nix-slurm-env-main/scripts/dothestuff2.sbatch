#!/usr/bin/env bash
#SBATCH --partition=cpu
#SBATCH --time=4-0
#SBATCH --output=/data/oc-compute03/cuihenni/testing2/output/%x-%A-%a.txt
#SBATCH --mem=2000
#SBATCH -c 2


echo "SLURM_JOB_ID=${SLURM_JOB_ID}"
echo hostname=$(hostname)


# Circumvent weird bug because of XDG_RUNTIME_DIR pointing to unwritable folder.
# Default mode of `srun` is to make all env vars available to the process so
# this is made available to `nix develop`.
export XDG_RUNTIME_DIR=~/XDG_RUNTIME_DIR
srun nix develop --impure --command bash -c "
    just justfilefunc /data/oc-compute03/cuihenni/testing2/scripts/exampleScript2.jl exampleArgument1 exampleArgument2 exampleArgument3
"
