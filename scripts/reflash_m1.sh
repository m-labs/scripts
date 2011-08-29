#!/bin/bash

# version of me
__VERSION__="2011-08-28"
echo "File name: $0, Version of me: ${__VERSION__}"


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

# Functions ###########################################################
call-help() {
	echo "
Usage: ./reflash_m1.sh                    version: ${__VERSION__}
	--release [VERSION]          # by default it will download 'currect' release
                                     # URL: http://milkymist.org/updates/

	--snapshot <VERSION> [data]  # if 'data' enable will reflash data partitions
                                     # URL: http://fidelio.qi-hardware.com/~xiangfu/build-milkymist/

	--local-folder <PATH>        # all files must be under <PATH>

	--lock-flash                 # lock 'standby' and 'rescue' partitions

	--read-flash                 # be default read 'standby.bin' from m1

	--bios-mac 00 2a             # '00' '2a' is the last MAC address
	--rc3 00 2a                  # used in factory flash
                                     # --bios-mac and --rc3 needs 'mkmmimg'

Written by: Xiangfu Liu <xiangfu@sharism.cc>
Please report bugs to <devel@lists.milkymist.org>
"

}

call-download() {
    wget -O "${WORKING_DIR}/${STANDBY}"       "${BASE_URL_HTTP}/${VERSION}/${STANDBY}"

    wget -O "${WORKING_DIR}/${SOC_RESCUE}"    "${BASE_URL_HTTP}/${VERSION}/${SOC_RESCUE}"
    wget -O "${WORKING_DIR}/${BIOS_RESCUE}"   "${BASE_URL_HTTP}/${VERSION}/${BIOS_RESCUE}"
    wget -O "${WORKING_DIR}/${SPLASH_RESCUE}" "${BASE_URL_HTTP}/${VERSION}/${SPLASH_RESCUE}"

    wget -O "${WORKING_DIR}/${SOC}"           "${BASE_URL_HTTP}/${VERSION}/${SOC}"
    wget -O "${WORKING_DIR}/${BIOS}"          "${BASE_URL_HTTP}/${VERSION}/${BIOS}"
    wget -O "${WORKING_DIR}/${SPLASH}"        "${BASE_URL_HTTP}/${VERSION}/${SPLASH}"

    wget -O "${WORKING_DIR}/${FLICKERNOISE}"  "${BASE_URL_HTTP}/${VERSION}/${FLICKERNOISE}"
}

