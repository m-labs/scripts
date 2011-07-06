#!/bin/bash

USB_ORIGIN=0403:6010

DATE=$(date "+%m%d")

BUS=$(lsusb | grep ${USB_ORIGIN} | awk -F":" '{print $1}' | awk '{print $2}')
DEV=$(lsusb | grep ${USB_ORIGIN} | awk -F":" '{print $1}' | awk '{print $4}')

DEVICE=/dev/bus/usb/${BUS}/${DEV}
SERIAL=${DATE}${DEV}

if [ $1 != "" ]; then
	SERIAL=$1
fi

FLASH_CONF_FILE=`mktemp`
cat > ${FLASH_CONF_FILE}<<EOF
vendor_id=0x20b7
product_id=0x0713
chip_type=2232H
self_powered=false
max_power=90
remote_wakeup=false
in_is_isochronous=false
out_is_isochronous=false
suspend_pull_downs=false
change_usb_version=false
usb_version=0
manufacturer="Qi Hardware"
product="Milkymist One JTAG/Serial"
use_serial=true
serial="${SERIAL}"
EOF

echo "Flash device: " ${DEVICE}
echo "Using serial: " ${SERIAL}

./ftdi_eeprom --erase-eeprom ${DEVICE}
./ftdi_eeprom --flash-eeprom ${DEVICE} ${FLASH_CONF_FILE}

echo "Done"
