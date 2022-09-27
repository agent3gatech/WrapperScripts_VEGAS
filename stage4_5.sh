#!/bin/bash

#
#
#	This script executes stage4 and stage5
#
#
#

# --- the parameters

CUTSFILESTAGE4=${1}
CONFIGFILESTAGE4=${2}
SIZELOWER=${3}
SIZEUPPER=${4}
LOOKUPTABLE=${5}
CUTSFILESTAGE5=${6}
CONFIGFILESTAGE5=${7}
SRC=${8}
CALIBDIRIN=${9}
FINALOUTDIR=${10}
RUN=${11}
ROOT=${12}
VEGASBASE=${13}
DBSERVER=${14}
CUTBADTIMES=${15}
SCRATCHDIR=${16}
MCNOISELVL=${17}

if [[ "${MCNOISELVL}" == "no" ]]; then
  MCNOISELVL=""
fi
if [[ "${SRC}" == "MC" ]]; then
    MCOPTION="-G_SimulationMode=true"
else
    MCOPTION=""
fi

# --- the environment
module load ${ROOT}
export VEGASBASE=${13}
export LD_LIBRARY_PATH=$VEGASBASE/lib:$LD_LIBRARY_PATH
export PATH=$VEGASBASE/bin:$PATH

echo "${VEGASBASE}"
echo "${ROOT}"

#export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH
#export LD_LIBRARY_PATH=/nv/hp11/aotte6/code/cfitsio/lib/
# ---


SCRATCHDIR=${SCRATCHDIR}/`echo "${PBS_JOBID}" | cut -d "[" -f 2 | cut -d "]" -f "1"`
mkdir -p ${SCRATCHDIR}

echo
echo removing old file if any...
echo ---------------------------------------------------------------------------------------------------------

rm ${FINALOUTDIR}${RUN}.${SRC}${MCNOISELVL}.root
#rm ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root
rm ${SCRATCHDIR}/*

echo "Copying ${CALIBDIRIN}${RUN}.${SRC}${MCNOISELVL}.root to  ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root"
cp ${CALIBDIRIN}${RUN}.${SRC}${MCNOISELVL}.root ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root

echo "vaStage4"
echo ---------------------------------------------------------------------------------------------------------
   ARGUMENTS=" -config ${CONFIGFILESTAGE4} -cuts ${CUTSFILESTAGE4} ${MCOPTION} -OverrideLTCheck=1 -SizeLower=0/${SIZELOWER} -S4A_MaxSize=${SIZEUPPER} -table ${LOOKUPTABLE} ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root"
   #ARGUMENTS=" -config ${CONFIGFILESTAGE4} -cuts ${CUTSFILESTAGE4} ${MCOPTION} -SizeLower=0/${SIZELOWER} -S4A_MaxSize=${SIZEUPPER} -table ${LOOKUPTABLE} ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root"
   echo "${VEGASBASE}/bin/vaStage4 ${ARGUMENTS}"
#    time ${VEGASBASE}/bin/vaStage4 -config ${CONFIGFILESTAGE4} -cuts ${CUTSFILESTAGE4} ${MCOPTION} -SizeLower=0/${SIZELOWER} -S4A_MaxSize=${SIZEUPPER} -table ${LOOKUPTABLE} ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root

time ${VEGASBASE}/bin/vaStage4 ${ARGUMENTS}

EXITCODE=$?
echo EXITCODE of vaStage4 is $EXITCODE

echo "vaStage5"

echo ---------------------------------------------------------------------------------------------------------

if [[ "${SRC}" == "MC" ]]; then



  echo "No stage5 for MC, will copy files instead"
  cp ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}.root


else

    #retrieve the cut times
    CUTTIMEOPTION=""
    TIMECUTS=`mysql -h ${DBSERVER} -u readonly -D VOFFLINE --execute="SELECT time_cut_mask FROM tblRun_Analysis_Comments WHERE run_id=${RUN}" | xargs echo -n | cut -d " " -f 2`
    if [[ ${TIMECUTS} != NULL && "${CUTBADTIMES}" == "true" && ! "${SRC}" == "MC" ]]; then
         CUTTIMEOPTION="-ES_CutTimes=${TIMECUTS}"
    elif [ -e ~/timecuts/${RUN}.cuts ]; then
         TIMECUTS2=`cat ~/timecuts/${RUN}.cuts`
         CUTTIMEOPTION="-ES_CutTimes=${TIMECUTS2}"
    fi
      
    echo "Times being cut:" $CUTTIMEOPTION



    ARGUMENTS=" -cuts ${CUTSFILESTAGE5} -config ${CONFIGFILESTAGE5} ${MCOPTION} ${CUTTIMEOPTION} -Overwrite 0 -RemoveCutEvents 1  -inputFile ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root -outputFile ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}.root"
    echo  "${VEGASBASE}/bin/vaStage5 ${ARGUMENTS}"

#  time ${VEGASBASE}/bin/vaStage5 -cuts ${CUTSFILESTAGE5} -config ${CONFIGFILESTAGE5} ${MCOPTION} ${CUTTIMEOPTION} -inputFile ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root -outputFile ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}.root

time ${VEGASBASE}/bin/vaStage5 ${ARGUMENTS}
# cp ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}.root


fi


EXITCODE=$?
echo EXITCODE of vaStage5 is $EXITCODE


echo -------------------------------------------------------------------------------------------------------


echo "Cleaning up"

#rm ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}_tmp.root
mv ${SCRATCHDIR}/${RUN}.${SRC}${MCNOISELVL}.root ${FINALOUTDIR}/${RUN}.${SRC}${MCNOISELVL}.root

if [ -f ${FINALOUTDIR}/${RUN}.${SRC}${MCNOISELVL}.root ]; then
 echo "We have a stage4 and stage5 processed file of run ${RUN}"
else
 echo -e "\033[31m stage4 and stage5  processed file of run ${RUN} is not at its final destination \033[m"
fi

rm -rf ${SCRATCHDIR}
