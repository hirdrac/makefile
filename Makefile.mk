#
# Makefile.mk - version 1.16.1 (2020/11/17)
# Copyright (C) 2020 Richard Bradley
#
# Additional contributions from:
#   Stafford Horne (github:stffrdhrn)
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
#  clobber         deletes build directory & built binaries/libraries/files
#  tests           run all tests for DEFAULT_ENV
#  info            prints summary of defined build targets
#  help            prints command summary
#
# Makefile Parameters:
#  BIN<1-99>       name of binary to build
#  BIN1.SRC        source files for binary 1 (C/C++ source files, no headers)
#  BIN1.OBJS       additional binary 1 object dependencies (.o,.a files)
#  BIN1.DEPS       additional dependencies for building all binary 1 objects
#
#  LIB<1-99>       name of library to build (without .a/.so/.dll extension)
#  LIB1.TYPE       type of library to build: static(default) and/or shared
#  LIB1.SRC        source files for library 1
#  LIB1.OBJS       additional library 1 object dependencies
#  LIB1.DEPS       additional dependencies for building all library 1 objects
#  LIB1.VERSION    major(.minor(.patch)) version of shared library 1
#
#  FILE<1-999>     file to generate (i.e. generated source code)
#  FILE1.DEPS      file dependencies to trigger a rebuild for file 1
#  FILE1.CMD       command to execute to create file 1
#                  for CMD, these variables can be used in the definition:
#                    DEPS - same as FILE1.DEPS
#                    DEP1 - first DEPS value only
#                    OUT  - same as FILE1
#
#  TEMPLATE<1-99>  file to generate (w/ template variables)
#  TEMPLATE1.DEPS  used to create 'FILE1.DEPS'
#  TEMPLATE1.CMD   used to create 'FILE1.CMD'
#                  use of other vars (BUILD_TMP,DEP1,OUT,etc.) should be escaped
#  TEMPLATE1.FILE1 values used for 'FILE1' creation
#                  referenced by $(VALS) or $(VAL1),$(VAL2),etc. in template
#
#  TEST<1-999>     unit test description (optional)
#  TEST1.ARGS      arguments for running test 1 binary
#  TEST1.SRC       source files for unit test 1
#  TEST1.OBJS      additional unit test 1 object dependencies
#  TEST1.DEPS      additional dependencies for building all test 1 objects
#
#  COMPILER        compiler to use (gcc,clang)
#  CROSS_COMPILE   binutils and gcc toolchain prefix (i.e. arm-linux-gnueabi-)
#  STANDARD        language standard(s) of source code
#  OPT_LEVEL       optimization level for release & profile builds
#  OPT_LEVEL_DEBUG optimization level for debug builds
#  SUBSYSTEM       subsystem value for Windows binary builds
#  WARN            C/C++ compile warning flags (-W optional)
#  WARN_C          C specific warnings (WARN setting used for C code if unset)
#  PACKAGES        list of packages for pkg-config
#  PACKAGES_TEST   additional packages for all tests
#  INCLUDE         includes needed not covered by pkg-config (-I optional)
#  LIBS            libraries needed not covered by pkg-config (-l optional)
#  LIBS_TEST       additional libs to link with for all tests (-l optional)
#  DEFINE          defines for compilation (-D optional)
#  OPTIONS         list of options to enable - use instead of specific flags
#    warn_error    make all compiler warnings into errors
#    pthread       compile with pthreads support
#    lto           enable link-time optimization
#    modern_c++    enable warnings for some old-style C++ syntax (pre C++11)
#    no_rtti       disable C++ RTTI
#    no_except     disable C++ exceptions
#    pedantic      enforces strict ISO C/C++ compliance
#    static_rtlib  staticly link with runtime library (libgcc usually)
#    static_stdlib staticly link with C++ standard library (libstdc++ usually)
#  FLAGS           additional compiler flags not otherwise specified
#  FLAGS_TEST      additional compiler flags for all tests
#  FLAGS_RELEASE   additional compiler flags for release builds
#  FLAGS_DEBUG     additional compiler flags for debug builds
#  FLAGS_PROFILE   additional compiler flags for profile builds
#  LINK_FLAGS      additional linking flags not otherwise specified
#  *_EXTRA         available for most settings to provide additional values
#
#  <OS>.<VAR>      set OS specific value for any setting - overrides non-OS
#                    specific value.  WINDOWS,LINUX supported
#
#  CXXFLAGS/CFLAGS/ASFLAGS/LDFLAGS
#    can be used to override settings generated compile/link flags
#    (globally or for specific targets)
#
#  BUILD_DIR       directory for generated object/prerequisite files
#  DEFAULT_ENV     default environment to build (release,debug,profile)
#  OUTPUT_DIR      default output directory (defaults to current directory)
#  OUTPUT_LIB_DIR  directory for generated libraries (defaults to OUTPUT_DIR)
#  OUTPUT_BIN_DIR  directory for generated binaries (defaults to OUTPUT_DIR)
#  CLEAN_EXTRA     extra files to delete for 'clean' target
#  CLOBBER_EXTRA   extra files to delete for 'clobber' target
#  SUBDIRS         sub-directories to also make with base targets
#  SYMLINKS        symlinks to the current dir to create for building
#  SOURCE_DIR      source files base directory
#
#  Settings STANDARD/OPT_LEVEL/OPT_LEVEL_DEBUG/SUBSYSTEM/PACKAGES/INCLUDE/LIBS/
#    DEFINE/OPTIONS/FLAGS/LINK_FLAGS/CXXFLAGS/CFLAGS/ASFLAGS/LDFLAGS/SOURCE_DIR
#    can be set for specific targets to override global values
#    (ex.: BIN1.FLAGS = -pthread)
#    A value of '-' can be used to clear the setting for the target
#
#  Filename wildcard '*' supported for .SRC,.DEPS,.OBJS settings
#
#  <X>.LIBS/<X>.OBJS can accept LIB labels of library targets. Library
#    LIBS/PACKAGES/binary will automatically be used in target building.
#    LIBS will perfer shared library for linking if available, OBJS will only
#    allow linking with static libraries.
#    (ex.: BIN1.LIBS = LIB1)
#
# Output Variables:
#  ENV             current build environment
#  SFX             current build environment binary suffix
#  BUILD_TMP       build environment specific temporary directory
#  ALL_FILES       all FILEx targets (useful for .DEPS rule on specific targets)
#  <X>.ALL_FILES   all FILEx targets from a specific template
#  LIBPREFIX       name prefix for libraries (usually 'lib')
#

#### Make Version & Multi-include Check ####
_min_ver := 4.2
MAKE_VERSION ?= 1.0
ifeq ($(filter $(_min_ver),$(firstword $(sort $(MAKE_VERSION) $(_min_ver)))),)
  $(error GNU make version $(_min_ver) or later required)
endif

ifdef _makefile_already_included
  $(error $(lastword $(MAKEFILE_LIST)) included multiple times)
endif
override _makefile_already_included := 1


#### Shell Commands ####
SHELL = /bin/sh
PKGCONF ?= pkg-config
RM ?= rm -f --


#### Basic Settings ####
COMPILER ?= $(firstword $(_compiler_names))
CROSS_COMPILE ?=
STANDARD ?=
OPT_LEVEL ?= 3
OPT_LEVEL_DEBUG ?= g
ifndef WARN
  WARN = all extra no-unused-parameter non-virtual-dtor overloaded-virtual $(_$(COMPILER)_warn)
  WARN_C ?= all extra no-unused-parameter write-strings $(_$(COMPILER)_warn)
else
  WARN_C ?= $(WARN)
