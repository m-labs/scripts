#!/bin/bash

# version of me
__VERSION__="2012-03-05"
echo -e "File name: $0\t version: ${__VERSION__}"


STANDBY="standby.fpg"
SOC_RESCUE="soc-rescue.fpg"
BIOS_RESCUE="bios-rescue.bin"
SPLASH_RESCUE="splash-rescue.raw"
SOC="soc.fpg"
BIOS="bios.bin"
SPLASH="splash.raw"
FLICKERNOISE="flickernoise.fbi"
DATA="data.flash5.bin"

FJMEM="${HOME}/.qi/milkymist/fjmem/fjmem.bit"
BIOS_RESCUE_WITHOUT_CRC="${HOME}/.qi/milkymist/bios-crc/bios-rescue-without-CRC.bin"
MAC_DIR="${HOME}/.qi/milkymist/bios-mac/tmp"

# Functions ###########################################################
# This option is for me or other develop test the image:
#    --snapshot <VERSION> [data] if 'data' enable, it will REFLASH DATA PARTITION
#    VERSION can found at
#		     http://fidelio.qi-hardware.com/~xiangfu/build-milkymist/

call-help() {
	echo -e \
"
Usage: ./reflash_m1.sh [OPTION] [PARAM...]

  --release [VERSION]         by default it will download the latest release
  --local-folder              please use m1nor instead
  --lock-flash                lock 'standby' and 'rescue' partitions
  --read-flash <PARTITION>    read from RESCUE partition, by default only read
                              'standby.bin'
                              PARTITION: standby soc bios splash flickernoise
  --bios-mac XX XX            'XX' 'XX' is the last MAC address
  --rc3 XX XX                 used in factory flash, reflash all partitions
  --qi [VERSION] [--data]     by default it will download the latest qi release

NOTICE: '--bios-mac' and '--rc3' needs command 'mkmmimg'
        '--release'  VERSION can found at http://milkymist.org/updates/
        '--qi'       VERSION can found at
                 http://downloads.qi-hardware.com/software/images/Milkymist_One
        '--data'     if this option enable, it will REFLASH DATA PARTITION
                     BACKUP before you use this option

Version: ${__VERSION__}

Written by: Xiangfu Liu <xiangfu@openmobilefree.net>
Please report bugs to <devel@lists.milkymist.org>
"
}

# $1: is the file name you want save
# $2: is the URL
call-wget() {
    wget -O "$1" "$2"
    if [ "$?" != "0" ]; then
	rm -f "$1"
    fi
}

call-download() {
    call-wget "${WORKING_DIR}/${STANDBY}"       "${BASE_URL_HTTP}/${VERSION}/${STANDBY}"

    call-wget "${WORKING_DIR}/${SOC_RESCUE}"    "${BASE_URL_HTTP}/${VERSION}/${SOC_RESCUE}"
    call-wget "${WORKING_DIR}/${BIOS_RESCUE}"   "${BASE_URL_HTTP}/${VERSION}/${BIOS_RESCUE}"
    call-wget "${WORKING_DIR}/${SPLASH_RESCUE}" "${BASE_URL_HTTP}/${VERSION}/${SPLASH_RESCUE}"

    call-wget "${WORKING_DIR}/${SOC}"           "${BASE_URL_HTTP}/${VERSION}/${SOC}"
    call-wget "${WORKING_DIR}/${BIOS}"          "${BASE_URL_HTTP}/${VERSION}/${BIOS}"
    call-wget "${WORKING_DIR}/${SPLASH}"        "${BASE_URL_HTTP}/${VERSION}/${SPLASH}"

    call-wget "${WORKING_DIR}/${FLICKERNOISE}"  "${BASE_URL_HTTP}/${VERSION}/${FLICKERNOISE}"
}

