#!/bin/sh

# Called by prepare_stage4_5.sh

CUTSFILESTAGE4=$1
CONFIGFILESTAGE4=$2
#SIZELOWER=$3 # Do not use parameter 3; dummy parameter
SIZEUPPER=$4
#ALLLOOKUPTABLES=("${!5}") # Do not use parameter 5; it is a dummy parameter.
CUTSFILESTAGE5=$6
CONFIGFILESTAGE5=$7
SRC=$8
CALIBDIRIN=$9
OUTDIR=${10}
ROOT=${11}
VEGASBASE=${12}
DBSERVER=${13}
SCRIPTDIR=${14}
CUTBADTIMES=${15}
SCRATCHDIR=${16}
QUEUE=${17}
if [[ "${SRC}" == "MC" ]]; then
    MCNOISELVL=${18}
 LIST=( `echo ${19}` )
 for ((i=0;i<${#LIST[@]};i++)); do
	RUNS=`echo "${RUNS}"; echo "${LIST[${i}]}"`
 done
 RUNS=( `echo "$RUNS"` )

 FINALOUTDIR=${OUTDIR}/MC
 FINALCALIBDIRIN=${CALIBDIRIN}/MC/
else
    MCNOISELVL=""
    LIST=( `echo ${18}` )
    for ((i=0;i<${#LIST[@]};i++)); do
	RUNS=`echo "${RUNS}"; echo "${LIST[${i}]}" | cut -d . -f2`
	DAYS=`echo "${DAYS}"; echo "${LIST[${i}]}" | cut -d . -f1`
	ALLSIZELOWERS=`echo "${ALLSIZELOWERS}"; echo "${LIST[${i}]}" | cut -d . -f3`
	ALLLOOKUPTABLES=`echo "${ALLLOOKUPTABLES}"; echo "${LIST[${i}]}" | cut -d . -f4-`
    done

    RUNS=( `echo "${RUNS}"` )
    DAYS=( `echo "${DAYS}"` )
    ALLSIZELOWERS=( `echo "${ALLSIZELOWERS}"`  )
    ALLLOOKUPTABLES=( `echo "${ALLLOOKUPTABLES}"` )
    echo "Size lower number 3 is "${ALLSIZELOWERS[3]}"."

fi

 echo "${RUNS}"
 echo "${DAYS}"

EXECUTABLE=$SCRIPTDIR/execute_stage4_5VTS.sh


if [ "${MCNOISELVL}" = "" ]; then
  MCNOISELVL="no"
fi

#RUNSTOCALIBRATE=""

for ((i=0;i<${#RUNS[@]};i++)); do

if [[ "${SRC}" != "MC" ]]; then
 
 FINALOUTDIR=${OUTDIR}/${DAYS[${i}]}/
 FINALCALIBDIRIN=${CALIBDIRIN}/${DAYS[${i}]}/

 SRC=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUNS[${i}]}"  | xargs echo -n  | cut -d " " -f 2-`
 SRC=${SRC// /_}
 SRC=${SRC////_}

fi

  mkdir -p ${FINALOUTDIR}/log

  echo "adding run ${RUNS[${i}]} to list for stage4 and stage5"
 # RUNSTOCALIBRATE="${RUNS[${i}]},${RUNSTOCALIBRATE}"
    
  OUTFILEBASE=${FINALOUTDIR}/${RUNS[${i}]}.${SRC}${MCNOISELVL}
  
  RUNNUM=`echo "${PBS_JOBID}" | cut -d "[" -f 2 | cut -d "]" -f "1"`

  ARGUMENTS=" -q ${QUEUE} -h -N VTSstage45 -d ${FINALOUTDIR} -e log/err-${RUNS[${i}]} -o log/out-${RUNS[${i}]} -t ${RUNS[${i}]} -v arg1=${CUTSFILESTAGE4},arg2=${CONFIGFILESTAGE4},arg3=${ALLSIZELOWERS[${i}]},arg4=${SIZEUPPER},arg5=${ALLLOOKUPTABLES[${i}]},arg6=${CUTSFILESTAGE5},arg7=${CONFIGFILESTAGE5},arg8=${SRC},arg9=${FINALCALIBDIRIN},arg10=${FINALOUTDIR},arg11=${RUNS[${i}]},arg12=${ROOT},arg13=${VEGASBASE},arg14=${DBSERVER},arg15=${CUTBADTIMES},arg16=${SCRATCHDIR},arg17=${SCRIPTDIR},arg18=${MCNOISELVL} ${EXECUTABLE}"

          echo "qsub ${ARGUMENTS}"

          qsub ${ARGUMENTS}

          while [ "$?" != "0" ]
            do
              sleep 5
             qsub ${ARGUMENTS}
         done

done

echo ---------------------------------------------------------------------------------------------------------


##########################################
