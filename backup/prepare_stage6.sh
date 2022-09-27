#!/bin/bash

RUNLIST=$1
STAGE6OUTNAME=$2
OUTDIR=$3
CONFIGFILE=$4
CUTSFILE=$5
DATADIR=$6
MSWFLOAT=$7
MSLFLOAT=$8
SHOWERMAXFLOAT=$9
THETASQRFLOAT=${10}
EAFILE=${11}
SCRATCH=${12} 
QUEUE=${13}
ROOTSYS=${14}
VERITASBASE=${15}
DBSERVER=${16}
SCRIPTDIR=${17}

#################################################


ALLRUNS=( `cat ${RUNLIST}` )

mkdir -p ${OUTDIR}

RUNLIST=${OUTDIR}/${STAGE6OUTNAME}_runlist.txt
rm ${RUNLIST}
touch ${RUNLIST}

#fill array with control 

STAGE4RD=""
for ((i=0;i<${#ALLRUNS[@]};i++)); do
STAGE4RD=`echo "${STAGE4RD} 0"`
done

STAGE4RD=( `echo "${STAGE4RD}"` )

ALLINSTAGE45=0


while [ ${ALLINSTAGE45} == "0" ]; do

  for ((i=0;i<${#ALLRUNS[@]};i++)); do

     STRING=( `echo ${ALLRUNS[${i}]//// }` )

     DAY=${STRING[ ${#STRING[@]}-2  ]}
 
     RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`

     SRC=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUN}"  | xargs echo -n  | cut -d " " -f 2-`
     SRC=${SRC// /_}
     SRC=${SRC////_}

     if [ -f  ${DATADIR}/${DAY}/${RUN}.${SRC}*.root ]; then
	 echo "I found a stage4 and stage5 processed file ${DATADIR}/${DAY}/${RUN}.${SRC}.root"

	 if [ ${STAGE4RD[${i}]} == "0" ]; then
	     #echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root` ${EAFILE}" >> ${RUNLIST}
	     echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	 fi

	 STAGE4RD[${i}]=1
      
         

     else
          echo "\033[31m I could not find a stage4 and stage5 processed file for run ${DATADIR}/${DAY}/${RUN}.${SRC}.root \033[m"
     fi

  
  done

  ALLINSTAGE45=1
  for ((i=0;l<${#ALLRUNS[@]};l++)); do
     if [ ${STAGE4RD[${l}]} == "0" ]; then
	 ALLINSTAGE45=0
         echo "`qstat`"
         echo "`date`: I go to sleep for the next 4 minutes"
         sleep 4m
         echo "`date`: Woken up, ready for the next round
"
	 break
     fi
  done


done
                             

  
    SHOWERMAX=$(echo "${SHOWERMAXFLOAT}*100" | bc -l | cut -d . -f1)
    MSW=$(echo "${MSWFLOAT}*100" | bc -l | cut -d . -f1)
    MSL=$(echo "${MSLFLOAT}*100" | bc -l | cut -d . -f1)
    THETASQR=$(echo "${THETASQRFLOAT}*1000" | bc -l | cut -d . -f1)

    OUTFILEBASE=Stage6_${STAGE6OUTNAME}_SHOWERMAX${SHOWERMAX}_MSW${MSW}_MSL${MSL}_THETASQR${THETASQR}

    EXECUTABLE=${SCRIPTDIR}/execute_stage6VTS.sh


    ARGUMENTS=" -q ${QUEUE}  -d ${OUTDIR} -v arg1=${RUNLIST},arg2=${OUTDIR},arg3=${CONFIGFILE},arg4=${CUTSFILE},arg5=${SHOWERMAXFLOAT},arg6=${MSWFLOAT},arg7=${MSLFLOAT},arg8=${THETASQRFLOAT},arg9=${OUTFILEBASE},arg10=${SCRATCH},arg11=${ROOTSYS},arg12=${VERITASBASE},arg13=${SCRIPTDIR} ${EXECUTABLE}"

          echo "qsub ${ARGUMENTS}"

          qsub ${ARGUMENTS}

          while [ "$?" != "0" ]
            do
              sleep 5
             qsub ${ARGUMENTS}
         done
  
echo ---------------------------------------------------------------------------------------------------------
echo Stage6 JOB SUBMITTED. Have a lot of fun!

