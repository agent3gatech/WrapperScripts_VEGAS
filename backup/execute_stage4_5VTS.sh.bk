#PBS -l nodes=1:ppn=1
#PBS -l mem=4gb
#PBS -l walltime=5:00:00

#!/bin/bash

#
#
#	This script executes stage4 and stage5
#
#
#

# --- the parameters

CUTSFILESTAGE4=${arg1}
CONFIGFILESTAGE4=${arg2}
SIZELOWER=${arg3}
SIZEUPPER=${arg4}
LOOKUPTABLE=${arg5}
CUTSFILESTAGE5=${arg6}
CONFIGFILESTAGE5=${arg7}
SRC=${arg8}
CALIBDIRIN=${arg9}
FINALOUTDIR=${arg10}
RUN=${arg11}
export ROOTSYS=${arg12}
export VERITASBASE=${arg13}
DBSERVER=${arg14}
CUTBADTIMES=${arg15}
SCRATCHDIR=${arg16}
SCRIPTDIR=${arg17}
MCNOISELVL=${arg18}

# --- the environment


export PATH=~/bin:/nv/hp11/aotte6/code/VERITAS/bbftp:$PATH


# ---

echo "----------------------------------------------------------"
echo "execute_stage4_5 on `hostname`"
date
echo "Will process  run ${RUN} (${SRC})..."
echo "----------------------------------------------------------"

# ---

EXECUTE="${SCRIPTDIR}/stage4_5.sh ${CUTSFILESTAGE4} ${CONFIGFILESTAGE4} ${SIZELOWER} ${SIZEUPPER} ${LOOKUPTABLE} ${CUTSFILESTAGE5} ${CONFIGFILESTAGE5} ${SRC} ${CALIBDIRIN} ${FINALOUTDIR} ${RUN} ${ROOTSYS} ${VERITASBASE} ${DBSERVER} ${CUTBADTIMES} ${SCRATCHDIR} ${MCNOISELVL}"

echo "${EXECUTE}"
${EXECUTE}


