#!/bin/bash

####################################################
# Master script that executes all VEGAS stages
# requires input file with all the necessary configurations
###########################################################

CONFIGFILE=$1

#remove empty lines and lines beginning with # in the configfile
OPTIONS=( `sed '/^$/d' ${CONFIGFILE} | sed '/^\#/d'` )

#reading in all the options
for ((i=0;i<${#OPTIONS[@]};i++)); do

NAME=`echo ${OPTIONS[$i]} | cut -d = -f 1` 
PARAMETER=`echo ${OPTIONS[$i]} | cut -d = -f 2` 

#echo "${NAME} ${PARAMETER}"

case ${NAME} in 

 "CONFIGANDCUTSDIR") CONFIGANDCUTSDIR=${PARAMETER}  ;;

 "CREATERUNLIST") CREATERUNLIST=${PARAMETER}  ;;

 "SOURCENAME") SOURCENAME=${PARAMETER}  ;;

 "DAYSTART") DAYSTART=${PARAMETER}  ;;

 "DAYSTOP") DAYSTOP=${PARAMETER}  ;;

 "MINELEVATION") MINELEVATION=${PARAMETER}  ;;

 "MAXELEVATION") MAXELEVATION=${PARAMETER}  ;;

 "RUNLIST") RUNLIST=${PARAMETER}  ;;

 "DOWNLOAD") DOWNLOAD=${PARAMETER}  ;;

 "CALIBRATEDDATADIR") CALIBRATEDDATADIR=${PARAMETER}  ;;

 "DOSTAGE12") DOSTAGE12=${PARAMETER}  ;;

 "DELETEOLDSTAGE12") DELETEOLDSTAGE12=${PARAMETER} ;;

 "STAGE1CONFIGFILE") STAGE1CONFIGFILE=${PARAMETER} ;;

 "STAGE2CONFIGFILE") STAGE2CONFIGFILE=${PARAMETER} ;;

 "QUEUE")  QUEUE=${PARAMETER} ;;

 "SCRATCH")  SCRATCH=${PARAMETER} ;;

 "ROOT")  ROOT=${PARAMETER} ;; 

 "VEGASBASE") VEGASBASE=${PARAMETER} ;;

 "DBSERVER") DBSERVER=${PARAMETER} ;;

 "SCRIPTDIR") SCRIPTDIR=${PARAMETER};;

 "VERITASDATABASEDIR") VERITASDATABASEDIR=${PARAMETER} ;;

 "DOSTAGE45RUN1")  DOSTAGE45RUN1=${PARAMETER} ;;

 "STAGE45DATADIRRUN1") STAGE45DATADIRRUN1=${PARAMETER} ;;

 "SIZELOWERRUN1") SIZELOWERRUN1=${PARAMETER} ;;

 "SIZEUPPERRUN1") SIZEUPPERRUN1=${PARAMETER} ;;

 "STAGE4CUTSFILERUN1") STAGE4CUTSFILERUN1=${PARAMETER} ;;

 "STAGE4CONFIGFILERUN1") STAGE4CONFIGFILERUN1=${PARAMETER} ;;

 "LOOKUPTABLERUN1") LOOKUPTABLERUN1=${PARAMETER} ;;

 "LOOKUPTABLEDIRRUN1") LOOKUPTABLEDIRRUN1=${PARAMETER} ;;

 "STAGE5CUTSFILERUN1") STAGE5CUTSFILERUN1=${PARAMETER} ;;

 "STAGE5CONFIGFILERUN1") STAGE5CONFIGFILERUN1=${PARAMETER} ;;

 "DELETEOLDSTAGE45RUN1") DELETEOLDSTAGE45RUN1=${PARAMETER} ;;

 "CUTBADTIMESRUN1") CUTBADTIMESRUN1=${PARAMETER} ;;

 "DOSTAGE6RUN1")  DOSTAGE6RUN1=${PARAMETER} ;; 

 "DELETEOLDSTAGE6RUN1") DELETEOLDSTAGE6RUN1=${PARAMETER} ;;

 "STAGE6CUTSFILERUN1") STAGE6CUTSFILERUN1=${PARAMETER} ;;

 "STAGE6CONFIGFILERUN1") STAGE6CONFIGFILERUN1=${PARAMETER} ;;
     
 "STAGE6DATADIRRUN1") STAGE6DATADIRRUN1=${PARAMETER} ;;

 "STAGE6OUTNAMERUN1") STAGE6OUTNAMERUN1=${PARAMETER} ;;

 "MSWRUN1") MSWRUN1=${PARAMETER} ;;

 "MSLRUN1") MSLRUN1=${PARAMETER} ;;

 "SHOWERMAXRUN1") SHOWERMAXRUN1=${PARAMETER} ;;

 "THETASQRRUN1") THETASQRRUN1=${PARAMETER} ;;
 
 "EAFILERUN1") EAFILERUN1=${PARAMETER} ;;

 "MC") MC=${PARAMETER} ;;

 "MC_CARE") MC_CARE=${PARAMETER} ;;

 "MCDIRRAW") MCDIRRAW=${PARAMETER} ;;

 "MCNOISELVL") MCNOISELVL=${PARAMETER} ;;

 "MCRUNLIST") MCRUNLIST=${PARAMETER} ;;

 "BOXCUTTYPE") BOXCUTTYPE=${PARAMETER} ;;


          *) echo -e "Boy, boy, you screwed it once more. What is ${NAME}?\nShould you be using the other MakeMeFamous?";;
