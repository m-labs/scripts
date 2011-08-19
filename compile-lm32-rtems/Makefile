#
# Written 2011 by Xiangfu Liu <xiangfu@sharism.cc>
# this file try to manager build RTMS toolchain
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

RTEMS_VERSION=4.11
#make sure you have wrtie access
RTEMS_PREFIX=/opt/rtems-$(RTEMS_VERSION)

RTEMS_SOURCES_URL=http://www.rtems.org/ftp/pub/rtems/SOURCES/$(RTEMS_VERSION)

# For Mac OS X use curl.
WGET=wget -c -O 
# WGET=curl -o 

BINUTILS_VERSION=2.21
GCC_CORE_VERSION=4.5.2
NEWLIB_VERSION=1.19.0
GCC_G++_VERSION=4.5.2
GDB_VERSION=7.2
GMP_VERSION=4.3.2
MPC_VERSION=0.8.1
MPFR_VERSION=2.4.2

BINUTILS=binutils-$(BINUTILS_VERSION).tar.bz2 
GCC_CORE=gcc-core-$(GCC_CORE_VERSION).tar.bz2 
NEWLIB=newlib-$(NEWLIB_VERSION).tar.gz
GCC_G++=gcc-g++-$(GCC_G++_VERSION).tar.bz2 
GDB=gdb-$(GDB_VERSION).tar.bz2
GMP=gmp-$(GMP_VERSION).tar.bz2
MPC=mpc-$(MPC_VERSION).tar.gz 
MPFR=mpfr-$(MPFR_VERSION).tar.bz2

BINUTILS_PATCH=binutils-$(BINUTILS_VERSION)-rtems$(RTEMS_VERSION)-20110107.diff
GCC_CORE_PATCH=gcc-core-$(GCC_CORE_VERSION)-rtems$(RTEMS_VERSION)-20110220.diff
NEWLIB_PATCH=newlib-$(NEWLIB_VERSION)-rtems$(RTEMS_VERSION)-20110109.diff
GCC_G++_PATCH=gcc-g++-$(GCC_G++_VERSION)-rtems$(RTEMS_VERSION)-20110131.diff
GDB_PATCH=gdb-$(GDB_VERSION)-rtems$(RTEMS_VERSION)-20100907.diff

DL=$(if $(wildcard ../dl/.),../dl,dl)

RTEMS_PATCHES_DIR=rtems-patches
MM1_PATCHES_DIR=milkymist-one-patches

.PHONY:	all clean

all: .install.gdb.ok .install.gcc.ok

.install.gcc.ok: .compile.gcc.ok
	cd b-gcc && make install
	touch $@

.compile.gcc.ok: .install.binutils.ok .patch.ok gcc-$(GCC_CORE_VERSION)/newlib
	export PATH=$(RTEMS_PREFIX)/bin:$$PATH
	mkdir -p b-gcc
	(cd b-gcc/;\
	  ../gcc-$(GCC_CORE_VERSION)/configure --target=lm32-rtems4.11 \
	  --with-gnu-as --with-gnu-ld --with-newlib --verbose --enable-threads \
	  --enable-languages="c" --disable-shared --prefix=$(RTEMS_PREFIX); \
	 make all; \
	 make info; \
	)
	touch $@

.install.binutils.ok: .compile.binutils.ok
	mkdir -p $(RTEMS_PREFIX)
	cd b-binutils && make install
	touch $@

.compile.binutils.ok: .patch.ok
	mkdir -p b-binutils
	(cd b-binutils; \
	 ../binutils-$(BINUTILS_VERSION)/configure --target=lm32-rtems4.11 --prefix=$(RTEMS_PREFIX); \
	 make all; \
	 make info; \
	)
	touch $@

gcc-$(GCC_CORE_VERSION)/newlib: .unzip.ok
	(cd gcc-$(GCC_CORE_VERSION); ln -s ../newlib-$(NEWLIB_VERSION)/newlib;)

.patch.ok: .unzip.ok $(RTEMS_PATCHES_DIR)/.ok
	(cd binutils-$(BINUTILS_VERSION); cat ../$(RTEMS_PATCHES_DIR)/$(BINUTILS_PATCH) | patch -p1)
	(cd gcc-$(GCC_CORE_VERSION); \
	 cat ../$(RTEMS_PATCHES_DIR)/$(GCC_CORE_PATCH) | patch -p1; \
	 cat ../$(MM1_PATCHES_DIR)/gcc-core-0001-support-for-the-hardware-divider.patch | patch -p1; \
	)
	(cd newlib-$(NEWLIB_VERSION); cat ../$(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH) | patch -p1)
	(cd gdb-$(GDB_VERSION); \
	 cat ../$(RTEMS_PATCHES_DIR)/$(GDB_PATCH) | patch -p1; \
	 cat ../$(MM1_PATCHES_DIR)/gdb-remote-target-interrupt-before-ack.patch | patch -p1; \
	)
	touch $@

