#!/bin/sh


#GLOBAL DEFINED CUTS AND  LOOKUPTABLE

RUNLIST=$1
CALIBDIR=$2
FINALOUTDIRBASE=$3
SIZELOWER=$4
SIZEUPPER=$5
CUTSFILESTAGE4=$6
CONFIGFILESTAGE4=$7
LOOKUPTABLE=$8
LOOKUPTABLEDIR=$9
CUTSFILESTAGE5=${10}
CONFIGFILESTAGE5=${11}
SCRATCH=${12} 
QUEUE=${13} 
ROOTSYS=${14}
VERITASBASE=${15}
DBSERVER=${16}
SCRIPTDIR=${17}
CUTBADTIMES=${18}
MC=${19}
MCNOISELVL=${20}
MCRUNLIST=${21}

#############################################

LOOKUPTABLE=${LOOKUPTABLEDIR}/${LOOKUPTABLE}


###################################
# submit run by run
echo "${MC}"
if [[ "${MC}" == "true" ]]; then #MC stuff
echo "looks like we are processing MC"
  RUNLIST=${MCRUNLIST}

  #Separate the MCNOISELEVELS
  noiselevels=${MCNOISELVL//%/ }
  noiselevels=( `echo "${noiselevels}"` )
  NOISELEVELLOOPS=${#noiselevels[@]}
echo "${NOISELEVELLOOPS}"

else
  MCNOISELVL=""
  NOISELEVELLOOPS=1
  echo "We are not processing MC. MCNOISELVL should be empty. It is: ${MCNOISELVL}"
fi


for ((n=0;n<NOISELEVELLOOPS;n++)); do
    ALLRUNS=( `cat ${RUNLIST}` )

    #fill array with control 

    STAGE4RD=""
    for ((i=0;i<${#ALLRUNS[@]};i++)); do
		STAGE4RD=`echo "${STAGE4RD} 0"`
    done
    
    STAGE4RD=( `echo "${STAGE4RD}"` )

    ALLINSTAGE45=0

    RUNS=""

    while [ ${ALLINSTAGE45} == "0" ]; do

	for ((i=0;i<${#ALLRUNS[@]};i++)); do

		    if [ "${MC}" = "true" ]; then #MC stuff
			RUNLIST=${MCRUNLIST}
			SRC=MC
			FINALOUTDIR=${FINALOUTDIRBASE}/MC/
			CALIBDIRFINAL=${CALIBDIR}/MC/
			#CALIBDIRFINAL=${CALIBDIR}/
			RUN=${ALLRUNS[${i}]}
			MCNOISELVL=${noiselevels[${n}]}

		    else #DATA Stuff

			STRING=( `echo ${ALLRUNS[${i}]//// }` )
			
			DAY=${STRING[ ${#STRING[@]}-2  ]}
 
		        RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`

			SRC=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUN}"  | xargs echo -n  | cut -d " " -f 2-`
			SRC=${SRC// /_}
			SRC=${SRC////_}

                        #echo " ${CALIBDIR}/${DAY}/${RUN}.${SRC}.root ${STAGE4RD[${i}]} ${FINALOUTDIRBASE}/${DAY}/${RUN}.${SRC}.root"
			FINALOUTDIR=${FINALOUTDIRBASE}/${DAY}
			CALIBDIRFINAL=${CALIBDIR}/${DAY}/
		    fi
       
	
		    if [ -f  ${FINALOUTDIR}/${RUN}.${SRC}${MCNOISELVL}.root ]; then
			echo "I found an already stage4 and stage5 processed file ${FINALOUTDIR}/${RUN}.${SRC}${MCNOISELVL}.root"
			STAGE4RD[${i}]=1
		    fi

		    if [ -f ${CALIBDIRFINAL}${RUN}.${SRC}${MCNOISELVL}.root -a ${STAGE4RD[${i}]} == "0" ]; then
  
			echo "I found a calibrated file for run ${RUN} in ${CALIBDIR}/${DAY}/ . Adding Run to the list of stage 4/5 files." 
	   
			STAGE4RD[${i}]=1

			if [[ "${MC}" == "true" ]]; then #MC stuff
			    RUNS=`echo ${RUNS} ${RUN}`
			else
			    RUNS=`echo ${RUNS} ${DAY}.${RUN}`
			fi

		    else if [ ! -f ${CALIBDIRFINAL}${RUN}.${SRC}${MCNOISELVL}.root ]; then
			echo -e "\033[31m I could not find a calibrated file for run ${RUN}.${SRC}${MCNOISELVL} in ${CALIBDIRFINAL} I will try again in 10min. \033[m"
		    fi
		    fi
		    echo " "
	done

	ALLINSTAGE45=1
	for ((i=0;l<${#ALLRUNS[@]};l++)); do
		    if [ ${STAGE4RD[${l}]} == "0" ]; then
			ALLINSTAGE45=0
			echo "`date`: I go to sleep for the next 10 minutes"
			sleep 10m
			echo "`date`: Woken up, ready for the next roun"
			break
		    fi
	done



    done

    #next line calls stage4 script
    
    if [[ "${RUNS}" != "" ]]; then 
	echo " ${SCRIPTDIR}/submit_stage4_5.sh ${CUTSFILESTAGE4} ${CONFIGFILESTAGE4} ${SIZELOWER} ${SIZEUPPER} ${LOOKUPTABLE} ${CUTSFILESTAGE5} ${CONFIGFILESTAGE5} ${SRC} ${CALIBDIR} ${FINALOUTDIRBASE} ${ROOTSYS} ${VERITASBASE} ${DBSERVER} ${SCRIPTDIR} ${CUTBADTIMES} ${SCRATCH} ${QUEUE} ${MCNOISELVL} ${RUNS}"
	
	${SCRIPTDIR}/submit_stage4_5.sh ${CUTSFILESTAGE4} ${CONFIGFILESTAGE4} ${SIZELOWER} ${SIZEUPPER} ${LOOKUPTABLE} ${CUTSFILESTAGE5} ${CONFIGFILESTAGE5} ${SRC} ${CALIBDIR} ${FINALOUTDIRBASE} ${ROOTSYS} ${VERITASBASE} ${DBSERVER} ${SCRIPTDIR} ${CUTBADTIMES} ${SCRATCH} ${QUEUE} ${MCNOISELVL} "${RUNS}"
    fi

done #looping over MC noiselevels