call-jtag() {
    if [ "${FJMEM_PATH}" == "" ]; then
	FJMEM_PATH=${WORKING_DIR}
    fi

    if [ ! -f "${FJMEM_PATH}/${FJMEM}" ]; then
	wget -O "${FJMEM_PATH}/${FJMEM}" http://milkymist.org/updates/2011-07-13/for-rc3/fjmem.bit
    fi

    if [ "${BIOS_RESCUE_PATH}" == "" ]; then
	BIOS_RESCUE_PATH=${WORKING_DIR}
    fi


    # UrJtag option ##########################################
    JTAG_DEBUG=""
    #JTAG_DEBUG="debug all"

    JTAG_NOVERIFY="noverify"
    # UrJtag option ##########################################

    #UrJtag batch file
    JTAG_BATCH_FILE=`mktemp`

    cat > ${JTAG_BATCH_FILE}<<EOF
${JTAG_DEBUG}

cable milkymist
detect
instruction CFG_OUT 000100 BYPASS
instruction CFG_IN 000101 BYPASS
pld load ${FJMEM_PATH}/${FJMEM}
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

EOF

    if [ "$1" == "--lock-flash" ]; then
	echo "lockflash 0x000000  55" >> ${JTAG_BATCH_FILE}
    fi

    if [ "$1" == "--read-flash" ]; then
	echo "readmem 0x000000 0x00A0000 ${WORKING_DIR}/${STANDBY}" >> ${JTAG_BATCH_FILE}

	#echo "readmem 0x0A0000 0x0180000 ${WORKING_DIR}/${SOC_RESCUE}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x220000 0x0020000 ${BIOS_RESCUE_PATH}/${BIOS_RESCUE}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x240000 0x00A0000 ${WORKING_DIR}/${SPLASH_RESCUE}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x2E0000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE_RESCUE}" >> ${JTAG_BATCH_FILE}

	#echo "readmem 0x6E0000 0x0180000 ${WORKING_DIR}/${SOC}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x860000 0x0020000 ${WORKING_DIR}/${BIOS}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x880000 0x00A0000 ${WORKING_DIR}/${SPLASH}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x920000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE}" >> ${JTAG_BATCH_FILE}

	#echo "readmem 0xD20000 0x12E0000 ${WORKING_DIR}/${DATA}" >> ${JTAG_BATCH_FILE}
    fi

    if [ "$1" == "--release" ] || [ "$1" == "--snapshot" ]; then
	echo "eraseflash 0x000000 105" >> ${JTAG_BATCH_FILE}

	echo "flashmem 0x000000 ${WORKING_DIR}/${STANDBY} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x0A0000 ${WORKING_DIR}/${SOC_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x220000 ${BIOS_RESCUE_PATH}/${BIOS_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x240000 ${WORKING_DIR}/${SPLASH_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x2E0000 ${WORKING_DIR}/${FLICKERNOISE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}

	echo "lockflash 0x000000  55" >> ${JTAG_BATCH_FILE}

	echo "flashmem 0x6E0000 ${WORKING_DIR}/${SOC} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x860000 ${WORKING_DIR}/${BIOS} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x880000 ${WORKING_DIR}/${SPLASH} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x920000 ${WORKING_DIR}/${FLICKERNOISE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}

	if [ -f "$2" ]; then
	    echo "eraseflash 0xD20000 151" >> ${JTAG_BATCH_FILE}
	    echo "flashmem   0xD20000 $2 ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	fi

    fi

    echo "pld reconfigure" >> ${JTAG_BATCH_FILE}

    jtag  ${JTAG_BATCH_FILE}
    echo "-------------------------------------------------------------"
    echo "jtag batch file is ${JTAG_BATCH_FILE}"
    echo "Your m1 was successfully reflashed. To boot the new software,"
    echo "Please now press the middle button of your Milkymist One."
    echo "-------------------------------------------------------------"

}


# Main ###########################################################

if [ "$1" == "--release" ]; then
    BASE_URL_HTTP="http://milkymist.org/updates"
    VERSION="$2"

    if [ "${VERSION}" == "" ]; then
	VERSION="current"
    fi

    VERSION_SERVER=$(wget -O - ${BASE_URL_HTTP}/${VERSION}/version-app 2> /dev/null)
    if [ "${VERSION_SERVER}" == "" ]; then
	echo "ERROR: can't fetch files: ${BASE_URL_HTTP}/${VERSION}/version-app"
	exit 1
    fi

    WORKING_DIR="${HOME}/.qi/milkymist/release/${VERSION}"
    mkdir -p ${WORKING_DIR}

    VERSION_LOCAL=$(cat "${WORKING_DIR}/version-app")

    if [ "${VERSION_SERVER}" == "${VERSION_LOCAL}" ]; then
	echo "local version same with server version - do not download them again"
    else
	(cd "${WORKING_DIR}" ; rm -f \
	    ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
	    ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} \
	    version-app)
	wget -O ${WORKING_DIR}/version-app ${BASE_URL_HTTP}/${VERSION}/version-app
	call-download
    fi

    call-jtag $1
    exit 0
fi


