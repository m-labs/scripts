#!/bin/bash

###################################################################
__VERSION__="2011-08-17"
echo "Version of me: ${__VERSION__}"
echo "File name: $0"

WORKING_DIR=".."

STANDBY="standby.fpg"
SOC_RESCUE="soc-rescue.fpg"
SPLASH_RESCUE="splash-rescue.raw"
SOC="soc.fpg"
BIOS="bios.bin"
SPLASH="splash.raw"
FLICKERNOISE="flickernoise.fbi"
DATA="data.flash5.bin"

FJMEM="fjmem.bit"

MAC_DIR="BIOSMAC"
BIOS_RESCUE="bios-rescue-without-CRC.bin"
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

###################################################################
mkdir -p ${MAC_DIR}

dd if=${BIOS_RESCUE} of=${MAC_DIR}/${HEAD_TMP}   bs=8 count=28
dd if=${BIOS_RESCUE} of=${MAC_DIR}/${REMAIN_TMP} bs=8  skip=29

printf "\\x$(printf "%x" 0x10)" >  ${MAC_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0xe2)" >> ${MAC_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0xd5)" >> ${MAC_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}

printf "\\x$(printf "%x" 0x$1)" >> ${MAC_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x$2)" >> ${MAC_DIR}/${MAC_TMP}

printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}
printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}

cat ${MAC_DIR}/${HEAD_TMP} \
    ${MAC_DIR}/${MAC_TMP} \
    ${MAC_DIR}/${REMAIN_TMP} \
    > ${MAC_DIR}/${BIOS_RESCUE_MAC}

mkmmimg ${MAC_DIR}/${BIOS_RESCUE_MAC} write

###################################################################
#UrJtag option
NOVERIFY="noverify" 
#DEBUG="debug all"
DEBUG=""

#UrJtag batch file
BATCH_FILE=`mktemp`
cat > ${BATCH_FILE}<<EOF
${DEBUG}

cable milkymist
detect
instruction CFG_OUT 000100 BYPASS
instruction CFG_IN 000101 BYPASS
pld load ${FJMEM}
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

eraseflash 0x000000 256

flashmem 0x000000 ${WORKING_DIR}/${STANDBY} ${NOVERIFY}

flashmem 0x0A0000 ${WORKING_DIR}/${SOC_RESCUE} ${NOVERIFY}
flashmem 0x240000 ${WORKING_DIR}/${SPLASH_RESCUE} ${NOVERIFY}
flashmem 0x2E0000 ${WORKING_DIR}/${FLICKERNOISE} ${NOVERIFY}

flashmem 0x6E0000 ${WORKING_DIR}/${SOC} ${NOVERIFY}
flashmem 0x860000 ${WORKING_DIR}/${BIOS} ${NOVERIFY}
flashmem 0x880000 ${WORKING_DIR}/${SPLASH} ${NOVERIFY}
flashmem 0x920000 ${WORKING_DIR}/${FLICKERNOISE} ${NOVERIFY}

flashmem 0x220000 ${MAC_DIR}/${BIOS_RESCUE_MAC} ${NOVERIFY}

flashmem 0xD20000 ${DATA} ${NOVERIFY}

pld reconfigure
EOF

jtag ${BATCH_FILE}
if [ "$?" == "0" ]; then
    rm -f ${BATCH_FILE}

    echo "-------------------------------------------------------------"
    echo "Your m1 was successfully reflashed. To boot the new software,"
    echo "Please now press the middle button of your Milkymist One."
    echo "-------------------------------------------------------------"
else
    echo "there are errors when running jtag."
fi


#ChangeLog
# __VERSION__="2011-07-15"
#  * First Version

# __VERSION__="2011-08-12"
#  * erase whole flash before wirte anything

# __VERSION__="2011-08-17"
#  * add debug all
