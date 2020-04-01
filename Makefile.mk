#
# Makefile.mk - version 1.9 (2020/2/8)
# Copyright (C) 2020 Richard Bradley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Makefile assistant for C/C++ projects
#
# Include this file at the end of your makefile to create basic make targets
# and allow the definition of binary/library builds by parameter assignment.
#
# Make Targets:
#  all             executes DEFAULT_ENV (defaults to 'release')
#  release         makes all optimized binaries/libraries/tests
#  debug           builds debug versions of all binaries/libraries/tests
#  profile         builds gprof versions of all binaries/libraries/tests
#  clean           deletes build directory & test binaries
#  clobber         deletes build directory & built binaries/libraries
#  tests           run all tests for DEFAULT_ENV
#  info            prints summary of defined build targets
#  help            prints command summary
#
# Makefile Parameters:
#  BIN1            name of binary to build (up to 99, i.e. BIN2, BIN39, etc.)
#  BIN1.SRC        source files for binary 1 (C/C++ source files, no headers)
#  BIN1.OBJS       additional binary 1 object dependencies (.o,.a files)
#  BIN1.DEPS       additional dependencies for building all binary 1 objects
#
#  LIB1            name of library to build (without .a/.so extension)
#  LIB1.TYPE       type of library to build: static(default) and/or shared
#  LIB1.SRC        source files for library 1
#  LIB1.OBJS       additional library 1 object dependencies
#  LIB1.DEPS       additional dependencies for building all library 1 objects
#  LIB1.VERSION    major(.minor(.patch)) version of shared library 1
#
#  TEST1           name of unit test to build
#  TEST1.ARGS      arguments for running test 1 binary
#  TEST1.SRC       source files for unit test 1
#  TEST1.OBJS      additional unit test 1 object dependencies
#  TEST1.DEPS      additional dependencies for building all test 1 objects
#
#  FILE1           file(s) to generate (i.e. generated source code)
#  FILE1.DEPS      file dependencies to trigger a rebuild
#  FILE1.CMD       command to execute to create file(s)
#                  for CMD, these variables can be used in the definition:
#                    DEPS - same as FILE1.DEPS
#                    DEP1 - first DEPS value only
#                    OUT  - same as FILE1
#
#  TEMPLATE1.FILE1 values to use for FILE1 creation
#                  referenced by $(VALS) or $(VAL1),$(VAL2),etc.
#  TEMPLATE1       used to create 'FILE1'
#  TEMPLATE1.DEPS  used to create 'FILE1.DEPS'
#  TEMPLATE1.CMD   used to create 'FILE1.CMD'
#                  use of other vars (TMP,DEP1,OUT,etc.) should be escaped
#
#  COMPILER        compiler to use (gcc,clang)
#  CROSS_COMIPLE   binutils and gcc toolchain prefix (i.e arm-linux-gnueabi-)
#  STANDARD        language standard(s) of source code
#  OPT_LEVEL       optimization level for release & profile builds
#  OPTIMIZE        compiler flags for release & profile builds
#  DEBUG           compiler flags for debug builds
#  PROFILE         compiler flags for profile builds
#  WARN            C/C++ compile warning flags (-W optional)
#  WARN_C          C specific warnings (WARN setting used for C code if unset)
#  PACKAGES        list of packages for pkg-config
#  INCLUDE         includes needed not covered by pkg-config (-I optional)
#  LIBS            libraries needed not covered by pkg-config (-l optional)
#  DEFINE          defines for compilation (-D optional)
#  OPTIONS         list of options to enable - use instead of specific flags
#    warn_error    make all compiler warnings into errors
#    pthread       compile with pthreads support
#    lto           enable link-time optimization
#    modern_c++    enable warnings for some old-style C++ syntax (pre C++11)
#    no_rtti       disable C++ RTTI
#    no_except     disable C++ exceptions
#  FLAGS           additional compiler flags not otherwise specified
#  TEST_PACKAGES   additional packages for all tests
#  TEST_LIBS       additional libs to link with for all tests (-l optional)
#  TEST_FLAGS      additional compiler flags for all tests
#  *_EXTRA         available for most settings to provide additional values
#
#  BUILD_DIR       directory for generated object/prerequisite files
#  DEFAULT_ENV     default environment to build (release,debug,profile)
#  OUTPUT_DIR      default output directory (defaults to current directory)
#  LIB_OUTPUT_DIR  directory for generated libraries (defaults to OUTPUT_DIR)
#  BIN_OUTPUT_DIR  directory for generated binaries (defaults to OUTPUT_DIR)
#  CLEAN_EXTRA     extra files to delete for 'clean' target
#  CLOBBER_EXTRA   extra files to delete for 'clobber' target
#  SUBDIRS         sub-directories to also make with base targets
#  SYMLINKS        symlinks to the current dir to create for building
#  SOURCE_DIR      source files base directory
#
#  Settings STANDARD/OPT_LEVEL/PACKAGES/INCLUDE/LIBS/DEFINE/OPTIONS/FLAGS can
#    be set for specific targets to override global values
#    (ex.: BIN1.FLAGS = -pthread).
#    A value of '-' can be used to clear the setting for the target
#
# Output Variables:
#  ENV             current build environment
#  SFX             current build environment binary suffix
#  TMP             environment specific temporary directory
#  ALL_FILES       all FILEx targets (useful for .DEPS rule on specific targets)
#

#### Make Version & Multi-include Check ####
_min_ver := 4.2
MAKE_VERSION ?= 1.0
ifeq ($(filter $(_min_ver),$(firstword $(sort $(MAKE_VERSION) $(_min_ver)))),)
  $(error GNU make version $(_min_ver) or later required)
endif

ifdef _makefile_already_included
  $(error $(lastword $(MAKEFILE_LIST)) included muliple times)
endif
override _makefile_already_included := 1


#### Shell Commands ####
SHELL = /bin/sh
PKGCONF ?= pkg-config
RM ?= rm -f --


#### Basic Settings ####
COMPILER ?= $(firstword $(compiler_names))
CROSS_COMPILE ?=
STANDARD ?=
OPT_LEVEL ?= 3

OPTIMIZE ?= -O$(or $(if $1,$($1.OPT_LEVEL)),$(OPT_LEVEL))
DEBUG ?= -g -O1 -DDEBUG -D_FORTIFY_SOURCE=1
PROFILE ?= -pg
ifndef WARN
  WARN = all extra no-unused-parameter non-virtual-dtor overloaded-virtual $($(COMPILER)_warn)
  WARN_C ?= all extra no-unused-parameter $($(COMPILER)_warn)
