#!/bin/bash

#
#
#       This script will process several laser runs
#       naming of raw files is runnum.laser.cvbf
#


#runlist of the laser runs like a normal runlist
RUNLIST=$1
#where the output goes to
OUT=$2
#config file
STAGE1CONFIGFILE=$3


VERITASDATABASE=/nv/pc1/aotte6/veritas/raw_data/

#export ROOTSYS=/veritas_tools/root/root_v5.18
#export VEGASBASE=/veritas_tools/vegas/tmp


#COMMON FOR ALL VEGAS VERSIONS
#export PATH=$PATH:$ROOTSYS/bin
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOTSYS/lib
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VERITASBASE/lib
#export PATH=$PATH:$VEGASBASE/bin
#export VERITAS=$VERITASBASE/vegas
#export PATH=$VERITASBASE/bin:$PATH


ALLRUNS=( `cat ${RUNLIST}` )

i=0

while [ "$i" -lt "${#ALLRUNS[@]}" ]; do

#for ((i=0;i<${#ALLRUNS[@]};let "i+=4")); do

  let stop=$i+4
  for ((r=$i;r<${stop};r++)); do	    
	    
    STRING=( `echo ${ALLRUNS[${r}]//// }` )
	    
    CURRENTDAY=${STRING[ ${#STRING[@]}-2  ]}
 
    RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`

    echo "$CURRENTDAY $RUN"

    CALIBDIROUT=${OUT}/

    mkdir -p ${CALIBDIROUT}

    CALIBDIRIN=${VERITASDATABASE}/${CURRENTDAY}
  
    INPUTFILE=`echo ${CALIBDIRIN}/${RUN}.laser.cvbf`

    if [ ! -f ${CALIBDIROUT}/${RUN}.laser.root ]; then
      echo "time ${VEGAS}/bin/vaStage1  -config=${STAGE1CONFIGFILE} ${INPUTFILE} ${CALIBDIROUT}/${RUN}.laser.root"
            time ${VEGAS}/bin/vaStage1  -config=${STAGE1CONFIGFILE} ${INPUTFILE} ${CALIBDIROUT}/${RUN}.laser.root
    else 
       echo "laser run ${RUN} already processed"
    fi

    RUNS=`echo ${RUNS} ${RUN}`

  done

  RUNS=( `echo ${RUNS}` )

  cp $CALIBDIROUT/${RUNS[0]}.laser.root $CALIBDIROUT/merged.laser.root

  CURRENTDIR=`pwd`
  cd ${VEGAS}/macros/
  time root -q ${VEGAS}/macros/combineLaser.C\(\"$CALIBDIROUT/merged.laser.root\",\"$CALIBDIROUT/${RUNS[0]}.laser.root\",\"$CALIBDIROUT/${RUNS[1]}.laser.root\",\"$CALIBDIROUT/${RUNS[2]}.laser.root\",\"$CALIBDIROUT/${RUNS[3]}.laser.root\"\)
  cd ${CURRENTDIR}

RUNS=""

let "i+=4"
done
