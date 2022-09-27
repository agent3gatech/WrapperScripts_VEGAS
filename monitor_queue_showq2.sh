#!/bin/bash

#
#
#       This script monitors the batch queue and submits jobs that
#       have been put on hold
#

MAXJOBSRUNNING=40

cd $HOME/data/veritas/log
today=`date +"%Y%m%d"`
here=`hostname -s`
Filout=$here.$today
inter=60
#
while [ 1 = 1 ]
do
  #echo `hostname -s` `date +"%Y%m%d %T"`

#  not_array_running=`showq -u $USER | egrep "Idle|Running" | egrep -v "\(|\)" | wc -l`
#  array_running=0;
#  for X in `showq -u $USER | egrep "Idle|Running" | egrep -o '\([[:alnum:]]*?\)'| sed 's/[()]//g'`; do
#        array_running=`echo "$array_running + $X" | bc`;
#        echo $X
#  done
#  running=`echo "$not_array_running + $array_running" | bc`;
#  echo "$not_array_running + $array_running"

  running=`qstat | grep VTS | grep " R " | wc -l`
  echo "Jobs running: ${running}"

  runs=( )

  if [ ${running} -lt ${MAXJOBSRUNNING} -a "$?" = "0"  ]; then
            #runs=( `qstat | grep VTS | grep $USER | grep H | cut -d ' ' -f 1` )

            #not_array_runs=( `showq -u $USER -b | egrep -v "\(|\)" | cut -d ' ' -f 1` )
	    #array_runs=0;
  	    #for X in `showq -u $USER -b | egrep "\(|\)" | cut -d" " -f1| sed 's/.*(\([0-9]*\))/\1/g'`; do
  	    for X in `showq -u $USER -b | egrep "\(|\)" | cut -d"(" -f1`; do
        	runs=("${runs[@]}" "$X" );
  	    done
  
	    # runs=`echo "$not_array_runs + $array_runs" | bc`;
            echo "${runs}"
            if [ "${runs}" != "" ]; then
              echo "${MAXJOBSRUNNING}-${running} ${#runs[@]}"
              DIFF=$[ ${MAXJOBSRUNNING}-${running} ]
               
              if [ ${#runs[@]} -lt ${DIFF} ]; then
                   DIFF=$[ ${#runs[@]} ]
              fi
              #DIFF=$[ ${DIFF}-1 ] 
              echo "${DIFF}"
              #echo "mjobctl -u ${runs[@]:0:${DIFF}}"
              #mjobctl -u ${runs[@]:0:${DIFF}}
              #for J in ${runs[@]}; do
              for (( J=0; J<${DIFF}; J++ )); do
                echo "mjobctl -u ${runs[$J]}"
                mjobctl -u ${runs[$J]}
              done
              # ${runs[@]:0:${DIFF}}
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
