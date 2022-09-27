#!/bin/bash

#
#
#       This script monitors the batch queue and submits jobs that
#       have been put on hold
#

MAXJOBSRUNNING=48

cd $HOME/data/veritas/log
today=`date +"%Y%m%d"`
here=`hostname -s`
Filout=$here.$today
inter=600
#
while [ 1 = 1 ]
do
  #echo `hostname -s` `date +"%Y%m%d %T"`
  running=`qstat | grep VTS | egrep -e 'R|Q' | wc -l`
  if [ ${running} -lt ${MAXJOBSRUNNING} -a "$?" = "0"  ]; then
            runs=( `qstat | grep VTS | grep $USER | grep H | cut -d ' ' -f 1` )
            if [ "${runs}" != "" ]; then

              DIFF=$[ ${MAXJOBSRUNNING}-${running} ]
              if [ ${#runs[@]} -lt ${DIFF} ]; then
                   DIFF=$[ ${#runs[@]} ]
              fi
              #DIFF=$[ ${DIFF}-1 ] 
              echo "${DIFF}"
              echo "qrls ${runs[@]:0:${DIFF}}"
              qrls ${runs[@]:0:${DIFF}}
              if [ "$?" = "0" ]; then
                   echo "`date`: Added new job ${runs} to queue ...." >>$Filout
              fi
            fi                  
  fi
  sleep $inter
  newday=`date +"%Y%m%d"`
  if [ "$today" != "$newday" ]
  then
   today=$newday
   Filout=$here.$today
  fi
done