endif
PACKAGES ?=
PACKAGES_TEST ?=
INCLUDE ?=
LIBS ?=
LIBS_TEST ?=
DEFINE ?=
OPTIONS ?=
FLAGS ?=
FLAGS_TEST ?=
FLAGS_RELEASE ?=
FLAGS_DEBUG ?=
FLAGS_PROFILE ?=
LINK_FLAGS ?=

BUILD_DIR ?= build
DEFAULT_ENV ?= $(firstword $(_env_names))
OUTPUT_DIR ?=
OUTPUT_LIB_DIR ?= $(OUTPUT_DIR)
OUTPUT_BIN_DIR ?= $(OUTPUT_DIR)
CLEAN_EXTRA ?=
CLOBBER_EXTRA ?=
SUBDIRS ?=
SYMLINKS ?=
SOURCE_DIR ?=

# default values to be more obvious if used/handled improperly
override ENV := ENV
override SFX := SFX
override BUILD_TMP := BUILD_TMP
override LIBPREFIX := lib

# apply *_EXTRA setting values
$(foreach x,WARN WARN_C PACKAGES PACKAGES_TEST INCLUDE LIBS LIBS_TEST DEFINE OPTIONS FLAGS FLAGS_TEST FLAGS_RELEASE FLAGS_DEBUG FLAGS_PROFILE,\
  $(if $($x_EXTRA),$(eval override $x += $($x_EXTRA))))


#### OS Specific Values ####
override _uname := $(shell uname -s | tr A-Z a-z)
override _windows := $(filter cygwin% mingw% msys%,$(_uname))
override _linux := $(filter linux%,$(_uname))
override _pic_flag := $(if $(_windows),,-fPIC)
override _libprefix := $(if $(filter cygwin%,$(_uname)),cyg,$(if $(filter msys%,$(_uname)),msys-,lib))
override _libext := .$(if $(_windows),dll,so)
ifneq ($(_windows),)
  $(foreach x,$(filter WINDOWS.%,$(.VARIABLES)),\
    $(eval override $(patsubst WINDOWS.%,%,$x) = $(value $x)))
else ifneq ($(_linux),)
  $(foreach x,$(filter LINUX.%,$(.VARIABLES)),\
    $(eval override $(patsubst LINUX.%,%,$x) = $(value $x)))
endif


#### Environment Details ####
override _env_names := release debug profile
override _opt_lvl = $(or $(strip $($1.OPT_LEVEL)),$(strip $(OPT_LEVEL)))
override _debug_opt_lvl = $(or $(strip $($1.OPT_LEVEL_DEBUG)),$(strip $(OPT_LEVEL_DEBUG)))

override _release_uc := RELEASE
override _release_sfx :=
override _release_op = $(if $(_opt_lvl),-O$(_opt_lvl))
override _debug_uc := DEBUG
override _debug_sfx := -g
override _debug_op = -g $(if $(_debug_opt_lvl),-O$(_debug_opt_lvl))
override _profile_uc := PROFILE
override _profile_sfx := -pg
override _profile_op = -pg $(if $(_opt_lvl),-O$(_opt_lvl))


#### Compiler Details ####
override _compiler_names := gcc clang

override _gcc_cxx := g++
override _gcc_cc := gcc
override _gcc_as := gcc -x assembler-with-cpp
override _gcc_ar := gcc-ar
override _gcc_ranlib := gcc-ranlib
override _gcc_warn := shadow=local
override _gcc_modern := -Wzero-as-null-pointer-constant -Wregister -Wsuggest-override -Wsuggest-final-methods -Wsuggest-final-types

override _clang_cxx := clang++
override _clang_cc := clang
override _clang_as := clang -x assembler-with-cpp
override _clang_ar := llvm-ar
override _clang_ranlib := llvm-ranlib
override _clang_warn := shadow
override _clang_modern := -Wzero-as-null-pointer-constant -Wregister -Winconsistent-missing-override


#### Terminal Output ####
# _fg1 - binary/library built
# _fg2 - warning or removal notice
# _fg3 - test passed
# _fg4 - test failed or fatal error
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
override _msgInfo := $(_bold)$(_fg1)
override _msgWarn := $(_bold)$(_fg2)
override _msgErr := $(_bold)$(_fg4)


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(_compiler_names)),)
  $(error $(_msgErr)COMPILER: unknown compiler$(_end))
endif

CXX = $(CROSS_COMPILE)$(or $(_$(COMPILER)_cxx),c++)
CC = $(CROSS_COMPILE)$(or $(_$(COMPILER)_cc),cc)
AS = $(CROSS_COMPILE)$(or $(_$(COMPILER)_as),as)
AR = $(CROSS_COMPILE)$(or $(_$(COMPILER)_ar),ar)
RANLIB = $(CROSS_COMPILE)$(or $(_$(COMPILER)_ranlib),ranlib)

override _c_ptrn := %.c
override _c_stds := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18 c2x gnu2x
override _asm_ptrn := %.s %.S %.sx
override _cxx_ptrn := %.cc %.cp %.cxx %.cpp %.CPP %.c++ %.C
override _cxx_stds := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a c++20 gnu++20

override define _check_standard  # <1:standard var> <2:set prefix>
override $2_cxx_std := $$(addprefix -std=,$$(filter $$($1),$$(_cxx_stds)))
ifeq ($$(filter 0 1,$$(words $$($2_cxx_std))),)
  $$(error $$(_msgErr)$1: multiple C++ standards not allowed$$(_end))
endif
override $2_c_std := $$(addprefix -std=,$$(filter $$($1),$$(_c_stds)))
ifeq ($$(filter 0 1,$$(words $$($2_c_std))),)
  $$(error $$(_msgErr)$1: multiple C standards not allowed$$(_end))
endif
ifneq ($$(filter-out $$(_cxx_stds) $$(_c_stds),$$($1)),)
  $$(error $$(_msgErr)$1: unknown '$$(filter-out $$(_cxx_stds) $$(_c_stds),$$($1))'$$(_end))
endif
endef


#### Package Handling ####
# syntax: (<target>.)PACKAGES = <pkg name>(:<min version>) ...
override _pkg_n = $(word 1,$(subst :, ,$1))
override _pkg_v = $(word 2,$(subst :, ,$1))
override _check_pkgs =\
$(sort $(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call _pkg_n,$x) $(if $(call _pkg_v,$x),--atleast-version=$(call _pkg_v,$x),--exists) && echo '1'),\
    $(call _pkg_n,$x),\
    $(warning $(_msgWarn)$1: package '$(call _pkg_n,$x)'$(if $(call _pkg_v,$x), [version >= $(call _pkg_v,$x)]) not found$(_end)))))

override _get_pkg_flags = $(if $1,$(strip $(shell $(PKGCONF) $1 --cflags)))
override _get_pkg_libs = $(if $1,$(strip $(shell $(PKGCONF) $1 --libs)))
override _gen_pkg_ver_list = $(foreach p,$(sort $1),$p:$(strip $(shell $(PKGCONF) $p --modversion)))

override define _verify_pkgs  # <1:config pkgs var> <2:valid pkgs>
ifeq ($$($1),)
else ifeq ($$($1),-)
else ifneq ($$(words $$($1)),$$(words $$($2)))
  $$(error $$(_msgErr)Cannot build because of package error(s)$$(_end))
endif
endef


#### OPTIONS handling ####
override _op_list := warn_error pthread lto modern_c++ no_rtti no_except pedantic static_rtlib static_stdlib

override define _check_options  # <1:options var> <2:set prefix>
ifneq ($$(filter-out $$(_op_list),$$($1)),)
  $$(error $$(_msgErr)$1: unknown '$$(filter-out $$(_op_list),$$($1))'$$(_end))
