#!/bin/sh

#Called by MakeMeFamous.sh

#GLOBAL DEFINED CUTS AND  LOOKUPTABLE

RUNLIST=$1
CALIBDIR=$2
FINALOUTDIRBASE=$3
SIZELOWER=$4  # This parameter is now ignored; instead BOXCUTTYPE is used along with CUTS.txt to read in the appropriate SIZE cut.
SIZEUPPER=$5
CUTSFILESTAGE4=$6
CONFIGFILESTAGE4=$7
LOOKUPTABLE=$8
LOOKUPTABLEDIR=$9
CUTSFILESTAGE5=${10}
CONFIGFILESTAGE5=${11}
SCRATCH=${12} 
QUEUE=${13} 
ROOT=${14}
VEGASBASE=${15}
DBSERVER=${16}
SCRIPTDIR=${17}
CUTBADTIMES=${18}
MC=${19}
MCNOISELVL=${20}
MCRUNLIST=${21}
BOXCUTTYPE=${22}

#############################################

LOOKUPTABLE=${LOOKUPTABLEDIR}/${LOOKUPTABLE}
SCRIPTDIR2=/storage/home/hcoda1/7/agent3/lookuptables/
LOOKUPTABLEDIR2=/storage/home/hcoda1/7/agent3/lookuptables/

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

    # Set up a blank array with number of entries = total number of runs
    # More elegant way to do this?
    ALLLOOKUPTABLES=""
    for ((i=0;i<${#ALLRUNS[@]};i++)); do
                ALLLOOKUPTABLES=`echo "${ALLLOOKUPTABLES}"`
    done
    ALLLOOKUPTABLES=( `echo "${ALLLOOKUPTABLES}"` )
    # End blank lookuptable array stuff

    # Set up a blank array with number of entries = total number of runs
    # More elegant way to do this?
    ALLSIZELOWERS=""
    for ((i=0;i<${#ALLRUNS[@]};i++)); do
                ALLSIZELOWERS=`echo "${ALLSIZELOWERS}"`
    done
    ALLSIZELOWERS=( `echo "${ALLSIZELOWERS}"` )
    # End blank sizelower array stuff

    # Check what cuts we are using in BOXCUTTYPE variable (SOFT/MEDIUM/HARD) and 
    if [ ${BOXCUTTYPE} == "SOFT"  ]; then
	echo "Preparing stage4 and 5 for SOFT cuts!"
	CUTVAL=1
    elif [ ${BOXCUTTYPE} == "MEDIUM"  ] || [ ${BOXCUTTYPE} == "MODERATE" ]; then
	echo "Preparing stage4 and 5 for MEDIUM cuts!"
	CUTVAL=2
    elif [ ${BOXCUTTYPE} == "HARD"  ]; then
	echo "Preparing stage4 and 5 for HARD cuts!"
	CUTVAL=3
    else
	echo "You goofed, bro.  What BOXCUTTYPE are you using?  SOFT, MEDIUM, or HARD?"
	exit
    fi

    ALLINSTAGE45=0

    RUNS=""

    while [ ${ALLINSTAGE45} == "0" ]; do

	for ((i=0;i<${#ALLRUNS[@]};i++)); do
		    echo "Run $((i+1)) of ${#ALLRUNS[@]}." # Tells us which run out of total number of runs is being prepared.
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
			DATE=`echo ${DAY} | cut -d d -f 2` # Gets the date without the "d" letter at the beginning; just an int date.
		        RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`

		        # Use if/elif/elif/.../elif/else clause to select the correct lookuptable from the ${SCRIPTDIR}/LTs.txt text file
			if [ ${DATE} -lt 20070604 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20070604 ] && [ ${DATE} -lt 20071124 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20071124 ] && [ ${DATE} -lt 20080519 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20080519 ] && [ ${DATE} -lt 20081112 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20081112 ] && [ ${DATE} -lt 20090606 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20090606 ] && [ ${DATE} -lt 20090801 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==1 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((1+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20090801 ] && [ ${DATE} -lt 20091102 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20091102 ] && [ ${DATE} -lt 20100527 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20100527 ] && [ ${DATE} -lt 20101120 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20101120 ] && [ ${DATE} -lt 20110516 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20110516 ] && [ ${DATE} -lt 20111110 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20111110 ] && [ ${DATE} -lt 20120505 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20120505 ] && [ ${DATE} -lt 20120801 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==2 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((4+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20120801 ] && [ ${DATE} -lt 20121029 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20121029 ] && [ ${DATE} -lt 20130523 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20130523 ] && [ ${DATE} -lt 20131117 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20131117 ] && [ ${DATE} -lt 20140513 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20140513 ] && [ ${DATE} -lt 20141108 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20141108 ] && [ ${DATE} -lt 20150601 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20150601 ] && [ ${DATE} -lt 20151108 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			elif [ ${DATE} -gt 20151108 ] && [ ${DATE} -lt 20160601 ]; then
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
                        elif [ ${DATE} -gt 20160601 ] && [ ${DATE} -lt 20161108 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20161108 ] && [ ${DATE} -lt 20170601 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20170601 ] && [ ${DATE} -lt 20171108 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $2}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20171108 ] && [ ${DATE} -lt 20180601 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==3 {print $1}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20180601 ] && [ ${DATE} -lt 20181108 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR}/`cat ${SCRIPTDIR}/LTs.txt | awk 'NR==4 {print $2}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20181108 ] && [ ${DATE} -lt 20190601 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR2}/`cat ${SCRIPTDIR2}/LTs.txt | awk 'NR==4 {print $1}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
			elif [ ${DATE} -gt 20190601 ] && [ ${DATE} -lt 20191108 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR2}/`cat ${SCRIPTDIR2}/LTs.txt | awk 'NR==5 {print $2}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
                        elif [ ${DATE} -gt 20191108 ] && [ ${DATE} -lt 20200601 ]; then
                                ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR2}/`cat ${SCRIPTDIR2}/LTs.txt | awk 'NR==5 {print $1}'`
                                ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`
			else
				echo "Could not find appropriate date range for this run!  Assuming V6 data / ATM21..."
			        ALLLOOKUPTABLES[${i}]=${LOOKUPTABLEDIR2}/`cat ${SCRIPTDIR2}/LTs.txt | awk 'NR==5 {print $1}'`
				ALLSIZELOWERS[${i}]=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((7+var)) {print $2}'`                           
			fi
			echo "Lookup table for this run is "${ALLLOOKUPTABLES[${i}]}"."
			echo "Size cut for this run is "${ALLSIZELOWERS[${i}]}"."
			CURRENTLT=${ALLLOOKUPTABLES[${i}]}
			CURRENTSIZECUT=${ALLSIZELOWERS[${i}]}

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
			    RUNS=`echo ${RUNS} ${DAY}.${RUN}.${CURRENTSIZECUT}.${CURRENTLT}` # LT for this run now appended to the RUNS array since bash allows passing only one array.
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
			echo "`date`: Woken up, ready for the next round"
			break
		    fi
	done



    done

    #next line calls stage4 script
    
    if [[ "${RUNS}" != "" ]]; then 
	echo " ${SCRIPTDIR}/submit_stage4_5.sh ${CUTSFILESTAGE4} ${CONFIGFILESTAGE4} "SIZELOWERnowvariesbyrun..." ${SIZEUPPER} "lookuptablearray..." ${CUTSFILESTAGE5} ${CONFIGFILESTAGE5} ${SRC} ${CALIBDIR} ${FINALOUTDIRBASE} ${ROOT} ${VEGASBASE} ${DBSERVER} ${SCRIPTDIR} ${CUTBADTIMES} ${SCRATCH} ${QUEUE} ${MCNOISELVL} ${RUNS}"
	
	${SCRIPTDIR}/submit_stage4_5.sh ${CUTSFILESTAGE4} ${CONFIGFILESTAGE4} ${SIZELOWER} ${SIZEUPPER} ${ALLLOOKUPTABLES} ${CUTSFILESTAGE5} ${CONFIGFILESTAGE5} ${SRC} ${CALIBDIR} ${FINALOUTDIRBASE} ${ROOT} ${VEGASBASE} ${DBSERVER} ${SCRIPTDIR} ${CUTBADTIMES} ${SCRATCH} ${QUEUE} ${MCNOISELVL} "${RUNS}"
    fi

done #looping over MC noiselevels