else
  WARN_C ?= $(WARN)
endif
PACKAGES ?=
INCLUDE ?=
LIBS ?=
DEFINE ?=
OPTIONS ?=
FLAGS ?=
TEST_PACKAGES ?=
TEST_LIBS ?=
TEST_FLAGS ?=

BUILD_DIR ?= build
DEFAULT_ENV ?= $(firstword $(env_names))
OUTPUT_DIR ?=
LIB_OUTPUT_DIR ?= $(OUTPUT_DIR)
BIN_OUTPUT_DIR ?= $(OUTPUT_DIR)
CLEAN_EXTRA ?=
CLOBBER_EXTRA ?=
SUBDIRS ?=
SYMLINKS ?=
SOURCE_DIR ?=

# default values to be more obvious if used/handled improperly
override ENV := ENV
override SFX := SFX
override TMP := TMP

# apply *_EXTRA setting values
$(foreach x,OPTIMIZE DEBUG PROFILE WARN WARN_C PACKAGES INCLUDE LIBS DEFINE OPTIONS FLAGS TEST_PACKAGES TEST_LIBS TEST_FLAGS,\
  $(if $($x_EXTRA),$(eval override $x += $($x_EXTRA))))


#### Environment Details ####
env_names ?= release debug profile
release_sfx ?=
release_flags ?= $(OPTIMIZE)
debug_sfx ?= -g
debug_flags ?= $(DEBUG)
profile_sfx ?= -pg
profile_flags ?= $(OPTIMIZE) $(PROFILE)


#### Compiler Details ####
compiler_names ?= gcc clang

gcc_cxx ?= g++
gcc_cc ?= gcc
gcc_as ?= gcc -x assembler-with-cpp
gcc_ar ?= gcc-ar
gcc_ranlib ?= gcc-ranlib
gcc_warn ?= shadow=local
gcc_modern ?= -Wsuggest-override -Wzero-as-null-pointer-constant -Wregister

clang_cxx ?= clang++
clang_cc ?= clang
clang_as ?= clang -x assembler-with-cpp
clang_ar ?= llvm-ar
clang_ranlib ?= llvm-ranlib
clang_warn ?= shadow
clang_modern ?= -Winconsistent-missing-override -Wzero-as-null-pointer-constant


#### Terminal Output ####
# _fg1 - binary/library built
# _fg2 - warning or removal notice
# _fg3 - test passed
# _fg4 - test failed, fatal error
ifneq ($(shell which setterm 2>/dev/null),)
  override _bold := $(shell setterm --bold on)
  override _fg0 := $(shell setterm --foreground default)
  override _fg1 := $(shell setterm --foreground cyan)
  override _fg2 := $(shell setterm --foreground magenta)
  override _fg3 := $(shell setterm --foreground green)
  override _fg4 := $(shell setterm --foreground red)
  override _end := $(shell setterm --default)
else
  override _bold := $(shell echo -e '\e[1m')
  override _fg0 := $(shell echo -e '\e[39m')
  override _fg1 := $(shell echo -e '\e[36m')
  override _fg2 := $(shell echo -e '\e[35m')
  override _fg3 := $(shell echo -e '\e[32m')
  override _fg4 := $(shell echo -e '\e[31m')
  override _end := $(shell echo -e '\e[m')
endif
override _info := $(_bold)$(_fg1)
override _warn := $(_bold)$(_fg2)
override _err := $(_bold)$(_fg4)


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(compiler_names)),)
  $(error $(_err)COMPILER: unknown compiler$(_end))
endif

CXX = $(CROSS_COMPILE)$(or $($(COMPILER)_cxx),c++)
CC = $(CROSS_COMPILE)$(or $($(COMPILER)_cc),cc)
AS = $(CROSS_COMPILE)$(or $($(COMPILER)_as),as)
AR = $(CROSS_COMPILE)$(or $($(COMPILER)_ar),ar)
RANLIB = $(CROSS_COMPILE)$(or $($(COMPILER)_ranlib),ranlib)

c_ptrn ?= %.c
asm_ptrn ?= %.s %.S %.sx
cxx_ptrn ?= %.cc %.cp %.cxx %.cpp %.CPP %.c++ %.C
cxx_standards ?= c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a
cc_standards ?= c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18

override define check_standard  # <1:standard var> <2:set prefix>
override $2_cxx_std := $$(addprefix -std=,$$(filter $$($1),$$(cxx_standards)))
ifeq ($$(filter 0 1,$$(words $$($2_cxx_std))),)
  $$(error $$(_err)$1: multiple C++ standards not allowed$$(_end))
endif
override $2_cc_std := $$(addprefix -std=,$$(filter $$($1),$$(cc_standards)))
ifeq ($$(filter 0 1,$$(words $$($2_cc_std))),)
  $$(error $$(_err)$1: multiple C standards not allowed$$(_end))
endif
ifneq ($$(filter-out $$(cxx_standards) $$(cc_standards),$$($1)),)
  $$(error $$(_err)$1: unknown '$$(filter-out $$(cxx_standards) $$(cc_standards),$$($1))'$$(_end))
endif
endef
$(eval $(call check_standard,STANDARD,))


#### Package Handling ####
# syntax: (<target>.)PACKAGES = <pkg name>(:<min version>) ...
override pkg_n = $(word 1,$(subst :, ,$1))
override pkg_v = $(word 2,$(subst :, ,$1))
override check_pkgs =\
$(strip $(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call pkg_n,$x) $(if $(call pkg_v,$x),--atleast-version=$(call pkg_v,$x),--exists) && echo '1'),\
    $(call pkg_n,$x),\
    $(warning $(_warn)$1: package '$(call pkg_n,$x)'$(if $(call pkg_v,$x), [version >= $(call pkg_v,$x)]) not found$(_end)))))

override get_pkg_flags = $(if $1,$(shell $(PKGCONF) $1 --cflags))
override get_pkg_libs = $(if $1, $(shell $(PKGCONF) $1 --libs))
override get_pkg_ver = $(shell $(PKGCONF) $1 --modversion)

override define verify_pkgs  # <1:config pkgs var> <2:valid pkgs>
ifeq ($$($1),)
else ifeq ($$($1),-)
else ifneq ($$(words $$($1)),$$(words $$($2)))
  $$(error $$(_err)Cannot build because of package error(s)$$(_end))
endif
endef


#### OPTIONS handling ####
override _op_list := warn_error pthread lto modern_c++ no_rtti no_except

override define check_options  # <1:options var> <2:set prefix>
ifneq ($$(filter-out $$(_op_list),$$($1)),)
  $$(error $$(_err)$1: unknown '$$(filter-out $$(_op_list),$$($1))'$$(_end))