endif
override $2_op_warn :=
override $2_op_flags :=
override $2_op_link :=
ifneq ($$(filter warn_error,$$($1)),)
  override $2_op_warn += -Werror
endif
ifneq ($$(filter pthread,$$($1)),)
  override $2_op_flags += -pthread
endif
ifneq ($$(filter lto,$$($1)),)
  override $2_op_flags += -flto
endif
ifneq ($$(filter pedantic,$$($1)),)
  override $2_op_warn += -Wpedantic
  override $2_op_flags += -pedantic-errors
endif
ifneq ($$(filter static_rtlib,$$($1)),)
  override $2_op_link += -static-libgcc
endif
override $2_op_cxx_warn := $$($2_op_warn)
override $2_op_cxx_flags := $$($2_op_flags)
override $2_op_cxx_link := $$($2_op_link)
ifneq ($$(filter modern_c++,$$($1)),)
  override $2_op_cxx_warn += $$(_$$(COMPILER)_modern)
endif
ifneq ($$(filter no_rtti,$$($1)),)
  override $2_op_cxx_flags += -fno-rtti
endif
ifneq ($$(filter no_except,$$($1)),)
  override $2_op_cxx_flags += -fno-exceptions
endif
ifneq ($$(filter static_stdlib,$$($1)),)
  override $2_op_cxx_link += -static-libstdc++
endif
endef


#### Internal Calculated Values ####
override _comma := ,
override _1-9 := 1 2 3 4 5 6 7 8 9
override _10-99 := $(foreach x,$(_1-9),$(addprefix $x,0 $(_1-9)))
override _1-99 := $(_1-9) $(_10-99)
override _1-999 := $(_1-99) $(foreach x,$(_1-9),$(addprefix $x,$(addprefix 0,0 $(_1-9)) $(_10-99)))

