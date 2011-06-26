#!/bin/bash

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
serial="$2"
EOF

more ${FLASH_CONF_FILE}

ftdi_eeprom --erase-eeprom $1
ftdi_eeprom --flash-eeprom $1 ${FLASH_CONF_FILE}
