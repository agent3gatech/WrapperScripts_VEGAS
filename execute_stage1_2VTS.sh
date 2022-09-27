#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l walltime=12:00:00

#!/bin/bash

#
#
#	This script will calibrate one MC file
#
#
#

# --- the parameters
RUNNUM=`echo "${PBS_JOBID}" | cut -d "[" -f 2 | cut -d "]" -f "1"`


SRC=${arg1}
MC_CARE=${arg2}
RUN=${RUNNUM}
LASERRUN=${arg3}
CALIBDIRIN=${arg4}
CALIBDIROUT=${arg5}
STAGE1CONFIGFILE=${arg6}
STAGE2CONFIGFILE=${arg7}
SCRIPTDIR=${arg8}
ROOT=${arg9}
VEGASBASE=${arg10}
SCRATCHDIR=${arg11}
MCNOISELVL=${arg12}

echo "${SCRIPTDIR}"
echo "${STAGE2CONFIGFILE}"
echo "${STAGE1CONFIGFILE}"
echo "${CALIBDIROUT}"

# ---

echo "----------------------------------------------------------"
echo "execute_stage1_2 on `hostname`"
date
echo "Will calibrate run ${RUN} (${SRC} ${MCNOISELVL})..."
echo "----------------------------------------------------------"

# ---

EXECUTE="${SCRIPTDIR}/stage1_2.sh ${SRC} ${MC_CARE} ${RUN} ${LASERRUN} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} ${ROOT} ${VEGASBASE} ${SCRATCHDIR} ${MCNOISELVL}"

echo "${EXECUTE}"
${EXECUTE}

