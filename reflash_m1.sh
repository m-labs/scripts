#!/bin/sh

# version of me
__VERSION__="2011-04-10"

NOVERIFY=noverify
FLICKERNOISE=flickernoise.fbi

BATCH_FILE=`mktemp`
cat > ${BATCH_FILE}<<EOF
cable milkymist
detect
instruction CFG_OUT 000100 BYPASS
instruction CFG_IN 000101 BYPASS
pld load fjmem.bit
initbus fjmem opcode=000010
frequency 6000000
detectflash 0
endian big

flashmem 0x000000 standby.fpg ${NOVERIFY}

flashmem 0x0A0000 soc-rescue.fpg ${NOVERIFY}
flashmem 0x220000 bios-rescue.bin ${NOVERIFY}
flashmem 0x240000 splash-rescue.raw ${NOVERIFY}
flashmem 0x2E0000 ${FLICKERNOISE} ${NOVERIFY}

flashmem 0x6E0000 soc.fpg ${NOVERIFY}
flashmem 0x860000 bios.bin ${NOVERIFY}
flashmem 0x880000 splash.raw ${NOVERIFY}

flashmem 0x920000 ${FLICKERNOISE} ${NOVERIFY}

eraseflash 0xD20000 151
flashmem   0xD20000 data.flash5.bin ${NOVERIFY}

pld reconfigure
EOF

jtag  ${BATCH_FILE}
rm -f ${BATCH_FILE}
