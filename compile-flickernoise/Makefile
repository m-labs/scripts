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
RTEMS_MAKEFILE_PATH?=/opt/rtems-$(RTEMS_VERSION)/lm32-rtems$(RTEMS_VERSION)/milkymist

LIBPNG_VERSION=1.5.4
JBIG2DEC_VERSION=0.11
FREETYPE2_VERSION=2.4.4
MUPDF_VERSION=0.8
CURL_VERSION=7.21.7
EXPAT_VERSION=2.0.1

LIBPNG=libpng-$(LIBPNG_VERSION).tar.gz
LIBJPEG=jpegsrc.v8b.tar.gz
OPENJPEG=openjpeg_v1_2.tar.gz
JBIG2DEC=jbig2dec-$(JBIG2DEC_VERSION).tar.gz
FREETYPE2=freetype-$(FREETYPE2_VERSION).tar.gz
MUPDF=mupdf-$(MUPDF_VERSION)-source.tar.gz
CURL=curl-$(CURL_VERSION).tar.bz2
EXPAT=expat-$(EXPAT_VERSION).tar.gz

DL=$(if $(wildcard ../dl/.),../dl,dl)
BUILD_DIR=build_dir

MILKYMIST_GIT_URL:=git://github.com/milkymist
MILKYMIST_GIT_DIR?=/opt/milkymist

CONFIGURE_VARS=CC=lm32-rtems4.11-gcc \
	AR=lm32-rtems4.11-ar \
	LD=lm32-rtems4.11-ld \
	RANLIB=lm32-rtems4.11-ranlib \
	CFLAGS="-O9 -Wall -mbarrel-shift-enabled \
	  -mmultiply-enabled -mdivide-enabled -msign-extend-enabled \
	  -I $(RTEMS_MAKEFILE_PATH)/lib/include \
	  -B $(RTEMS_MAKEFILE_PATH)/lib \
	  -specs bsp_specs -qrtems"

RTEMS_CONFIGURE_FLAGS=--target=lm32-rtems4.11 --enable-rtemsbsp=milkymist \
	--enable-testsuites=samples --enable-posix --disable-itron \
	--enable-networking --disable-multiprocessing

ALL:flickernoise.fbi flickernoise-pdf.fbiz

build_dir/.prepare:
	mkdir -p build_dir
	touch $@

$(BUILD_DIR)/libpng: $(DL)/$(LIBPNG).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(LIBPNG)
	(cd $(BUILD_DIR)/libpng-$(LIBPNG_VERSION); $(CONFIGURE_VARS) \
	CPPFLAGS="-DPNG_NO_FLOATING_ARITHMETIC -DPNG_NO_FLOATING_POINT" \
	 ./configure --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH) \
	 --host=lm32-rtems4.11; \
	 make; \
	 make install; \
	)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/libjpeg: $(DL)/$(LIBJPEG).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(LIBJPEG)
	(cd $(BUILD_DIR)/jpeg-8b; $(CONFIGURE_VARS) ./configure \
	 --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install;\
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/openjpeg: $(DL)/$(OPENJPEG).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(OPENJPEG); mv trunk openjpeg-trunk
	cd $(BUILD_DIR)/openjpeg-trunk; \
	 patch -Np1 < ../../patches/openjpeg-0001-for-milkymist-one.patch
	cd $(BUILD_DIR)/openjpeg-trunk; $(CONFIGURE_VARS) make; \
	 lm32-rtems4.11-ranlib libopenjpeg.a; \
	 cp libopenjpeg.a $(RTEMS_MAKEFILE_PATH)/lib; \
	 cp libopenjpeg/openjpeg.h $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/jbig2dec: $(DL)/$(JBIG2DEC).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(JBIG2DEC)
	cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION); rm config.sub; automake --add-missing; exit 0
	(cd $(BUILD_DIR)/jbig2dec-$(JBIG2DEC_VERSION); $(CONFIGURE_VARS) ./configure \
	  --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/freetype2: $(DL)/$(FREETYPE2).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(FREETYPE2)
	(cd $(BUILD_DIR)/freetype-$(FREETYPE2_VERSION); \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared \
	 --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install; \
	)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/mupdf: $(DL)/$(MUPDF).ok  build_dir/.prepare  \
                    $(BUILD_DIR)/libpng $(BUILD_DIR)/libjpeg \
                    $(BUILD_DIR)/openjpeg $(BUILD_DIR)/jbig2dec $(BUILD_DIR)/freetype2
	cd $(BUILD_DIR); tar xf ../$(DL)/$(MUPDF)
#First, compile the code generation tools natively:
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION); \
	 patch -Np1 < ../../patches/mupdf-0001-for-milkymist-one.patch; \
	)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION); \
	 mkdir -p build/release; \
	 gcc -o build/release/cmapdump ./mupdf/cmapdump.c  -lfreetype -ljpeg -lz -lm -Ifitz; \
	 gcc -o build/release/fontdump ./mupdf/fontdump.c  -lfreetype -ljpeg -lz -lm -Ifitz; \
	 mkdir -p build/generated; \
	)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION); \
	 OS=Rtems \
	 CC=lm32-rtems4.11-gcc \
	 CFLAGS="-O9 -mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled -msign-extend-enabled \
	 -I $(RTEMS_MAKEFILE_PATH)/lib/include -I $(RTEMS_MAKEFILE_PATH)/lib/include/freetype2 \
	 -B $(RTEMS_MAKEFILE_PATH)/lib -specs bsp_specs -qrtems" \
	 LDFLAGS="-L $(RTEMS_MAKEFILE_PATH)/lib" \
	 make build=release build/release/libmupdf.a; \
	)
	(cd $(BUILD_DIR)/mupdf-$(MUPDF_VERSION); \
	 cp fitz/fitz.h   $(RTEMS_MAKEFILE_PATH)/lib/include; \
	 cp mupdf/mupdf.h $(RTEMS_MAKEFILE_PATH)/lib/include; \
	 cp build/release/libmupdf.a $(RTEMS_MAKEFILE_PATH)/lib; \
	)
	touch $@

