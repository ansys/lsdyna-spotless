# lsdyna-spotless
A toolkit for running LS-DYNA simulations on AWS spot instances while encapsulating away the interruptible behavior by checkpointing on-interruption and greedy job restart. It makes a compute fleet of spot instances running LS-DYNA simulations behaves like no spot were used, i.e. *spotless*.

# Background
AWS Spot instances offer great value (70% – 90% savings) comparing to on-demand instances. However, interruptions can occur if AWS needs to take an instance back which may result in loss of compute progress if not handled. Such loss of compute progress becomes more likely and more expensive for larger jobs utilizing more compute nodes and/or running for longer. To be able to seamlessly manage these interruptions and minimize their detrimental effects is a key feature that will convince customers to run ANSYS LS-DYNA on AWS spot instances. The ideal solution enables the customer to stay blissfully ignorant of interruptions and use spot instances in the same way as on-demand ones.

A tool is developed by my team to handle these interruptions. Said tool can:
* Polling for the arrival of interruption signals
* Save progress of running jobs after receiving interruption signal
* Resubmit/resume these jobs when new spot instances are granted back by AWS with minimal time spent in dormancy

Effectively: a HPC user using a cluster with spot instances notices no difference comparing to using a cluster with on-demand instances, except maybe a slight increase (<10% in test runs so far) in turnaround time if interruptions did occur. What is easily noticeable is the savings.

# Prerequisites
* AWS ParallelCluster (v2.8.1 or later)
* SLURM scheduler
* OpenMPI
* License server
* MPPDYNA binary (OpenMPI version)
* Each MPPDYNA job is launched from its own directory

# Setting Up Environment
After unzipping the toolkit package, run the env-vars.sh script to set up some environment variables. Make sure to take a look inside to make sure the default values make sense and modify if needed. The MPPDYNA variable should be set to the path of the executable that is going to be used.

Copy all the tools distributed within the package to the binary folder just created, `/shared/ansys/bin` by default.

# Launching Jobs
Each job is assumed to be in its own folder with its own SLURM job script. Each folder should have a different name too. This is usually already naturally enforced by the filesystem if the folders are in the same parent folder, e.g., the user's home directory. By default, the job script assumes the main input deck for LS-DYNA is named main.k. If the name is different, either change it or create a soft link for it:
```
ln -sf actual-input-deck.k main.k
start-jobs 2 72 spotq.slurm job-1 job-2 job-3
```

This will submit many jobs each with 2 nodes and 72 tasks per node for a total of 144 tasks per job. If some other jobs need a different number of nodes and/or tasks, they could be started separately with a different command, e.g.:

```
start-jobs 1 72 spotq.slurm job-4 job-5
```
The tool will intelligently decide if a user is adding jobs to a queue or starting a new job queue from scratch, in which case some housekeeping tasks will be performed.

# Stopping Jobs
If for some reason, the user needs to stop the test before all the jobs are finished, a simple utility is provided for that:

```
stop-jobs
```
This will stop all outstanding jobs previously launched by start-job.

# Analyzing Timings
The time of each change of status of a job is logged. By analyzing the start and stop time of a job, excluding the time intervals where it was interrupted, one can derive the effctive run time, and by comparing this to the wall clock time elapsed, the overhead caused by spot instance interruptions. A utility is provided for a simple tabulation of the timings data.

```
$ calc-timing ../var/timings.old
job /shared/lstc/neon finished in 1543 seconds, after interrupt(s).
job /shared/lstc/neon-9 finished in 1308 seconds, uninterrupted.
job /shared/lstc/neon-8 finished in 1333 seconds, uninterrupted.
job /shared/lstc/neon-1 finished in 1478 seconds, after interrupt(s).
job /shared/lstc/neon-3 finished in 1279 seconds, uninterrupted.
job /shared/lstc/neon-2 finished in 1537 seconds, after interrupt(s).
job /shared/lstc/neon-5 finished in 1313 seconds, uninterrupted.
job /shared/lstc/neon-4 finished in 1295 seconds, uninterrupted.
job /shared/lstc/neon-7 finished in 1334 seconds, uninterrupted.
job /shared/lstc/neon-6 finished in 1304 seconds, uninterrupted.
10 jobs finished and they finished in 13724 seconds in CPU time.
Wall clock time: 14669 seconds elapsed.
```
Note these timings are simulated with `SQMOCKTEST="true"` in the environment and multiple user-injected interruptions generated with EC2 mock tool and are not representative of interruption frequency or performance of AWS spot instances.
