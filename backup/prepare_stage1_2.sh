#!/bin/bash

RUNLIST=$1
#base directory of calibrated data
OUT=$2
STAGE1CONFIGFILE=$3
STAGE2CONFIGFILE=$4
SCRATCH=$5
QUEUE=$6
ROOTSYS=$7
VEGASBASE=$8
VERITASDATABASE=$9
SCRIPTDIR=${10}
DBSERVER=${11}
MC=${12}
MC_CARE=${13}
MCDIRRAW=${14}
MCNOISELVL=${15}
MCRUNLIST=${16}


###################################

if [ "${MC}" = "true" ]; then #MC stuff

    RUNS=`cat ${MCRUNLIST}`
   
    CALIBDIRIN=${MCDIRRAW}/
    CALIBDIROUT=${OUT}/MC/
    SRC="MC"

    #Loop over all the noise levels
    noiselevels=${MCNOISELVL//%/ }
    for level in $noiselevels; do
	LASERRUN=simLaser${level}
	echo "
           ${SCRIPTDIR}/submit_stage1_2.sh ${SCRATCH} ${QUEUE} ${ROOTSYS} ${VEGASBASE} ${SCRIPTDIR} ${SRC} ${LASERRUN} ${MC_CARE} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} ${level} $RUNS"    
	${SCRIPTDIR}/submit_stage1_2.sh ${SCRATCH} ${QUEUE} ${ROOTSYS} ${VEGASBASE} ${SCRIPTDIR} ${SRC} ${LASERRUN} ${MC_CARE} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} ${level} "$RUNS"

	echo " "
    done

else # DATA stuff
    ALLRUNS=( `cat ${RUNLIST}` )

    for ((i=0;i<${#ALLRUNS[@]};i++)); do

		STRING=( `echo ${ALLRUNS[${i}]//// }` )

		CURRENTDAY=${STRING[ ${#STRING[@]}-2  ]}
 
	        RUNS=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`
		
		SRC=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUNS}"  | xargs echo -n  | cut -d " " -f 2-`
		SRC=${SRC// /_}
		SRC=${SRC////_}
		
		GROUPID=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select t1.group_id from tblRun_Group as t1, tblRun_GroupComment as t2 where t1.run_id="${RUNS}" and t1.group_id=t2.group_id and t2.group_type='laser'" | xargs echo -n  | cut -d " " -f 2`

		LASERRUN=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select t2.run_id from tblRun_Group as t1, tblRun_Info as t2 where t1.group_id="${GROUPID}" and t1.run_id=t2.run_id and  (t2.run_type='flasher' or t2.run_type='laser')" | xargs echo -n  | cut -d " " -f 2`	
		if [ -z "${LASERRUN}" -o ! -f "${VERITASDATABASE}/${CURRENTDAY}/${LASERRUN}.laser.cvbf" ]; then
		    echo -e "\033[31m Warning Laser run not found in the database or run in database not in directory, search for a laser run in ${VERITASDATABASE}/${CURRENTDAY}/  \033[m"
		    if [ -f ${VERITASDATABASE}/${CURRENTDAY}/*laser* ]; then
			LASERRUN=`ls ${VERITASDATABASE}/${CURRENTDAY}/*laser*`
			LASERRUN=( `echo ${LASERRUN//// }` )
			LASERRUN=`echo ${LASERRUN[ ${#LASERRUN[@]}-1  ]} | cut -d . -f 1-2`
			echo -e "\033[32m Will use laserrun ${LASERRUN} \033[m"
		    else
			echo -e "\033[31m Bad, bad, bad, no laser run found. Put one in the directory ${VERITASDATABASE}/${CURRENTDAY}/ and be sure it has laser in its name \033[m"
			i=$i+1
			echo " "
			continue
		    fi
		else
		    LASERRUN=${LASERRUN}.laser
		fi


		CALIBDIROUT=${OUT}/${CURRENTDAY}/
		CALIBDIRIN=${VERITASDATABASE}/${CURRENTDAY}

		if [ ! -f ${CALIBDIRIN}/${RUNS}.${SRC}.cvbf -o -f ${CALIBDIRIN}/${RUNS}.vbf ]; then
		    echo -e "\033[31m raw data file ${CALIBDIRIN}/${RUNS}.${SRC}.cvbf or ${CALIBDIRIN}/${RUNS}.vbf does not exist, get it and come back later. I will proceed anyway. \033[m"
		fi


		#maybe there is a merged laser run
		if [ -f ${CALIBDIROUT}/*merged.laser.root ]; then
		    LASERRUN=`ls ${CALIBDIROUT}/*merged.laser.root`
		    LASERRUN=( `echo ${LASERRUN//// }` )
		    LASERRUN=`echo ${LASERRUN[ ${#LASERRUN[@]}-1  ]} | cut -d . -f 1-2`
		    echo -e "\033[32m Found a merged laserrun. Will use laserrun ${LASERRUN} \033[m"
		fi

		for ((l=i+1;l<${#ALLRUNS[@]};l++)); do

			    STRING=( `echo ${ALLRUNS[${l}]//// }` )

			    DAY=${STRING[ ${#STRING[@]}-2  ]}
 
					if [ "${DAY}" = "${CURRENTDAY}" ]; then
					    RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`
					    RUNS=`echo ${RUNS} ${RUN}`
					    i=$l

					    if [ ! -f ${CALIBDIRIN}/${RUN}.${SRC}.cvbf -o -f ${CALIBDIRIN}/${RUN}.vbf ]; then
						echo -e "\033[31m raw data file ${CALIBDIRIN}/${RUN}.${SRC}.cvbf or ${CALIBDIRIN}/${RUN}.vbf does not exist, get it and come back later. I will proceed anyway. \033[m"
					    fi

					else
					    i=$l-1
					    break
					fi
		done

   #next line calls calibration for the day
		echo "
                   ${SCRIPTDIR}/submit_stage1_2.sh ${SCRATCH} ${QUEUE} ${ROOTSYS} ${VEGASBASE} ${SCRIPTDIR} ${SRC} ${LASERRUN} ${MC_CARE} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} $RUNS"

		   ${SCRIPTDIR}/submit_stage1_2.sh ${SCRATCH} ${QUEUE} ${ROOTSYS} ${VEGASBASE} ${SCRIPTDIR}  ${SRC} ${LASERRUN} ${MC_CARE} ${CALIBDIRIN} ${CALIBDIROUT} ${STAGE1CONFIGFILE} ${STAGE2CONFIGFILE} "$RUNS"

		   echo " "
    done

fi #End data stuff

