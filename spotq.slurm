#!/bin/bash
#SBATCH -J job                # Job name
#SBATCH -o job.%j.out         # Name of stdout output file (%j expands to jobId)

INPUTDECK="main.k"

if ls d3dump* 1>/dev/null 2>&1; then
    mode="r=$(ls -t d3dump* | head -1 | cut -c1-8)"
    op="restart"
else
    mode="i=$INPUTDECK"
    op="start"
fi

# create/overwrite checkpoint command file
echo "sw1." >switch

# launch monitor tasks
job_file=$(scontrol show job $SLURM_JOB_ID | awk -F= '/Command=/{print $2}')
srun --overcommit --ntasks=$SLURM_JOB_NUM_NODES --ntasks-per-node=1 $SQDIR/bin/poll "$SLURM_JOB_ID" "$SLURM_SUBMIT_DIR" "$job_file" &>/dev/null &

# Launch MPI-based executable
echo -e "$SLURM_SUBMIT_DIR ${op}ed: $(date) | $(date +%s)" >>$SQDIR/var/timings.log
srun --mpi=pmix_v3 --overcommit $MPPDYNA $mode
echo -e "$SLURM_SUBMIT_DIR stopped: $(date) | $(date +%s)" >>$SQDIR/var/timings.log