# TEMPLATE<1-99> labels
override _template_labels := $(filter $(sort $(foreach x,$(filter TEMPLATE%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix TEMPLATE,$(_1-99)))

# verify template configs
override define _check_template_entry  # <1:label>
override _$1_labels := $$(subst $1.,,$$(filter $1.FILE%,$$(.VARIABLES)))
ifeq ($$(_$1_labels),)
  $$(error $$(_msgErr)$1: no FILE entries$$(_end))
else ifeq ($$(strip $$($1)),)
  $$(error $$(_msgErr)$1 required)
else ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(_msgErr)$1.CMD required$$(_end))
endif
endef
$(foreach x,$(_template_labels),$(eval $(call _check_template_entry,$x)))

ifneq ($(words $(foreach t,$(_template_labels),$($t_labels))),$(words $(sort $(foreach t,$(_template_labels),$($t_labels)))))
  $(error $(_msgErr)Multiple templates contain the same FILE entry$(_end))
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

# LIB<1-99>, LIB_<id> labels (<id> is the default target)
override _lib_labels1 := $(filter $(sort $(foreach x,$(filter LIB%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix LIB,$(_1-99)))
override _lib_labels2 := $(sort $(foreach x,$(filter LIB_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
$(foreach x,$(_lib_labels2),$(eval $x ?= $(subst LIB_,,$x)))
override _lib_labels := $(strip $(_lib_labels1) $(_lib_labels2))

# BIN<1-99>, BIN_<id> labels (<id> is the default target>
override _bin_labels1 := $(filter $(sort $(foreach x,$(filter BIN%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix BIN,$(_1-99)))
override _bin_labels2 := $(sort $(foreach x,$(filter BIN_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
$(foreach x,$(_bin_labels2),$(eval $x ?= $(subst BIN_,,$x)))
override _bin_labels := $(strip $(_bin_labels1) $(_bin_labels2))

# FILE<1-999>, FILE_<id> labels
override _file_labels1 := $(filter $(sort $(foreach x,$(filter FILE%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix FILE,$(_1-999)))
override _file_labels2 := $(sort $(foreach x,$(filter FILE_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
override _file_labels := $(strip $(_file_labels1) $(_file_labels2))

# TEST<1-999> TEST_<id> labels
override _test_labels1 := $(filter $(sort $(foreach x,$(filter TEST%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix TEST,$(_1-999)))
override _test_labels2 := $(sort $(foreach x,$(filter TEST_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
override _test_labels := $(strip $(_test_labels1) $(_test_labels2))

override _src_labels := $(strip $(_lib_labels) $(_bin_labels) $(_test_labels))
override _all_labels := $(strip $(_src_labels) $(_file_labels))
override _subdir_targets := $(foreach e,$(_env_names),$e tests_$e clean_$e) clobber install install-strip
override _base_targets := all tests info help clean $(_subdir_targets)

# strip extra spaces from all names
$(foreach x,$(_all_labels),$(if $($x),$(eval override $x = $(strip $(value $x)))))

# output name check
override define _check_name  # <1:label>
ifeq ($$(strip $$($1)),)
  $$(error $$(_msgErr)$1 required$$(_end))
else ifneq ($$(words $$($1)),1)
  $$(error $$(_msgErr)$1: spaces not allowed$$(_end))
else ifneq ($$(findstring *,$$($1)),)
  $$(error $$(_msgErr)$1: wildcard '*' not allowed$$(_end))
else ifneq ($$(filter $$($1),$$(_base_targets) $$(foreach e,$$(_env_names),$1$$(_$$e_sfx))),)
  $$(error $$(_msgErr)$1: name conflicts with existing target$$(_end))
endif
endef
$(foreach x,$(_lib_labels) $(_bin_labels),$(eval $(call _check_name,$x)))

# target setting patterns
override _bin_ptrn := %.SRC %.OBJS %.LIBS %.STANDARD %.OPT_LEVEL %.OPT_LEVEL_DEBUG %.DEFINE %.INCLUDE %.FLAGS %.LINK_FLAGS %.PACKAGES %.OPTIONS %.DEPS %.SUBSYSTEM %.CXXFLAGS %.CFLAGS %.ASFLAGS %.LDFLAGS %.SOURCE_DIR
override _lib_ptrn := %.TYPE %.VERSION $(_bin_ptrn)
override _test_ptrn := %.ARGS $(_bin_ptrn)

# binary entry check
override define _check_bin_entry  # <1:bin label>
$$(foreach x,$$(filter-out $$(_bin_ptrn),$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_msgWarn)Unknown binary parameter '$$x'$$(_end)))
endef
$(foreach x,$(_bin_labels),$(eval $(call _check_bin_entry,$x)))

# library entry check
override define _check_lib_entry  # <1:lib label>
$$(foreach x,$$(filter-out $$(_lib_ptrn),$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_msgWarn)Unknown library parameter '$$x'$$(_end)))
ifneq ($$(filter %.a %.so %.dll,$$($1)),)
  $$(error $$(_msgErr)$1: library names should not be specified with an extension$$(_end))
else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
  $$(error $$(_msgErr)$1.TYPE: only 'static' and/or 'shared' allowed$$(_end))
endif
override _$1_major_ver := $$(word 1,$$(subst ., ,$$($1.VERSION)))
override _$1_minor_ver := $$(word 2,$$(subst ., ,$$($1.VERSION)))
endef
$(foreach x,$(_lib_labels),$(eval $(call _check_lib_entry,$x)))

# test entry check
override define _check_test_entry  # <1:test label>
$$(foreach x,$$(filter-out $$(_test_ptrn),$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_msgWarn)Unknown test parameter '$$x'$$(_end)))
endef
$(foreach x,$(_test_labels),$(eval $(call _check_test_entry,$x)))

# file entry check
override define _check_file_entry  # <1:file label>
$$(foreach x,$$(filter-out %.DEPS %.CMD,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(_msgWarn)Unknown file parameter '$$x'$$(_end)))
ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(_msgErr)$1.CMD required$$(_end))
endif
endef
$(foreach x,$(_file_labels),$(eval $(call _check_file_entry,$x)))

# macro to encode path as part of name and remove suffix (for object files)
override _src_bname = $(subst /,__,$(subst ../,,$(basename $1)))

# macro to get values that appear multiple times in a list (for error messages)
override _find_dups = $(strip $(foreach x,$(sort $1),$(if $(filter 1,$(words $(filter $x,$1))),,$x)))

# duplicate name check
override _all_names := $(foreach x,$(_lib_labels) $(_bin_labels) $(_file_labels),$($x))
ifneq ($(words $(_all_names)),$(words $(sort $(_all_names))))
  $(error $(_msgErr)Duplicate binary/library/file names [$(_msgWarn)$(call _find_dups,$(_all_names))$(_msgErr)]$(_end))
endif

ifeq ($(filter $(DEFAULT_ENV),$(_env_names)),)
  $(error $(_msgErr)DEFAULT_ENV: invalid value$(_end))
endif
MAKECMDGOALS ?= $(DEFAULT_ENV)

override define _check_dir # <1:dir var>
ifeq ($$(filter 0 1,$$(words $$($1))),)
  $$(error $$(_msgErr)$1: spaces not allowed$$(_end))
else ifneq ($$(findstring *,$$($1)),)
  $$(error $$(_msgErr)$1: wildcard '*' not allowed$$(_end))
endif
endef

ifeq ($(strip $(BUILD_DIR)),)
  $(error $(_msgErr)BUILD_DIR required$(_end))
endif
$(eval $(call _check_dir,BUILD_DIR))
$(eval $(call _check_dir,OUTPUT_DIR))
$(eval $(call _check_dir,OUTPUT_BIN_DIR))
$(eval $(call _check_dir,OUTPUT_LIB_DIR))

override _static_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $($x.TYPE),$(if $(filter static,$($x.TYPE)),$x),$x)))
override _shared_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))

$(eval $(call _check_dir,SOURCE_DIR))
override _src_path := $(if $(SOURCE_DIR),$(filter-out ./,$(SOURCE_DIR:%/=%)/))
override _symlinks := $(addprefix $(_src_path),$(SYMLINKS))

# output target name generation macros - <1:build env> <2:label>
override _gen_bin_name = $(_$1_bdir)$($2)$(_$1_bsfx)
override _gen_bin_aliases = $(if $(_$1_bdir),$($2)$(_$1_sfx))
override _gen_static_lib_name = $(_$1_ldir)$($2)$(_$1_lsfx).a
override _gen_static_lib_aliases = $($2)$(_$1_sfx) $(if $(_$1_ldir),$($2)$(_$1_sfx).a)
override _gen_implib_name = $(_$1_ldir)$($2)$(_$1_lsfx).dll.a
override _gen_shared_lib_name = $(if $(_windows),$(_$1_bdir)$($2)$(_$1_bsfx)$(if $(_$2_major_ver),-$(_$2_major_ver)).dll,$(_$1_ldir)$($2)$(_$1_lsfx).so$(if $($2.VERSION),.$($2.VERSION)))
override _gen_shared_lib_aliases = $($2)$(_$1_sfx) $(if $(or $(if $(_windows),$(_$1_bdir),$(_$1_ldir)),$($2.VERSION)),$($2)$(_$1_sfx)$(_libext))
override _gen_shared_lib_links = $(if $(_windows),,$(if $($2.VERSION),$(_$1_ldir)$($2)$(_$1_lsfx).so $(if $(_$2_minor_ver),$(_$1_ldir)$($2)$(_$1_lsfx).so.$(_$2_major_ver))))

# environment specific setup
override define _setup_env0  # <1:build env>
override ENV := $1
override SFX := $$(_$1_sfx)
override BUILD_TMP := $$(BUILD_DIR)/$$(ENV)_tmp
override _$1_ldir := $$(if $$(OUTPUT_LIB_DIR),$$(OUTPUT_LIB_DIR:%/=%)/)
override _$1_bdir := $$(if $$(OUTPUT_BIN_DIR),$$(OUTPUT_BIN_DIR:%/=%)/)
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env0,$e)))

override define _setup_env1  # <1:build env>
override ENV := $1
override SFX := $$(_$1_sfx)
override BUILD_TMP := $$(BUILD_DIR)/$$(ENV)_tmp
override _$1_lsfx := $$(if $$(filter 1,$$(words $$(filter $$(_$1_ldir),$$(foreach e,$$(_env_names),$$(_$$e_ldir))))),,$$(_$1_sfx))
override _$1_bsfx := $$(if $$(filter 1,$$(words $$(filter $$(_$1_bdir),$$(foreach e,$$(_env_names),$$(_$$e_bdir))))),,$$(_$1_sfx))

ifneq ($$(_libprefix),lib)
  override LIBPREFIX := $$(_libprefix)
endif
override _$1_shared_libs := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_name,$1,$$x))
override _$1_shared_aliases := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_aliases,$1,$$x))
override _$1_links := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_links,$1,$$x))
ifneq ($$(_libprefix),lib)
  override LIBPREFIX := lib
endif
ifneq ($$(_windows),)
  override _$1_implibs := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_implib_name,$1,$$x))
endif

override _$1_libbin_targets :=\
  $$(_$1_shared_libs) $$(_$1_implibs)\
  $$(foreach x,$$(_static_lib_labels),$$(call _gen_static_lib_name,$1,$$x))\
  $$(foreach x,$$(_bin_labels),$$(call _gen_bin_name,$1,$$x))

override _$1_file_targets := $$(foreach x,$$(_file_labels),$$($$x))
override _$1_test_targets := $$(foreach x,$$(_test_labels),$$x$$(_$1_sfx))
override _$1_build_targets := $$(_$1_file_targets) $$(_$1_libbin_targets) $$(_$1_test_targets)
override _$1_aliases :=\
  $$(foreach x,$$(_all_labels),$$x$$(_$1_sfx))\
  $$(foreach x,$$(_bin_labels),$$(call _gen_bin_aliases,$1,$$x))\
  $$(foreach x,$$(_static_lib_labels),$$(call _gen_static_lib_aliases,$1,$$x))\
  $$(_$1_shared_aliases)
override _$1_goals := $$(sort\
  $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),all) $1,$$(MAKECMDGOALS)),$$(_$1_build_targets))\
  $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),tests) tests_$1,$$(MAKECMDGOALS)),$$(_$1_test_targets))\
  $$(filter $$(_$1_build_targets) $$(sort $$(_$1_aliases)),$$(MAKECMDGOALS)))
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env1,$e)))

# setting value processing functions
override _format_warn = $(foreach x,$1,$(if $(filter -%,$x),$x,-W$x))
override _format_include = $(foreach x,$1,$(if $(filter -%,$x),$x,-I$x))
override _format_define = $(foreach x,$1,$(if $(filter -%,$x),$x,-D'$x'))

override _format_lib_arg =\
$(if $(filter -%,$1),$1,\
$(if $(filter ./,$(dir $1)),,-L$(dir $1)) -l$(if $(filter %.a %.so %.dll,$1),:)$(notdir $1))

override _format_lib_name =\
$(if $1,$(if $(filter ./,$(dir $1)),,-L$(dir $1)) -l:$(notdir $1))

override _format_global_libs = $(foreach x,$1,\
$(if $(filter $x,$(_lib_labels)),$(error $(_msgErr)LIB label '$x' not allowed in global LIBS setting$(_end)),\
$(call _format_lib_arg,$x)))

