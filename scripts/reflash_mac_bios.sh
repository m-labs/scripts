#!/bin/bash

# version of me
__VERSION__="2011-05-21"

BASE_URL_HTTP="http://www.milkymist.org/snapshots"
VERSION="latest"
WORKING_DIR="${HOME}/.qi/milkymist/bios/${VERSION}"

FJMEM="fjmem.bit"
BIOS_RESCUE="bios-rescue.bin"

HEAD_TMP="head.tmp"
MAC_TMP="mac.tmp"
REMAIN_TMP="remain.tmp"
BIOS_RESCUE_MAC="bios.$1$2.bin"

###################################################################
if [ $# != 2 ]; then
    echo "Usage:"
    echo "      $0" "00" "17" 
    echo "      \$1 \$2 is the last two mac address with Hexadecimal"
    exit 1
fi

mkdir -p ${WORKING_DIR}

MD5SUMS_SERVER=$(\
    wget -O - ${BASE_URL_HTTP}/${VERSION}/md5sums 2> /dev/null | \
    grep -E "(${FJMEM}|${BIOS_RESCUE})" | sort)

if [ "${MD5SUMS_SERVER}" == "" ]; then
    echo "ERROR: can't fetch files from server"
    exit 1
fi

MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}" ; \
    md5sum --binary ${FJMEM} ${BIOS_RESCUE} 2> /dev/null) | sort )

if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
    echo "present files are identical to the ones on the server - do not download them again"
else
    (cd "${WORKING_DIR}" ; rm -f ${FJMEM} ${BIOS_RESCUE})
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${FJMEM}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${BIOS_RESCUE}"
fi

####################################################
dd if=${WORKING_DIR}/${BIOS_RESCUE} of=${WORKING_DIR}/${HEAD_TMP}   bs=8 count=28
dd if=${WORKING_DIR}/${BIOS_RESCUE} of=${WORKING_DIR}/${REMAIN_TMP} bs=8  skip=29

printf "\\x$(printf "%x" 0x10)" >  ${WORKING_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0xe2)" >> ${WORKING_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0xd5)" >> ${WORKING_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x00)" >> ${WORKING_DIR}/${MAC_TMP}

printf "\\x$(printf "%x" 0x$1)" >> ${WORKING_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x$2)" >> ${WORKING_DIR}/${MAC_TMP}

printf "\\x$(printf "%x" 0x00)" >> ${WORKING_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x00)" >> ${WORKING_DIR}/${MAC_TMP}

cat ${WORKING_DIR}/${HEAD_TMP} \
    ${WORKING_DIR}/${MAC_TMP} \
    ${WORKING_DIR}/${REMAIN_TMP} \
    > ${WORKING_DIR}/${BIOS_RESCUE_MAC}

#UrJtag option ####################################################
NOVERIFY="noverify"

#UrJtag batch file
BATCH_FILE=`mktemp`
cat > ${BATCH_FILE}<<EOF
cable milkymist
detect
instruction CFG_OUT 000100 BYPASS
instruction CFG_IN 000101 BYPASS
pld load ${WORKING_DIR}/${FJMEM}
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

flashmem 0x220000 ${WORKING_DIR}/${BIOS_RESCUE_MAC} ${NOVERIFY}

pld reconfigure
EOF

jtag  ${BATCH_FILE}
if [ "$?" == "0" ]; then
    rm -f ${BATCH_FILE}

    echo "-------------------------------------------------------------"
    echo "Your bios-rescue with MAC address $1:$2 was successfully reflashed."
    echo "To boot the new software, Please now press the middle button of your Milkymist One."
    echo "-------------------------------------------------------------"
else
    echo "there are errors when running jtag. "
fi