esac

done

#####################################################
#####################################################

#create a runlist

#####################################################

if [ "${CREATERUNLIST}" = "true" ]; then

  echo "Will create a runlist for data taken between ${DAYSTART} and ${DAYSTOP} on ${SOURCENAME}"
  echo "Minimum elevation ${MINELEVATION} and maximum elevation ${MAXELEVATION}"
  echo "runlist will be written to file ${RUNLIST}:
        "

  ${SCRIPTDIR}/create_runlist.sh ${SOURCENAME} ${DAYSTART} ${DAYSTOP} ${MINELEVATION} ${MAXELEVATION} ${RUNLIST}

echo""
fi

#####################################################
#####################################################

#download the data

#####################################################

if [ "${DOWNLOAD}" = "true" ]; then

  echo "Will download the data runs listed in ${RUNLIST}:
        "

  ${SCRIPTDIR}/download.sh ${RUNLIST}

echo""
fi

####################################################
####################################################

#Run stage 1 and 2

####################################################

if [ "${DOSTAGE12}" = "true" ]; then

  echo "Will execute stage1 and stage2 with the following parameters:"
  echo "        RUNLIST=${RUNLIST} 
        CALIBRATEDDATADIR=${CALIBRATEDDATADIR} 
        QUEUE=${QUEUE}
        SCRATCH=${SCRATCH}
        ROOT=${ROOT} 
        VEGASBASE=${VEGASBASE} 
        VERITASDATABASEDIR=${VERITASDATABASEDIR}
        CONFIGANDCUTSDIR=${CONFIGANDCUTSDIR}
        STAGE1CONFIGFILE=${STAGE1CONFIGFILE}
        STAGE2CONFIGFILE=${STAGE2CONFIGFILE}
        DBSERVER=${DBSERVER}
        DELETEOLDSTAGE12=${DELETEOLDSTAGE12}
        MC=${MC}
        MC_CARE=${MC_CARE}
        MCDIRRAW=${MCDIRRAW} 
        MCNOISELVL=${MCNOISELVL} 
        MCRUNLIST=${MCRUNLIST}
        "
  if [[ "${DELETEOLDSTAGE12}" == "true" && ! "${MC}" = "true" ]]; then
      echo "deleting maybe existing stage1/2 output, may take a while ... "
      rm -r ${CALIBRATEDDATADIR}/d*
  elif [[ "${DELETEOLDSTAGE12}" == "true" && "${MC}" = "true" ]]; then
      echo "deleting maybe existing stage1/2 output, may take a while ... "
      rm -r ${CALIBRATEDDATADIR}/MC/*
  fi



  ${SCRIPTDIR}/prepare_stage1_2.sh ${RUNLIST}  ${CALIBRATEDDATADIR} ${CONFIGANDCUTSDIR}/${STAGE1CONFIGFILE} ${CONFIGANDCUTSDIR}/${STAGE2CONFIGFILE}  ${SCRATCH} ${QUEUE} ${ROOT} ${VEGASBASE} ${VERITASDATABASEDIR} ${SCRIPTDIR} ${DBSERVER} ${MC} ${MC_CARE} ${MCDIRRAW} ${MCNOISELVL} ${MCRUNLIST}

fi

####################################################
####################################################

#Run stage 4 and 5 RUN1

####################################################

if [ "${DOSTAGE45RUN1}" = "true" ]; then

  echo "Will execute stage4 and stage5 with the following parameters:"
  echo "        RUNLIST=${RUNLIST} 
        CALIBRATEDDATADIR=${CALIBRATEDDATADIR} 
        STAGE45DATADIRRUN1 =${STAGE45DATADIRRUN1} 
        SIZELOWERRUN1=${SIZELOWERRUN1} 
        SIZEUPPERRUN1=${SIZEUPPERRUN1} 
        CONFIGANDCUTSDIR=${CONFIGANDCUTSDIR}
        STAGE4CUTSFILERUN1=${STAGE4CUTSFILERUN1} 
        STAGE4CONFIGFILERUN1=${STAGE4CONFIGFILERUN1} 
        LOOKUPTABLERUN1=${LOOKUPTABLERUN1} 
        LOOKUPTABLEDIRRUN1=${LOOKUPTABLEDIRRUN1} 
        STAGE5CUTSFILERUN1=${STAGE5CUTSFILERUN1} 
        STAGE5CONFIGFILERUN1=${STAGE5CONFIGFILERUN1}
        QUEUE=${QUEUE}
        SCRATCH=${SCRATCH}
        ROOT=${ROOT} 
        VEGASBASE=${VEGASBASE}
        DBSERVER=${DBSERVER}
        DELETEOLDSTAGE45RUN1=${DELETEOLDSTAGE45RUN1}
        CUTBADTIMESRUN1=${CUTBADTIMESRUN1}
        MC=${MC} 
        MCNOISELVL=${MCNOISELVL} 
        MCRUNLIST=${MCRUNLIST}
        BOXCUTTYPE=${BOXCUTTYPE}
        "

  if [[ "${DELETEOLDSTAGE45RUN1}" == "true"  && ! "${MC}" == "true" ]]; then
      echo "deleting maybe existing stage4/5 output, may take a while ... "
      rm -r ${STAGE45DATADIRRUN1}/d*                                                                                                                         
  elif [[ "${DELETEOLDSTAGE45RUN1}" == "true" && "${MC}" == "true" ]]; then
      echo "deleting maybe existing stage4/5 output, may take a while ... "
      rm -r ${STAGE45DATADIRRUN1}/MC/*
  fi

  ${SCRIPTDIR}/prepare_stage4_5.sh ${RUNLIST} ${CALIBRATEDDATADIR} ${STAGE45DATADIRRUN1} ${SIZELOWERRUN1} ${SIZEUPPERRUN1} ${CONFIGANDCUTSDIR}/${STAGE4CUTSFILERUN1} ${CONFIGANDCUTSDIR}/${STAGE4CONFIGFILERUN1} ${LOOKUPTABLERUN1} ${LOOKUPTABLEDIRRUN1} ${CONFIGANDCUTSDIR}/${STAGE5CUTSFILERUN1} ${CONFIGANDCUTSDIR}/${STAGE5CONFIGFILERUN1} ${SCRATCH} ${QUEUE} ${ROOT} ${VEGASBASE} ${DBSERVER} ${SCRIPTDIR} ${CUTBADTIMESRUN1} ${MC} ${MCNOISELVL} ${MCRUNLIST} ${BOXCUTTYPE}

  fi


####################################################
####################################################

#Run stage 6 RUN1

####################################################

if [ "${DOSTAGE6RUN1}" = "true" ]; then

  echo "Will execute stage6 with the following parameters:"
  echo "        RUNLIST=${RUNLIST} 
        STAGE45DATADIRRUN1 =${STAGE45DATADIRRUN1}
        STAGE6DATADIRRUN1=${STAGE6DATADIRRUN1}
        CONFIGANDCUTSDIR=${CONFIGANDCUTSDIR}
        STAGE6CUTSFILERUN1=${STAGE6CUTSFILERUN1} 
        STAGE6CONFIGFILERUN1=${STAGE6CONFIGFILERUN1} 
        STAGE6OUTNAMERUN1=${STAGE6OUTNAMERUN1}
        MSWRUN1=${MSWRUN1}
        MSLRUN1=${MSLRUN1}
        SHOWERMAXRUN1=${SHOWERMAXRUN1}
        THETASQRRUN1=${THETASQRRUN1}
        EAFILERUN1=${EAFILERUN1}
        QUEUE=${QUEUE}
        SCRATCH=${SCRATCH}
        ROOT=${ROOT} 
        VEGASBASE=${VEGASBASE}
        DELETEOLDSTAGE6RUN1=${DELETEOLDSTAGE6RUN1}
        DBSERVER=${DBSERVER}
	BOXCUTTYPE=${BOXCUTTYPE}
        "

  if [ "${DELETEOLDSTAGE6RUN1}" = "true" ]; then
      echo "deleting maybe existing stage6 output, may take a while ... "
      rm -r ${STAGE6DATADIRRUN1}/*
  fi
  ${SCRIPTDIR}/prepare_stage6.sh ${RUNLIST} ${STAGE6OUTNAMERUN1} ${STAGE6DATADIRRUN1} ${CONFIGANDCUTSDIR}/${STAGE6CONFIGFILERUN1}  ${CONFIGANDCUTSDIR}/${STAGE6CUTSFILERUN1}  ${STAGE45DATADIRRUN1} ${MSWRUN1} ${MSLRUN1} ${SHOWERMAXRUN1} ${THETASQRRUN1} ${EAFILERUN1} ${SCRATCH} ${QUEUE} ${ROOT} ${VEGASBASE} ${DBSERVER} ${SCRIPTDIR} ${BOXCUTTYPE}

fi

#####################################################

echo " Done everything you asked me to do .... go become famous then! "
