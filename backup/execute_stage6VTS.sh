#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l walltime=24:00:00

#!/bin/bash

#
#
#	This script will calibrate one MC file
#
#
#

# --- the parameters
RUNLIST=${arg1}
OUTDIR=${arg2}
CONFIGFILE=${arg3}
CUTSFILE=${arg4}
SHOWERMAX=${arg5}
MSW=${arg6}
MSL=${arg7}
THETASQR=${arg8}
OUTPUTFILENAME=${arg9}
SCRATCH=${arg10}
ROOTSYS=${arg11}
VERITASBASE=${arg12}
SCRIPTDIR=${arg13}

# --- the environment

export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH

# ---

echo "----------------------------------------------------------"
echo "stage6-execute on `hostname`"
date
echo "----------------------------------------------------------"

# ---
EXECUTE="${SCRIPTDIR}/stage6.sh ${RUNLIST} ${OUTDIR} ${CONFIGFILE} ${CUTSFILE} ${SHOWERMAX} ${MSW} ${MSL} ${THETASQR} ${OUTPUTFILENAME} ${SCRATCH} ${ROOTSYS} ${VERITASBASE}"

echo "${EXECUTE}"
${EXECUTE}


echo ---------------------------------------------------------------------------------------------------------
echo Stage6 completed. Have a lot of fun!

