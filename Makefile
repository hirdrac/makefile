# Example Makefile
# (actual examples commented out to avoid errors)

### EXAMPLE 1 - simple binary build ###
### makes executable 'binary1' in makefile directory
#BIN1 = binary1
#BIN1.SRC = binary1.cc other.cpp subdir/more_src.C

### EXAMPLE 2 - static & shared library build ###
### makes static library 'libtest.a' and shared library 'libtest.so'
#LIB1 = libtest
#LIB1.SRC = libSource.cc
#LIB1.TYPE = static shared

### EXAMPLE 3 - unit test that automatically builds/runs if any other
### target is (re)built
### (tests can be manually built/run with 'make tests' command
#TEST1 = mytest
#TEST1.SRC = mytest.cc other.cpp

### Settings to use for all binary/library/test builds
### (per binary/library settings not currently available)
# set compiler to clang (defaults to gcc)
#COMPILER = clang
#
# add additional flags to be used for compiling/linking
#FLAGS = -flto -pthread
#
# set packages to use for all targets, as defined by pkg-config
# ('--as-needed' flag is passed to the linker by default so only the
# libraries used are linked with each binary)
#PACKAGES = freetype2
#
# override default optimization values with different settings
#OPTIMIZE = -O2 -march=native


### See comments at the top of 'Makefile.mk' for descriptions of other
### variable settings and make targets


# always put this include at the end of your makefile
include Makefile.mk

# END
