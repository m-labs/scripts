#!/bin/bash

OPENWRT_DIR_NAME="openwrt-milkymist."$1
OPENWRT_DIR="/home/xiangfu/${OPENWRT_DIR_NAME}/"
CONFIG_FILE_TYPE="config."$1

MAKE_VARS=" V=99 IGNORE_ERRORS=m -j4 "

########################################################################
DATE=$(date "+%Y-%m-%d")
TIME=$(date "+%H-%M-%S")
DATE_TIME=`date +"%m%d%Y-%H%M"`

GET_FEEDS_VERSION_SH="/home/xiangfu/bin/get-feeds-revision.sh"
PATCH_OPENWRT_SH="/home/xiangfu/bin/patch-openwrt.sh"

IMAGES_DIR="/home/xiangfu/build-milkymist/milkymist-openwrt.$1-${DATE_TIME}/"
mkdir -p ${IMAGES_DIR}

BUILD_LOG="${IMAGES_DIR}/BUILD_LOG"
VERSIONS_FILE="${IMAGES_DIR}/VERSIONS"


########################################################################
cd ${OPENWRT_DIR}

echo "make distclean ..."
make distclean 


echo "updating git repo..."
git fetch -a
git reset --hard origin/master
if [ "$?" != "0" ]; then
	echo "ERROR: updating openwrt failed"
	exit 1
fi


echo "update and install feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a
if [ "$?" != "0" ]; then
	echo "ERROR: update and install feeds failed"
	exit 1
fi
cp feeds/qipackages/milkymist-files/data/m1/conf/${CONFIG_FILE_TYPE} .config
sed -i '/CONFIG_ALL/s/.*/CONFIG_ALL=y/' .config 
yes "" | make oldconfig > /dev/null


echo "copy files, create VERSION, copy dl folder, last prepare..."
rm -f dl    && ln -s ~/dl


echo "patch openwrt "
${PATCH_OPENWRT_SH} ${OPENWRT_DIR}


echo "starting compiling - this may take several hours..."
time make ${MAKE_VARS} > ${IMAGES_DIR}/BUILD_LOG 2>&1
if [ "$?" != "0" ]; then
	echo "ERROR: Build failed! Please refer to the log file"
	tail -n 100 ${IMAGES_DIR}/BUILD_LOG > ${IMAGES_DIR}/BUILD_LOG.`date +"%m%d%Y-%H%M"`.last100
        echo -e "\
say #milkymist The Openwrt build has FAILED, \
see log here: http://fidelio.qi-hardware.com/~xiangfu/build-milkymist/milkymist-openwrt.$1-${DATE_TIME}/\nclose" \
             | nc turandot.qi-hardware.com 3858
else
echo -e "\
say #milkymist The Openwrt build was successfull, \
see images here: http://fidelio.qi-hardware.com/~xiangfu/build-milkymist/milkymist-openwrt.$1-${DATE_TIME}/\nclose" \
     | nc turandot.qi-hardware.com 3858
fi


echo "getting version numbers of used repositories..."
${GET_FEEDS_VERSION_SH} ${OPENWRT_DIR} > ${VERSIONS_FILE}


echo "copy all files to IMAGES_DIR..."
cp .config ${IMAGES_DIR}/config
cp build_dir/linux-lm32/linux-3.0/.config ${IMAGES_DIR}/kernel.config
cp feeds.conf ${IMAGES_DIR}/
cp -a bin/lm32/* ${IMAGES_DIR} 2>/dev/null

(cd ${IMAGES_DIR}; \
 grep -E "ERROR:\ package.*failed to build" BUILD_LOG | grep -v "package/kernel" > failed_packages.txt; \
 bzip2 -z BUILD_LOG; \
)

echo "DONE :)"