override _format_target_libs = $(foreach x,$1,\
$(if $(filter $x,$(_lib_labels)),$(or $(call _format_lib_name,$(_$x_shared_name)),$(_$x_name)),\
$(call _format_lib_arg,$x)))

# build environment detection
override _build_env := $(strip $(foreach e,$(_env_names),$(if $(_$e_goals),$e)))
ifeq ($(filter 0 1,$(words $(_build_env))),)
  $(error $(_msgErr)Targets in multiple environments not allowed$(_end))
else ifneq ($(_build_env),)
  # setup build targets/variables for selected environment
  override ENV := $(_build_env)
  override SFX := $(_$(ENV)_sfx)
  override BUILD_TMP := $(BUILD_DIR)/$(ENV)_tmp
  override ALL_FILES := $(foreach x,$(_file_labels),$($x))
  $(foreach t,$(_template_labels),\
    $(eval override $t.ALL_FILES := $(foreach x,$(_$t_labels),$($x))))

  $(eval $(call _check_standard,STANDARD,))
  $(eval $(call _check_options,OPTIONS,))

  override _pkgs := $(call _check_pkgs,PACKAGES)
  override _pkg_flags := $(call _get_pkg_flags,$(_pkgs))

  override _pkgs_test := $(call _check_pkgs,PACKAGES_TEST)
  override _test_pkg_flags := $(if $(_pkgs_test),$(call _get_pkg_flags,$(_pkgs) $(_pkgs_test)),$(_pkg_flags))

  override _define := $(call _format_define,$(DEFINE))
  override _include := $(call _format_include,$(INCLUDE))
  override _warn := $(call _format_warn,$(WARN))
  override _warn_c := $(call _format_warn,$(WARN_C))

  # setup compile flags for each build path
  override _xflags :=  $(_pkg_flags) $(FLAGS) $(FLAGS_$(_$(ENV)_uc))
  override _cxxflags_$(ENV) := $(strip $(or $(CXXFLAGS),$(_cxx_std) $(_$(ENV)_op) $(_warn) $(_op_cxx_warn) $(_define) $(_include) $(_op_cxx_flags) $(_xflags)))
  override _cflags_$(ENV) := $(strip $(or $(CFLAGS),$(_c_std) $(_$(ENV)_op) $(_warn_c) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_xflags)))
  override _asflags_$(ENV) := $(strip $(or $(ASFLAGS),$(_$(ENV)_op) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_xflags)))
  override _src_path_$(ENV) := $(_src_path)

  ifneq ($(_pkg_flags),$(strip $(_test_pkg_flags) $(FLAGS_TEST)))
    override _test_xflags :=  $(_test_pkg_flags) $(FLAGS) $(FLAGS_$(_$(ENV)_uc)) $(FLAGS_TEST)
    override _cxxflags_$(ENV)-tests := $(strip $(or $(CXXFLAGS),$(_cxx_std) $(_$(ENV)_op) $(_warn) $(_op_cxx_warn) $(_define) $(_include) $(_op_cxx_flags) $(_test_xflags)))
    override _cflags_$(ENV)-tests := $(strip $(or $(CFLAGS),$(_c_std) $(_$(ENV)_op) $(_warn_c) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_test_xflags)))
    override _asflags_$(ENV)-tests := $(strip $(or $(ASFLAGS),$(_$(ENV)_op) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_test_xflags)))
    override _src_path_$(ENV)-tests := $(_src_path)
  endif

  override _libs := $(call _format_global_libs,$(LIBS))
  override _libs_test := $(call _format_global_libs,$(LIBS_TEST))

  ## entry binary name & alias target assignment
  $(foreach x,$(_bin_labels),\
    $(eval override _$x_name := $(call _gen_bin_name,$(ENV),$x))\
    $(eval override _$x_aliases := $x$(SFX) $(call _gen_bin_aliases,$(ENV),$x) $(if $(SFX),$x $($x))))

  $(foreach x,$(_static_lib_labels),\
    $(eval override _$x_name := $(call _gen_static_lib_name,$(ENV),$x))\
    $(eval override _$x_aliases := $x$(SFX) $(call _gen_static_lib_aliases,$(ENV),$x) $(if $(SFX),$x $($x) $($x).a)))

  ifneq ($$(_libprefix),lib)
    override LIBPREFIX := $(_libprefix)
  endif
  $(foreach x,$(_shared_lib_labels),\
    $(eval override _$x_shared_name := $(call _gen_shared_lib_name,$(ENV),$x))\
    $(eval override _$x_shared_aliases := $x$(SFX) $(call _gen_shared_lib_aliases,$(ENV),$x) $(if $(SFX),$x $($x) $($x)$(_libext)))\
    $(if $(_windows),,\
      $(eval override _$x_soname := $(if $(_$x_major_ver),$(notdir $($x)).so.$(_$x_major_ver)))\
      $(eval override _$x_shared_links := $(call _gen_shared_lib_links,$(ENV),$x))))
  ifneq ($$(_libprefix),lib)
    override LIBPREFIX := lib
  endif

  $(if $(_windows),$(foreach x,$(_shared_lib_labels),\
    $(eval override _$x_implib := $(call _gen_implib_name,$(ENV),$x))))

  # .DEPS wildcard translation
  $(foreach x,$(_all_labels),\
    $(eval override _$x_deps := $(foreach d,$($x.DEPS),$(if $(findstring *,$d),$(wildcard $d),$d))))

  ## general entry setting parsing (pre)
  override define _build_entry1  # <1:label>
  ifneq ($$(strip $$($1.SOURCE_DIR)),-)
    $$(eval $$(call _check_dir,$1.SOURCE_DIR))
    override _$1_source_dir := $$(if $$($1.SOURCE_DIR),$$(filter-out ./,$$($1.SOURCE_DIR:%/=%)/))
    override _src_path_$$(ENV)-$1 := $$(or $$(_$1_source_dir),$$(_src_path))
  endif

  override _$1_src := $$(foreach x,$$($1.SRC),$$(if $$(findstring *,$$x),$$(patsubst $$(_src_path_$$(ENV)-$1)%,%,$$(wildcard $$(_src_path_$$(ENV)-$1)$$x)),$$x))
  ifeq ($$(strip $$($1.SRC)),)
    $$(error $$(_msgErr)$1.SRC: no source files specified$$(_end))
  else ifeq ($$(strip $$(_$1_src)),)
    $$(error $$(_msgErr)$1.SRC: no source files match pattern$$(_end))
  else ifneq ($$(words $$(_$1_src)),$$(words $$(sort $$(_$1_src))))
    $$(error $$(_msgErr)$1.SRC: duplicate source files [$$(_msgWarn)$$(call _find_dups,$$(_$1_src))$$(_msgErr)]$$(_end))
  else ifneq ($$(filter-out $(_cxx_ptrn) $(_c_ptrn) $(_asm_ptrn),$$(_$1_src)),)
    $$(error $$(_msgErr)$1.SRC: invalid source files [$$(_msgWarn)$$(filter-out $(_cxx_ptrn) $(_c_ptrn) $(_asm_ptrn),$$(_$1_src))$$(_msgErr)]$$(_end))
  endif

  override _$1_lang := $$(if $$(filter $(_asm_ptrn),$$(_$1_src)),asm) $$(if $$(filter $(_c_ptrn),$$(_$1_src)),c) $$(if $$(filter $(_cxx_ptrn),$$(_$1_src)),cxx)
  override _$1_src_objs := $$(addsuffix .o,$$(call _src_bname,$$(_$1_src)))

  ifneq ($$(strip $$($1.OBJS)),-)
    override _$1_other_objs := $$(foreach x,$$($1.OBJS),\
      $$(if $$(findstring *,$$x),$$(wildcard $$x),\
        $$(if $$(filter $$x,$$(_lib_labels)),$$(or $$(_$$x_name),$$(error $$(_msgErr)$1.OBJS: static type required for library '$$x'$$(_end))),$$x)))
  endif

  ifneq ($$(strip $$($1.SUBSYSTEM)),-)
    override _$1_subsystem := $$(if $$(_windows),$$(or $$($1.SUBSYSTEM),$$(SUBSYSTEM)))
  endif

  ifneq ($$(strip $$($1.LINK_FLAGS)),-)
    override _$1_link_flags := $$(or $$($1.LINK_FLAGS),$$(LINK_FLAGS))
  endif

  ifeq ($$(strip $$($1.STANDARD)),)
    override _$1_cxx_std := $$(_cxx_std)
    override _$1_c_std := $$(_c_std)
  else ifneq ($$(strip $$($1.STANDARD)),-)
    $$(eval $$(call _check_standard,$1.STANDARD,_$1))
  endif

  ifeq ($$(strip $$($1.OPTIONS)),)
    override _$1_op_warn := $$(_op_warn)
    override _$1_op_flags := $$(_op_flags)
    override _$1_op_link := $$(_op_link)
    override _$1_op_cxx_warn := $$(_op_cxx_warn)
    override _$1_op_cxx_flags := $$(_op_cxx_flags)
    override _$1_op_cxx_link := $$(_op_cxx_link)
  else ifneq ($$(strip $$($1.OPTIONS)),-)
    $$(eval $$(call _check_options,$1.OPTIONS,_$1))
  endif

  ifneq ($$(strip $$($1.PACKAGES)),-)
    override _$1_pkgs := $$(or $$(call _check_pkgs,$1.PACKAGES),$$(_pkgs))
  endif

  ifneq ($$(strip $$($1.LIBS)),-)
    override _$1_libs := $$(or $$(call _format_target_libs,$$($1.LIBS)),$$(_libs))
  endif

  ifneq ($$(strip $$($1.DEFINE)),-)
    override _$1_define := $$(or $$(call _format_define,$$($1.DEFINE)),$$(_define))
  endif

  ifneq ($$(strip $$($1.INCLUDE)),-)
    override _$1_include := $$(or $$(call _format_include,$$($1.INCLUDE)),$$(_include))
  endif

  ifneq ($$(strip $$($1.FLAGS)),-)
    override _$1_flags := $$(or $$($1.FLAGS),$$(FLAGS))
  endif
  endef
  $(foreach x,$(_src_labels),$(eval $(call _build_entry1,$x)))

  ## general entry setting parsing (post)
  override define _build_entry2  # <1:label> <2:test flag>
  ifneq ($$(strip $$($1.LIBS)),-)
    override _$1_req_pkgs1 := $$(foreach x,$$($1.LIBS),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_pkgs)))
    override _$1_req_libs1 := $$(foreach x,$$($1.LIBS),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_libs)))
    override _$1_link_deps := $$(foreach x,$$($1.LIBS),$$(if $$(filter $$x,$$(_lib_labels)),$$(or $$(_$$x_shared_name),$$(_$$x_name))))
  endif

  ifneq ($$(strip $$($1.OBJS)),-)
    override _$1_req_pkgs2 := $$(foreach x,$$($1.OBJS),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_pkgs)))
    override _$1_req_libs2 := $$(foreach x,$$($1.OBJS),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_libs)))
  endif

  override _$1_xpkgs := $$(sort $$(_$1_pkgs) $$(if $2,$$(_pkgs_test)) $$(_$1_req_pkgs1) $$(_$1_req_pkgs2))
  ifneq ($$(_$1_xpkgs),)
    override _$1_pkg_libs := $$(call _get_pkg_libs,$$(_$1_xpkgs))
    override _$1_pkg_flags := $$(call _get_pkg_flags,$$(_$1_xpkgs))
    ifeq ($$(_$1_xpkgs),$$(_pkgs))
      override _$1_pkg_trigger := .packages_ver
    else ifeq ($$(_$1_xpkgs),$$(sort $$(_pkgs) $$(_pkgs_test)))
      override _$1_pkg_trigger := .packages_ver-tests
    else
      override _$1_pkg_trigger := .packages_ver-$1
      override _$1_make_pkg_trigger := 1
    endif
  endif

  override _$1_xlibs := $$(_$1_libs) $$(if $2,$$(_libs_test)) $$(_$1_req_libs1) $$(_$1_req_libs2) $$(_$1_pkg_libs)

  # NOTE: LIBS before PACKAGES libs in case included static lib requires package
  override _$1_xflags := $$(_$1_pkg_flags) $$(_$1_flags) $$(FLAGS_$$(_$$(ENV)_uc)) $$(if $2,$$(FLAGS_TEST))
  override _cxxflags_$$(ENV)-$1 := $$(strip $$(or $$($1.CXXFLAGS),$$(CXXFLAGS),$$(_$1_cxx_std) $$(call _$$(ENV)_op,$1) $$(_warn) $$(_$1_op_cxx_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_cxx_flags) $$(_$1_xflags)))
  override _cflags_$$(ENV)-$1 := $$(strip $$(or $$($1.CFLAGS),$$(CFLAGS),$$(_$1_c_std) $$(call _$$(ENV)_op,$1) $$(_warn_c) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_xflags)))
  override _asflags_$$(ENV)-$1 := $$(strip $$(or $$($1.ASFLAGS),$$(ASFLAGS),$$(call _$$(ENV)_op,$1) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_xflags)))

  override _$1_build := $$(ENV)-$1
  ifeq ($$(_src_path_$$(ENV)-$1),$$(_src_path))
    ifeq ($$(_$1_deps),)
      # if compile flags match then use a shared build path
      ifeq ($$(_cxxflags_$$(ENV)-$1),$$(_cxxflags_$$(ENV)-test))
        ifeq ($$(_cflags_$$(ENV)-$1),$$(_cflags_$$(ENV)-test))
          ifeq ($$(_asflags_$$(ENV)-$1),$$(_asflags_$$(ENV)-test))
            override _$1_build := $$(ENV)-test
          endif
        endif
      endif
      ifeq ($$(_cxxflags_$$(ENV)-$1),$$(_cxxflags_$$(ENV)))
        ifeq ($$(_cflags_$$(ENV)-$1),$$(_cflags_$$(ENV)))
          ifeq ($$(_asflags_$$(ENV)-$1),$$(_asflags_$$(ENV)))
            override _$1_build := $$(ENV)
          endif
        endif
      endif
    endif
  endif
  endef
  $(foreach x,$(_lib_labels) $(_bin_labels),$(eval $(call _build_entry2,$x,)))
  $(foreach x,$(_test_labels),$(eval $(call _build_entry2,$x,test)))

  # NOTES:
  # - <label>.DEPS can cause an isolated build even though there are no compile
  #   flag changes (target 'source.o : | dep' rules would affect other builds
  #   without isolation)

  $(foreach x,$(_test_labels),\
    $(eval override _$x_aliases := $x$(SFX))\
    $(eval override _$x_run := $(BUILD_DIR)/$(_$x_build)/__$x))

  # check for source conflicts like src/file.cc & src/file.cpp
  override _all_source := $(sort $(foreach x,$(_src_labels),$(_$x_src)))
  override _all_source_base := $(call _src_bname,$(_all_source))
  ifneq ($(words $(_all_source_base)),$(words $(sort $(_all_source_base))))
    $(error $(_msgErr)Conflicting source files - each basename must be unique$(_end))
  endif

  # halt build for package errors on non-test entries
  $(eval $(call _verify_pkgs,PACKAGES,_pkgs))
  $(foreach x,$(_bin_labels) $(_lib_labels),$(eval $(call _verify_pkgs,$x.PACKAGES,_$x_pkgs)))

  # determine LDFLAGS value for each entry
  $(foreach x,$(_src_labels),\
    $(eval override _$x_ldflags := $(or $(strip $($x.LDFLAGS)),$(strip $(LDFLAGS)),\
      -Wl$(_comma)--as-needed -L$(or $(_$(ENV)_ldir),.)\
      $(if $(_$x_soname),-Wl$(_comma)-h$(_comma)'$(_$x_soname)')\
      $(if $(_$x_implib),-Wl$(_comma)--out-implib$(_comma)'$(_$x_implib)')\
      $(if $(_$x_subsystem),-Wl$(_comma)$--subsystem$(_comma)$(_$x_subsystem))\
      $(if $(filter cxx,$(_$x_lang)),$(_$x_op_cxx_link),$(_$x_op_link))\
      $(_$x_link_flags))))

  # file entry command evaluation
  $(foreach x,$(_file_labels),\
    $(eval override OUT = $($x))\
    $(eval override DEPS = $(or $($x.DEPS),$$(error $$(_msgErr)Cannot use DEPS if $x.DEPS is not set$$(_end))))\
    $(foreach n,$(wordlist 1,$(words $($x.DEPS)),$(_1-99)),\
      $(eval override DEP$n = $(word $n,$($x.DEPS))))\
    $(eval override _$x_command := $(value $x.CMD)))

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
	@echo '$(_msgInfo)==== Build Target Info ====$(_end)'
	$(if $(filter 0,$(words $(_all_labels))),@echo 'No build targets defined')
	$(if $(_bin_labels),@echo 'Binaries($(words $(_bin_labels))): $(_bold)$(foreach x,$(_bin_labels),$(value $x))$(_end)')
	$(if $(_lib_labels),@echo 'Libraries($(words $(_lib_labels))): $(_bold)$(foreach x,$(_lib_labels),$(value $x))$(_end)')
	$(if $(_file_labels),@echo 'Files($(words $(_file_labels))): $(_bold)$(foreach x,$(_file_labels),$(value $x))$(_end)')
	$(if $(_test_labels),@echo 'Tests($(words $(_test_labels)))')
	@echo

