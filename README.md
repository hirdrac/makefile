# Makefile.mk
Single-file makefile include that allows defining C++ makefiles with simple variable assignments.<br>
Can be used for building binaries, shared/static libraries, and unit tests (auto-execute when building).
See Makefile.mk comments for variable parameters and standard targets.

## Feature Summary
* Can define up to 99 binaries, 99 libraries, and 999 unit tests in the same makefile
* Built object files are placed together in a build directory
* Dependency files are automatically generated to insure re-compilation for source changes is handled correctly
* Makefile value changes are automatically detected and will always insure everything is compiled correctly without requiring a 'make clean' to remove old object files
* Multiple build environments are supported:
   * 'release' - default, build with full optimizations
   * 'debug' - build with minimal optimizations and enable debug flags (output binaries will have '-g' suffix)
   * 'profile' - optimized build with added profiling options enabled ('-pg' suffix added to output binaries)
* Single configure option to switch compilers (gcc & clang are both currently supported)
* Binary/library output defaults to makefile directory but an optional output directory can be configured
* Simple configure option to allow building with various 3rd party libraries (run 'pkg-config --list-all' to see what packages your system supports)
* Default options for all compiler flags (warnings, optimizations, etc.) are provided.  These default values can either be overridden or extended by config options (See Makefile.mk for all config settings)

## Requirements
* GNU make 4.2 or newer
* gcc or clang compiler

## Supported Platforms
* Linux (developed on Fedora Linux)
* Cygwin/MinGW/Msys2 on Windows

Other unix-like platforms may work as well but are untested.

## Makefile Usage Example
<pre>
# Simple binary builds
BIN1 = example1
BIN1.SRC = file1.cc file2.cc file3.cc

BIN99 = example2
BIN99.SRC = file4.cpp

# Shared & static library build (will output both libexample.so,libexample.a)
LIB1 = libexample
LIB1.SRC = libsrc.cc file4.cpp
LIB1.TYPE = shared static

# compile flags applied to all binaries
FLAGS = -pthreads -flto
# add package specified compile/link flags (as defined by pkg-config)
PACKAGES = freetype2
# extra warning flags (in addition to default flags)
WARN_EXTRA = -Werror
# use specific C++ standard instead of compiler default
STANDARD = c++17

# include must be at end
include Makefile.mk
</pre>
