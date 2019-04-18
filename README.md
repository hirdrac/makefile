# Makefile.mk
Single-file makefile include that allows defining C++ makefiles with simple variable assignments.<br>
Can be used for building binaries, shared/static libraries, and unit tests (auto execute when building).
See Makefile.mk comments for variable parameters.


## Makefile usage example
<pre>
BIN1 = example1
BIN1.SRC = file1.cc file2.cc file3.cc

BIN2 = example2
BIN2.SRC = file4.cpp

# compile flags applied to all binaries
FLAGS = -pthreads -flto
# add library specified compile/link flags (as defined by pkg-config)
PACKAGES = freetype2

# include must be at end
include Makefile.mk
</pre>
