#!/bin/bash

#
#
#	This script will calibrate one file
#
#
#

# --- the parameters

SRC=${1}
MC_CARE=${2}
RUN=${3}
LASERRUN=${4}
CALIBDIRIN=${5}
CALIBDIROUT=${6}
STAGE1CONFIGFILE=${7}
STAGE2CONFIGFILE=${8}
ROOT=${9}
VEGASBASE=${10}
SCRATCHDIR=${11}
MCNOISELVL=${12}
if [ ${MCNOISELVL} = "no" ]; then
  MCNOISELVL=""
fi

# --- the environment
module load ${ROOT}
export VEGASBASE=${10}
export LD_LIBRARY_PATH=$VEGASBASE/lib:$LD_LIBRARY_PATH
export PATH=$VEGASBASE/bin:$PATH

echo "${VEGASBASE}"
echo "${ROOT}"


RUNNUM=`echo "${PBS_JOBID}" | cut -d "[" -f 2 | cut -d "]" -f "1"`
#scratch tmp dir that holds the intermediate and final data products
#SCRATCHTMP=${SCRATCHDIR}/${PBS_JOBID}${RUN}
SCRATCHTMP=${SCRATCHDIR}/${RUN}
mkdir -p ${SCRATCHTMP}

echo
echo  vaStage1:
echo ---------------------------------------------------------------------------------------------------------

#cp data to scratch tmp distinguish between raw/MC CARE and MC


#GRISU sims
if [[ "${SRC}" = "MC" && "${MC_CARE}" != "true" ]]; then
    echo "cp ${CALIBDIRIN}/pedestals/pedestalFiles/noise${MCNOISELVL}.root ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root"
          cp ${CALIBDIRIN}/pedestals/pedestalFiles/noise${MCNOISELVL}.root ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root
    MCSTAGE2OPTIONS="-PaddingApp=PaddingFromLibrary -PFL_LibraryFileName=${CALIBDIRIN}/pedestals/noiseLibraries/noiseLibrary.${MCNOISELVL}.root -PFL_NoiseLevel=${MCNOISELVL} -G_SimulationMode=1"
    RAWINPUT=${SCRATCHTMP}
    RUNINFILENAME=${RUN}.vbf 
    cp ${CALIBDIRIN}/${RUNINFILENAME} ${RAWINPUT}/

#CARE sims
elif [[ "${SRC}" = "MC" && "${MC_CARE}" = "true" ]]; then
    MCNOISELVL="CARE"
    RUNINFILENAME=${RUN}.${SRC}.cvbf

    #swap the two lines below and you use scratch
    #RAWINPUT=${SCRATCHTMP}
    RAWINPUT=${CALIBDIRIN}
    cp ${CALIBDIRIN}/${RUNINFILENAME} ${RAWINPUT}/
   
    echo "time ${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -G_SimulationMode=1 -CRH_Algorithm=VASimulationRunHeaderFiller -Stage1_RunMode=data  -AIFC_CameraRotation=1/0.0,2/0.0,3/0.0,4/0.0 ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root" 
          time ${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -G_SimulationMode=1 -CRH_Algorithm=VASimulationRunHeaderFiller -Stage1_RunMode=data  -AIFC_CameraRotation=1/0.0,2/0.0,3/0.0,4/0.0 ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root 
    MCSTAGE2OPTIONS="-G_SimulationMode=1 -TWTZ_MinEntriesPerHistogram=2"

#normal data
else
    RAWINPUT=${SCRATCHDIR}/veritas_rawdata/


    if [ -f ${CALIBDIRIN}/${RUN}.${SRC}.cvbf ]; then 
        RUNINFILENAME=${RUN}.${SRC}.cvbf

    elif [ -f ${CALIBDIRIN}/${RUN}.vbf ]; then  
        RUNINFILENAME=${RUN}.vbf
    else
        echo "\nCould not find your vbf file!  Exiting..."
        exit
    fi

        #RUNINFILENAME=${RUN}.${SRC}.cvbf 
    if [ -f ${RAWINPUT}/${RUNINFILENAME} ]; then
        touch ${RAWINPUT}/${RUNINFILENAME}
    else
        mkdir -p  ${RAWINPUT}
        echo "copying file to scratch: ${RAWINPUT}"
        cp ${CALIBDIRIN}/${RUNINFILENAME} ${RAWINPUT}/${RUNINFILENAME}
    fi
    
    echo "time ${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=data ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}.root" 
    time ${VEGASBASE}/bin/vaStage1 -config=${STAGE1CONFIGFILE} -Stage1_RunMode=data ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}.root 
    #MCSTAGE2OPTIONS="-LGDL_Algorithm=LowGainDataLoaderFromFile -LGDLFF_FileName=${VEGASBASE}/common/lowGainDataFiles/59946-59947_doublepass.root"
    MCSTAGE2OPTIONS=""
fi
      

echo
echo  vaStage2:
echo ---------------------------------------------------------------------------------------------------------

echo " running vaStage2 on RUN ${RUN}"

echo " time ${VEGASBASE}/bin/vaStage2 ${MCSTAGE2OPTIONS} -config=${STAGE2CONFIGFILE} ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root  ${CALIBDIROUT}${LASERRUN}.root"
      
       time ${VEGASBASE}/bin/vaStage2 ${MCSTAGE2OPTIONS} -config=${STAGE2CONFIGFILE} ${RAWINPUT}/${RUNINFILENAME} ${SCRATCHTMP}/${RUN}.${SRC}${MCNOISELVL}.root  ${CALIBDIROUT}${LASERRUN}.root

EXITCODE=$?
echo EXITCODE of vaStage2 is $EXITCODE

echo Cleaning up

cd ${SCRATCHTMP}/
mv  ${RUN}.${SRC}${MCNOISELVL}.root ${CALIBDIROUT}/
#tar -cp ${RUN}.${SRC}${MCNOISELVL}.root | ssh vhe0 "(cd ${CALIBDIROUT} ; tar -xp)"
rm -rf ${SCRATCHTMP}

if [ -f ${CALIBDIROUT}/${RUN}.${SRC}${MCNOISELVL}.root ]; then
   echo "Calibration of run ${RUN} completed. Have a lot of fun!"
else
   echo -e "\033[31m Calibrated run ${RUN} did not arrived in its final place, where did it get lost? \033[m"
fi
