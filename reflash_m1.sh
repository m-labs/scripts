#!/bin/bash

# version of me
__VERSION__="2011-04-21"

BASE_URL_HTTP="http://www.milkymist.org/snapshots"
VERSION="latest"
WORKING_DIR="${HOME}/.qi/milkymist/${VERSION}"

FJMEM="fjmem.bit"
STANDBY="standby.fpg"
SOC_RESCUE="soc-rescue.fpg"
BIOS_RESCUE="bios-rescue.bin"
SPLASH_RESCUE="splash-rescue.raw"
SOC="soc.fpg"
BIOS="bios.bin"
SPLASH="splash.raw"
FLICKERNOISE="flickernoise.fbi"
DATA="data.flash5.bin"

mkdir -p ${WORKING_DIR}

MD5SUMS_SERVER=$(\
wget -O - ${BASE_URL_HTTP}/${VERSION}/md5sums 2> /dev/null |\
grep -E "(${FJMEM}|${STANDBY}|${SOC_RESCUE}|${BIOS_RESCUE}|${SPLASH_RESCUE}|\
${SOC}|${BIOS}|${SPLASH}|${FLICKERNOISE}|${DATA})" | sort)
if [ "${MD5SUMS_SERVER}" == "" ]; then
    echo "ERROR: can't fetch files from server"
    exit 1
fi

MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}" ; \
    md5sum --binary ${FJMEM} ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
    ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA} 2> /dev/null) | sort )

if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
    echo "present files are identical to the ones on the server - do not download them again"
else
    (cd "${WORKING_DIR}" ; rm -f ${FJMEM} ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
        ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA})
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${FJMEM}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${STANDBY}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${SOC_RESCUE}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${BIOS_RESCUE}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${SPLASH_RESCUE}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${SOC}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${BIOS}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${SPLASH}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${FLICKERNOISE}"
    wget -P "${WORKING_DIR}" "${BASE_URL_HTTP}/${VERSION}/${DATA}"
fi

#UrJtag option
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

flashmem 0x000000 ${WORKING_DIR}/${STANDBY} ${NOVERIFY}

flashmem 0x0A0000 ${WORKING_DIR}/${SOC_RESCUE} ${NOVERIFY}
flashmem 0x220000 ${WORKING_DIR}/${BIOS_RESCUE} ${NOVERIFY}
flashmem 0x240000 ${WORKING_DIR}/${SPLASH_RESCUE} ${NOVERIFY}
flashmem 0x2E0000 ${WORKING_DIR}/${FLICKERNOISE} ${NOVERIFY}

flashmem 0x6E0000 ${WORKING_DIR}/${SOC} ${NOVERIFY}
flashmem 0x860000 ${WORKING_DIR}/${BIOS} ${NOVERIFY}
flashmem 0x880000 ${WORKING_DIR}/${SPLASH} ${NOVERIFY}

flashmem 0x920000 ${WORKING_DIR}/${FLICKERNOISE} ${NOVERIFY}

eraseflash 0xD20000 151
flashmem   0xD20000 ${WORKING_DIR}/${DATA} ${NOVERIFY}

pld reconfigure
EOF

jtag  ${BATCH_FILE}
if [ "$?" == "0" ]; then
    rm -f ${BATCH_FILE}

    echo "-------------------------------------------------------------"
    echo "Your m1 was successfully reflashed. To boot the new software,"
    echo "Please now press the middle button of your Milkymist One."
    echo "-------------------------------------------------------------"
else
    echo "there are errors when running jtag. "
fi
