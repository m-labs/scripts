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

# For Mac OS X use curl.
WGET=wget -c -O 
# WGET=curl -o 

# export PATH=/opt/rtems-4.11/bin:$PATH 
# export RTEMS_MAKEFILE_PATH=/opt/rtems-4.11/lm32-rtems4.11/milkymist

RTEMS_VERSION=4.11
RTEMS_MAKEFILE_PATH ?= \
    /opt/rtems-$(RTEMS_VERSION)/lm32-rtems$(RTEMS_VERSION)/milkymist

LIBPNG_VERSION    = 1.5.6
JBIG2DEC_VERSION  = 0.11
FREETYPE2_VERSION = 2.4.4
MUPDF_VERSION     = 0.8
CURL_VERSION      = 7.22.0
EXPAT_VERSION     = 2.0.1

LIBPNG    = libpng-$(LIBPNG_VERSION).tar.gz
LIBJPEG   = jpegsrc.v8c.tar.gz
OPENJPEG  = openjpeg_v1_2.tar.gz
JBIG2DEC  = jbig2dec-$(JBIG2DEC_VERSION).tar.gz
FREETYPE2 = freetype-$(FREETYPE2_VERSION).tar.gz
MUPDF     = mupdf-$(MUPDF_VERSION)-source.tar.gz
CURL      = curl-$(CURL_VERSION).tar.bz2
EXPAT     = expat-$(EXPAT_VERSION).tar.gz

DL        = $(if $(wildcard ../dl/.),../dl,dl)
BUILD_DIR = ./build_dir

MILKYMIST_GIT_URL  = git://github.com/milkymist
MILKYMIST_GIT_DIR ?= /opt/milkymist

CONFIGURE_VARS = CC=lm32-rtems4.11-gcc AR=lm32-rtems4.11-ar \
    LD=lm32-rtems4.11-ld RANLIB=lm32-rtems4.11-ranlib \
    CFLAGS="-O9 -Wall -mbarrel-shift-enabled -mmultiply-enabled \
           -mdivide-enabled -msign-extend-enabled \
           -I $(RTEMS_MAKEFILE_PATH)/lib/include -B $(RTEMS_MAKEFILE_PATH)/lib \
           -specs bsp_specs -qrtems"

RTEMS_CONFIGURE_FLAGS = --target=lm32-rtems4.11 --enable-rtemsbsp=milkymist \
    --enable-testsuites=samples --enable-posix --disable-itron \
    --enable-networking --disable-multiprocessing

HOST_CC   = gcc

ALL: flickernoise.fbi flickernoise-pdf.fbiz

build_dir/.prepare:
	mkdir -p build_dir
	touch $@

$(BUILD_DIR)/libpng: $(DL)/$(LIBPNG).ok build_dir/.prepare
	tar xf $(DL)/$(LIBPNG) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/libpng-$(LIBPNG_VERSION) && $(CONFIGURE_VARS) \
	CPPFLAGS="-DPNG_NO_FLOATING_ARITHMETIC -DPNG_NO_FLOATING_POINT" \
	 ./configure --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH) \
	 --host=lm32-rtems4.11 && \
	 make all install)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* \
	 $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/libjpeg: $(DL)/$(LIBJPEG).ok build_dir/.prepare
	tar xf $(DL)/$(LIBJPEG) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/jpeg-8c && $(CONFIGURE_VARS) ./configure \
	 --host=lm32-rtems4.11 --disable-shared \
	 --prefix=$(RTEMS_MAKEFILE_PATH) && \
	 make all install)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/openjpeg: $(DL)/$(OPENJPEG).ok build_dir/.prepare
	tar xf $(DL)/$(OPENJPEG) -C $(BUILD_DIR)
	mv $(BUILD_DIR)/trunk $(BUILD_DIR)/openjpeg-trunk
	(cd $(BUILD_DIR)/openjpeg-trunk && \
	 patch -Np1 < ../../patches/openjpeg-0001-for-milkymist-one.patch)
	(cd $(BUILD_DIR)/openjpeg-trunk && $(CONFIGURE_VARS) make && \
	 lm32-rtems4.11-ranlib libopenjpeg.a && \
	 cp libopenjpeg.a $(RTEMS_MAKEFILE_PATH)/lib && \
	 cp libopenjpeg/openjpeg.h $(RTEMS_MAKEFILE_PATH)/lib/include)
	touch $@

