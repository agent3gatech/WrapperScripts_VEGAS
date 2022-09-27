#!/bin/bash

# Called by MakeMeFamous.sh

RUNLIST=$1
STAGE6OUTNAME=$2
OUTDIR=$3
CONFIGFILE=$4
CUTSFILE=$5
DATADIR=$6
SCRATCH=${12} 
QUEUE=${13}
ROOT=${14}
VEGASBASE=${15}
DBSERVER=${16}
SCRIPTDIR=${17}
BOXCUTTYPE=${18}

#################################################


ALLRUNS=( `cat ${RUNLIST} | sort` ) # We must now pipe the runlist into sort because out-of-order runlists break this whole damn thing.

mkdir -p ${OUTDIR}

RUNLIST=${OUTDIR}/${STAGE6OUTNAME}_runlist.txt
rm ${RUNLIST}
touch ${RUNLIST}

# Read in all cut values from CUTS.txt in the SCRIPTDIR.
CUTVAL=0 # Will keep track of whether we want to use SOFT=0, MED=1, or HARD=2 cuts.
if [ ${BOXCUTTYPE} == "SOFT"  ]; then
    echo "Preparing stage6 for SOFT cuts!"
    CUTVAL=0
elif [ ${BOXCUTTYPE} == "MEDIUM"  ] || [ ${BOXCUTTYPE} == "MODERATE"  ]; then
    echo "Preparing stage6 for MEDIUM cuts!"
    CUTVAL=1
elif [ ${BOXCUTTYPE} == "HARD"  ]; then
    echo "Preparing stage6 for HARD cuts!"
    CUTVAL=2
else
    echo "You goofed.  What BOXCUTTYPE are you using?  SOFT, MEDIUM, or HARD?  This is the easy part."
    exit
fi
V4_MSW=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((2+var)) {print $4}'`       
V4_MSL=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((2+var)) {print $6}'`
V4_SHOWERMAXFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((2+var)) {print $7}'`
V4_RINGSIZE=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((2+var)) {print $8}'`
V4_THETASQRFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((2+var)) {print $9}'`
V5_MSW=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((5+var)) {print $4}'`        
V5_MSL=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((5+var)) {print $6}'`
V5_SHOWERMAXFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((5+var)) {print $7}'`
V5_RINGSIZE=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((5+var)) {print $8}'`
V5_THETASQRFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((5+var)) {print $9}'`
V6_MSW=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((8+var)) {print $4}'`
V6_MSL=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((8+var)) {print $6}'`
V6_SHOWERMAXFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((8+var)) {print $7}'`
V6_RINGSIZE=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((8+var)) {print $8}'`
V6_THETASQRFLOAT=`cat ${SCRIPTDIR}/CUTS.txt | awk -v var="$CUTVAL" 'NR==((8+var)) {print $9}'`
echo "Done setting up all of the cuts for your cut type."

#fill array with control 