endif
override $2_op_warn :=
override $2_op_flags :=
ifneq ($$(filter warn_error,$$($1)),)
  override $2_op_warn += -Werror
endif
ifneq ($$(filter pthread,$$($1)),)
  override $2_op_flags += -pthread
endif
ifneq ($$(filter lto,$$($1)),)
  override $2_op_flags += -flto
endif
override $2_op_cxx_warn := $$($2_op_warn)
override $2_op_cxx_flags := $$($2_op_flags)
ifneq ($$(filter modern_c++,$$($1)),)
  override $2_op_cxx_warn += $$($$(COMPILER)_modern)
endif
ifneq ($$(filter no_rtti,$$($1)),)
  override $2_op_cxx_flags += -fno-rtti
endif
ifneq ($$(filter no_except,$$($1)),)
  override $2_op_cxx_flags += -fno-exceptions
endif
endef
$(eval $(call check_options,OPTIONS,))


#### Internal Calculated Values ####
override _comma := ,
override _digits := 1 2 3 4 5 6 7 8 9
override _1-99 := $(_digits) $(foreach x,$(_digits),$(addprefix $x,0 $(_digits)))

override _template_labels := $(strip $(foreach x,$(_1-99),$(if $(TEMPLATE$x),TEMPLATE$x)))

# verify template configs
override define check_template_entry  # <1:label>
override _$1_labels := $$(strip $$(foreach n,$$(_1-99),$$(if $$($1.FILE$$n),FILE$$n)))
ifeq ($$(_$1_labels),)
  $$(error $$(_err)$1: no FILE entries$$(_end))
else ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(_err)$1.CMD: command required$$(_end))
endif
endef
$(foreach x,$(_template_labels),$(eval $(call check_template_entry,$x)))

ifneq ($(words $(foreach t,$(_template_labels),$($t_labels))),$(words $(sort $(foreach t,$(_template_labels),$($t_labels)))))
  $(error $(_err)multiple templates contain the same FILE entry$(_end))
endif

# create file entries from templates
$(foreach t,$(_template_labels),\
  $(foreach x,$(_$t_labels),\
    $(eval override VALS := $$($t.$x))\
    $(foreach n,$(wordlist 1,$(words $(VALS)),$(_1-99)),\
      $(eval override VAL$n := $$(word $n,$$(VALS))))\
    $(eval override $x = $($t))\
    $(eval override $x.DEPS = $($t.DEPS))\
    $(eval override $x.CMD = $($t.CMD))))

override _lib_labels := $(strip $(foreach x,$(_1-99),$(if $(LIB$x),LIB$x)))
override _bin_labels := $(strip $(foreach x,$(_1-99),$(if $(BIN$x),BIN$x)))
override _test_labels := $(strip $(foreach x,$(_1-99),$(if $(TEST$x),TEST$x)))
override _file_labels := $(strip $(foreach x,$(_1-99),$(if $(FILE$x),FILE$x)))
override ALL_FILES = $(foreach x,$(_file_labels),$($x))
override _src_labels := $(_lib_labels) $(_bin_labels) $(_test_labels)
override _all_labels := $(_src_labels) $(_file_labels)
override _subdir_targets := $(foreach x,$(env_names),$x tests_$x clean_$x) clobber install install-strip
override _base_targets := all tests info help clean $(_subdir_targets)

override define check_entry  # <1:label>
override $1 := $$(strip $$($1))
ifneq ($$(words $$($1)),1)
  $$(error $$(_err)$1: spaces not allowed in name$$(_end))
else ifneq ($$(filter $$($1),$$(_base_targets) $$(foreach x,$$(env_names),$1$$($$x_sfx))),)
  $$(error $$(_err)$1: name conflicts with existing target$$(_end))
else ifeq ($$(strip $$($1.SRC)),)
  $$(error $$(_err)$1.SRC: no source files specified$$(_end))
else ifneq ($$(words $$($1.SRC)),$$(words $$(sort $$($1.SRC))))
  $$(error $$(_err)$1.SRC: duplicate source files$$(_end))
endif
ifeq ($$($1.STANDARD),)
  override _$1_cxx_std := $$(_cxx_std)
  override _$1_cc_std := $$(_cc_std)
else ifneq ($$($1.STANDARD),-)
  $$(eval $$(call check_standard,$1.STANDARD,_$1))
endif
ifeq ($$($1.OPTIONS),)
  override _$1_op_warn := $$(_op_warn)
  override _$1_op_flags := $$(_op_flags)
  override _$1_op_cxx_warn := $$(_op_cxx_warn)
  override _$1_op_cxx_flags := $$(_op_cxx_flags)
else ifneq ($$($1.OPTIONS),-)
  $$(eval $$(call check_options,$1.OPTIONS,_$1))
endif
override _$1_lang := $$(if $$(filter $(asm_ptrn),$$($1.SRC)),asm) $$(if $$(filter $(c_ptrn),$$($1.SRC)),c) $$(if $$(filter $(cxx_ptrn),$$($1.SRC)),cxx)
ifneq ($$(filter-out $(cxx_ptrn) $(c_ptrn) $(asm_ptrn),$$($1.SRC)),)
  $$(error $$(_err)$1.SRC: invalid '$$(filter-out $(cxx_ptrn) $(c_ptrn) $(asm_ptrn),$$($1.SRC))'$$(_end))
endif
endef
$(foreach x,$(_src_labels),$(eval $(call check_entry,$x)))

override define check_bin_entry  # <1:bin label>
$$(foreach x,$$(filter-out %.SRC %.OBJS %.LIBS %.STANDARD %.OPT_LEVEL %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.OPTIONS %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_warn)Unknown binary parameter '$$x'$$(_end)))
endef
$(foreach x,$(_bin_labels),$(eval $(call check_bin_entry,$x)))

override define check_lib_entry  # <1:lib label>
$$(foreach x,$$(filter-out %.TYPE %.SRC %.OBJS %.LIBS %.VERSION %.STANDARD %.OPT_LEVEL %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.OPTIONS %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_warn)Unknown library parameter '$$x'$$(_end)))
ifneq ($$(filter %.a %.so,$$($1)),)
  $$(error $$(_err)$1: library names should not be specified with an extension$$(_end))
else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
  $$(error $$(_err)$1.TYPE: only 'static' and/or 'shared' allowed$$(_end))
endif
endef
$(foreach x,$(_lib_labels),$(eval $(call check_lib_entry,$x)))

