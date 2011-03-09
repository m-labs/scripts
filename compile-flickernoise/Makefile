#
# Written 2011 by Xiangfu Liu <xiangfu@sharism.cc>
# this file try to manager build flickernoise toolchain
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# before compile flickernoise. you need the lm32-rtems toolchain and rtems

# export PATH=/opt/rtems-4.11/bin:$PATH 
# export RTEMS_MAKEFILE_PATH=/opt/rtems-4.11/lm32-rtems4.11/milkymist

RTEMS_VERSION=4.11
RTEMS_MAKEFILE_PATH?=/opt/rtems-$(RTEMS_VERSION)/lm32-rtems$(RTEMS_VERSION)/milkymist

ZLIB_VERSION=1.2.5
LIBPNG_VERSION=1.4.4
JBIG2DEC_VERSION=0.11
FREETYPE2_VERSION=2.4.4
MUPDF_VERSION=0.8

ZLIB=zlib-$(ZLIB_VERSION).tar.gz
LIBPNG=libpng-$(LIBPNG_VERSION).tar.gz
LIBJPEG=jpegsrc.v8b.tar.gz
OPENJPEG=openjpeg_v1_2.tar.gz
JBIG2DEC=jbig2dec-$(JBIG2DEC_VERSION).tar.gz
FREETYPE2=freetype-$(FREETYPE2_VERSION).tar.gz
MUPDF=mupdf-$(MUPDF_VERSION)-source.tar.gz

DL=$(if $(wildcard ../dl/.),../dl,dl)
BUILD_DIR=$(if $(wildcard ../build_dir/.),../build_dir,build_dir)

CONFIGURE_VARS=CC=lm32-rtems4.11-gcc \
	AR=lm32-rtems4.11-ar \
	CFLAGS="-O9 -Wall -mbarrel-shift-enabled \
	  -mmultiply-enabled -mdivide-enabled -msign-extend-enabled \
	  -I $(RTEMS_MAKEFILE_PATH)/lib/include \
	  -B $(RTEMS_MAKEFILE_PATH)/lib \
	  -specs bsp_specs -qrtems"

$(BUILD_DIR)/zlib: $(DL)/$(ZLIB).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(ZLIB)
	(cd $(BUILD_DIR)/zlib-$(ZLIB_VERSION); $(CONFIGURE_VARS) \
	 ./configure --static --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 sed -i '/cp $$(SHAREDLIBV) $$(DESTDIR)$$(sharedlibdir)/d' Makefile; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/z* $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/libpng: $(DL)/$(LIBPNG).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(LIBPNG)
	(cd $(BUILD_DIR)/libpng-$(LIBPNG_VERSION); $(CONFIGURE_VARS) \
	 ./configure --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH) \
	 --host=lm32-rtems4.11; \
	 make; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/libjpeg: $(DL)/$(LIBJPEG).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(LIBJPEG)
	(cd $(BUILD_DIR)/jpeg-8b; $(CONFIGURE_VARS) ./configure \
	 --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install;\
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/openjpeg: $(DL)/$(OPENJPEG).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(OPENJPEG); mv trunk openjpeg-trunk
	cd $(BUILD_DIR)/openjpeg-trunk; \
	 patch -Np1 < ../../patches/openjpeg-0001-for-milkymist-one.patch
	cd $(BUILD_DIR)/openjpeg-trunk; $(CONFIGURE_VARS) make; \
	 lm32-rtems4.11-ranlib libopenjpeg.a; \
	 cp libopenjpeg.a $(RTEMS_MAKEFILE_PATH)/lib; \
	 cp libopenjpeg/openjpeg.h $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/jbig2dec: $(DL)/$(JBIG2DEC).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(JBIG2DEC)
	cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION); rm config.sub; automake --add-missing; exit 0
	(cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION); $(CONFIGURE_VARS) ./configure \
	  --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/freetype2: $(DL)/$(FREETYPE2).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(FREETYPE2)
	cd $(BUILD_DIR)/freetype-$(FREETYPE2_VERSION)
	(cd $(BUILD_DIR)/freetype-$(FREETYPE2_VERSION); \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared \
	 --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include

$(BUILD_DIR)/mupdf: $(DL)/$(MUPDF).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(MUPDF)
#First, compile the code generation tools natively:
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION); \
	 mkdir -p  build/release/; \
	 $(CC) -o build/release/cmapdump ./mupdf/cmapdump.c  -lfreetype -ljpeg -lz -lm -Ifitz; \
	 $(CC) -o build/release/fontdump ./mupdf/fontdump.c  -lfreetype -ljpeg -lz -lm -Ifitz; \
	)
