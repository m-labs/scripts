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

# before compile rtems. you need the lm32-rtems toolchain

RTEMS_VERSION=4.11
RTEMS_MAKEFILE_PATH?=/opt/rtems-$(RTEMS_VERSION)/lm32-rtems$(RTEMS_VERSION)/milkymist
RTEMS_GIT_DIR=../../rtems-milkymist.git

CONFIGURE_FLAGS=--target=lm32-rtems4.11 --enable-rtemsbsp=milkymist \
	--enable-testsuites=samples --enable-posix --disable-itron \
	--enable-networking --disable-multiprocessing

all:
#	(cd $(RTEMS_GIT_DIR); ./bootstrap -c && ./bootstrap -p && ./bootstrap)
	mkdir -p bsp-milkymist
	(cd bsp-milkymist; \
	 ../$(RTEMS_GIT_DIR)/configure $(CONFIGURE_FLAGS); \
	 make all; make install; \
	)

git-clone:
	git clone https://github.com/fallen/rtems-milkymist.git

clean:
	rm -rf bsp-milkymist