override define check_test_entry  # <1:test label>
$$(foreach x,$$(filter-out %.ARGS %.SRC %.OBJS %.LIBS %.STANDARD %.OPT_LEVEL %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.OPTIONS %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_warn)Unknown test parameter '$$x'$$(_end)))
endef
$(foreach x,$(_test_labels),$(eval $(call check_test_entry,$x)))

override define check_file_entry  # <1:file label>
$$(foreach x,$$(filter-out %.DEPS %.CMD,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_warn)Unknown file parameter '$$x'$$(_end)))
ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(_err)$1.CMD: command required$$(_end))
endif
endef
$(foreach x,$(_file_labels),$(eval $(call check_file_entry,$x)))

override _all_names := $(foreach x,$(_all_labels),$($x))
ifneq ($(words $(_all_names)),$(words $(sort $(_all_names))))
  $(error $(_err)Duplicate binary/library/test names$(_end))
endif

# macro to encode path as part of name and remove suffix
override src_bname = $(subst /,__,$(subst ../,,$(basename $1)))

# check for source conflicts like src/file.cc & src/file.cpp
override _all_source := $(sort $(foreach x,$(_all_labels),$($x.SRC)))
override _all_source_base := $(call src_bname,$(_all_source))
ifneq ($(words $(_all_source_base)),$(words $(sort $(_all_source_base))))
  $(error $(_err)Conflicting source files - each basename must be unique$(_end))
endif

ifeq ($(filter $(DEFAULT_ENV),$(env_names)),)
  $(error $(_err)DEFAULT_ENV: invalid value$(_end))
endif
MAKECMDGOALS ?= $(DEFAULT_ENV)

ifneq ($(words $(BUILD_DIR)),1)
  $(error $(_err)BUILD_DIR: spaces not allowed$(_end))
else ifeq ($(filter 0 1,$(words $(OUTPUT_DIR))),)
  $(error $(_err)OUTPUT_DIR: spaces not allowed$(_end))
else ifeq ($(filter 0 1,$(words $(BIN_OUTPUT_DIR))),)
  $(error $(_err)BIN_OUTPUT_DIR: spaces not allowed$(_end))
else ifeq ($(filter 0 1,$(words $(LIB_OUTPUT_DIR))),)
  $(error $(_err)LIB_OUTPUT_DIR: spaces not allowed$(_end))
endif

override _static_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $($x.TYPE),$(if $(filter static,$($x.TYPE)),$x),$x)))
override _shared_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))
override _src_path := $(if $(SOURCE_DIR),$(SOURCE_DIR:%/=%)/)

# environment specific setup
override define setup_env  # <1:build env>
override ENV := $1
override SFX := $$($1_sfx)
override TMP := $$(BUILD_DIR)/$$(ENV)_tmp
override _$1_libdir := $$(if $$(LIB_OUTPUT_DIR),$$(LIB_OUTPUT_DIR:%/=%)/)
override _$1_bindir := $$(if $$(BIN_OUTPUT_DIR),$$(BIN_OUTPUT_DIR:%/=%)/)

ifneq ($$(filter 1,$$(words $$(filter $$(_$1_libdir),$$(foreach x,$$(env_names),$$(_$$x_libdir))))),)
override _$1_lib_targets :=\
  $$(foreach x,$$(_static_lib_labels),$$(_$1_libdir)$$($$x).a)\
  $$(foreach x,$$(_shared_lib_labels),$$(_$1_libdir)$$($$x).so$$(if $$($$x.VERSION),.$$($$x.VERSION)))
else
override _$1_lib_targets :=\
  $$(foreach x,$$(_static_lib_labels),$$(_$1_libdir)$$($$x)$$($1_sfx).a)\
  $$(foreach x,$$(_shared_lib_labels),$$(_$1_libdir)$$($$x)$$($1_sfx).so$$(if $$($$x.VERSION),.$$($$x.VERSION)))
endif

ifneq ($$(filter 1,$$(words $$(filter $$(_$1_bindir),$$(foreach x,$$(env_names),$$(_$$x_bindir))))),)
override _$1_bin_targets := $$(foreach x,$$(_bin_labels),$$(_$1_bindir)$$($$x))
else
override _$1_bin_targets := $$(foreach x,$$(_bin_labels),$$(_$1_bindir)$$($$x)$$($1_sfx))
endif

override _$1_file_targets := $$(foreach x,$$(_file_labels),$$($$x))
override _$1_test_targets := $$(foreach x,$$(_test_labels),$$($$x)$$($1_sfx))
override _$1_build_targets := $$(_$1_file_targets) $$(_$1_lib_targets) $$(_$1_bin_targets) $$(_$1_test_targets)
override _$1_aliases :=\
  $$(foreach x,$$(_all_labels),$$x$$($1_sfx))\
  $$(foreach x,$$(_lib_labels),$$($$x)$$($1_sfx))\
  $$(if $$(_$1_libdir),$$(foreach x,$$(_static_lib_labels),$$($$x)$$($1_sfx).a))\
  $$(foreach x,$$(_shared_lib_labels),\
    $$(if $$(or $$(_$1_libdir),$$($$x.VERSION)),$$($$x)$$($1_sfx).so))\
  $$(if $$(_$1_bindir),$$(foreach x,$$(_bin_labels),$$($$x)$$($1_sfx)))
override _$1_goals :=\
  $$(sort\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),all) $1,$$(MAKECMDGOALS)),$$(_$1_build_targets))\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),tests) tests_$1,$$(MAKECMDGOALS)),$$(_$1_test_targets))\
    $$(filter $$(_$1_build_targets) $$(_$1_aliases),$$(MAKECMDGOALS)))
override _$1_links :=\
  $$(foreach x,$$(_shared_lib_labels),\
    $$(if $$($$x.VERSION),$$(_$1_libdir)$$($$x)$$($1_sfx).so)\
    $$(if $$(word 2,$$(subst ., ,$$($$x.VERSION))),\
      $$(_$1_libdir)$$($$x)$$($1_sfx).so.$$(word 1,$$(subst ., ,$$($$x.VERSION)))))
endef
$(foreach x,$(env_names),$(eval $(call setup_env,$x)))

# setting value processing functions
override format_warn = $(foreach x,$1,$(if $(filter -%,$x),$x,-W$x))
override format_include = $(foreach x,$1,$(if $(filter -%,$x),$x,-I$x))
override format_define = $(foreach x,$1,$(if $(filter -%,$x),$x,-D'$x'))
override format_libs = $(foreach x,$1,$(if $(filter -%,$x),$x,$(if $(filter ./,$(dir $x)),,-L$(dir $x)) -l$(notdir $x)))


