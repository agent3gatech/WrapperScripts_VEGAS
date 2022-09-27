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
ROOT=${6}
module load ${ROOT}
export VEGASBASE=${7}


# --- the environment
export LD_LIBRARY_PATH=$VEGASBASE/lib:$LD_LIBRARY_PATH
export PATH=$VEGASBASE/bin:$PATH

echo "${VEGASBASE}"
echo "${ROOT}"


# ---
mkdir -p ${CALIBDIROUT}

    if [ "${SRC}" = "MC" ]; then
	echo "Going through laser run ${LASERRUN}"
	echo "${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=simLaser -AIF_DataSource=CompiledOnly -AIFC_OverrideArray=VC499_BASE -G_SimulationMode=1 dummyFileName ${CALIBDIROUT}${LASERRUN}.root"
	${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=simLaser -AIF_DataSource=CompiledOnly -AIFC_OverrideArray=VC499_BASE -G_SimulationMode=1 dummyFileName ${CALIBDIROUT}${LASERRUN}.root
    else
	echo "time ${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} ${CALIBDIRIN}/${LASERRUN}.cvbf ${CALIBDIROUT}/${LASERRUN}.root"
	time ${VEGASBASE}/bin/vaStage1  -config=${STAGE1CONFIGFILE} ${CALIBDIRIN}/${LASERRUN}.cvbf ${CALIBDIROUT}/${LASERRUN}.root
    fi

echo "completed processing the laser/flasher run. Have a lot of fun!"