$(BUILD_DIR)/jbig2dec: $(DL)/$(JBIG2DEC).ok build_dir/.prepare
	tar xf $(DL)/$(JBIG2DEC) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION) && rm config.sub && \
	 automake --add-missing ; exit 0)
	(cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION) && $(CONFIGURE_VARS) \
	 ./configure --host=lm32-rtems4.11 --disable-shared \
	 --prefix=$(RTEMS_MAKEFILE_PATH) && \
	 make all install)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/freetype2: $(DL)/$(FREETYPE2).ok build_dir/.prepare
	tar xf $(DL)/$(FREETYPE2) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/freetype-$(FREETYPE2_VERSION) && \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared \
	 --prefix=$(RTEMS_MAKEFILE_PATH) && make all install)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* \
	 $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/mupdf: $(DL)/$(MUPDF).ok  build_dir/.prepare  \
                    $(BUILD_DIR)/libpng $(BUILD_DIR)/libjpeg \
                    $(BUILD_DIR)/openjpeg $(BUILD_DIR)/jbig2dec \
		    $(BUILD_DIR)/freetype2
	tar xf $(DL)/$(MUPDF) -C $(BUILD_DIR)
#First, compile the code generation tools natively:
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION) && \
	 patch -Np1 < ../../patches/mupdf-0001-for-milkymist-one.patch)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION) && \
	 mkdir -p build/release && \
	 $(HOST_CC) -o build/release/cmapdump ./mupdf/cmapdump.c  \
	     -lfreetype -ljpeg -lz -lm -Ifitz && \
	 $(HOST_CC) -o build/release/fontdump ./mupdf/fontdump.c  \
	     -lfreetype -ljpeg -lz -lm -Ifitz && \
	 mkdir -p build/generated)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION) && \
	 OS=Rtems CC=lm32-rtems4.11-gcc \
	 CFLAGS="-O9 -mbarrel-shift-enabled -mmultiply-enabled \
	  -mdivide-enabled -msign-extend-enabled \
	  -I $(RTEMS_MAKEFILE_PATH)/lib/include -I \
	  $(RTEMS_MAKEFILE_PATH)/lib/include/freetype2 \
	  -B $(RTEMS_MAKEFILE_PATH)/lib -specs bsp_specs -qrtems" \
	 LDFLAGS="-L $(RTEMS_MAKEFILE_PATH)/lib" \
	 make build=release build/release/libmupdf.a)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION) && \
	 cp fitz/fitz.h   $(RTEMS_MAKEFILE_PATH)/lib/include && \
	 cp mupdf/mupdf.h $(RTEMS_MAKEFILE_PATH)/lib/include && \
	 cp build/release/libmupdf.a $(RTEMS_MAKEFILE_PATH)/lib)
	touch $@

$(BUILD_DIR)/curl: $(DL)/$(CURL).ok
	tar xf $(DL)/$(CURL) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/curl-$(CURL_VERSION) && \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared \
	  --prefix=$(RTEMS_MAKEFILE_PATH) --without-librtmp --disable-ftp \
	  --disable-ldap --disable-ldaps --disable-rtsp --disable-dict \
	  --disable-telnet --disable-tftp --disable-pop3 --disable-imap \
	  --disable-smtp --disable-gopher --disable-manual && \
	 echo "#define HAVE_SOCKET 1" >> lib/setup.h && \
	 make all install)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* \
	  $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/expat: $(DL)/$(EXPAT).ok
	tar xf $(DL)/$(EXPAT) -C $(BUILD_DIR)
	(cd $(BUILD_DIR)/expat-$(EXPAT_VERSION) && \
	 sed -i 's/ppc)/lm32)/' conftools/config.sub && \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared \
	  --prefix=$(RTEMS_MAKEFILE_PATH) && \
	 make all install)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* \
	  $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

REPO_DIRS=milkymist flickernoise rtems-yaffs2 liboscparse mtk autotest-m1 
milkymist-git-clone:
	mkdir -p $(MILKYMIST_GIT_DIR)
	git clone git://git.rtems.org/rtems.git $(MILKYMIST_GIT_DIR)/rtems
	for d in $(REPO_DIRS); \
	  do (git clone $(MILKYMIST_GIT_URL)/$$d.git \
	      $(MILKYMIST_GIT_DIR)/$$d) || exit 1; \
	done