# build environment detection
override _build_env := $(strip $(foreach x,$(env_names),$(if $(_$x_goals),$x)))
ifeq ($(filter 0 1,$(words $(_build_env))),)
  $(error $(_err)Targets in multiple environments not allowed$(_end))
else ifneq ($(_build_env),)
  # setup build targets/variables for selected environment
  override ENV := $(_build_env)
  override SFX := $($(ENV)_sfx)
  override TMP := $(BUILD_DIR)/$(ENV)_tmp

  override _pkgs := $(call check_pkgs,PACKAGES)
  ifneq ($(_pkgs),)
    override _pkg_flags := $(call get_pkg_flags,$(_pkgs))
    override _pkg_libs := $(call get_pkg_libs,$(_pkgs))
  endif

  override _test_pkgs := $(call check_pkgs,TEST_PACKAGES)
  ifneq ($(_test_pkgs),)
    override _test_pkg_flags := $(call get_pkg_flags,$(_test_pkgs))
    override _test_pkg_libs := $(call get_pkg_libs,$(_test_pkgs))
  endif

  override _define := $(call format_define,$(DEFINE))
  override _include := $(call format_include,$(INCLUDE))
  ifeq ($(strip $(CXXFLAGS)),)
    override CXXFLAGS = $(_cxx_std) $($(ENV)_flags) $(call format_warn,$(WARN)) $(_op_cxx_warn) $(_define) $(_include) $(_op_cxx_flags) $(_pkg_flags) $(FLAGS)
  endif
  ifeq ($(strip $(CFLAGS)),)
    override CFLAGS = $(_cc_std) $($(ENV)_flags) $(call format_warn,$(WARN_C)) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_pkg_flags) $(FLAGS)
  endif
  ifeq ($(strip $(ASFLAGS)),)
    override ASFLAGS = $($(ENV)_flags) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_pkg_flags) $(FLAGS)
  endif

  ifeq ($(strip $(LDFLAGS)),)
    override LDFLAGS = -Wl,--as-needed -L$(or $(_$(ENV)_libdir),.)
  endif

  # setup compile flags for each build path
  # default compile flags
  override _cxxflags_$(ENV) := $(CXXFLAGS)
  override _cflags_$(ENV) := $(CFLAGS)
  override _asflags_$(ENV) := $(ASFLAGS)
  # default compile flags for tests
  # (used if TEST_FLAGS is set or TEST_PACKAGES generates compile flags)
  override _cxxflags_$(ENV)-tests := $(_cxxflags_$(ENV)) $(_test_pkg_flags) $(TEST_FLAGS)
  override _cflags_$(ENV)-tests := $(_cflags_$(ENV)) $(_test_pkg_flags) $(TEST_FLAGS)
  override _asflags_$(ENV)-tests := $(_asflags_$(ENV)) $(_test_pkg_flags) $(TEST_FLAGS)

  override _libs := $(call format_libs,$(LIBS))
  override _test_libs := $(call format_libs,$(TEST_LIBS))

  # pre-build setup per label
  override define build_entry  # <1:label>
  override _$1_src_objs := $$(addsuffix .o,$$(call src_bname,$$($1.SRC)))
  ifeq ($$($1.PACKAGES),)
    override _$1_pkg_libs := $$(_pkg_libs) $$(if $$(filter $1,$$(_test_labels)),$$(_test_pkg_libs))
    override _$1_pkg_flags := $$(_pkg_flags)
  else ifneq ($$($1.PACKAGES),-)
    override _$1_pkgs := $$(call check_pkgs,$1.PACKAGES)
    override _$1_pkg_libs := $$(call get_pkg_libs,$$(_$1_pkgs))
    override _$1_pkg_flags := $$(call get_pkg_flags,$$(_$1_pkgs))
  endif

  # NOTE: LIBS before PACKAGES libs in case included static lib requires package
  ifeq ($$($1.LIBS),)
    override _$1_libs := $$(_libs) $$(if $$(filter,$1,$$(_test_labels)),$$(_test_libs)) $$(_$1_pkg_libs)
  else ifneq ($$($1.LIBS),-)
    override _$1_libs := $$(call format_libs,$$($1.LIBS)) $$(_$1_pkg_libs)
  else
    override _$1_libs := $$(_$1_pkg_libs)
  endif

  override _$1_test_flags := $$(if $$(filter $1,$$(_test_labels)),$$(strip $$(if $$($1.PACKAGES),,$$(_test_pkg_flags)) $$(if $$($1.FLAGS),,$$(TEST_FLAGS))))
  override _$1_build_sfx := $$(if $$(or $$($1.STANDARD),$$($1.OPT_LEVEL),$$($1.DEFINE),$$($1.INCLUDE),$$($1.PACKAGES),$$($1.OPTIONS),$$($1.FLAGS),$$($1.CXXFLAGS),$$($1.CFLAGS),$$($1.ASFLAGS),$$($1.DEPS)),-$1)
  override _$1_build := $$(ENV)$$(or $$(_$1_build_sfx),$$(if $$(_$1_test_flags),-tests))
  ifneq (_$1_build_sfx,)
    ifeq ($$($1.DEFINE),)
      override _$1_define := $$(_define)
    else ifneq ($$($1.DEFINE),-)
      override _$1_define := $$(call format_define,$$($1.DEFINE))
    endif

    ifeq ($$($1.INCLUDE),)
      override _$1_include := $$(_include)
    else ifneq ($$($1.INCLUDE),-)
      override _$1_include := $$(call format_include,$$($1.INCLUDE))
    endif

    # NOTE: FLAGS after PACKAGES flags so specified flags always override
    ifeq ($$($1.FLAGS),)
      override _$1_flags := $$(_$1_pkg_flags) $$(FLAGS) $$(_$1_test_flags)
    else ifneq ($$($1.FLAGS),-)
      override _$1_flags := $$(_$1_pkg_flags) $$($1.FLAGS) $$(_$1_test_flags)
    else
      override _$1_flags := $$(_$1_pkg_flags) $$(_$1_test_flags)
    endif

    override _cxxflags_$$(_$1_build) := $$(or $$($1.CXXFLAGS),$$(_$1_cxx_std) $$(call $$(ENV)_flags,$1) $$(call format_warn,$$(WARN)) $$(_$1_op_cxx_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_cxx_flags) $$(_$1_flags))
    override _cflags_$$(_$1_build) := $$(or $$($1.CFLAGS),$$(_$1_cc_std) $$(call $$(ENV)_flags,$1) $$(call format_warn,$$(WARN_C)) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_flags))
    override _asflags_$$(_$1_build) := $$(or $$($1.ASFLAGS),$$(call $$(ENV)_flags,$1) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_flags))
  endif
  endef
  $(foreach x,$(_src_labels),$(eval $(call build_entry,$x)))

  # NOTES:
  # - _<label>_build_sfx is non-empty if an isolated build is required for target
  #   (technically not always true but current behavior is to be safe without
  #   doing the work of checking if compile flags would actually change because
  #   of the target specific config)
  # - <label>.DEPS can cause an isolated build even though there are no compile
  #   flag changes (target 'source.o : | dep' rules would affect other builds
  #   without isolation)

  # halt build for package errors on non-test targets
  $(eval $(call verify_pkgs,PACKAGES,_pkgs))
  $(foreach x,$(_bin_labels) $(_lib_labels),$(eval $(call verify_pkgs,$x.PACKAGES,_$x_pkgs)))

  ifneq ($(filter 1,$(words $(filter $(_$(ENV)_bindir),$(foreach x,$(env_names),$(_$x_bindir))))),)
    # each environment has a different bindir
    $(foreach x,$(_bin_labels),\
      $(eval override _$x_name := $(_$(ENV)_bindir)$($x)))
  else
    # environments share the same bindir - add env suffix to binary names
    $(foreach x,$(_bin_labels),\
      $(eval override _$x_name := $(_$(ENV)_bindir)$($x)$(SFX)))
  endif

  ifneq ($(filter 1,$(words $(filter $(_$(ENV)_libdir),$(foreach x,$(env_names),$(_$x_libdir))))),)
    # each environment has a different libdir
    $(foreach x,$(_static_lib_labels),\
      $(eval override _$x_name := $(_$(ENV)_libdir)$($x).a))
    $(foreach x,$(_shared_lib_labels),\
      $(eval override _$x_shared_lib := $($x).so))
  else
    # environments share the same libdir - add env suffix to library names
    $(foreach x,$(_static_lib_labels),\
      $(eval override _$x_name := $(_$(ENV)_libdir)$($x)$(SFX).a))
    $(foreach x,$(_shared_lib_labels),\
      $(eval override _$x_shared_lib := $($x)$(SFX).so))
  endif

  $(foreach x,$(_bin_labels),\
    $(eval override _$x_mkdir := $(_$(ENV)_bindir)$(if $(filter ./,$(dir $($x))),,$(dir $($x))))\
    $(eval override _$x_aliases := $x$(SFX) $(if $(_$(ENV)_bindir),$($x)$(SFX)) $(if $(SFX),$x $($x))))
  $(foreach x,$(_lib_labels),\
    $(eval override _$x_mkdir := $(_$(ENV)_libdir)$(if $(filter ./,$(dir $($x))),,$(dir $($x)))))
  $(foreach x,$(_static_lib_labels),\
    $(eval override _$x_aliases := $x$(SFX) $($x)$(SFX) $(if $(_$(ENV)_libdir),$($x)$(SFX).a) $(if $(SFX),$x $($x) $($x).a)))
  $(foreach x,$(_shared_lib_labels),\
    $(eval override _$x_shared_name := $(_$(ENV)_libdir)$(_$x_shared_lib)$(if $($x.VERSION),.$($x.VERSION)))\
    $(eval override _$x_soname := $(if $($x.VERSION),$(notdir $($x)).so.$(word 1,$(subst ., ,$($x.VERSION)))))\
    $(eval override _$x_shared_aliases := $x$(SFX) $($x)$(SFX) $(if $(or $(_$(ENV)_libdir),$($x.VERSION)),$($x)$(SFX).so) $(if $(SFX),$x $($x) $($x).so)))
  $(foreach x,$(_test_labels),\
    $(eval override _$x_aliases := $x$(SFX) $($x)$(SFX))\
    $(eval override _$x_run := $(BUILD_DIR)/$(_$x_build)/__$x))

  $(foreach x,$(_file_labels),\
    $(eval override OUT := $($x))\
    $(eval override DEPS := $($x.DEPS))\
    $(foreach n,$(wordlist 1,$(words $($x.DEPS)),$(_1-99)),\
      $(eval override DEP$n := $(word $n,$($x.DEPS))))\
    $(eval override _$x_aliases := $x$(SFX))\
    $(eval override _$x_command := $($x.CMD)))

  # binaries depend on lib goals to make sure libs are built first
  override _lib_goals :=\
    $(foreach x,$(_static_lib_labels),$(if $(filter $(_$x_aliases) $(_$x_name),$(_$(ENV)_goals)),$(_$x_name)))\
    $(foreach x,$(_shared_lib_labels),$(if $(filter $(_$x_shared_aliases) $(_$x_shared_name),$(_$(ENV)_goals)),$(_$x_shared_name)))
  # tests depend on lib & bin goals to make sure they always build/run last
  override _bin_goals :=\
    $(foreach x,$(_bin_labels),$(if $(filter $(_$x_aliases) $(_$x_name),$(_$(ENV)_goals)),$(_$x_name)))
  # if tests are a stated target, build all test binaries before running them
  override _test_goals :=\
    $(foreach x,$(_test_labels),$(if $(filter $(_$x_aliases) tests tests_$(ENV) $(ENV),$(MAKECMDGOALS)),$(_$x_run)))