.unzip.ok: $(DL)/$(BINUTILS).ok $(DL)/$(GCC_CORE).ok $(DL)/$(NEWLIB).ok $(DL)/$(GDB).ok $(DL)/$(MPFR).ok $(DL)/$(MPC).ok $(DL)/$(GMP).ok
	tar xf $(DL)/$(BINUTILS)
	tar xf $(DL)/$(GCC_CORE)
	tar xf $(DL)/$(NEWLIB)
	tar xf $(DL)/$(GDB)
	tar xf $(DL)/$(GMP)
	tar xf $(DL)/$(MPC)
	tar xf $(DL)/$(MPFR)
	rm -rf gcc-$(GCC_CORE_VERSION)/gmp gcc-$(GCC_CORE_VERSION)/mpc gcc-$(GCC_CORE_VERSION)/mpfr
	ln -s  ../gmp-$(GMP_VERSION) gcc-$(GCC_CORE_VERSION)/gmp
	ln -s  ../mpc-$(MPC_VERSION) gcc-$(GCC_CORE_VERSION)/mpc
	ln -s  ../mpfr-$(MPFR_VERSION) gcc-$(GCC_CORE_VERSION)/mpfr
	touch $@

.install.gdb.ok: .compile.gdb.ok
	cd b-gdb && make install
	touch $@

.compile.gdb.ok: .install.binutils.ok .patch.ok
	export PATH=$(RTEMS_PREFIX)/bin:$$PATH
	mkdir -p b-gdb
	(cd b-gdb/; \
	  ../gdb-$(GDB_VERSION)/configure --target=lm32-rtems4.11 --prefix=$(RTEMS_PREFIX); \
	 make all; \
	)
	touch $@

$(RTEMS_PATCHES_DIR)/.ok:
	mkdir -p $(RTEMS_PATCHES_DIR)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(BINUTILS_PATCH) $(RTEMS_SOURCES_URL)/$(BINUTILS_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(GCC_CORE_PATCH) $(RTEMS_SOURCES_URL)/$(GCC_CORE_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH) $(RTEMS_SOURCES_URL)/$(NEWLIB_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(GCC_G++_PATCH) $(RTEMS_SOURCES_URL)/$(GCC_G++_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(GDB_PATCH) $(RTEMS_SOURCES_URL)/$(GDB_PATCH)
	touch $@

$(DL)/$(BINUTILS).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(BINUTILS) $(RTEMS_SOURCES_URL)/$(BINUTILS)
	touch $@

$(DL)/$(GCC_CORE).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(GCC_CORE) $(RTEMS_SOURCES_URL)/$(GCC_CORE)
	touch $@

$(DL)/$(GCC_G++).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(GCC_G++) $(RTEMS_SOURCES_URL)/$(GCC_G++)
	touch $@

$(DL)/$(NEWLIB).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(NEWLIB) $(RTEMS_SOURCES_URL)/$(NEWLIB)
	touch $@

$(DL)/$(GDB).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(GDB) $(RTEMS_SOURCES_URL)/$(GDB)
	touch $@

$(DL)/$(GMP).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(GMP) $(RTEMS_SOURCES_URL)/$(GMP)
	touch $@

$(DL)/$(MPC).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(MPC) $(RTEMS_SOURCES_URL)/$(MPC)
	touch $@

$(DL)/$(MPFR).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(MPFR) $(RTEMS_SOURCES_URL)/$(MPFR)
	touch $@

clean:
	rm -rf b-binutils
	rm -rf b-gcc
	rm -rf b-gdb
	rm -rf binutils-$(BINUTILS_VERSION)
	rm -rf gcc-$(GCC_CORE_VERSION)
	rm -rf newlib-$(NEWLIB_VERSION)
	rm -rf gdb-$(GDB_VERSION)
	rm -rf $(RTEMS_PATCHES_DIR)
	rm -rf gmp-$(GMP_VERSION)
	rm -rf mpc-$(MPC_VERSION)
	rm -rf mpfr-$(MPFR_VERSION)
	rm -rf .unzip.ok
	rm -rf .patch.ok