help:
	@echo '$(_msgInfo)==== Command Help ====$(_end)'
	@echo '$(_bold)make$(_end) or $(_bold)make all$(_end)   builds default environment ($(_bold)$(_fg3)$(DEFAULT_ENV)$(_end))'
	@echo '$(_bold)make $(_fg3)<env>$(_end)         builds specified environment'
	@echo '                   available: $(_bold)$(_fg3)$(_env_names)$(_end)'
	@echo '$(_bold)make clean$(_end)         removes all build files except for made binaries/libraries'
	@echo '$(_bold)make clobber$(_end)       as clean, but also removes made binaries/libraries'
	@echo '$(_bold)make tests$(_end)         builds/runs all tests'
	@echo '$(_bold)make info$(_end)          prints build target summary'
	@echo '$(_bold)make help$(_end)          prints this information'
	@echo

override define _setup_env_targets  # <1:build env>
$1: $$(_$1_build_targets)
tests_$1: $$(_$1_test_targets)

clean_$1:
	@([ -d "$$(BUILD_DIR)/$1_tmp" ] && $$(RM) "$$(BUILD_DIR)/$1_tmp/"* && rmdir -- "$$(BUILD_DIR)/$1_tmp") || true
	@$$(RM) "$$(BUILD_DIR)/.$1-cmd-"*
	@for D in "$$(BUILD_DIR)/$1"*; do\
	  ([ -d "$$$$D" ] && echo "$$(_msgWarn)Cleaning '$$$$D'$$(_end)" && $$(RM) "$$$$D/"*.mk "$$$$D/"*.o "$$$$D/__TEST"* "$$$$D/.compile_cmd"* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env_targets,$e)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver" "$(BUILD_DIR)/.packages_ver"* $(foreach x,$(_symlinks),"$x")
	@([ -d "$(BUILD_DIR)" ] && rmdir -p -- "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(_msgWarn)Removing '$$X'$(_end)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach e,$(_env_names),$(_$e_libbin_targets) $(_$e_file_targets) $(_$e_links)) core gmon.out $(CLOBBER_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(_msgWarn)Removing '$$X'$(_end)" && $(RM) "$$X") || true; done
	@for X in $(foreach y,$(sort $(filter-out ./,$(foreach e,$(_env_names),$(foreach x,$(_$e_libbin_targets) $(_$e_file_targets),$(dir $x))))),"$y"); do\
	  ([ -d "$$X" ] && rmdir -p --ignore-fail-on-non-empty -- "$$X") || true; done