endif


#### Main Targets ####
.PHONY: $(_base_targets)

.DEFAULT_GOAL = $(DEFAULT_ENV)
all: $(DEFAULT_ENV)
tests: tests_$(DEFAULT_ENV)

info:
	@echo '$(_info)==== Build Target Info ====$(_end)'
	$(if $(filter 0,$(words $(_all_labels))),@echo 'No build targets defined')
	$(if $(_bin_labels),@echo 'Binaries($(words $(_bin_labels))): $(_bold)$(foreach x,$(_bin_labels),$(value $x))$(_end)')
	$(if $(_lib_labels),@echo 'Libraries($(words $(_lib_labels))): $(_bold)$(foreach x,$(_lib_labels),$(value $x))$(_end)')
	$(if $(_file_labels),@echo 'Files($(words $(_file_labels))): $(_bold)$(foreach x,$(_file_labels),$(value $x))$(_end)')
	$(if $(_test_labels),@echo 'Tests($(words $(_test_labels))): $(_bold)$(foreach x,$(_test_labels),$(value $x))$(_end)')
	@echo

help:
	@echo '$(_info)==== Command Help ====$(_end)'
	@echo '$(_bold)make$(_end) or $(_bold)make all$(_end)   builds default environment ($(_bold)$(_fg3)$(DEFAULT_ENV)$(_end))'
	@echo '$(_bold)make $(_fg3)<env>$(_end)         builds specified environment'
	@echo '                   available: $(_bold)$(_fg3)$(env_names)$(_end)'
	@echo '$(_bold)make clean$(_end)         removes all build files except for made binaries/libraries'
	@echo '$(_bold)make clobber$(_end)       as clean, but also removes made binaries/libraries'
	@echo '$(_bold)make tests$(_end)         builds/runs all tests'
	@echo '$(_bold)make info$(_end)          prints build target summary'
	@echo '$(_bold)make help$(_end)          prints this information'
	@echo

