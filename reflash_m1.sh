#!/bin/sh

# version of me
__VERSION__="2011-04-10"

BATCH_FILE=flash.batch
NOVERIFY=noverify
FLICKERNOISE=flickernoise.fbi

batch() {
    echo -e "$1" >> "${BATCH_FILE}"
}

rm -rf ${BATCH_FILE}
batch "cable milkymist"
batch "detect"
batch "instruction CFG_OUT 000100 BYPASS"
batch "instruction CFG_IN 000101 BYPASS"
batch "pld load fjmem.bit"
batch "initbus fjmem opcode=000010"
batch "frequency 6000000"
batch "detectflash 0"
batch "endian big"

batch "flashmem 0x000000 standby.fpg ${NOVERIFY}"

batch "flashmem 0x0A0000 soc-rescue.fpg ${NOVERIFY}"
batch "flashmem 0x220000 bios-rescue.bin ${NOVERIFY}"
batch "flashmem 0x240000 splash-rescue.raw ${NOVERIFY}"

batch "flashmem 0x6E0000 soc.fpg ${NOVERIFY}"
batch "flashmem 0x860000 bios.bin ${NOVERIFY}"
batch "flashmem 0x880000 splash.raw ${NOVERIFY}"

batch "flashmem 0x920000 ${FLICKERNOISE} ${NOVERIFY}"

batch "eraseflash 0xD20000 151"
batch "flashmem   0xD20000 data.flash5.bin ${NOVERIFY}"

jtag ${BATCH_FILE}
