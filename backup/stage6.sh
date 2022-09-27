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
SHOWERMAX=$5
MSW=$6
MSL=$7
THETASQR=$8
OUTPUTFILENAME=$9
SCRATCH=${10}
export ROOTSYS=${11}
export VEGASBASE=${12}


# --- the environment

export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH

export LD_LIBRARY_PATH=/nv/hp11/aotte6/code/cfitsio/lib/
export LD_LIBRARY_PATH=/usr/local/packages/intel/compiler/12.0.0.084/lib/intel64:$LD_LIBRARY_PATH

#COMMON FOR ALL VEGAS VERSIONS
export PATH=$ROOTSYS/bin:$PATH
export LD_LIBRARY_PATH=$ROOTSYS/lib/root:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$VEGASBASE/lib:$LD_LIBRARY_PATH
export PATH=$VEGASBASE/bin:$PATH
export VEGAS=$VEGASBASE/vegas
export PATH=$VEGAS/bin:$PATH

echo "$LD_LIBRARY_PATH"
#echo "${PATH}"

#TEMPO2 Configuration
export TEMPO2=/nv/hp11/aotte6/code/tempo2/tempo2-2012.11.1/T2runtime/
export PATH=${TEMPO2}/bin:${PATH}
export LIBDIR=${TEMPO2}/lib
export LD_LIBRARY_PATH=${LIBDIR}:${LD_LIBRARY_PATH}


# ---

THETA=$(echo "scale=4; sqrt(${THETASQR})" | bc -l)

echo "THETASQR is ${THETASQR}, THETA is ${THETA}"


echo
echo vaStage6:
echo ---------------------------------------------------------------------------------------------------------

#change into the output directory, otherwise the tempo2 output will be written into your home
SCRATCH=${SCRATCH}/${PBS_JOBID}
mkdir ${SCRATCH}
cd ${SCRATCH}

echo " running vaStage6"
echo " time ${VEGAS}/bin/vaStage6 -S6A_ConfigDir=${OUTDIR} -config=${CONFIGFILE} -cuts=${CUTSFILE} -S6A_Batch=1 -MeanScaledWidthUpper=${MSW} -MeanScaledLengthUpper=${MSL} -MaxHeightLower=${SHOWERMAX} -S6A_RingSize=${THETA} -RBM_SearchWindowSqCut=${THETASQR} -S6A_ExcludeSource=1 -S6A_ExcludeStars=1 -S6A_OutputFileName=${OUTPUTFILENAME} ${RUNLIST}"

       time ${VEGAS}/bin/vaStage6 -S6A_ConfigDir=${OUTDIR} -config=${CONFIGFILE} -cuts=${CUTSFILE} -S6A_Batch=1 -MeanScaledWidthUpper=${MSW} -MeanScaledLengthUpper=${MSL} -MaxHeightLower=${SHOWERMAX} -S6A_RingSize=${THETA} -RBM_SearchWindowSqCut=${THETASQR} -S6A_ExcludeSource=1 -S6A_ExcludeStars=1 -S6A_OutputFileName=${OUTPUTFILENAME} ${RUNLIST}

mv ${SCRATCH}/* ${OUTDIR}/
rm -rf ${SCRATCH}  

EXITCODE=$?
echo EXITCODE of vaStage6 is $EXITCODE