override define setup_env_targets  # <1:build env>
$1: $$(_$1_build_targets)
tests_$1: $$(_$1_test_targets)

clean_$1:
	@([ -d "$(BUILD_DIR)/$1_tmp" ] && $$(RM) "$$(BUILD_DIR)/$1_tmp/"* && rmdir -- "$$(BUILD_DIR)/$1_tmp") || true
	@$$(RM) "$$(BUILD_DIR)/.$1-cmd-"*
	@for D in "$$(BUILD_DIR)/$1"*; do\
	  ([ -d "$$$$D" ] && echo "$$(_warn)Cleaning '$$$$D'$$(_end)" && $$(RM) "$$$$D/"*.mk "$$$$D/"*.o "$$$$D/__TEST"* "$$$$D/.compile_cmd"* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach x,$(env_names),$(eval $(call setup_env_targets,$x)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver" "$(BUILD_DIR)/.packages_ver"* $(foreach x,$(SYMLINKS),"$x")
	@([ -d "$(BUILD_DIR)" ] && rmdir -p -- "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA) $(foreach x,$(env_names),$(_$x_file_targets)); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(_warn)Removing '$$X'$(_end)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach e,$(env_names),$(_$e_lib_targets) $(_$e_links) $(_$e_bin_targets)) core gmon.out $(CLOBBER_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(_warn)Removing '$$X'$(_end)" && $(RM) "$$X") || true; done
	@for X in $(filter-out "./",$(sort $(subst /./,/,$(foreach e,$(env_names),$(foreach x,$(_bin_labels),"$(_$e_bindir)$(dir $($x))") $(foreach x,$(_lib_labels),"$(_$e_libdir)$(dir $($x))"))))); do\
	  ([ -d "$$X" ] && rmdir -p --ignore-fail-on-non-empty -- "$$X") || true; done

install: ; $(error $(_err)Target 'install' not implemented$(_end))
install-strip: ; $(error $(_err)Target 'install-strip' not implemented$(_end))

override define make_subdir_target  # <1:target>
$1: _subdir_$1
.PHONY: _subdir_$1
_subdir_$1:
	@for D in $$(SUBDIRS); do\
	  ([ -d "$$$$D" ] && ($$(MAKE) -C "$$$$D" $1 || true)) || echo "$$(_warn)SUBDIRS: unknown directory '$$$$D' - skipping$$(_end)"; done
endef
ifneq ($(strip $(SUBDIRS)),)
  $(foreach x,$(_subdir_targets),$(eval $(call make_subdir_target,$x)))
endif


#### Unknown Target Handling ####
.SUFFIXES:
.DEFAULT: ; $(error $(_err)$(if $(filter $<,$(_all_source)),Missing source file '$<','$<' unknown)$(_end))


#### Build Functions ####
override define rebuild_check  # <1:trigger file> <2:trigger text>
ifneq ($$(file <$1),$2)
  $$(shell $$(RM) "$1")
endif
$1:
	@mkdir -p "$$(@D)"
	@echo -n "$2" >$1
endef

# static library build
override define make_static_lib  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(AR) rc '$$(_$1_name)' $$(strip $$(_$1_all_objs) $$($1.OBJS))
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-static
$$(eval $$(call rebuild_check,$$$$(_$1_trigger),$$$$(_$1_link_cmd)))

ifneq ($$($1.DEPS),)
$$(_$1_all_objs): | $$($1.DEPS)
endif

$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_all_objs) $$($1.OBJS) $$(_$1_trigger)
ifneq ($$(_$1_mkdir),)
	@mkdir -p "$$(_$1_mkdir)"
endif
	@-$$(RM) "$$@"
	$$(_$1_link_cmd)
	$$(RANLIB) '$$@'
	@echo "$$(_info)Static library '$$@' built$$(_end)"
endef

# shared library build
override define make_shared_lib  # <1:label>
override _$1_shared_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)-pic/,$$(_$1_src_objs))
override _$1_shared_link_cmd := $$(strip $$(if $$(filter cxx,$$(_$1_lang)),$$(CXX) $$(_cxxflags_$$(_$1_build)),$$(CC) $$(_cflags_$$(_$1_build))) $$(LDFLAGS) -fPIC -shared $$(if $$(_$1_soname),-Wl$$(_comma)-h$$(_comma)'$$(_$1_soname)') $$(_$1_shared_objs) $$($1.OBJS) $$(_$1_libs)) -o '$$(_$1_shared_name)'
override _$1_shared_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-shared
$$(eval $$(call rebuild_check,$$$$(_$1_shared_trigger),$$$$(_$1_shared_link_cmd)))

ifneq ($$($1.DEPS),)
$$(_$1_shared_objs): | $$($1.DEPS)
endif

$$(_$1_shared_aliases): $$(_$1_shared_name)
$$(_$1_shared_name): $$(_$1_shared_objs) $$($1.OBJS) $$(_$1_shared_trigger)
ifneq ($$(_$1_mkdir),)
	@mkdir -p "$$(_$1_mkdir)"
endif
	$$(_$1_shared_link_cmd)
ifneq ($$($1.VERSION),)
	ln -sf "$$(notdir $$(_$1_shared_name))" "$$(_$$(ENV)_libdir)$$(_$1_shared_lib)"
ifneq ($$(word 2,$$(subst ., ,$$($1.VERSION))),)
	ln -sf "$$(notdir $$(_$1_shared_name))" "$$(_$$(ENV)_libdir)$$(_$1_shared_lib).$$(word 1,$$(subst ., ,$$($1.VERSION)))"
endif
endif
	@echo "$$(_info)Shared library '$$@' built$$(_end)"
endef

# binary build
override define make_bin  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(strip $$(if $$(filter cxx,$$(_$1_lang)),$$(CXX) $$(_cxxflags_$$(_$1_build)),$$(CC) $$(_cflags_$$(_$1_build))) $$(LDFLAGS) $$(_$1_all_objs) $$($1.OBJS) $$(_$1_libs)) -o '$$(_$1_name)'
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$(_$1_trigger),$$$$(_$1_link_cmd)))

