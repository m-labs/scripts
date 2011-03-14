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
BUILD_DIR=build_dir

LEKERNEL_GIT_URL:=https://github.com/lekernel
LEKERNEL_GIT_DIR:=../../lekernel

CONFIGURE_VARS=CC=lm32-rtems4.11-gcc \
	AR=lm32-rtems4.11-ar \
	CFLAGS="-O9 -Wall -mbarrel-shift-enabled \
	  -mmultiply-enabled -mdivide-enabled -msign-extend-enabled \
	  -I $(RTEMS_MAKEFILE_PATH)/lib/include \
	  -B $(RTEMS_MAKEFILE_PATH)/lib \
	  -specs bsp_specs -qrtems"

ALL:flickernoise

build_dir/.prepare
	mkdir -p build_dir
	touch $@

$(BUILD_DIR)/zlib: $(DL)/$(ZLIB).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(ZLIB)
	(cd $(BUILD_DIR)/zlib-$(ZLIB_VERSION); $(CONFIGURE_VARS) \
	 ./configure --static --prefix=$(RTEMS_MAKEFILE_PATH); \
	 make; \
	 sed -i '/cp $$(SHAREDLIBV) $$(DESTDIR)$$(sharedlibdir)/d' Makefile; \
	 make install; \
	)
	mv $(RTEMS_MAKEFILE_PATH)/include/z* $(RTEMS_MAKEFILE_PATH)/lib/include
	touch $@

$(BUILD_DIR)/libpng: $(DL)/$(LIBPNG).ok build_dir/.prepare
	cd $(BUILD_DIR); tar xf ../$(DL)/$(LIBPNG)
	(cd $(BUILD_DIR)/libpng-$(LIBPNG_VERSION); $(CONFIGURE_VARS) \
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
	cd $(BUILD_DIR)/freetype-$(FREETYPE2_VERSION)
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
$(BUILD_DIR)/zlib $(BUILD_DIR)/libpng $(BUILD_DIR)/libjpeg \
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

#You will need Lemon and RE2C to compile libFPVM. 
lekernel:
	mkdir -p $(LEKERNEL_GIT_DIR)
	git clone $(LEKERNEL_GIT_URL)/milkymist.git $(LEKERNEL_GIT_DIR)/milkymist.git
	git clone $(LEKERNEL_GIT_URL)/flickernoise.git $(LEKERNEL_GIT_DIR)/flickernoise.git
	git clone $(LEKERNEL_GIT_URL)/liboscparse.git $(LEKERNEL_GIT_DIR)/liboscparse.git
	git clone $(LEKERNEL_GIT_URL)/milkymist.git $(LEKERNEL_GIT_DIR)/milkymist.git
	git clone $(LEKERNEL_GIT_URL)/mtk.git $(LEKERNEL_GIT_DIR)/mtk.git
	git clone $(LEKERNEL_GIT_URL)/rtems-yaffs2.git $(LEKERNEL_GIT_DIR)/rtems-yaffs2.git

update_lekernel_git:
	(cd $(LEKERNEL_GIT_DIR)/flickernoise.git; git pull)
	(cd $(LEKERNEL_GIT_DIR)/milkymist.git; git pull)
	(cd $(LEKERNEL_GIT_DIR)/mtk.git; git pull)
	(cd $(LEKERNEL_GIT_DIR)/liboscparse.git; git pull)
	(cd $(LEKERNEL_GIT_DIR)/rtems-yaffs2.git; git pull)

libfpvm:
	(cd $(LEKERNEL_GIT_DIR)/milkymist.git/software/libfpvm/lm32-rtems && make && make install)
	touch $@
mtk:
	(cd $(LEKERNEL_GIT_DIR)/$@.git && make milkymist && make install-milkymist; )
	touch $@

liboscparse:
	(cd $(LEKERNEL_GIT_DIR)/$@.git && make && make install;)
	touch $@

rtems-yaffs2:
	(cd $(LEKERNEL_GIT_DIR)/$@.git/direct/rtems && make && make install;)
	touch $@

#you will need clang for compile milkymist tools
flickernoise: $(BUILD_DIR)/mupdf libfpvm mtk liboscparse rtems-yaffs2 
	(cd $(LEKERNEL_GIT_DIR)/$@.git/src && make)
	cp $(LEKERNEL_GIT_DIR)/$@.git/src/bin/* ./

####
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


clean:
	rm -rf build_dir/*