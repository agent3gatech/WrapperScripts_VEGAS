#!/bin/sh

CUTSFILESTAGE4=$1
CONFIGFILESTAGE4=$2
SIZELOWER=$3
SIZEUPPER=$4
LOOKUPTABLE=$5
CUTSFILESTAGE5=$6
CONFIGFILESTAGE5=$7
SRC=$8
CALIBDIRIN=$9
OUTDIR=${10}
ROOTSYS=${11}
VERITASBASE=${12}
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
    done

    RUNS=( `echo "${RUNS}"` )
    DAYS=( `echo "${DAYS}"` )

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

  echo "adding run ${RUNS[${i}]} to list for stage 4.2 and stage5"
 # RUNSTOCALIBRATE="${RUNS[${i}]},${RUNSTOCALIBRATE}"
    
  OUTFILEBASE=${FINALOUTDIR}/${RUNS[${i}]}.${SRC}${MCNOISELVL}


  ARGUMENTS=" -q ${QUEUE} -h -N VTSstage45 -d ${FINALOUTDIR} -e log/err-\$MOAB_JOBARRAYINDEX -o log/out-\$MOAB_JOBARRAYINDEX -t [${RUNS[${i}]}] -v arg1=${CUTSFILESTAGE4},arg2=${CONFIGFILESTAGE4},arg3=${SIZELOWER},arg4=${SIZEUPPER},arg5=${LOOKUPTABLE},arg6=${CUTSFILESTAGE5},arg7=${CONFIGFILESTAGE5},arg8=${SRC},arg9=${FINALCALIBDIRIN},arg10=${FINALOUTDIR},arg11=${RUNS[${i}]},arg12=${ROOTSYS},arg13=${VERITASBASE},arg14=${DBSERVER},arg15=${CUTBADTIMES},arg16=${SCRATCHDIR},arg17=${SCRIPTDIR},arg18=${MCNOISELVL} ${EXECUTABLE}"

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