ifneq ($$($1.DEPS),)
$$(_$1_all_objs): | $$($1.DEPS)
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_all_objs) $$($1.OBJS) $$(_$1_trigger) | $$(_lib_goals)
ifneq ($$(_$1_mkdir),)
	@mkdir -p "$$(_$1_mkdir)"
endif
	$$(_$1_link_cmd)
	@echo "$$(_info)Binary '$$@' built$$(_end)"
endef

# generic file build
override define make_file  # <1:label>
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$(_$1_trigger),$$$$($1.CMD)))

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$($1)
$$($1): $$(_$1_trigger) $$($1.DEPS)
	$$(_$1_command)
	@echo "$$(_info)File '$$@' created$$(_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define make_test  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(strip $$(if $$(filter cxx,$$(_$1_lang)),$$(CXX) $$(_cxxflags_$$(_$1_build)),$$(CC) $$(_cflags_$$(_$1_build))) $$(LDFLAGS) $$(_$1_all_objs) $$($1.OBJS) $$(_$1_libs)) -o '$$(_$1_run)'
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$(_$1_trigger),$$$$(_$1_link_cmd)))

ifneq ($$($1.DEPS),)
$$(_$1_all_objs): | $$($1.DEPS)
endif

$$(_$1_run): $$(_$1_all_objs) $$($1.OBJS) $$(_$1_trigger) | $$(_lib_goals) $$(_bin_goals)
	$$(_$1_link_cmd)
ifeq ($$(filter tests tests_$$(ENV) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$(_$1_run) $$($1.ARGS);\
	EXIT_STATUS=$$$$?;\
	if [[ $$$$EXIT_STATUS -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX) '$$($1)'$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX) '$$($1)'$$(_end)"; exit $$$$EXIT_STATUS; fi
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_run) | $$(_test_goals)
ifneq ($$(filter tests tests_$$(ENV) $1$$(SFX) $$($1)$$(SFX),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$(_$1_run) $$($1.ARGS);\
	if [[ $$$$? -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX) '$$($1)'$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX) '$$($1)'$$(_end)"; $$(RM) "$$(_$1_run)"; fi
endif
endef


override define make_dep  # <1:path> <2:src> <3:cmd trigger> <4:pkg trigger>
$1/$(call src_bname,$2).o: $(_src_path)$2 $1/$3 $$(BUILD_DIR)/.compiler_ver $4 | $$(SYMLINKS)
-include $1/$(call src_bname,$2).mk
endef

override define make_obj  # <1:path> <2:build> <3:flags> <4:src list>
ifneq ($4,)
$1/%.mk: ; @$$(RM) "$$(@:.mk=.o)"

$$(eval $$(call rebuild_check,$1/.compile_cmd_c,$$(strip $$(CC) $$(_cflags_$2) $3)))
$(addprefix $1/,$(addsuffix .o,$(call src_bname,$(filter $(c_ptrn),$4)))):
	$$(strip $$(CC) $$(_cflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(c_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd_c,$$(_pkg_trigger-$2))))

$$(eval $$(call rebuild_check,$1/.compile_cmd_s,$$(strip $$(AS) $$(_asflags_$2) $3)))
$(addprefix $1/,$(addsuffix .o,$(call src_bname,$(filter $(asm_ptrn),$4)))):
	$$(strip $$(AS) $$(_asflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(asm_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd_s,$$(_pkg_trigger-$2))))

$$(eval $$(call rebuild_check,$1/.compile_cmd,$$(strip $$(CXX) $$(_cxxflags_$2) $3)))
$1/%.o: ; $$(strip $$(CXX) $$(_cxxflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(cxx_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd,$$(_pkg_trigger-$2))))
endif
endef


#### Create Build Targets ####
.DELETE_ON_ERROR:
ifneq ($(_build_env),)
  $(shell mkdir -p $(TMP))

  # symlink creation rule
  $(foreach x,$(SYMLINKS),$(eval $x: ; @ln -s . "$x"))

  # .compiler_ver rule (rebuild trigger for compiler version upgrades)
  $(eval $(call rebuild_check,$(BUILD_DIR)/.compiler_ver,$(shell $(CC) --version | head -1)))

  # .packages_ver rules (rebuild triggers for package version changes)
  $(if $(_pkgs),\
    $(eval override _pkg_trigger-$(ENV) := $(BUILD_DIR)/.packages_ver)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver,$(foreach p,$(sort $(_pkgs)),$p:$(call get_pkg_ver,$p)))))

  $(if $(_test_pkgs),\
    $(eval override _pkg_trigger-$(ENV)-tests := $(BUILD_DIR)/.packages_ver-tests)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver-tests,$(foreach p,$(sort $(_pkgs) $(_test_pkgs)),$p:$(call get_pkg_ver,$p)))))

  $(foreach x,$(_src_labels),$(if $(_$x_pkgs),\
    $(eval override _pkg_trigger-$(ENV)-$x := $(BUILD_DIR)/.packages_ver-$x)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver-$x,$(foreach p,$(sort $(_$x_pkgs)),$p:$(call get_pkg_ver,$p))))))

  # make .o/.mk files for each build path
  # NOTES:
  # - don't put 'call' args on separate lines, this can add spaces to values
  # - object builds are before linking so '<objs>: DEPS' rules don't affect
  #   compile commands by changing '$<' var
  $(foreach b,$(sort $(foreach x,$(_static_lib_labels) $(_bin_labels) $(_test_labels),$(_$x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b,$b,,$(sort $(foreach x,$(_static_lib_labels) $(_bin_labels) $(_test_labels),$(if $(filter $(_$x_build),$b),$($x.SRC)))))))

  $(foreach b,$(sort $(foreach x,$(_shared_lib_labels),$(_$x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b-pic,$b,-fPIC,$(sort $(foreach x,$(_shared_lib_labels),$(if $(filter $(_$x_build),$b),$($x.SRC)))))))

  # make binary/library/test build targets
  .PHONY: $(sort $(foreach x,$(_lib_labels),$(_$x_aliases) $(_$x_shared_aliases)))
  $(foreach x,$(_static_lib_labels),$(eval $(call make_static_lib,$x)))
  $(foreach x,$(_shared_lib_labels),$(eval $(call make_shared_lib,$x)))
  $(foreach x,$(_bin_labels),$(eval $(call make_bin,$x)))
  $(foreach x,$(_file_labels),$(eval $(call make_file,$x)))
  $(foreach x,$(_test_labels),$(eval $(call make_test,$x)))
endif

#### END ####
