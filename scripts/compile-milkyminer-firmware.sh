#!/bin/bash

DATE_TIME=`date +"%Y%m%d-%H%M"`


IMAGES_DIR="/home/xiangfu/building/Milkymist/milkyminer-firmware-${DATE_TIME}"
DEST_DIR="/home/xiangfu/build-milkymist"
mkdir -p ${IMAGES_DIR}
mkdir -p ${DEST_DIR}


BUILD_LOG="${IMAGES_DIR}/BUILD_LOG"
VERSIONS="${IMAGES_DIR}/VERSIONS"
touch ${BUILD_LOG} ${VERSIONS}


MILKYMINER_GIT_DIR=/home/xiangfu/milkymist-firmware/milkyminer
MD5_BINARIES="soc.fpg"


abort() {
	tail -n 100 ${IMAGES_DIR}/BUILD_LOG > ${IMAGES_DIR}/BUILD_LOG.`date +"%m%d%Y-%H%M"`.last100
	echo "$1"
	exit 1
}

get-feeds-revision() {
    if [ -d "$1" ]; then
        cd $1
        repo=$(git config -l | grep remote.origin.url | cut -d "=" -f 2)
        rev=$(git log | head -n 1 | cut -b8-)
        branch=$(git branch | grep "*" | cut -b3-)
        echo "${repo}  ${branch} ${rev}" >> ${VERSIONS}
    fi
}


echo "update git ..."
(cd ${MILKYMINER_GIT_DIR} && git fetch -a && git reset --hard origin/master)

echo "get git versions ..."
get-feeds-revision ${MILKYMINER_GIT_DIR}


VERSIONS_NEW=`cat ${VERSIONS}`
VERSIONS_OLD=`cat ${IMAGES_DIR}/../milkyminer-VERSIONS`
if [ "${VERSIONS_NEW}" == "${VERSIONS_OLD}" ]; then
	echo "No new commit, ignore build"
	rm -f ${IMAGES_DIR}/*
	rmdir ${IMAGES_DIR}
	exit 0
fi
cp ${VERSIONS} ${IMAGES_DIR}/../milkyminer-VERSIONS


echo "compile tools ..."
make -C ${MILKYMINER_GIT_DIR}/ clean host >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	abort "ERROR: milkyminer/tools"
fi


echo "compile soc ..."
#the Xilinx libs(libstdc++.so.6) have some conflict
(source ~/.bashrc && \
 source /home/Xilinx/13.4/ISE_DS/settings64.sh && \
 make -C ${MILKYMINER_GIT_DIR}/boards/milkymist-one/flash)  >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	abort "ERROR: compile SOC"
fi
cp ${MILKYMINER_GIT_DIR}/boards/milkymist-one/flash/soc.fpg ${IMAGES_DIR}


echo "generate md5sum ..."
(cd ${IMAGES_DIR} && md5sum --binary ${MD5_BINARIES} > ${IMAGES_DIR}/md5sums)
(cd ${IMAGES_DIR} && bzip2 -z BUILD_LOG;)

mv ${IMAGES_DIR} ${DEST_DIR}

echo "DONE!"