call-jtag() {
    if [ ! -f "${FJMEM}" ]; then
	mkdir -p `dirname ${FJMEM}`
	call-wget "${FJMEM}.bz2" http://milkymist.org/updates/fjmem.bit.bz2
	bunzip2 "${FJMEM}.bz2"
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
pld load ${FJMEM}
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

EOF

    if [ "$1" == "--lock-flash" ]; then
	echo "lockflash 0x000000  55" >> ${JTAG_BATCH_FILE}
    fi

    if [ "$1" == "--read-flash" ]; then
	if [ "$2" == "standby" ] || [ "$2" == "" ]; then
	    echo "readmem 0x000000 0x00A0000 ${WORKING_DIR}/${STANDBY}" >> ${JTAG_BATCH_FILE}
	fi
	if [ "$2" == "soc" ]; then
	    echo "readmem 0x0A0000 0x0180000 ${WORKING_DIR}/${SOC_RESCUE}" >> ${JTAG_BATCH_FILE}
	fi
	if [ "$2" == "bios" ]; then
	    echo "readmem 0x220000 0x0020000 ${WORKING_DIR}/${BIOS_RESCUE}" >> ${JTAG_BATCH_FILE}
	fi
	if [ "$2" == "splash" ]; then
	    echo "readmem 0x240000 0x00A0000 ${WORKING_DIR}/${SPLASH_RESCUE}" >> ${JTAG_BATCH_FILE}
	fi
	if [ "$2" == "flickernoise" ]; then
	    echo "readmem 0x2E0000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE_RESCUE}" >> ${JTAG_BATCH_FILE}
	fi

	#echo "readmem 0x6E0000 0x0180000 ${WORKING_DIR}/${SOC}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x860000 0x0020000 ${WORKING_DIR}/${BIOS}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x880000 0x00A0000 ${WORKING_DIR}/${SPLASH}" >> ${JTAG_BATCH_FILE}
	#echo "readmem 0x920000 0x0400000 ${WORKING_DIR}/${FLICKERNOISE}" >> ${JTAG_BATCH_FILE}

	#echo "readmem 0xD20000 0x12E0000 ${WORKING_DIR}/${DATA}" >> ${JTAG_BATCH_FILE}
    fi

    if [ "$1" == "--release" ] || [ "$1" == "--qi" ] || [ "$1" == "--snapshot" ]; then
	echo "flashmem 0x000000 ${WORKING_DIR}/${STANDBY} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}

	echo "flashmem 0x0A0000 ${WORKING_DIR}/${SOC_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x220000 ${BIOS_RESCUE_PATH}/${BIOS_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x240000 ${WORKING_DIR}/${SPLASH_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x2E0000 ${WORKING_DIR}/${FLICKERNOISE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}

	echo "flashmem 0x6E0000 ${WORKING_DIR}/${SOC} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x860000 ${WORKING_DIR}/${BIOS} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x880000 ${WORKING_DIR}/${SPLASH} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "flashmem 0x920000 ${WORKING_DIR}/${FLICKERNOISE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}

	if [ -f "$2" ]; then
	    echo "eraseflash 0xD20000 151" >> ${JTAG_BATCH_FILE}
	    echo "flashmem   0xD20000 $2 ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	fi

	echo "lockflash 0x000000  55" >> ${JTAG_BATCH_FILE}
	# we have to lockflash after all flashmem finished
	# see: http://lists.milkymist.org/pipermail/devel-milkymist.org/2011-October/001939.html
    fi

    if [ "$1" == "--bios-mac" ]; then
	echo "flashmem 0x220000 ${BIOS_RESCUE_PATH}/${BIOS_RESCUE} ${JTAG_NOVERIFY}" >> ${JTAG_BATCH_FILE}
	echo "lockflash 0x000000  55" >> ${JTAG_BATCH_FILE}
	# same as before.
    fi

    echo "pld reconfigure" >> ${JTAG_BATCH_FILE}

    jtag  ${JTAG_BATCH_FILE}
    echo "-------------------------------------------------------------"
    echo "jtag batch file is ${JTAG_BATCH_FILE}"
    echo "Your m1 was successfully reflashed. To boot the new software,"
    echo "Please re-plug the power cable of your Milkymist One."
    echo "-------------------------------------------------------------"

}

call-create-bios () {
    HEAD_TMP="head.tmp"
    MAC_TMP="mac.tmp"
    REMAIN_TMP="remain.tmp"

    mkdir -p ${MAC_DIR}
    mkdir -p `dirname ${BIOS_RESCUE_WITHOUT_CRC}`

    rm -f "${BIOS_RESCUE_WITHOUT_CRC}"

    call-wget "${BIOS_RESCUE_WITHOUT_CRC}" \
	http://downloads.qi-hardware.com/software/images/Milkymist_One/latest/bios-rescue-without-CRC.bin

    dd if="${BIOS_RESCUE_WITHOUT_CRC}"  of=${MAC_DIR}/${HEAD_TMP}   bs=8 count=28
    dd if="${BIOS_RESCUE_WITHOUT_CRC}"  of=${MAC_DIR}/${REMAIN_TMP} bs=8  skip=29

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
	> $1

    mkmmimg $1 write
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
	call-wget ${WORKING_DIR}/version-app ${BASE_URL_HTTP}/${VERSION}/version-app
	call-download
    fi

    call-jtag $1
    exit 0
fi


if [ "$1" == "--qi" ] || [ "$1" == "--snapshot" ]; then
    if [ "$1" == "--snapshot" ] && [ "$#" == "1" ]; then
	call-help
	exit 1
    fi

    BASE_URL_HTTP="http://fidelio.qi-hardware.com/~xiangfu/build-milkymist"
    VERSION="latest"

    if [ "$1" == "--qi" ]; then
        BASE_URL_HTTP="http://downloads.qi-hardware.com/software/images/Milkymist_One"
    fi

    if [ "$2" != "--data" ] && [ "$2" != "" ]; then
        VERSION="$2"
    fi

    MD5SUMS_SERVER=$(\
    wget -O - ${BASE_URL_HTTP}/${VERSION}/md5sums 2> /dev/null |\
    grep -E "(${STANDBY}|${SOC_RESCUE}|${BIOS_RESCUE}|${SPLASH_RESCUE}|${SOC}|${BIOS}|${SPLASH}|${FLICKERNOISE}|${DATA})" | sort)
    if [ "${MD5SUMS_SERVER}" == "" ]; then
	echo "ERROR: can't fetch files: ${BASE_URL_HTTP}/${VERSION}/md5sums"
	exit 1
    fi

    WORKING_DIR="${HOME}/.qi/milkymist/${1##--}/${VERSION}"
    mkdir -p ${WORKING_DIR}

    MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}" ; \
	md5sum --binary ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
	${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA} 2> /dev/null) | sort )

    if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
	echo "present files are identical to the ones on the server - do not download them again"
    else
	(cd "${WORKING_DIR}" ; rm -f ${STANDBY} ${SOC_RESCUE} ${BIOS_RESCUE} ${SPLASH_RESCUE} \
	   ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA})
	call-wget "${WORKING_DIR}/${DATA}" "${BASE_URL_HTTP}/${VERSION}/${DATA}"
	call-download
    fi

    if [ "$2" == "--data" ] || [ "$3" == "--data" ]; then
	call-jtag $1 "${WORKING_DIR}/${DATA}"
    else
	call-jtag $1
    fi

    exit 0