install: ; $(error $(_msgErr)Target 'install' not implemented$(_end))
install-strip: ; $(error $(_msgErr)Target 'install-strip' not implemented$(_end))

override define _make_subdir_target  # <1:target>
$1: _subdir_$1
.PHONY: _subdir_$1
_subdir_$1:
	@for D in $$(SUBDIRS); do\
	  ([ -d "$$$$D" ] && ($$(MAKE) -C "$$$$D" $1 || true)) || echo "$$(_msgWarn)SUBDIRS: unknown directory '$$$$D' - skipping$$(_end)"; done
endef
ifneq ($(strip $(SUBDIRS)),)
  $(foreach x,$(_subdir_targets),$(eval $(call _make_subdir_target,$x)))
endif


#### Unknown Target Handling ####
.SUFFIXES:
.DEFAULT: ; $(error $(_msgErr)$(if $(filter $<,$(_all_source)),Missing source file '$<','$<' unknown)$(_end))


#### Build Macros ####
override define _rebuild_check  # <1:trigger file> <2:trigger text>
ifneq ($$(strip $$(file <$1)),$$(strip $2))
  ifneq ($$(file <$1),)
    $$(info $$(_msgWarn)$1 changed$$(_end))
  endif
  $$(if $$(strip $$(filter-out ./,$$(dir $1))),$$(shell mkdir -p "$$(dir $1)"))
  $$(file >$1,$2)
endif
endef

override define _rebuild_check_var # <1:trigger file> <2:trigger text var>
ifneq ($$(strip $$(file <$1)),$$(strip $$($2)))
  ifneq ($$(file <$1),)
    $$(info $$(_msgWarn)$1 changed$$(_end))
  endif
  $$(if $$(strip $$(filter-out ./,$$(dir $1))),$$(shell mkdir -p "$$(dir $1)"))
  $$(file >$1,$$(value $2))
endif
endef

# make path of input file - <1:file w/ path>
override _make_path = $(if $(strip $(filter-out ./,$(dir $1))),@mkdir -p "$(dir $1)")

# link binary/test/shared lib - <1:label>
override _do_link = $(if $(filter cxx,$(_$1_lang)),$(CXX) $(_cxxflags_$(_$1_build)),$(CC) $(_cflags_$(_$1_build))) $(_$1_ldflags)

# static library build
override define _make_static_lib  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(AR) rc '$$(_$1_name)' $$(strip $$(_$1_all_objs) $$(_$1_other_objs))
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-static
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_all_objs): | $$(_$1_deps)
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_trigger)
	$$(call _make_path,$$@)
	@-$$(RM) "$$@"
	$$(_$1_link_cmd)
	$$(RANLIB) '$$@'
	@echo "$$(_msgInfo)Static library '$$@' built$$(_end)"
endef