milkymist-git-update:
	(cd $(MILKYMIST_GIT_DIR)/rtems && git fetch -a && \
	  git reset --hard origin/master) || exit 1;
	for d in $(REPO_DIRS); \
	  do (cd $(MILKYMIST_GIT_DIR)/$$d  && git fetch -a && \
	      git reset --hard origin/master) || exit 1; \
	done

#You will need Lemon and RE2C to compile libFPVM. 
libfpvm:
	make -C $(MILKYMIST_GIT_DIR)/milkymist/software/libfpvm/ install

mtk:
	make -C $(MILKYMIST_GIT_DIR)/$@ milkymist install-milkymist

liboscparse:
	make -C $(MILKYMIST_GIT_DIR)/$@ all install

rtems-yaffs2:
	(cd $(MILKYMIST_GIT_DIR)/$@ && make -f Makefile.rtems all install)

rtems: $(BUILD_DIR)/bsp-milkymist/Makefile
	(cd $(BUILD_DIR)/bsp-milkymist && make all install)
	touch $@

$(BUILD_DIR)/bsp-milkymist/Makefile:
	mkdir -p $(BUILD_DIR)/bsp-milkymist
	(cd $(MILKYMIST_GIT_DIR)/rtems && \
	  ./bootstrap -c && ./bootstrap -p && ./bootstrap)
	(cd $(BUILD_DIR)/bsp-milkymist && \
	  $(MILKYMIST_GIT_DIR)/rtems/configure $(RTEMS_CONFIGURE_FLAGS))

#you will need clang for compile milkymist tools
flickernoise.fbi: rtems libfpvm mtk liboscparse rtems-yaffs2 \
		  $(BUILD_DIR)/mupdf $(BUILD_DIR)/curl $(BUILD_DIR)/expat
	make -C $(MILKYMIST_GIT_DIR)/flickernoise/src \
	     clean bin/flickernoise.fbi
	cp $(MILKYMIST_GIT_DIR)/flickernoise/src/bin/$@ .

flickernoise-pdf.fbiz: flickernoise.fbi
	WITH_PDF=1 make -C $(MILKYMIST_GIT_DIR)/flickernoise/src \
	     clean bin/flickernoise.fbiz
	cp $(MILKYMIST_GIT_DIR)/flickernoise/src/bin/flickernoise.fbiz ./$@

boot.bin:
	MMDIR=$(MILKYMIST_GIT_DIR)/milkymist \
	  make -C $(MILKYMIST_GIT_DIR)/autotest-m1/src clean boot.bin
	cp $(MILKYMIST_GIT_DIR)/autotest-m1/src/boot.bin ./$@

boot.crc.bin:
	MMDIR=$(MILKYMIST_GIT_DIR)/milkymist IMAGES_DIR=$(IMAGES_DIR) \
	  make -C $(MILKYMIST_GIT_DIR)/autotest-m1/src clean boot.crc.bin
	cp $(MILKYMIST_GIT_DIR)/autotest-m1/src/boot.crc.*.bin ./

####
$(DL)/$(LIBPNG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(LIBPNG) "http://dfn.dl.sourceforge.net/\
project/libpng/libpng15/$(LIBPNG_VERSION)/$(LIBPNG)"
	touch $@

$(DL)/$(LIBJPEG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(LIBJPEG) "http://www.ijg.org/files/$(LIBJPEG)"
	touch $@

$(DL)/$(OPENJPEG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(OPENJPEG) "http://www.openjpeg.org/$(OPENJPEG)"
	touch $@

$(DL)/$(JBIG2DEC).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(JBIG2DEC) \
	  "http://ghostscript.com/~giles/jbig2/jbig2dec/$(JBIG2DEC)"
	touch $@

$(DL)/$(FREETYPE2).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(FREETYPE2) "http://ufpr.dl.sourceforge.net/\
project/freetype/freetype2/$(FREETYPE2_VERSION)/$(FREETYPE2)"
	touch $@

$(DL)/$(MUPDF).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(MUPDF) "http://mupdf.com/download/archive/$(MUPDF)"
	touch $@

$(DL)/$(CURL).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(CURL) "http://curl.haxx.se/download/$(CURL)"
	touch $@

$(DL)/$(EXPAT).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(EXPAT) "http://download.sourceforge.net/\
project/expat/expat/$(EXPAT_VERSION)/expat-$(EXPAT_VERSION).tar.gz"
	touch $@

.PHONY: clean clean-rtems boot.crc.bin

clean:
	rm -rf build_dir/*

clean-rtems:
	rm -rf build_dir/bsp-milkymist/