STAGE4RD=""
for ((i=0;i<${#ALLRUNS[@]};i++)); do
	STAGE4RD=`echo "${STAGE4RD} 0"`
done
STAGE4RD=( `echo "${STAGE4RD}"` )
echo "Done filling blank array."


ALLINSTAGE45=0

ID=0  # This is the run group ID that will be incremented when a new group is detected.
VTSEPOCH=""  # Keeps track of the current epoch (configuration) of VERITAS.
PREVEPOCH="" # This will keep track of the prev epoch.
while [ ${ALLINSTAGE45} == "0" ]; do
  TOTALNUMRUNS=${#ALLRUNS[@]}
  for ((i=0;i<${TOTALNUMRUNS};i++)); do
     ATM21=0 # Flag for which atmospheric model we need.
     ATM22=0 
     STRING=( `echo ${ALLRUNS[${i}]//// }` )

     DAY=${STRING[ ${#STRING[@]}-2  ]}
     DATE=`echo ${DAY} | cut -d d -f 2` # Gets the date without the "d" letter at the beginning; just an int date.
     RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1` # Just the run number by itself

     SRC=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUN}"  | xargs echo -n  | cut -d " " -f 2-`
     SRC=${SRC// /_}
     SRC=${SRC////_}

     if [ -f  ${DATADIR}/${DAY}/${RUN}.${SRC}*.root ]; then
	 echo "I found a stage4 and stage5 processed file ${DATADIR}/${DAY}/${RUN}.${SRC}.root"

	# Determine whether to use ATM21 or ATM22 effective area:
    	if [ ${DATE} -lt 20070604 ]; then
		ATM21=1
        elif [ ${DATE} -gt 20070604 ] && [ ${DATE} -lt 20071124 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20071124 ] && [ ${DATE} -lt 20080519 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20080519 ] && [ ${DATE} -lt 20081112 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20081112 ] && [ ${DATE} -lt 20090606 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20090606 ] && [ ${DATE} -lt 20090801 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20090801 ] && [ ${DATE} -lt 20091102 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20091102 ] && [ ${DATE} -lt 20100527 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20100527 ] && [ ${DATE} -lt 20101120 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20101120 ] && [ ${DATE} -lt 20110516 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20110516 ] && [ ${DATE} -lt 20111110 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20111110 ] && [ ${DATE} -lt 20120505 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20120505 ] && [ ${DATE} -lt 20120801 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20120801 ] && [ ${DATE} -lt 20121029 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20121029 ] && [ ${DATE} -lt 20130523 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20130523 ] && [ ${DATE} -lt 20131117 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20131117 ] && [ ${DATE} -lt 20140513 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20140513 ] && [ ${DATE} -lt 20141108 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20141108 ] && [ ${DATE} -lt 20150601 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20150601 ] && [ ${DATE} -lt 20151108 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20151108 ] && [ ${DATE} -lt 20160601 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20160601 ] && [ ${DATE} -lt 20161108 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20161108 ] && [ ${DATE} -lt 20170601 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20170601 ] && [ ${DATE} -lt 20171108 ]; then
		ATM22=1
        elif [ ${DATE} -ge 20171108 ] && [ ${DATE} -lt 20180601 ]; then
		ATM21=1
        elif [ ${DATE} -ge 20180601 ] && [ ${DATE} -lt 20181108 ]; then
                ATM22=1
        elif [ ${DATE} -ge 20181108 ] && [ ${DATE} -lt 20190601 ]; then
                ATM21=1
	elif [ ${DATE} -ge 20190601 ] && [ ${DATE} -lt 20191108 ]; then
                ATM22=1
	elif [ ${DATE} -ge 20191108 ] && [ ${DATE} -lt 20200601 ]; then
                ATM21=1


        else
	        echo "Could not find appropriate date range for this run!  Exiting..."
		exit
	fi

	# Set up a flag to use in awk for grabbing the correct atmosphere column in EAs.txt
	if [ ${ATM22} == "1" ]; then
		ATM_COLUMNFLAG=2
	else
		ATM_COLUMNFLAG=1
	fi

	# Figure out the VERITAS configuration for this run and select the effective area:
	if [ ${DATE} -lt 20090801 ]; then
		echo "This run looks to be V4 data..."
		VTSEPOCH="V4"
		CURRENT_EA=`cat ${SCRIPTDIR}/EAs.txt | awk -v var="$CUTVAL" -v column="$ATM_COLUMNFLAG" 'NR==((1+var)) {print $column}'`
	elif [ ${DATE} -gt 20090801 ] && [ ${DATE} -lt 20120801 ]; then
		echo "This run looks to be V5 data..."
		VTSEPOCH="V5"
		CURRENT_EA=`cat ${SCRIPTDIR}/EAs.txt | awk -v var="$CUTVAL" -v column="$ATM_COLUMNFLAG" 'NR==((4+var)) {print $column}'`
	elif [ ${DATE} -gt 20190601 ] && [ ${DATE} -lt 20191108 ]; then
		echo "This run looks to be V6 data..."
		VTSEPOCH="V6"
		CURRENT_EA=`cat ${SCRIPTDIR}/EAs.txt | awk -v var="$CUTVAL" -v column="$ATM_COLUMNFLAG" 'NR==((7+var)) {print $column}'`
	elif [ ${DATE} -gt 20191108 ]; then
                echo "This run looks to be V6 data..."
                VTSEPOCH="V6"
                CURRENT_EA=`cat ${SCRIPTDIR}/EAs.txt | awk -v var="$CUTVAL" -v column="$ATM_COLUMNFLAG" 'NR==((10+var)) {print $column}'`
	else
		echo "Could not find an appropriate VERITAS configuration (V4, V5, or V6) for this run's date!  Exiting..."
		exit
	fi
	

	# Let's generate our Stage 6 runlist now:
	# For runlists with only one run

#                      echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST} 
#                       echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
#                       echo "MeanScaledWidthUpper ${V6_MSW}" >> ${RUNLIST}
#                       echo "MeanScaledLengthUpper ${V6_MSL}" >> ${RUNLIST}
#                       echo "MaxHeightLower ${V6_SHOWERMAXFLOAT}" >> ${RUNLIST}
#                       echo "S6A_RingSize ${V6_RINGSIZE}" >> ${RUNLIST}
#                       echo "RBM_SearchWindowSqCut ${V6_THETASQRFLOAT}" >> ${RUNLIST}
#                       echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
#                       echo "[EA ID: ${ID}]" >> ${RUNLIST}
#                       echo "${CURRENT_EA}" >> ${RUNLIST}
#                       echo "[/EA ID: ${ID}]" >> ${RUNLIST}

	# For all other runlists with more than one run 
	if [ "$i" -eq "0" ]; then  # First line of our runlist text file should always be a run.
		if [ ${STAGE4RD[${i}]} == "0" ]; then
	    	echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST} # Add the full path to our stage45 run to the runlist for stage6.
			if [ ${#ALLRUNS[@]} == "1" ]; then
		
			                        echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
	                       			echo "MeanScaledWidthUpper ${V6_MSW}" >> ${RUNLIST}
                     				echo "MeanScaledLengthUpper ${V6_MSL}" >> ${RUNLIST}
      				                echo "MaxHeightLower ${V6_SHOWERMAXFLOAT}" >> ${RUNLIST}
                      				echo "S6A_RingSize ${V6_RINGSIZE}" >> ${RUNLIST}
                			        echo "RBM_SearchWindowSqCut ${V6_THETASQRFLOAT}" >> ${RUNLIST}
                    			        echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
                   				echo "[EA ID: ${ID}]" >> ${RUNLIST}
        	               			echo "${CURRENT_EA}" >> ${RUNLIST}
                   				echo "[/EA ID: ${ID}]" >> ${RUNLIST}

			fi		

		fi
	elif [ ${i} -eq $((TOTALNUMRUNS-1)) ]; then # Here on the final Run, we need to add in the EA ID and CONFIG ID stuff 
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		else
			echo "Multiple configurations not detected for this runlist."
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		if [ ${VTSEPOCH} == "V4" ]; then
			echo "MeanScaledWidthUpper ${V4_MSW}" >> ${RUNLIST}
			echo "MeanScaledLengthUpper ${V4_MSL}" >> ${RUNLIST}
			echo "MaxHeightLower ${V4_SHOWERMAXFLOAT}" >> ${RUNLIST}
			echo "S6A_RingSize ${V4_RINGSIZE}" >> ${RUNLIST}
			echo "RBM_SearchWindowSqCut ${V4_THETASQRFLOAT}" >> ${RUNLIST}
		elif [ ${VTSEPOCH} == "V5" ]; then
			echo "MeanScaledWidthUpper ${V5_MSW}" >> ${RUNLIST}
			echo "MeanScaledLengthUpper ${V5_MSL}" >> ${RUNLIST}
			echo "MaxHeightLower ${V5_SHOWERMAXFLOAT}" >> ${RUNLIST}
			echo "S6A_RingSize ${V5_RINGSIZE}" >> ${RUNLIST}
			echo "RBM_SearchWindowSqCut ${V5_THETASQRFLOAT}" >> ${RUNLIST}
		else
			echo "MeanScaledWidthUpper ${V6_MSW}" >> ${RUNLIST}
			echo "MeanScaledLengthUpper ${V6_MSL}" >> ${RUNLIST}
			echo "MaxHeightLower ${V6_SHOWERMAXFLOAT}" >> ${RUNLIST}
			echo "S6A_RingSize ${V6_RINGSIZE}" >> ${RUNLIST}
			echo "RBM_SearchWindowSqCut ${V6_THETASQRFLOAT}" >> ${RUNLIST}
		fi
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${CURRENT_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
	elif [ ${PREVEPOCH} == "V4" ] && [ ${VTSEPOCH} == "V5" ]; then
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V4_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V4_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V4_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V4_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V4_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	elif [ ${PREVEPOCH} == "V4" ] && [ ${VTSEPOCH} == "V6" ]; then
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V4_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V4_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V4_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V4_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V4_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	elif [ ${PREVEPOCH} == "V5" ] && [ ${VTSEPOCH} == "V6" ]; then
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V5_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V5_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V5_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V5_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V5_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	elif [ ${CURRENT_EA} != ${PREV_EA} ] && [ ${PREVEPOCH} == "V4" ]; then  # Here we do checks to see if we need a new config group for atmosphere change.
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V4_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V4_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V4_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V4_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V4_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	elif [ ${CURRENT_EA} != ${PREV_EA} ] && [ ${PREVEPOCH} == "V5" ]; then
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V5_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V5_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V5_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V5_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V5_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
	elif [ ${CURRENT_EA} != ${PREV_EA} ] && [ ${PREVEPOCH} == "V6" ]; then
		if [ ${ID} -ne "0" ]; then
			echo "[/RUNLIST ID: ${ID}]" >> ${RUNLIST}
		fi
		echo "[CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "MeanScaledWidthUpper ${V6_MSW}" >> ${RUNLIST}
		echo "MeanScaledLengthUpper ${V6_MSL}" >> ${RUNLIST}
		echo "MaxHeightLower ${V6_SHOWERMAXFLOAT}" >> ${RUNLIST}
		echo "S6A_RingSize ${V6_RINGSIZE}" >> ${RUNLIST}
		echo "RBM_SearchWindowSqCut ${V6_THETASQRFLOAT}" >> ${RUNLIST}
		echo "[/CONFIG ID: ${ID}]" >> ${RUNLIST}
		echo "[EA ID: ${ID}]" >> ${RUNLIST}
		echo "${PREV_EA}" >> ${RUNLIST}
		echo "[/EA ID: ${ID}]" >> ${RUNLIST}
		ID=$((ID+1))
		echo "[RUNLIST ID: ${ID}]" >> ${RUNLIST}
		echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST}
		
	else
		if [ ${STAGE4RD[${i}]} == "0" ]; then
                	echo "`ls ${DATADIR}/${DAY}/${RUN}.${SRC}*.root`" >> ${RUNLIST} # Add the full path to our stage45 run to the runlist for stage6.
                fi
	fi
	PREVDATE=${DATE} # Used to keep track of the previous date for comparing in case of need to change IDs.
	PREVEPOCH=${VTSEPOCH}
	PREV_EA=${CURRENT_EA} 

	STAGE4RD[${i}]=1

     else
          echo "I could not find a stage4 and stage5 processed file for run ${DATADIR}/${DAY}/${RUN}.${SRC}.root! "
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

echo "Done looping over the wait loop..."

done
                             

    # Commented the below lines out since we no longer can use one value for MSW, MSL, etc. for naming purposes...
    #SHOWERMAX=$(echo "${SHOWERMAXFLOAT}*100" | bc -l | cut -d . -f1)
    #MSW=$(echo "${MSWFLOAT}*100" | bc -l | cut -d . -f1)
    #MSL=$(echo "${MSLFLOAT}*100" | bc -l | cut -d . -f1)
    #THETASQR=$(echo "${THETASQRFLOAT}*1000" | bc -l | cut -d . -f1)

    #OUTFILEBASE=Stage6_${STAGE6OUTNAME}_SHOWERMAX${SHOWERMAX}_MSW${MSW}_MSL${MSL}_THETASQR${THETASQR}
    OUTFILEBASE=Stage6_${STAGE6OUTNAME}

    EXECUTABLE=${SCRIPTDIR}/execute_stage6VTS.sh


    ARGUMENTS=" -q ${QUEUE}  -d ${OUTDIR} -v arg1=${RUNLIST},arg2=${OUTDIR},arg3=${CONFIGFILE},arg4=${CUTSFILE},arg5=${OUTFILEBASE},arg6=${SCRATCH},arg7=${ROOT},arg8=${VEGASBASE},arg9=${SCRIPTDIR} ${EXECUTABLE}"

          echo "qsub ${ARGUMENTS}"

          qsub ${ARGUMENTS}

          while [ "$?" != "0" ]
            do
              sleep 5
             qsub ${ARGUMENTS}
         done
  
echo ---------------------------------------------------------------------------------------------------------
echo Stage6 JOB SUBMITTED. Have a lot of fun!

