# shared lib test, LIBPREFIX test
LIB1 = $(LIBPREFIX)test1
LIB1.SRC = test_lib.cc
LIB1.TYPE = shared

BIN1 = test1
BIN1.SRC = test.cc
BIN1.LIBS = LIB1

# version test
LIB2 = libtest2
LIB2.SRC = test_lib.cc
LIB2.TYPE = shared
LIB2.VERSION = 1.2.3

BIN2 = test2
BIN2.SRC = test.cc
BIN2.LIBS = LIB2


OUTPUT_BIN_DIR = bin
OUTPUT_LIB_DIR = lib

include ../../Makefile.mk

## END