fi

if [ "$1" == "--local-folder" ]; then
    echo "Please use m1nor from http://projects.qi-hardware.com/index.php/p/wernermisc/source/tree/master/m1/tools/m1nor"
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

    mkdir -p ${WORKING_DIR}
    call-jtag $1

    echo "-------------------------------------------------------------"
    echo "Read back files under ${WORKING_DIR}"
    echo "-------------------------------------------------------------"
    exit 0
fi

if [ "$1" == "--bios-mac" ]; then
    if [ "$#" != "3" ]; then
	call-help
	exit 1
    fi

    BIOS_RESCUE_MAC="bios.$2$3.bin"

    call-create-bios "${MAC_DIR}/${BIOS_RESCUE_MAC}" "$2" "$3"

    BIOS_RESCUE_PATH=${MAC_DIR}
    BIOS_RESCUE=${BIOS_RESCUE_MAC}

    call-jtag "--bios-mac"

    exit 0
fi

if [ "$1" == "--rc3" ]; then
    if [ "$#" != "3" ]; then
	call-help
	exit 1
    fi

    BIOS_RESCUE_MAC="bios.$2$3.bin"

    call-create-bios "${MAC_DIR}/${BIOS_RESCUE_MAC}" "$2" "$3"

    BIOS_RESCUE_PATH=${MAC_DIR}
    BIOS_RESCUE=${BIOS_RESCUE_MAC}


    BASE_URL_HTTP="http://milkymist.org/updates"
    VERSION="2011-11-29"

    MD5SUMS_SERVER=$(\
      wget -O - "${BASE_URL_HTTP}/${VERSION}/for-rc3/md5sums" 2> /dev/null |\
      grep -E "(${STANDBY}|${SOC_RESCUE}|${SPLASH_RESCUE}|${SOC}|${BIOS}|${SPLASH}|${FLICKERNOISE}|${DATA})" | sort)
    if [ "${MD5SUMS_SERVER}" == "" ]; then
	echo "ERROR: can't fetch files ${BASE_URL_HTTP}/${VERSION}/for-rc3/md5sums"
	exit 1
    fi

    WORKING_DIR="${HOME}/.qi/milkymist/for-rc3"
    mkdir -p ${WORKING_DIR}

    MD5SUMS_LOCAL=$( (cd "${WORKING_DIR}" ; \
	md5sum --binary ${STANDBY} ${SOC_RESCUE} ${SPLASH_RESCUE} \
	${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA} 2> /dev/null) | sort )

    if [ "${MD5SUMS_SERVER}" == "${MD5SUMS_LOCAL}" ]; then
	echo "present files are identical to the ones on the server - do not download them again"
    else
	(cd "${WORKING_DIR}" ; rm -f ${STANDBY} ${SOC_RESCUE} ${SPLASH_RESCUE} \
	   ${SOC} ${BIOS} ${SPLASH} ${FLICKERNOISE} ${DATA})
	call-download
	call-wget "${WORKING_DIR}/${SPLASH_RESCUE}" "${BASE_URL_HTTP}/${VERSION}/for-rc3/${SPLASH_RESCUE}"
	call-wget "${WORKING_DIR}/${SPLASH}"        "${BASE_URL_HTTP}/${VERSION}/for-rc3/${SPLASH}"
	call-wget "${WORKING_DIR}/${DATA}"          "${BASE_URL_HTTP}/${VERSION}/for-rc3/${DATA}"
    fi

    call-jtag "--release" "${WORKING_DIR}/${DATA}"

    exit 0
fi

# nomally not reach here
call-help
exit 1
