#PBS -l nodes=1:ppn=1
#PBS -l mem=4gb
#PBS -l walltime=11:00:00

#!/bin/bash

#
#
#	This script will calibrate one MC file
#
#
#

# Called by prepare_stage6.sh

# --- the parameters
RUNLIST=${arg1}
OUTDIR=${arg2}
CONFIGFILE=${arg3}
CUTSFILE=${arg4}
OUTPUTFILENAME=${arg5}
SCRATCH=${arg6}
ROOT=${arg7}
VEGASBASE=${arg8}
SCRIPTDIR=${arg9}

# --- the environment

#export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH

# ---

echo "----------------------------------------------------------"
echo "stage6-execute on `hostname`"
date
echo "----------------------------------------------------------"

# ---
EXECUTE="${SCRIPTDIR}/stage6.sh ${RUNLIST} ${OUTDIR} ${CONFIGFILE} ${CUTSFILE} ${OUTPUTFILENAME} ${SCRATCH} ${ROOT} ${VEGASBASE}"

echo "${EXECUTE}"
${EXECUTE}


echo ---------------------------------------------------------------------------------------------------------
echo Stage6 completed. Have a lot of fun!