if [ "$1" == "--snapshot" ]; then
    if [ "$2" == "" ]; then
	call-help
	exit 1
    fi

    BASE_URL_HTTP="http://fidelio.qi-hardware.com/~xiangfu/build-milkymist"
    VERSION="$2"

    MD5SUMS_SERVER=$(\
    wget -O - ${BASE_URL_HTTP}/${VERSION}/md5sums 2> /dev/null |\
    grep -E "(${STANDBY}|${SOC_RESCUE}|${BIOS_RESCUE}|${SPLASH_RESCUE}|${SOC}|${BIOS}|${SPLASH}|${FLICKERNOISE}|${DATA})" | sort)
    if [ "${MD5SUMS_SERVER}" == "" ]; then
	echo "ERROR: can't fetch files: ${BASE_URL_HTTP}/${VERSION}/md5sums"
	exit 1
    fi

    WORKING_DIR="${HOME}/.qi/milkymist/snapshots/${VERSION}"
    mkdir -p ${WORKING_DIR}

    MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}" ; \
	md5sum --binary ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
	${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA} 2> /dev/null) | sort )

    if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
	echo "present files are identical to the ones on the server - do not download them again"
    else
	(cd "${WORKING_DIR}" ; rm -f ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
	   ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA})
	wget -O "${WORKING_DIR}/${DATA}" "${BASE_URL_HTTP}/${VERSION}/${DATA}"
	call-download
    fi

    call-jtag $1 "${WORKING_DIR}/${DATA}"
    exit 0
fi

if [ "$1" == "--local-folder" ]; then
    echo "Not support yet!"
    exit 1
fi

if [ "$1" == "--lock-flash" ]; then
    WORKING_DIR="${HOME}/.qi/milkymist/lock-flash"
    mkdir -p ${WORKING_DIR}

    call-jtag $1
    exit 0
fi

if [ "$1" == "--read-flash" ]; then
    DATE_TIME=`date +"%Y%m%d-%H%M"`
    WORKING_DIR="${HOME}/.qi/milkymist/read-flash/${DATE_TIME}"
    FJMEM_PATH=${WORKING_DIR}/..

    mkdir -p ${WORKING_DIR}
    call-jtag $1

    echo "-------------------------------------------------------------"
    echo "Read back files under ${WORKING_DIR}"
    echo "-------------------------------------------------------------"
    exit 0
fi

if [ "$1" == "--bios-mac" ]; then
    echo "Not support yet!"
    exit 1
fi

if [ "$1" == "--rc3" ]; then
    if [ "$#" != "3" ]; then
        call-help
        exit 1
    fi

    MAC_DIR="BIOSMAC"
    BIOS_RESCUE="bios-rescue-without-CRC.bin"
    HEAD_TMP="head.tmp"
    MAC_TMP="mac.tmp"
    REMAIN_TMP="remain.tmp"
    BIOS_RESCUE_MAC="bios.$2$3.bin"

    mkdir -p ${MAC_DIR}

    dd if=${BIOS_RESCUE} of=${MAC_DIR}/${HEAD_TMP}   bs=8 count=28
    dd if=${BIOS_RESCUE} of=${MAC_DIR}/${REMAIN_TMP} bs=8  skip=29

    printf "\\x$(printf "%x" 0x10)" >  ${MAC_DIR}/${MAC_TMP}
    printf "\\x$(printf "%x" 0xe2)" >> ${MAC_DIR}/${MAC_TMP}
    printf "\\x$(printf "%x" 0xd5)" >> ${MAC_DIR}/${MAC_TMP}
    printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}

    printf "\\x$(printf "%x" 0x$2)" >> ${MAC_DIR}/${MAC_TMP}
    printf "\\x$(printf "%x" 0x$3)" >> ${MAC_DIR}/${MAC_TMP}

    printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}
    printf "\\x$(printf "%x" 0x00)" >> ${MAC_DIR}/${MAC_TMP}

    cat ${MAC_DIR}/${HEAD_TMP} \
        ${MAC_DIR}/${MAC_TMP} \
        ${MAC_DIR}/${REMAIN_TMP} \
        > ${MAC_DIR}/${BIOS_RESCUE_MAC}

    mkmmimg ${MAC_DIR}/${BIOS_RESCUE_MAC} write

    BIOS_RESCUE_PATH=${MAC_DIR}
    BIOS_RESCUE=${BIOS_RESCUE_MAC}

    WORKING_DIR=".."
    FJMEM_PATH="."

    call-jtag "--release" "${DATA}"

    exit 0
fi


# nomally not reach here
call-help
exit 1
