#!/bin/bash

RUNLIST=$1
FILES=( `cat ${RUNLIST}` )

BASEDIR=/nv/pc5/vhe/VERITAS/raw_data
UCLAHOST=gamma1.astro.ucla.edu
UCLABASEDIR=/veritas/data
BBFTPOPTIONS="-u bbftp -p 12 -m -S -V -e "

#DISKS=( vhe0a vhe0b vhe0c vhe0d vhe1a vhe1b vhe1c vhe1d vhe2a vhe2b vhe2c vhe2d vhe3a vhe3b vhe3c vhe3d vhe4a vhe4b vhe4c vhe4d vhe4e vhe4f vhe4g vhe4h ) 

#if [ "`hostname`" = "vhe0.ucsc.edu" ]; then
#    DISKSREAL=( mnt/disk2 mnt/disk3 mnt/disk4 vhe1a vhe1b vhe1c vhe1d vhe2a vhe2b vhe2c vhe2d vhe3a vhe3b vhe3c vhe3d )
#else
#    DISKSREAL=( vhe0a vhe0b vhe0c vhe0d vhe1a vhe1b vhe1c vhe1d vhe2a vhe2b vhe2c vhe2d vhe3a vhe3b vhe3c vhe3d vhe4a vhe4b vhe4c vhe4d vhe4e vhe4f vhe4g vhe4h ) 
#fi

DBSERVER=romulus.ucsc.edu

