#!/bin/bash
#
#
#	This script will process the laser run
#
#
#

# --- the parameters

echo "Processing a laser/flasher run"

SRC=${1}
LASERRUN=${2}
CALIBDIRIN=${3}
CALIBDIROUT=${4}
STAGE1CONFIGFILE=${5}
export ROOTSYS=${6}
export VEGASBASE=${7}


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

echo "${VEGAS}"
echo "${VEGASBASE}"
echo "${ROOTSYS}"


# ---
mkdir -p ${CALIBDIROUT}

    if [ "${SRC}" = "MC" ]; then
	echo "Going through laser run ${LASERRUN}"
	echo "${VEGAS}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=simLaser -AIF_DataSource=CompiledOnly -AIFC_OverrideArray=VC499_BASE -G_SimulationMode=1 dummyFileName ${CALIBDIROUT}${LASERRUN}.root"
	${VEGAS}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=simLaser -AIF_DataSource=CompiledOnly -AIFC_OverrideArray=VC499_BASE -G_SimulationMode=1 dummyFileName ${CALIBDIROUT}${LASERRUN}.root
    else
	echo "time ${VEGAS}/bin/vaStage1 -config=${STAGE1CONFIGFILE} ${CALIBDIRIN}/${LASERRUN}.cvbf ${CALIBDIROUT}/${LASERRUN}.root"
	time ${VEGAS}/bin/vaStage1  -config=${STAGE1CONFIGFILE} ${CALIBDIRIN}/${LASERRUN}.cvbf ${CALIBDIROUT}/${LASERRUN}.root
    fi

echo "completed processing the laser/flasher run. Have a lot of fun!"

