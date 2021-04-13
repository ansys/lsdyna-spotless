#!/bin/bash

export SQDIR="/shared/ansys"
# set to true if testing with EC2 mock tool
export SQMOCKTEST="false"
# choose the slurm queue to use
export SQQUEUE="other"
# choose which MPI installation and LS-DYNA MPP binary to use
export MPIROOT="/opt/amazon/openmpi"
export MPPDYNA="/shared/lstc/mppdyna-dp-ompi400"
export PATH="$SQDIR/bin:$MPIROOT/bin:$PATH"
export LD_LIBRARY_PATH=$MPIROOT/lib64:$LD_LIBRARY_PATH
# choose LSTC LS-DYNA license server to use
export LSTC_LICENSE=network
export LSTC_LICENSE_SERVER=ip-172-31-31-31.us-west-2.compute.internal
export TZ="America/Los_Angeles"

mkdir -p $SQDIR/bin
mkdir -p $SQDIR/var
mkdir -p $SQDIR/var/restart-done
mkdir -p $SQDIR/var/restart-queue
