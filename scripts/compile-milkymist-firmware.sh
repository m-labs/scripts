#!/bin/bash

DATE=$(date "+%Y-%m-%d")
TIME=$(date "+%H-%M-%S")
DATE_TIME=`date +"%m%d%Y-%H%M"`

CURR_DIR="`pwd`"
IMAGE_DIR="${HOME}/.qi/milkymist/milkymist-firmware/${DATE_TIME}/"
mkdir -p ${IMAGE_DIR}

BUILD_LOG="${IMAGE_DIR}/BUILD_LOG"
VERSIONS="${IMAGE_DIR}/VERSIONS"
touch ${BUILD_LOG} ${VERSIONS}

MILKYMIST_GIT_DIR="../../milkymist"
SCRIPTS_GIT_DIR=".."

MD5_BINARIES="bios.bin bios-rescue.bin boot.bin data.flash5.bin flickernoise flickernoise.bin flickernoise.fbi flickernoise.ralf soc.fpg soc-rescue.fpg splash.raw splash-rescue.raw standby.fpg"

get-feeds-revision() {
    if [ -d "$1" ]; then
        cd $1
        repo=$(git config -l | grep remote.origin.url | cut -d "=" -f 2)
        rev=$(git log | head -n 1 | cut -b8-)
        branch=$(git branch | grep "*" | cut -b3-)
        echo "${repo}  ${branch} ${rev}" >> ${VERSIONS}
    fi
    cd ${CURR_DIR}
}


echo "update git ..."
(cd ${SCRIPTS_GIT_DIR} && git fetch -a && git reset --hard origin/master)
#make -C ${SCRIPTS_GIT_DIR}/compile-flickernoise/ milkymist-git-clone #no needs every build
MILKYMIST_GIT_DIR=${MILKYMIST_GIT_DIR}  make -C ${SCRIPTS_GIT_DIR}/compile-flickernoise/ milkymist-git-update
if [ "$?" != "0" ]; then
	echo "ERROR: milkymist-git-update"
        echo -e "\
say #milkymist ERROR: milkymist-git-update \
see log here: http://fidelio.qi-hardware.com/~xiangfu/build-milkymist/milkymist-firmware-${DATE_TIME}/ \nclose" \
             | nc turandot.qi-hardware.com 3858
fi


echo "get git versions ..."
get-feeds-revision ${MILKYMIST_GIT_DIR}/autotest-m1.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/flickernoise.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/liboscparse.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/milkymist.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/mtk.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/rtems.git
get-feeds-revision ${MILKYMIST_GIT_DIR}/rtems-yaffs2.git
get-feeds-revision ${SCRIPTS_GIT_DIR}/


echo "compile toolchain ..."
rm -rf /opt/rtems-4.11/
make -C ${SCRIPTS_GIT_DIR}/compile-lm32-rtems clean all >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	echo "ERROR: compile-lm32-rtems toolchain "
fi


echo "compile tools ..."
(cd ${MILKYMIST_GIT_DIR}/milkymist.git && ./clean_all.sh)
make -C ${MILKYMIST_GIT_DIR}/milkymist.git/tools >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	echo "ERROR: milkymist.git/tools"
fi

echo "compile soc ..."
#the Xilinx libs(libstdc++.so.6) have some conflict
(source /home/Xilinx/13.2/ISE_DS/settings64.sh && \
 make -C ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash)  >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	echo "ERROR: compile SOC"
fi


echo "compile flickernoise ..."
export PATH=${MILKYMIST_GIT_DIR}/milkymist.git/tools:$PATH
MILKYMIST_GIT_DIR=${MILKYMIST_GIT_DIR} make -C ${SCRIPTS_GIT_DIR}/compile-flickernoise \
         clean flickernoise.fbi autotest-m1-boot.bin  >> ${BUILD_LOG} 2>&1
if [ "$?" != "0" ]; then
	echo "ERROR: compile flickernoise"
fi


echo "copy images to bin/ ..."
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/standby.fpg ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/soc.fpg ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/bios.bin ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/splash.raw ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/soc-rescue.fpg ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/bios-rescue.bin ${IMAGES_DIR}
cp ${MILKYMIST_GIT_DIR}/milkymist.git/boards/milkymist-one/flash/splash-rescue.raw ${IMAGES_DIR}

cp ${MILKYMIST_GIT_DIR}/flickernoise.git/src/bin/* ${IMAGES_DIR}/
cp ${MILKYMIST_GIT_DIR}/autotest-m1.git/src/boot.bin ${IMAGES_DIR}/

echo "build data patitions ..."
mkdir -p ${IMAGE_DIR}/data.flash5/patchpool
find ${MILKYMIST_GIT_DIR}/flickernoise.git/patches -name "*.fnp" -exec cp {} ${IMAGE_DIR}/data.flash5/patchpool \;

make -C ${MILKYMIST_GIT_DIR}/rtems-yaffs2.git/utils mm-mkyaffs2image
${MILKYMIST_GIT_DIR}/rtems-yaffs2.git/utils/mm-mkyaffs2image ${IMAGE_DIR}/data.flash5 ${IMAGES_DIR}/data.flash5.bin convert  >> ${BUILD_LOG} 2>&1
chmod 644 ${IMAGES_DIR}/data.flash5.bin

echo "generate md5sum ..."
(cd ${IMAGES_DIR} && md5sum --binary * > ${IMAGES_DIR}/md5sums)


echo "create SDK ..."
(cd /opt/ && tar cjvf ${IMAGES_DIR}/Flickernoise-lm32-rtems-4.11-SDK-for-Linux-x86_64.tar.bz2 rtems-4.11/)

echo "DONE!"