for ((i=0;i<${#FILES[@]};i++)); do

 STRING=( `echo ${FILES[${i}]//// }` )

 DAY=${STRING[ ${#STRING[@]}-2  ]}

 RUN=`echo ${STRING[ ${#STRING[@]}-1  ]} | cut -d . -f 1`

 SOURCE=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select source_id from tblRun_Info where run_id=${RUN}"  | xargs echo -n  | cut -d " " -f 2-`
 SOURCE=${SOURCE// /_}
 SOURCE=${SOURCE////_}

 GROUPID=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select t1.group_id from tblRun_Group as t1, tblRun_GroupComment as t2 where t1.run_id="${RUN}" and t1.group_id=t2.group_id and t2.group_type='laser' " | xargs echo -n  | cut -d " " -f 2`

 if [ "${GROUPID}" = "-1" ]
     then
     echo "Ups, no group specified for run ${RUN} in the database"
     LASERRUN=""
 else 
     LASERRUN=`mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select t2.run_id from tblRun_Group as t1, tblRun_Info as t2 where t1.group_id="${GROUPID}" and t1.run_id=t2.run_id and (t2.run_type='flasher' or t2.run_type='laser')"  | xargs echo -n  | cut -d " " -f 2`
 fi 

 if [ -z "${LASERRUN}" ]; then
      echo -e "\033[31m Attention, no laserrun for run ${RUN} in the database \033[m"
 fi

 echo "Run: ${RUN}, day: ${DAY}, source_id: ${SOURCE},  group_id: ${GROUPID}, laserrun: ${LASERRUN}"

 #getting serious about the run download or not to download?
 
 FILEUCLA=${UCLABASEDIR}/${DAY}/${RUN}.cvbf 

 FILELOCAL=${BASEDIR}/${DAY}/${RUN}.${SOURCE}.cvbf

 if [ -f ${FILELOCAL} ] 
     then 
     echo -e "\033[32m run is already in paradise \033[m"
     if  [ ! -f ${FILELOCAL} ]; then
		echo -e "\033[31m But link does not point to an existing file \033[m"
		echo -e "\033[31m ${FILELOCAL} \033[m"
	    fi
 else 
     echo "run is not yet in paradise"
  
     echo "I check if a directory for day ${DAY} exists"
     if [ -e ${BASEDIR}/${DAY} ]
	 then 
	 echo "Yes it does"
     else
          mkdir -p ${BASEDIR}/${DAY}/
chmod ug+w ${BASEDIR}/${DAY}/.
     fi
 
 #    echo "Let's figure out where we will put the run"
 #     DISKNUMBER=$[ (${RUN}-1) % ${#DISKS[@]} ]
 #     SPACEONDISK=0
 #     ITERATION=0
 #     MAXITERATIONS=$[ ${#DISKS[@]}+1 ]
 #     #if diskspace is less then 100GB search next disks
 #     while [ ${SPACEONDISK} -lt 100000000 -a ${ITERATION} -lt ${MAXITERATIONS} ]; do
#	  DISKNUMBER=$[ (${DISKNUMBER}+1) % ${#DISKS[@]}  ]
#          DISK=${DISKS[ ${DISKNUMBER} ]}
#          DISKREAL=${DISKSREAL[ ${DISKNUMBER} ]}
#	  CHECKDISK=( `df | grep  ${DISKREAL}` )
#	  SPACEONDISK=${CHECKDISK[ ${#CHECKDISK[@]}-3 ]}
#          echo "Space on disk ${DISKREAL} is ${SPACEONDISK}"
#          ITERATION=$[ ${ITERATION}+1 ]
#      done

 #     if [ ${ITERATION} -eq ${MAXITERATIONS} ]; then
#	  echo -e "\033[31m All Disks are full. Please write David an email that we need more disk space\033[m"
#	  exit
#      fi

 #     echo "Run ${RUN} will go to disk ${DISK}"
 #     MACHINE=`echo "${DISK}" | cut -b-4` 
 #     FINALDIRTRUE=/data_disks/${DISK}/data/raw/${DAY}
      FINALDIRTRUE=${BASEDIR}/${DAY}
      mkdir -p ${FINALDIRTRUE}
      chmod ug+w ${FINALDIRTRUE}
      chmod ug+w ${FINALDIRTRUE}/.

      echo "Download run ${RUN} ..."
      echo "bbftp ${BBFTPOPTIONS} \"mget ${FILEUCLA} ${FINALDIRTRUE}/ \" $UCLAHOST"
      #ssh  ${MACHINE} "(bbftp ${BBFTPOPTIONS} \"mget ${FILEUCLA} ${FINALDIRTRUE}/\" $UCLAHOST)"
      bbftp ${BBFTPOPTIONS} "mget ${FILEUCLA} ${FINALDIRTRUE}/" $UCLAHOST

    #inserting the source name into the filename
    mv ${FINALDIRTRUE}/${RUN}.cvbf ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf
    chmod ug+w ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf
    #if [ -f ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf ]; then
    #	ln -s ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf ${BASEDIR}/${DAY}/
    #fi

    #if [ -f ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf -a -h ${BASEDIR}/${DAY}/${RUN}.${SOURCE}.cvbf ]; then
    if [ -f ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf ]; then
      echo -e "\033[32m run has safely arrived in paradise \033[m"
      echo -e "\033[32m it is in ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf \033[m"
   #   echo -e "\033[32m the link is ${BASEDIR}/${DAY}/${RUN}.${SOURCE}.cvbf \033[m"
    else
      echo -e "\033[31m BAD, run has not arrived in paradise \033[m"
      echo -e "\033[31m Check if it is where it is supposed to be \033[m"
      echo -e "\033[31m ${FINALDIRTRUE}/${RUN}.${SOURCE}.cvbf \033[m"
    #  echo -e "\033[31m and the link ${BASEDIR}/${DAY}/${RUN}.${SOURCE}.cvbf \033[m"
    fi
 fi

  #now the laserrun the laserrun
  if [ -z "${LASERRUN}" ]
    then
     echo -e "\033[31m Sorry can not download the laserrun automatically, guess we have figured that out already earlier :( \033[m"
    else
      if [ "${LASERRUN}" = "${RUN}" ]
      then
        echo "run and laserrun are the same :)  ${LASERRUN} ${RUN}"
      else 
        if  [ -f ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf ]; then
	    echo -e "\033[32m Laser file is already in town \033[m"
	    #if  [ ! -f ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf ]; then
	    #	echo -e "\033[31m But link does not point to an existing file \033[m"
	    #	echo -e "\033[31m ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf \033[m"
	    #fi
        else
     #       #need to find a disk for the laser run in the same way we did for the data run
     #	    echo "Let's figure out where we will put the laser run"
	#    DISKNUMBER=$[ (${LASERRUN}-1) % ${#DISKS[@]} ]
        #    SPACEONDISK=0
	#    ITERATION=0
	#    MAXITERATIONS=$[ ${#DISKS[@]}+1 ]
        #    #if diskspace is less then 100GB search next disks
	#    while [ ${SPACEONDISK} -lt 100000000 -a ${ITERATION} -lt ${MAXITERATIONS} ]; do
	#	DISKNUMBER=$[ (${DISKNUMBER}+1) % ${#DISKS[@]}  ]
	#	DISK=${DISKS[ ${DISKNUMBER} ]}
	#	DISKREAL=${DISKSREAL[ ${DISKNUMBER} ]}
	#	CHECKDISK=( `df | grep  ${DISKREAL}` )
	#	SPACEONDISK=${CHECKDISK[ ${#CHECKDISK[@]}-3 ]}
	#	echo "Space on disk ${DISKREAL} is ${SPACEONDISK}"
	#	ITERATION=$[ ${ITERATION}+1 ]
	#   done

	#    if [ ${ITERATION} -eq ${MAXITERATIONS} ]; then
	#	echo -e "\033[31m All Disks are full. Please write David an email that we need more disk space\033[m"
	#	exit
	#    fi

	    DAYSTRING=( `mysql -h ${DBSERVER} -u readonly -D VERITAS --execute="select IF(data_start_time,data_start_time,'0 0')  from tblRun_Info where run_id=${LASERRUN}"` )

	    for ((n=2;n<${#DAYSTRING[@]};n=n+2)); do
	       if [ "${DAYSTRING[n]}" != "0"  ]; then
		    YEAR=`echo ${DAYSTRING[n]} | cut -d - -f 1`
		    MONTH=`echo ${DAYSTRING[n]} | cut -d - -f 2`
		    DAYUCLA=`echo ${DAYSTRING[n]} | cut -d - -f 3`
		    DAYUCLA=d${YEAR}${MONTH}${DAYUCLA}
	       fi	       
	    done


	 #   echo "Laserrun ${LASERRUN} will go to disk ${DISK}"
 
	  #  FINALDIRTRUE=/data_disks/${DISK}/data/raw/${DAY}
	    FINALDIRTRUE=${BASEDIR}/${DAY}
	    mkdir -p ${FINALDIRTRUE}
	    chmod ug+w ${FINALDIRTRUE}/.
	    echo "Download laserrun ${LASERRUN} ..."
	    echo "bbftp ${BBFTPOPTIONS} \"mget ${UCLABASEDIR}/${DAYUCLA}/${LASERRUN}.cvbf ${FINALDIRTRUE}/ \" $UCLAHOST"
	    bbftp ${BBFTPOPTIONS} "mget  ${UCLABASEDIR}/${DAYUCLA}/${LASERRUN}.cvbf ${FINALDIRTRUE}/" $UCLAHOST
	    mv ${FINALDIRTRUE}/${LASERRUN}.cvbf ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf
 chmod ug+w ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf
	    #if [ -f ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf ]; then
	    #	ln -s ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf ${BASEDIR}/${DAY}/
	    #fi

	    #if [ -f ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf -a -h ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf ]; then
	    if [ -f ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf ]; then
		echo -e "\033[32m laserrun ${LASERRUN} has safely arrived in paradise \033[m"
		echo -e "\033[32m it is in ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf \033[m"
	#	echo -e "\033[32m the link is ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf \033[m"
	    else
		echo -e "\033[31m laserrun ${LASERRUN} has not arrived in paradise.... BAD \033[m" 
		echo -e "\033[31m Check if it is where it is supposed to be \033[m"
		echo -e "\033[31m ${FINALDIRTRUE}/${LASERRUN}.laser.cvbf \033[m"
	#	echo -e "\033[31m and the link ${BASEDIR}/${DAY}/${LASERRUN}.laser.cvbf \033[m"
	    fi
	fi
      fi
  fi
  echo " "

done

echo "finished for now, bye"