$(BUILD_DIR)/curl: $(DL)/$(CURL).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(CURL)
	(cd $(BUILD_DIR)/curl-$(CURL_VERSION); \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH) \
	 --without-librtmp --disable-ftp --disable-ldap --disable-ldaps --disable-rtsp --disable-dict \
	 --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher \
	 --disable-manual; \
	 echo "#define HAVE_SOCKET 1" >> lib/setup.h; \
	 make; \
	 make install; \
	)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

$(BUILD_DIR)/expat: $(DL)/$(EXPAT).ok
	cd $(BUILD_DIR); tar xf ../$(DL)/$(EXPAT)
	(cd $(BUILD_DIR)/expat-$(EXPAT_VERSION); \
	 sed -i 's/ppc)/lm32)/' conftools/config.sub; \
	 $(CONFIGURE_VARS) ./configure --host=lm32-rtems4.11 --disable-shared --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 make install; \
	)
	cp -rf $(RTEMS_MAKEFILE_PATH)/include/* $(RTEMS_MAKEFILE_PATH)/lib/include
	rm -rf $(RTEMS_MAKEFILE_PATH)/include/*
	touch $@

milkymist-git-clone:
	mkdir -p $(MILKYMIST_GIT_DIR)
	git clone $(MILKYMIST_GIT_URL)/milkymist.git $(MILKYMIST_GIT_DIR)/milkymist.git
	git clone $(MILKYMIST_GIT_URL)/flickernoise.git $(MILKYMIST_GIT_DIR)/flickernoise.git
	git clone $(MILKYMIST_GIT_URL)/rtems-yaffs2.git $(MILKYMIST_GIT_DIR)/rtems-yaffs2.git
	git clone -b mmstaging $(MILKYMIST_GIT_URL)/rtems.git $(MILKYMIST_GIT_DIR)/rtems.git
	git clone $(MILKYMIST_GIT_URL)/liboscparse.git $(MILKYMIST_GIT_DIR)/liboscparse.git
	git clone $(MILKYMIST_GIT_URL)/mtk.git $(MILKYMIST_GIT_DIR)/mtk.git
	git clone $(MILKYMIST_GIT_URL)/autotest-m1.git $(MILKYMIST_GIT_DIR)/autotest-m1.git

milkymist-git-update:
	(cd $(MILKYMIST_GIT_DIR)/milkymist.git; git fetch -a; git reset --hard origin/master)
	(cd $(MILKYMIST_GIT_DIR)/flickernoise.git; git fetch -a; git reset --hard origin/master)
	(cd $(MILKYMIST_GIT_DIR)/rtems-yaffs2.git; git fetch -a; git reset --hard origin/master)
	(cd $(MILKYMIST_GIT_DIR)/rtems.git; git fetch -a; git reset --hard origin/mmstaging)
	(cd $(MILKYMIST_GIT_DIR)/liboscparse.git; git fetch -a; git reset --hard origin/master)
	(cd $(MILKYMIST_GIT_DIR)/mtk.git; git fetch -a; git reset --hard origin/master)
	(cd $(MILKYMIST_GIT_DIR)/autotest-m1.git; git fetch -a; git reset --hard origin/master)

#You will need Lemon and RE2C to compile libFPVM. 
libfpvm:
	(cd $(MILKYMIST_GIT_DIR)/milkymist.git/software/libfpvm/lm32-rtems && make && make install)

mtk:
	(cd $(MILKYMIST_GIT_DIR)/$@.git && make milkymist && make install-milkymist)

liboscparse:
	(cd $(MILKYMIST_GIT_DIR)/$@.git && make && make install)

rtems-yaffs2:
	(cd $(MILKYMIST_GIT_DIR)/$@.git && make -f Makefile.rtems && make -f Makefile.rtems  install)

rtems: $(BUILD_DIR)/bsp-milkymist/Makefile
	(cd $(BUILD_DIR)/bsp-milkymist; make all; make install)
	touch $@

$(BUILD_DIR)/bsp-milkymist/Makefile:
	mkdir -p $(BUILD_DIR)/bsp-milkymist
	(cd $(MILKYMIST_GIT_DIR)/rtems.git && patch -Np1 < ${CURDIR}/patches/rtems-0001-zlib-git-cvs-bug.patch)
	#workaround git cvs bug
	(cd $(MILKYMIST_GIT_DIR)/rtems.git && ./bootstrap -c && ./bootstrap -p && ./bootstrap)
	(cd $(BUILD_DIR)/bsp-milkymist && $(MILKYMIST_GIT_DIR)/rtems.git/configure $(RTEMS_CONFIGURE_FLAGS))

#you will need clang for compile milkymist tools
flickernoise.fbi: rtems libfpvm mtk liboscparse rtems-yaffs2 $(BUILD_DIR)/mupdf $(BUILD_DIR)/curl $(BUILD_DIR)/expat
	(cd $(MILKYMIST_GIT_DIR)/flickernoise.git/src && make clean && make bin/flickernoise.fbi)
	cp $(MILKYMIST_GIT_DIR)/flickernoise.git/src/bin/$@ ./

flickernoise-pdf.fbiz: flickernoise.fbi
	(cd $(MILKYMIST_GIT_DIR)/flickernoise.git/src && make clean && WITH_PDF=1 make bin/flickernoise.fbiz)
	cp $(MILKYMIST_GIT_DIR)/flickernoise.git/src/bin/flickernoise.fbiz ./$@

autotest-m1-boot.bin:
	(cd $(MILKYMIST_GIT_DIR)/autotest-m1.git/src && MMDIR=../$(MILKYMIST_GIT_DIR)/milkymist.git make)
	cp $(MILKYMIST_GIT_DIR)/autotest-m1.git/src/boot.bin ./$@

####
$(DL)/$(LIBPNG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(LIBPNG) \
          http://dfn.dl.sourceforge.net/project/libpng/libpng15/$(LIBPNG_VERSION)/$(LIBPNG)
	touch $@

$(DL)/$(LIBJPEG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(LIBJPEG) \
	  http://www.ijg.org/files/$(LIBJPEG)
	touch $@

$(DL)/$(OPENJPEG).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(OPENJPEG) \
	  http://www.openjpeg.org/$(OPENJPEG)
	touch $@

$(DL)/$(JBIG2DEC).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(JBIG2DEC) \
	  http://ghostscript.com/~giles/jbig2/jbig2dec/$(JBIG2DEC)
	touch $@

$(DL)/$(FREETYPE2).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(FREETYPE2) \
	  http://ufpr.dl.sourceforge.net/project/freetype/freetype2/$(FREETYPE2_VERSION)/$(FREETYPE2)
	touch $@

$(DL)/$(MUPDF).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(MUPDF) \
          http://mupdf.com/download/archive/$(MUPDF)
	touch $@

$(DL)/$(CURL).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(CURL) \
	 http://curl.haxx.se/download/$(CURL)
	touch $@

$(DL)/$(EXPAT).ok:
	mkdir -p dl
	$(WGET) $(DL)/$(EXPAT) \
	 http://download.sourceforge.net/project/expat/expat/$(EXPAT_VERSION)/expat-$(EXPAT_VERSION).tar.gz
	touch $@

.PHONY: clean clean-rtems

clean:
	rm -rf build_dir/*

clean-rtems:
	(cd $(MILKYMIST_GIT_DIR)/rtems.git && git checkout cpukit/zlib/zconf.h.in)
	rm -rf build_dir/bsp-milkymist/
