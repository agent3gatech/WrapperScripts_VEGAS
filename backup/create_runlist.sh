#!/bin/bash

#
#
#	This scripts creates a run list searching for $SOURCE in the database between $DAYSTART and $DAYSTOP
#       DAY format is YYYYMMDD
#       The runlist is written into the file $OUTFILE and runlist.txt otherwise
#

# --- the parameters


SOURCE=$1
DAYSTART=$2
DAYSTOP=$3
MINELEVATION=$4
MAXELEVATION=$5
OUTFILE=$6

DBSERVER=romulus.ucsc.edu

if [ "${DAYSTOP}" = "" ]; then
     DAYSTOP=10000000000
fi

if [ "${DAYSTART}" = "" ]; then
     DAYSTART=0
fi

if [ "${OUTFILE}" = "" ]; then
     OUTFILE=runlist.txt
fi


rm ${OUTFILE}
touch ${OUTFILE}

SOURCE=${SOURCE//_/\ }

echo "Searching for ${SOURCE} runs between ${DAYSTART} and ${DAYSTOP}; runlist is written to ${OUTFILE}"
echo "minimum elevation ${MINELEVATION} and maximum elevation ${MAXELEVATION}"
echo "Selecting runs with 3 or more telescopes during data taking"
echo "Weather B- or better"

DAYSTRING=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select IF(data_start_time,data_start_time,'0 0')  from tblRun_Info where source_id='${SOURCE}'"` )

RUNS=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select IF(data_start_time,run_id,'0')  from tblRun_Info where source_id='${SOURCE}'"` )


for ((i=2;i<${#DAYSTRING[@]};i=i+2)); do

  if [ "${DAYSTRING[i]}" != "0"  ]; then
      YEAR=`echo ${DAYSTRING[i]} | cut -d - -f 1`
      MONTH=`echo ${DAYSTRING[i]} | cut -d - -f 2`
      DAY=`echo ${DAYSTRING[i]} | cut -d - -f 3`
      if [ "${YEAR}${MONTH}${DAY}" -ge "${DAYSTART}" -a "${YEAR}${MONTH}${DAY}" -le "${DAYSTOP}" ]; then

         ELEVATION=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select AVG(DEGREES(t1.elevation_target)) from tblPositioner_Telescope1_Status AS t1, tblRun_Info as t2 where t2.run_id='${RUNS[i/2]}' AND (t1.timestamp > (t2.data_start_time+0)*1000 AND t1.timestamp < (t2.data_end_time+0)*1000)"` )
         gtminelevation=`echo "${ELEVATION[1]} > ${MINELEVATION}" | bc`
         ltmaxelevation=`echo "${ELEVATION[1]} < ${MAXELEVATION}" | bc`
         STATUS=( `mysql -h ${DBSERVER} -u readonly -D VOFFLINE --execute="select STATUS from tblRun_Analysis_Comments where run_id='${RUNS[i/2]}'"` )
         WEATHER=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select WEATHER from tblRun_Info where run_id='${RUNS[i/2]}'"` )
         CONFIGMASK=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select CONFIG_MASK from tblRun_Info where run_id='${RUNS[i/2]}'"` )
	   echo  "${YEAR}${MONTH}${DAY}  ${RUNS[i/2]} ${STATUS[1]} ${WEATHER[1]} ${CONFIGMASK[1]} ${ELEVATION[1]}"
         if [[ ("${STATUS[1]}" = "good_run" || "${STATUS[1]}" = "needs_adjustments") && ${gtminelevation} && ${ltmaxelevation} ]]; then
	   if [ ${CONFIGMASK[1]} -eq 15 -o ${CONFIGMASK[1]} -eq 14 -o ${CONFIGMASK[1]} -eq 14 -o ${CONFIGMASK[1]} -eq 13 -o ${CONFIGMASK[1]} -eq 11 -o ${CONFIGMASK[1]} -eq 7 ]; then
	   if [[ "${WEATHER[1]}" < "C" ]]; then
             echo  "selected"
	     echo "/d${YEAR}${MONTH}${DAY}/${RUNS[i/2]} " >> ${OUTFILE}
           fi
           fi
         fi
      fi
  fi

done
echo  "runlist written, have fun!"
