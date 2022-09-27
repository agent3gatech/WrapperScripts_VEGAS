#PBS -l nodes=1:ppn=1
#PBS -l mem=2gb
#PBS -l walltime=4:00:00

#!/bin/bash
#
#
#	This script will calibrate one DATA file
#
#
#

# --- the parameters

echo "----------------------------------------------------------"
echo "execute_laser_stage1_2.sh on `hostname`"
date
echo "----------------------------------------------------------"
export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH



SRC=${arg1}
MC_CARE=${arg2}
LASERRUN=${arg3}
CALIBDIRIN=${arg4}
CALIBDIROUT=${arg5}
STAGE1CONFIGFILE=${arg6}
STAGE2CONFIGFILE=${arg7}
export ROOTSYS=${arg8}
export VEGASBASE=${arg9}
SCRIPTDIR=${arg10}
SCRATCHDIR=${arg11}
QUEUE=${arg12}
if [ "${SRC}" = "MC" ]; then
    MCNOISELVL=${arg13}
    runstring=${arg14//%/ }
else
    MCNOISELVL=""
    runstring=${arg13//%/ }
fi

echo "${arg13}"

RUNS=( `echo "${runstring}"` )


# ---
mkdir -p ${CALIBDIROUT}/log



if [ -e ${CALIBDIROUT}/${LASERRUN}.root ]; then
    echo "Laserrun ${CALIBDIROUT}/${LASERRUN}.root already exists, do nothing."
else
    echo "Going through laser run ${LASERRUN}"

    EXECUTE="${SCRIPTDIR}/laser.sh ${SRC} ${LASERRUN} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${ROOTSYS} ${VEGASBASE}"
    echo "${EXECUTE}"
    ${EXECUTE}
fi

echo
echo submitting jobs to calibrate runs
echo ---------------------------------------------------------------------------------------------------------

echo runs ${runstring}



RUNSTOCALIBRATE=""

for ((i=0;i<${#RUNS[@]};i++)); do

  if [ -f ${CALIBDIROUT}/${RUNS[${i}]}.${SRC}${MCNOISELVL}.root ]; then
    echo "run ${RUNS[${i}]} already calibrated as ${CALIBDIROUT}/${RUNS[${i}]}.${SRC}${MCNOISELVL}.root, do nothing"
  else if [ -f ${CALIBDIRIN}/${RUNS[${i}]}.${SRC}.cvbf -o -f ${CALIBDIRIN}/${RUNS[${i}]}.vbf ]; then
       #Add run to list of runs that will be calibrated	
       RUNSTOCALIBRATE="${RUNS[${i}]},${RUNSTOCALIBRATE}"
  else
   echo -e "\033[31m raw data file ${CALIBDIRIN}/${RUNS[${i}]}.${SRC}.cvbf or ${CALIBDIRIN}/${RUNS[${i}]}.vbf does not exist, get it and come back later \033[m"
  fi
 fi

done

#remove last comma from string
RUNSTOCALIBRATE=${RUNSTOCALIBRATE%?}

EXECUTABLE=$SCRIPTDIR/execute_stage1_2VTS.sh


if [ "${MCNOISELVL}" = "" ]; then
  MCNOISELVL="no"
fi

if [ "${RUNSTOCALIBRATE}" != "" ]; then
     ARGUMENTS=" -q ${QUEUE} -h -d ${CALIBDIROUT} -e log/err-\$MOAB_JOBARRAYINDEX -o log/out-\$MOAB_JOBARRAYINDEX -N VTScalib -t [${RUNSTOCALIBRATE}] -v arg1=${SRC},arg2=${MC_CARE},arg3=${LASERRUN},arg4=${CALIBDIRIN},arg5=${CALIBDIROUT},arg6=${STAGE1CONFIGFILE},arg7=${STAGE2CONFIGFILE},arg8=${SCRIPTDIR},arg9=${ROOTSYS},arg10=${VEGASBASE},arg11=${SCRATCHDIR},arg12=${MCNOISELVL} ${EXECUTABLE}"

      echo "qsub ${ARGUMENTS}"

      qsub ${ARGUMENTS}

      while [ "$?" != "0" ]
         do
            sleep 5
            qsub ${ARGUMENTS}
         done

      echo ---------------------------------------------------------------------------------------------------------
      echo "JOBS SUBMITTED (if any). Have a lot of fun!"
fi

echo "execute_laser_stage1_2 completed. Have a lot of fun!"

