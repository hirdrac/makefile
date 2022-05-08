# Example Makefile
# (actual examples commented out to avoid errors)

### EXAMPLE 1 - simple binary build
### builds 'binary1' in makefile directory from specified source files
#BIN1 = binary1
#BIN1.SRC = binary1.cc other.cpp subdir/more_src.C

### EXAMPLE 2 - single line to name & build a binary from all C++ source
###   in directory (excluding sub-directories)
#BIN_binary2.SRC = *.cpp

### EXAMPLE 3 - build a binary with all C source from a specified directory
###   with a recursive search of all sub-directories in that directory.
###   second line defines symbols for only this target
#BIN_prog3.SRC = Source/**.c
#BIN_prog3.DEFINE = TESTBUILD PATH="/usr/local/"

### EXAMPLE 4 - static & shared library build
###   makes static library 'libtest.a' and shared library 'libtest.so'
#LIB1 = libtest
#LIB1.SRC = libSource.cc
#LIB1.TYPE = static shared

### EXAMPLE 5 - unit test that automatically runs after building
###   (tests can be forced to run w/ 'make tests')
#TEST1 = optional test description
#TEST1.SRC = mytest.cc other.cpp

### Settings to use for all binary/library/test builds
# set compiler to clang (defaults to gcc)
#COMPILER = clang
#
# add additional flags to be used for compiling/linking all targets
#FLAGS = -flto -pthread
#
# set packages to use for all targets, as defined by pkg-config
# ('--as-needed' flag is passed to the linker by default so only the
# libraries used are linked with each binary)
#PACKAGES = freetype2
#
# override default optimization level
#OPT_LEVEL = 2
#
# disable assert() for all targets
# (-D prepended to all DEFINE values automatically if not specified)
#DEFINE = NDEBUG


### See comments at the top of 'Makefile.mk' for descriptions of other
### variable settings and make targets


# always put this include at the end of your makefile
include Makefile.mk

# END