#Then, edit '''Makerules''' and:
# set <code>CC := lm32-rtems4.11-gcc</code>
# set <code>CFLAGS := -Ifitz -Imupdf -Wall -O9 -Wall -mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled -msign-extend-enabled -I $(RTEMS_MAKEFILE_PATH)/lib/include -I $(RTEMS_MAKEFILE_PATH)/lib/include/freetype2 -B $(RTEMS_MAKEFILE_PATH)/lib -specs bsp_specs -qrtems</code>
	make build=release build/release/libmupdf.a
	cp fitz/fitz.h   $(RTEMS_MAKEFILE_PATH)/lib/include 
	cp mupdf/mupdf.h $(RTEMS_MAKEFILE_PATH)/lib/include 
	cp build/release/libmupdf.a $(RTEMS_MAKEFILE_PATH)/lib

$(BUILD_DIR)/libFPVM:
	cd software/libfpvm/lm32-rtems
	make
	make install

$(BUILD_DIR)/MTK:
#After you have cloned the git repository, compilation and installation are very simple:
#Again, these commands requires the RTEMS_MAKEFILE_PATH environment variable
	make milkymist
	make install-milkymist

$(BUILD_DIR)/liboscparse:
#Run the following commands (making sure the environment variables listed above are set):
	make
	make install

$(BUILD_DIR)/Yaffs:
#[http://github.com/lekernel/rtems-yaffs2 rtems-yaffs2] 
#(Again, this command requires the RTEMS_MAKEFILE_PATH environment variable)
	cd direct/rtems
	make
	make install

$(BUILD_DIR)/Flickernoise:
	cd src
	make

#This produces an ELF binary. From that, you can either:
# try the ELF binary in the QEMU emulator with <code>qemu-system-lm32 -M milkymist -kernel flickernoise</code>
# generate a raw binary file with <code>make flickernoise.ralf</code>, suitable for TFTP netbooting (recommended), booting from the memory card or downloading over the serial line with flterm. Using flterm is not recommended as this method is slow because of the large size of the binary.
# generate a FBI image with <code>make flickernoise.fbi</code> that you can use with the auto-upgrade feature of Flickernoise (0.2+).
# generate a MCS flash image with <code>make flickernoise.mcs</code> 
#that you can download into the board's flash memory so that Flickernoise automatically starts at every boot.


$(DL)/$(ZLIB).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(ZLIB) http://zlib.net/$(ZLIB)
	touch $@

$(DL)/$(LIBPNG).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(LIBPNG) \
	  http://ufpr.dl.sourceforge.net/project/libpng/libpng14/older-releases/$(LIBPNG_VERSION)/$(LIBPNG_VERSION)
	touch $@

$(DL)/$(LIBJPEG).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(LIBJPEG) \
	  http://www.ijg.org/files/$(LIBJPEG)
	touch $@

$(DL)/$(OPENJPEG).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(OPENJPEG) \
	  http://www.openjpeg.org/$(OPENJPEG)
	touch $@

$(DL)/$(JBIG2DEC).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(JBIG2DEC) \
	  http://ghostscript.com/~giles/jbig2/jbig2dec/$(JBIG2DEC)
	touch $@

$(DL)/$(FREETYPE2).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(FREETYPE2) \
	  http://ufpr.dl.sourceforge.net/project/freetype/freetype2/$(FREETYPE2_VERSION)/$(FREETYPE2)
	touch $@

$(DL)/$(MUPDF).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(MUPDF) \
	  http://mupdf.com/download/$(MUPDF)
	touch $@