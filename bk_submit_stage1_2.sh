#!/bin/bash

#calibrates one sequence
SCRATCH=$1
QUEUE=$2
ROOT=$3
VEGASBASE=$4
SCRIPTDIR=$5
SRC=$6
LASERRUN=$7
MC_CARE=$8
CALIBDIRIN=$9
CALIBDIROUT=${10}
STAGE1CONFIGFILE=${11}
STAGE2CONFIGFILE=${12}

if [ "${SRC}" = "MC" ]; then
    MCNOISELVL=${13}
    RUNS=( `echo "${14}"` )
else
    MCNOISELVL=""
    RUNS=( `echo "${13}"` ) 
fi

runstring=`echo ${RUNS[@]}`
runstring=${runstring// /%}

echo ${runstring}

mkdir -p ${CALIBDIROUT}/log

EXECUTABLE=$SCRIPTDIR/execute_laser_stage1_2VTS.sh

if [ "${SRC}" = "MC" ]; then
 ARGUMENTS=" -q ${QUEUE} -d ${CALIBDIROUT} -e log/err-laser -o log/out-laser -v arg1=${SRC},arg2=${MC_CARE},arg3=${LASERRUN},arg4=${CALIBDIRIN},arg5=${CALIBDIROUT},arg6=${STAGE1CONFIGFILE},arg7=${STAGE2CONFIGFILE},arg8=${ROOT},arg9=${VEGASBASE},arg10=${SCRIPTDIR},arg11=${SCRATCH},arg12=${QUEUE},arg13=${MCNOISELVL},arg14=${runstring} ${EXECUTABLE}"
else
 ARGUMENTS=" -q ${QUEUE} -d ${CALIBDIROUT} -e log/err-laser -o log/out-laser -v arg1=${SRC},arg2=${MC_CARE},arg3=${LASERRUN},arg4=${CALIBDIRIN},arg5=${CALIBDIROUT},arg6=${STAGE1CONFIGFILE},arg7=${STAGE2CONFIGFILE},arg8=${ROOT},arg9=${VEGASBASE},arg10=${SCRIPTDIR},arg11=${SCRATCH},arg12=${QUEUE},arg13=${runstring} ${EXECUTABLE}"
fi

          echo "qsub ${ARGUMENTS}"

          qsub ${ARGUMENTS}

          while [ "$?" != "0" ]
            do
              sleep 5
             qsub ${ARGUMENTS}
         done



echo ---------------------------------------------------------------------------------------------------------
echo JOBS SUBMITTED. Have a lot of fun!

