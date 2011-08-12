#!/bin/bash

# version of me
__VERSION__="2011-08-10"

BASE_URL_HTTP="http://www.milkymist.org/snapshots"
VERSION="latest"

DATE_TIME=`date +"%Y%m%d-%H%M"`

WORKING_DIR="${HOME}/.qi/milkymist/readback/${DATE_TIME}"

FJMEM="fjmem.bit"
STANDBY="standby.fpg"
SOC_RESCUE="soc-rescue.fpg"
BIOS_RESCUE="bios-rescue.bin"
SPLASH_RESCUE="splash-rescue.raw"
FLICKERNOISE_RESCUE="flickernoise-rescue.fbi"
SOC="soc.fpg"
BIOS="bios.bin"
SPLASH="splash.raw"
FLICKERNOISE="flickernoise.fbi"
DATA="data.flash5.bin"

mkdir -p ${WORKING_DIR}

MD5SUMS_SERVER=$(\
wget -O - ${BASE_URL_HTTP}/${VERSION}/md5sums 2> /dev/null | grep -E "${FJMEM}" | sort)
if [ "${MD5SUMS_SERVER}" == "" ]; then
    echo "ERROR: can't fetch files from server"
    exit 1
fi

MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}/../" ; md5sum --binary ${FJMEM} 2> /dev/null) | sort )

if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
    echo "Present fjmem.bit are identical to the ones on the server - do not download them again"
else
    (cd "${WORKING_DIR}/../" ; rm -f ${FJMEM})
    echo "Downloading fjmem.bit ..."
    wget "${BASE_URL_HTTP}/${VERSION}/${FJMEM}" -O ${WORKING_DIR}/../${FJMEM}
fi

#UrJtag batch file
BATCH_FILE=`mktemp`
cat > ${BATCH_FILE}<<EOF
cable milkymist
detect
instruction CFG_OUT 000100 BYPASS
instruction CFG_IN 000101 BYPASS
pld load ${WORKING_DIR}/../${FJMEM}
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

  readmem 0x000000 0x00A0000 ${WORKING_DIR}/${STANDBY}

# readmem 0x0A0000 0x0180000 ${WORKING_DIR}/${SOC_RESCUE}
# readmem 0x220000 0x0020000 ${WORKING_DIR}/${BIOS_RESCUE}
# readmem 0x240000 0x00A0000 ${WORKING_DIR}/${SPLASH_RESCUE}
# readmem 0x2E0000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE_RESCUE}

# readmem 0x6E0000 0x0180000 ${WORKING_DIR}/${SOC}
# readmem 0x860000 0x0020000 ${WORKING_DIR}/${BIOS}
# readmem 0x880000 0x00A0000 ${WORKING_DIR}/${SPLASH}
# readmem 0x920000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE}

# readmem 0xD20000 0x12E0000 ${WORKING_DIR}/${DATA}

pld reconfigure
EOF

jtag  ${BATCH_FILE}
if [ "$?" == "0" ]; then
    rm -f ${BATCH_FILE}

    echo "-------------------------------------------------------------"
    echo "Files is under ${WORKING_DIR}"
    echo "-------------------------------------------------------------"
else
    echo "there are errors when running jtag."
fi
