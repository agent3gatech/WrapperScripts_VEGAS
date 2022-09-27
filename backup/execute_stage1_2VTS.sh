#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l walltime=40:00:00

#!/bin/bash

#
#
#	This script will calibrate one MC file
#
#
#

# --- the parameters

SRC=${arg1}
MC_CARE=${arg2}
RUN=${MOAB_JOBARRAYINDEX}
LASERRUN=${arg3}
CALIBDIRIN=${arg4}
CALIBDIROUT=${arg5}
STAGE1CONFIGFILE=${arg6}
STAGE2CONFIGFILE=${arg7}
SCRIPTDIR=${arg8}
ROOTSYS=${arg9}
VERITASBASE=${arg10}
SCRATCHDIR=${arg11}
MCNOISELVL=${arg12}

# --- the environment
export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH


export LD_LIBRARY_PATH=/nv/hp11/aotte6/code/cfitsio/lib/
export LD_LIBRARY_PATH=/usr/local/packages/intel/compiler/12.0.0.084/lib/intel64:$LD_LIBRARY_PATH
#COMMON FOR ALL VEGAS VERSIONS
#export PATH=$ROOTSYS/bin:$PATH
#export LD_LIBRARY_PATH=$ROOTSYS/lib/root:$LD_LIBRARY_PATH

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

EXECUTE="${SCRIPTDIR}/stage1_2.sh ${SRC} ${MC_CARE} ${RUN} ${LASERRUN} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} ${ROOTSYS} ${VERITASBASE} ${SCRATCHDIR} ${MCNOISELVL}"

echo "${EXECUTE}"
${EXECUTE}

