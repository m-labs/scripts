#!/bin/bash

###################################################################
__VERSION__="2011-08-26"
echo "Version of me: ${__VERSION__}"
echo "File name: $0"

FJMEM="fjmem.bit"

###################################################################
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

lockflash 0x000000 55

pld reconfigure
EOF

jtag ${BATCH_FILE}
if [ "$?" == "0" ]; then
    rm -f ${BATCH_FILE}

    echo "-------------------------------------------------------------"
    echo "Your m1 rescue partitions have locked."
    echo "-------------------------------------------------------------"
else
    echo "there are errors when running jtag."
fi
