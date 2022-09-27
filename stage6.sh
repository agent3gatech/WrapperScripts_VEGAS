#!/bin/bash

#
#
#	This script will calibrate one MC file
#
#
#

# --- the parameters
RUNLIST=$1
OUTDIR=$2
CONFIGFILE=$3
CUTSFILE=$4
OUTPUTFILENAME=$5
SCRATCH=${6}
ROOT=${7}
VEGASBASE=${8}

# --- the environment
module load ${ROOT}
export VEGASBASE=${8}
export LD_LIBRARY_PATH=$VEGASBASE/lib:$LD_LIBRARY_PATH
export PATH=$VEGASBASE/bin:$PATH

echo "${VEGASBASE}"
echo "${ROOT}"
echo "$LD_LIBRARY_PATH"

#TEMPO2 Configuration (Do this in your .bashrc!!!)
#export TEMPO2=/nv/hp11/aotte6/code/tempo2/tempo2-2012.11.1/T2runtime/
#export TEMPO2=/nv/pc5/vhe/tempo2-2014.2.1/T2runtime/
#export PATH=${TEMPO2}/bin:${PATH}
#export LIBDIR=${TEMPO2}/lib
#export LD_LIBRARY_PATH=${LIBDIR}:${LD_LIBRARY_PATH}


# ---

THETA=$(echo "scale=4; sqrt(${THETASQR})" | bc -l)

echo "THETASQR is ${THETASQR}, THETA is ${THETA}"


echo
echo vaStage6:
echo ---------------------------------------------------------------------------------------------------------

#change into the output directory, otherwise the tempo2 output will be written into your home
SCRATCH=${SCRATCH}/${PBS_JOBID}
mkdir -p ${SCRATCH}
cd ${SCRATCH}

echo " running vaStage6"
echo " time ${VEGASBASE}/bin/vaStage6 -S6A_ConfigDir=${OUTDIR} -config=${CONFIGFILE} -cuts=${CUTSFILE} -OverrideEACheck=1 -S6A_Batch=1 -S6A_ExcludeSource=1 -S6A_ExcludeStars=1 -S6A_OutputFileName=${OUTPUTFILENAME} ${RUNLIST}"

       time ${VEGASBASE}/bin/vaStage6 -S6A_ConfigDir=${OUTDIR} -config=${CONFIGFILE} -cuts=${CUTSFILE} -OverrideEACheck=1 -S6A_Batch=1 -S6A_ExcludeSource=1 -S6A_ExcludeStars=1 -S6A_OutputFileName=${OUTPUTFILENAME} ${RUNLIST}

mv ${SCRATCH}/* ${OUTDIR}/
#rm -rf ${SCRATCH}  

EXITCODE=$?
echo EXITCODE of vaStage6 is $EXITCODE
