#!/bin/bash

BASEDIR=$(cd $(dirname $0) ; pwd -P)
GFLAGSDIR=$BASEDIR/../gflags-zubuntu

# gflags: outside rocksdb (due to "make clean" issue)
if [ ! -d $GFLAGSDIR ]; then
	echo "no gflags!"
	(cd ..; git clone https://github.com/cwchung90/gflags gflags-zubuntu; \
	cd gflags-zubuntu; git checkout arm-ubuntu; sh UbuntuSetup.sh)
fi

# make it light version
# export EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS -DROCKSDB_LITE"
# export OPT+=" -DROCKSDB_LITE"

# to support gflags
export EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS -DGFLAGS=google -I$GFLAGSDIR/build/include "
export EXTRA_LDFLAGS="$EXTRA_LDFLAGS -lgflags -L$GFLAGSDIR/build/lib "

#gnueabi doesn't work due to GCC version
#sudo apt-get install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
export HOST=aarch64-linux-gnu

# To solve problems with std::future
# https://lists.debian.org/debian-arm/2013/12/msg00007.html
# http://stackoverflow.com/questions/22036396/stdpromise-error-on-cross-compiling
export EXTRA_CXXFLAGS+=" -Wno-maybe-uninitialized -Wno-conversion-null -Wno-format -Wno-error=format"
#export EXTRA_CXXFLAGS+=" -march=armv7-a -mtune=cortex-a9 -mfpu=neon"
#export EXTRA_CXXFLAGS+=" -march=armv7-a -mtune=cortex-a9"
export EXTRA_CXXFLAGS+=" -std=c++11 -std=gnu++11"


#export EXTRA_LDFLAGS+=" -march=armv7-a -Wl,--fix-cortex-a8"
#export EXTRA_LDFLAGS+=" -march=armv7-a -mtune=cortex-a9 -mfpu=neon -Wl,--fix-cortex-a8"
#export EXTRA_LDFLAGS+=" -march=armv7-a -mtune=cortex-a9 -Wl,--fix-cortex-a8"
export EXTRA_LDFLAGS+=" -lstdc++ -lsupc++"


# Set TARGET_OS manually
export MACHINE="arm" # for Makefile
export TARGET_OS="LinuxArm" # for build_detect_platform
# export CROSS_COMPILE="true" # Not needed

export CC="${HOST}-gcc"
export CXX="${HOST}-g++"
export LD="${HOST}-ld"
export AR="${HOST}-ar"
export NM="${HOST}-nm"
export AS="${HOST}-as"
export RANLIB="${HOST}-ranlib"
export STRIP="${HOST}-strip"
export OBJCOPY="${HOST}-objcopy"
export OBJDUMP="${HOST}-objdump"


make clean
#PORTABLE=1 make shared_lib -j8
PORTABLE=1 make release -j8
#PORTABLE=1 DEBUG_LEVEL=0 make static_lib -j8
#PORTABLE=1 make db_test
#PORTABLE=1 make db_test -j8 V=1
#PORTABLE=1 make db_test auto_roll_logger_test stringappend_test perf_context_test -j8
#PORTABLE=1 DEBUG_LEVEL=0 make all -j8