# shared library build
override define _make_shared_lib  # <1:label>
override _$1_shared_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)$$(if $$(_pic_flag),-pic)/,$$(_$1_src_objs))
override _$1_shared_link_cmd := $$(strip $$(call _do_link,$1) $$(_pic_flag) -shared $$(_$1_shared_objs) $$(_$1_other_objs) $$(_$1_xlibs)) -o '$$(_$1_shared_name)'
override _$1_shared_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-shared
$$(eval $$(call _rebuild_check_var,$$$$(_$1_shared_trigger),_$1_shared_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_shared_objs): | $$(_$1_deps)
endif

.PHONY: $$(_$1_shared_aliases)
$$(_$1_shared_aliases) $$(_$1_implib): $$(_$1_shared_name)
$$(_$1_shared_name): $$(_$1_shared_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_shared_trigger)
	$$(call _make_path,$$@)
	$$(call _make_path,$$(_$1_implib))
	$$(_$1_shared_link_cmd)
	$$(foreach x,$$(_$1_shared_links),ln -sf "$$(notdir $$@)" "$$x";)
	@echo "$$(_msgInfo)Shared library '$$@' built$$(_end)"
endef

# binary build
override define _make_bin  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(strip $$(call _do_link,$1) $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_xlibs)) -o '$$(_$1_name)'
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_all_objs): | $$(_$1_deps)
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_trigger) | $$(_lib_goals)
	$$(call _make_path,$$@)
	$$(_$1_link_cmd)
	@echo "$$(_msgInfo)Binary '$$@' built$$(_end)"
endef

# generic file build
override define _make_file  # <1:label>
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_command))

.PHONY: $1$$(SFX)
$1$$(SFX): $$($1)
$$($1): $$(_$1_trigger) $$(_$1_deps)
	$$(call _make_path,$$@)
	$$(value _$1_command)
	@echo "$$(_msgInfo)File '$$@' created$$(_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define _make_test  # <1:label>
override _$1_all_objs := $$(addprefix $$(BUILD_DIR)/$$(_$1_build)/,$$(_$1_src_objs))
override _$1_link_cmd := $$(strip $$(call _do_link,$1) $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_xlibs)) -o '$$(_$1_run)'
override _$1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_all_objs): | $$(_$1_deps)
endif

$$(_$1_run): $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_trigger) | $$(_lib_goals) $$(_bin_goals)
	$$(_$1_link_cmd)
ifeq ($$(filter tests tests_$$(ENV) $1$$(SFX),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$(_$1_run) $$($1.ARGS);\
	EXIT_STATUS=$$$$?;\
	if [[ $$$$EXIT_STATUS -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; exit $$$$EXIT_STATUS; fi
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_run) | $$(_test_goals)
ifneq ($$(filter tests tests_$$(ENV) $1$$(SFX),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$(_$1_run) $$($1.ARGS);\
	if [[ $$$$? -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; $$(RM) "$$(_$1_run)"; fi
endif
endef


override define _make_dep  # <1:path> <2:build> <3:src> <4:cmd trigger>
$1/$(call _src_bname,$3).o: $$(_src_path_$2)$3 $1/$4 $$(BUILD_DIR)/.compiler_ver $$(_pkg_trigger_$2) | $$(_symlinks)
-include $1/$(call _src_bname,$3).mk
endef


override define _make_obj  # <1:path> <2:build> <3:flags> <4:src list>
ifneq ($4,)
$1/%.mk: ; @$$(RM) "$$(@:.mk=.o)"

ifneq ($$(filter $$(_c_ptrn),$4),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd_c,$$(CC) $$(_cflags_$2) $3))
$(addprefix $1/,$(addsuffix .o,$(call _src_bname,$(filter $(_c_ptrn),$4)))):
	$$(strip $$(CC) $$(_cflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(_c_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$x,.compile_cmd_c)))
endif

ifneq ($$(filter $$(_asm_ptrn),$4),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd_s,$$(AS) $$(_asflags_$2) $3))
$(addprefix $1/,$(addsuffix .o,$(call _src_bname,$(filter $(_asm_ptrn),$4)))):
	$$(strip $$(AS) $$(_asflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(_asm_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$x,.compile_cmd_s)))
endif

ifneq ($$(filter $$(_cxx_ptrn),$4),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd,$$(CXX) $$(_cxxflags_$2) $3))
$1/%.o: ; $$(strip $$(CXX) $$(_cxxflags_$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(_cxx_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$x,.compile_cmd)))
endif
endif
endef


#### Create Build Targets ####
.DELETE_ON_ERROR:
ifneq ($(_build_env),)
  # symlink creation rule
  $(foreach x,$(_symlinks),$(eval $x: ; @ln -s . "$x"))

  # .packages_ver rules (rebuild triggers for package version changes)
  $(if $(_pkgs),\
    $(eval override _pkg_trigger_$(ENV) := $(BUILD_DIR)/.packages_ver)\
    $(eval $(call _rebuild_check,$(BUILD_DIR)/.packages_ver,$(call _gen_pkg_ver_list,$(_pkgs)))))

  $(if $(_pkgs_test),\
    $(eval override _pkg_trigger_$(ENV)-tests := $(BUILD_DIR)/.packages_ver-tests)\
    $(eval $(call _rebuild_check,$(BUILD_DIR)/.packages_ver-tests,$(call _gen_pkg_ver_list,$(_pkgs) $(_pkgs_test)))))

  $(foreach x,$(_src_labels),$(if $(_$x_make_pkg_trigger),\
    $(eval override _pkg_trigger_$(ENV)-$x := $(BUILD_DIR)/$(_$x_pkg_trigger))\
    $(eval $(call _rebuild_check,$(BUILD_DIR)/$(_$x_pkg_trigger),$(call _gen_pkg_ver_list,$(_$x_xpkgs))))))

  ifneq ($(_src_labels),)
  # .compiler_ver rule (rebuild trigger for compiler version change)
  $(eval $(call _rebuild_check,$(BUILD_DIR)/.compiler_ver,$(shell $(CC) --version | head -1)))

  # make .o/.mk files for each build path
  # NOTES:
  # - don't put 'call' args on separate lines, this can add spaces to values
  # - object builds are before linking so '<objs>: DEPS' rules don't affect
  #   compile commands by changing '$<' var
  $(foreach b,$(sort $(foreach x,$(if $(_pic_flag),$(_static_lib_labels),$(_lib_labels)) $(_bin_labels) $(_test_labels),$(_$x_build))),\
    $(eval $(call _make_obj,$$(BUILD_DIR)/$b,$b,,$(sort $(foreach x,$(if $(_pic_flag),$(_static_lib_labels),$(_lib_labels)) $(_bin_labels) $(_test_labels),$(if $(filter $(_$x_build),$b),$(_$x_src)))))))

  # shared libraries have a unique build path if -fPIC is required
  $(if $(_pic_flag),\
    $(foreach b,$(sort $(foreach x,$(_shared_lib_labels),$(_$x_build))),\
      $(eval $(call _make_obj,$$(BUILD_DIR)/$b-pic,$b,$(_pic_flag),$(sort $(foreach x,$(_shared_lib_labels),$(if $(filter $(_$x_build),$b),$(_$x_src))))))))
  endif

  # make binary/library/test build targets
  $(foreach x,$(_static_lib_labels),$(eval $(call _make_static_lib,$x)))
  $(foreach x,$(_shared_lib_labels),$(eval $(call _make_shared_lib,$x)))
  $(foreach x,$(_bin_labels),$(eval $(call _make_bin,$x)))
  $(foreach x,$(_file_labels),$(eval $(call _make_file,$x)))
  $(foreach x,$(_test_labels),$(eval $(call _make_test,$x)))
endif

#### END ####
