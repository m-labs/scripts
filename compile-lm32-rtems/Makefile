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

BINUTILS_VERSION=2.23.90
GCC_CORE_VERSION=4.5.4
NEWLIB_VERSION=1.20.0
GDB_VERSION=7.5.1
GMP_VERSION=4.3.2
MPC_VERSION=1.0.1
MPFR_VERSION=3.1.2

BINUTILS=binutils-$(BINUTILS_VERSION).tar.bz2
GCC_CORE=gcc-core-$(GCC_CORE_VERSION).tar.bz2
NEWLIB=newlib-$(NEWLIB_VERSION).tar.gz
GDB=gdb-$(GDB_VERSION).tar.bz2
GMP=gmp-$(GMP_VERSION).tar.bz2
MPC=mpc-$(MPC_VERSION).tar.gz
MPFR=mpfr-$(MPFR_VERSION).tar.bz2

GCC_CORE_PATCH=gcc-core-$(GCC_CORE_VERSION)-rtems$(RTEMS_VERSION)-20120703.diff
NEWLIB_PATCH=newlib-$(NEWLIB_VERSION)-rtems$(RTEMS_VERSION)-20130325.diff
GDB_PATCH=gdb-$(GDB_VERSION)-rtems$(RTEMS_VERSION)-20121130.diff

DL=$(if $(wildcard ../dl/.),../dl,dl)

RTEMS_PATCHES_DIR=rtems-patches
MM1_PATCHES_DIR=milkymist-one-patches

# make sure this rule stays at top
all: .install.gdb.ok .install.gcc.ok

.PHONY: all clean

.install.gcc.ok: .compile.gcc.ok
	$(MAKE) -C b-gcc install
	touch $@

.compile.gcc.ok: .install.binutils.ok .patch.ok gcc-$(GCC_CORE_VERSION)/newlib
	export PATH=$(RTEMS_PREFIX)/bin:$$PATH
	mkdir -p b-gcc
	cd b-gcc/ && \
	  ../gcc-$(GCC_CORE_VERSION)/configure --target=lm32-rtems4.11 \
	  --with-gnu-as --with-gnu-ld --with-newlib --verbose \
	  --enable-threads --enable-languages="c" --disable-shared \
	  --prefix=$(RTEMS_PREFIX)
	$(MAKE) -C b-gcc all
	$(MAKE) -C b-gcc info
	touch $@

.install.binutils.ok: .compile.binutils.ok
	mkdir -p $(RTEMS_PREFIX)
	$(MAKE) -C b-binutils install
	touch $@

.compile.binutils.ok: .patch.ok
	mkdir -p b-binutils
	cd b-binutils && \
	 ../binutils-$(BINUTILS_VERSION)/configure --target=lm32-rtems4.11 \
	 --prefix=$(RTEMS_PREFIX)
	$(MAKE) -C b-binutils all
	$(MAKE) -C b-binutils info
	touch $@

gcc-$(GCC_CORE_VERSION)/newlib: .unzip.ok
	cd gcc-$(GCC_CORE_VERSION) && \
	 ln -s ../newlib-$(NEWLIB_VERSION)/newlib

.patch.ok: .unzip.ok $(RTEMS_PATCHES_DIR)/.ok
	cd gcc-$(GCC_CORE_VERSION) && \
	 patch -p1 < ../$(RTEMS_PATCHES_DIR)/$(GCC_CORE_PATCH)
	cd newlib-$(NEWLIB_VERSION) && \
	 patch -p1 < ../$(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH)
	cd gdb-$(GDB_VERSION) && \
	 patch -p1 < ../$(RTEMS_PATCHES_DIR)/$(GDB_PATCH)
	touch $@

.unzip.ok: $(DL)/$(BINUTILS).ok $(DL)/$(GCC_CORE).ok $(DL)/$(NEWLIB).ok $(DL)/$(GDB).ok $(DL)/$(MPFR).ok $(DL)/$(MPC).ok $(DL)/$(GMP).ok
	tar xf $(DL)/$(BINUTILS)
	tar xf $(DL)/$(GCC_CORE)
	tar xf $(DL)/$(NEWLIB)
	tar xf $(DL)/$(GDB)
	tar xf $(DL)/$(GMP)
	tar xf $(DL)/$(MPC)
	tar xf $(DL)/$(MPFR)
	rm -rf gcc-$(GCC_CORE_VERSION)/gmp gcc-$(GCC_CORE_VERSION)/mpc \
	  gcc-$(GCC_CORE_VERSION)/mpfr
	ln -s  ../gmp-$(GMP_VERSION) gcc-$(GCC_CORE_VERSION)/gmp
	ln -s  ../mpc-$(MPC_VERSION) gcc-$(GCC_CORE_VERSION)/mpc
	ln -s  ../mpfr-$(MPFR_VERSION) gcc-$(GCC_CORE_VERSION)/mpfr
	touch $@

.install.gdb.ok: .compile.gdb.ok
	$(MAKE) -C b-gdb install
	touch $@

.compile.gdb.ok: .install.binutils.ok .patch.ok
	export PATH=$(RTEMS_PREFIX)/bin:$$PATH
	mkdir -p b-gdb
	cd b-gdb/ && ../gdb-$(GDB_VERSION)/configure --target=lm32-rtems4.11 \
	  --prefix=$(RTEMS_PREFIX)
	$(MAKE) -C b-gdb all
	touch $@

$(RTEMS_PATCHES_DIR)/.ok:
	mkdir -p $(RTEMS_PATCHES_DIR)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(GCC_CORE_PATCH) \
	  $(RTEMS_SOURCES_URL)/$(GCC_CORE_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(NEWLIB_PATCH) \
	  $(RTEMS_SOURCES_URL)/$(NEWLIB_PATCH)
	$(WGET) $(RTEMS_PATCHES_DIR)/$(GDB_PATCH) \
	  $(RTEMS_SOURCES_URL)/$(GDB_PATCH)
	touch $@

$(DL)/$(BINUTILS).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(BINUTILS) $(RTEMS_SOURCES_URL)/$(BINUTILS)
	touch $@

$(DL)/$(GCC_CORE).ok:
	mkdir -p $(DL)
	$(WGET) $(DL)/$(GCC_CORE) $(RTEMS_SOURCES_URL)/$(GCC_CORE)
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
	rm -f .*.ok
	rm -f .ok

# disable parallel execution of targets in this top-level Makefile.  Makefiles
# invoked via $(MAKE) still run parallel if -j was passed to the top-level
# Makefile.
.NOTPARALLEL:
