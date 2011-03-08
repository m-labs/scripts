#
# Written 2011 by Xiangfu Liu <xiangfu@sharism.cc>
# this file try to manager build RTMS toolchain
#

CP=cp -rf

RTEMS_VERSION=4.11
RTEMS_PREFIX=/opt/rtems-$(RTEMS_VERSION)
RTEMS_SOURCES_URL=http://www.rtems.org/ftp/pub/rtems/SOURCES/$(RTEMS_VERSION)

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
MPC=mpc-$(MPC_VERSION).tar.bz2
MPFR=mpfr-$(MPFR_VERSION).tar.bz2

BINUTILS_PATCH=$(BINUTILS)-$(BINUTILS_VERSION)-$(RTEMS_VERSION)-20110107.diff
GCC_CORE_PATCH=$(GCC_CORE)-$(GCC_CORE_VERSION)-$(RTEMS_VERSION)-20110220.diff
NEWLIB_PATCH=$(NEWLIB)-$(NEWLIB_VERSION)-$(RTEMS_VERSION)-20110109.diff
GCC_G++_PATCH=$(GCC_G++)-$(GCC_G++_VERSION)-$(RTEMS_VERSION)-20110131.diff
GDB_PATCH=$(GDB)-$(GDB_VERSION)-$(RTEMS_VERSION)-20100907.diff

DL=$(if $(wildcard ../dl/.),../dl,dl)
RTEMS_PATCHES=$(if $(wildcard ../rtems-patches/.),../rtems-patches,rtems-patches)

.PHONY:	all clean

all:
	...

.compile.install.ok:
	echo ""

.patch.ok: .unzip.ok $(RMTS_PATCHES)/.ok
	(cd $(BINUTILS_VERSION); cat $(RTEMS_PATCHES)/$(BINUTILS_PATCH) | patch -p1)
	(cd $(GCC_VERSION); cat $(RTEMS_PATCHES)/$(GCC_PATCH) | patch -p1)
	(cd $(NEWLIB_VERSION); cat $(RTEMS_PATCHES)/$(NEWLIB_PATCH) | patch -p1)

.unzip.ok: $(DL)/$(BINUTILS).ok $(DL)/$(GCC_CORE).ok $(DL)/$(NEWLIB).ok 
	tar xf $(DL)/$(BINUTILS)
	tar xf $(DL)/$(GCC_CORE)
	tar xf $(DL)/$(NEWLIB)

# downloads sourcees and patchesfor toolchain
$(RTEMS_PATCHES)/.ok:
	mkdir -p rtems-patches
	wget -c -O $(RTEMS_PATCHES)/$(BINUTILS_PATCH) $(RTEMS_SOURCES_URL)/$(BINUTILS_PATCH)
	wget -c -O $(RTEMS_PATCHES)/$(GCC_CORE_PATCH) $(RTEMS_SOURCES_URL)/$(GCC_CORE_PATCH)
	wget -c -O $(RTEMS_PATCHES)/$(NEWLIB_PATCH) $(RTEMS_SOURCES_URL)/$(NEWLIB_PATCH)
	#wget -c -O $(RTEMS_PATCHES)/$(GCC_G++_PATCH) $(RTEMS_SOURCES_URL)/$(GCC_G++_PATCH)
	#wget -c -O $(RTEMS_PATCHES)/$(GDB_PATCH) $(RTEMS_SOURCES_URL)/$(GDB_PATCH)
	touch $@
$(DL)/$(BINUTILS).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(BINUTILS) $(RTEMS_SOURCES_URL)/$(BINUTILS)
	touch $@
$(DL)/$(GCC_CORE).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(GCC_CORE) $(RTEMS_SOURCES_URL)/$(GCC_CORE)
	touch $@
$(DL)/$(GCC_G++).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(GCC_G++) $(RTEMS_SOURCES_URL)/$(GCC_G++)
	touch $@
$(DL)/$(NEWLIB).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(NEWLIB) $(RTEMS_SOURCES_URL)/$(NEWLIB)
	touch $@
$(DL)/$(GDB).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(GDB) $(RTEMS_SOURCES_URL)/$(GDB)
	touch $@
$(DL)/$(GMP).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(GMP) $(RTEMS_SOURCES_URL)/$(GMP)
	touch $@
$(DL)/$(MPC).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(MPC) $(RTEMS_SOURCES_URL)/$(MPC)
	touch $@
$(DL)/$(MPFR).ok:
	mkdir -p dl
	wget -c -O $(DL)/$(MPFR) $(RTEMS_SOURCES_URL)/$(MPFR)
	touch $@

clean:
	echo "clean"