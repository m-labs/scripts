#!/bin/bash

DEV=sdb

umount /dev/${DEV}*

tr '\0' '\377' < /dev/zero | dd of=/dev/${DEV} bs=1024 count=1024

FDISK_CMD_FILE=`mktemp`
cat > ${FDISK_CMD_FILE}<<EOF
o
n
p
1
1

t
6
w
EOF
fdisk -b 512 /dev/${DEV} < ${FDISK_CMD_FILE}

mkdosfs -F 16 /dev/${DEV}1

fdisk -l /dev/${DEV}
