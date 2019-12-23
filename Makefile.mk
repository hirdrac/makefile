#
# Makefile.mk - version 1.7 (2019/12/14)
# Copyright (C) 2019 Richard Bradley
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
#  gprof           builds gprof versions of all binaries/libraries/tests
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
#  STANDARD        language standard(s) of source code
#  OPTIMIZE        options for release & gprof builds
#  DEBUG           options for debug builds
#  PROFILE         options for gprof builds
#  WARN            compile warning options
#  WARN_C          C specific warnings
#  PACKAGES        list of packages for pkg-config
#  INCLUDE         includes needed not covered by pkg-config
#  LIBS            libraries needed not covered by pkg-config
#  DEFINE          defines for compilation
#  FLAGS           additional compiler flags not otherwise specified
#  TEST_PACKAGES   additional packages for all tests
#  TEST_LIBS       additional libs to link with for all tests
#  TEST_FLAGS      additional compiler flags for all tests
#  *_EXTRA         available for most settings to provide additional values
#
#  BUILD_DIR       directory for generated object/prerequisite files
#  DEFAULT_ENV     default environment to build (release,debug,gprof)
#  OUTPUT_DIR      default output directory (defaults to current directory)
#  LIB_OUTPUT_DIR  directory for generated libraries (defaults to OUTPUT_DIR)
#  BIN_OUTPUT_DIR  directory for generated binaries (defaults to OUTPUT_DIR)
#  CLEAN_EXTRA     extra files to delete for 'clean' target
#  CLOBBER_EXTRA   extra files to delete for 'clobber' target
#  SUBDIRS         sub-directories to also make with base targets
#  SYMLINKS        symlinks to the current dir to create for building
#  SOURCE_DIR      source files base directory
#
#  Settings STANDARD/PACKAGES/INCLUDE/LIBS/DEFINE/FLAGS can be set for specific
#    targets to override global values (ex.: BIN1.FLAGS = -pthread).
#
# Output Variables:
#  ENV             current build environment
#  SFX             current build environment binary suffix
#  TMP             environment specific temporary directory
#  ALL_FILES       all FILEx targets (useful for .DEPS rule on specific targets)
#

#### Make Version Check ####
min_ver := 4.2
MAKE_VERSION ?= 1.0
ifeq ($(filter $(min_ver),$(firstword $(sort $(MAKE_VERSION) $(min_ver)))),)
  $(error GNU make version $(min_ver) or later required)
endif


#### Shell Commands ####
SHELL = /bin/sh
PKGCONF ?= pkg-config
RM ?= rm -f --


#### Basic Settings ####
COMPILER ?= $(firstword $(compiler_names))
STANDARD ?=
OPTIMIZE ?= -O3
DEBUG ?= -g -O1 -DDEBUG
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
FLAGS ?=
TEST_PACKAGES ?=
TEST_LIBS ?=
TEST_FLAGS?=

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
$(foreach x,OPTIMIZE DEBUG PROFILE WARN WARN_C PACKAGES INCLUDE LIBS DEFINE FLAGS TEST_PACKAGES TEST_LIBS TEST_FLAGS,\
  $(if $($x_EXTRA),$(eval override $x += $$($x_EXTRA))))


#### Environment Details ####
env_names ?= release debug gprof
release_sfx ?=
release_flags ?= $(OPTIMIZE)
debug_sfx ?= -g
debug_flags ?= $(DEBUG)
gprof_sfx ?= -pg
gprof_flags ?= $(OPTIMIZE) $(PROFILE)


#### Compiler Details ####
compiler_names ?= gcc clang
gcc_cxx ?= g++
gcc_cc ?= gcc
gcc_as ?= gcc -x assembler-with-cpp
gcc_ar ?= gcc-ar
gcc_ranlib ?= gcc-ranlib
gcc_warn ?= shadow=local
clang_cxx ?= clang++
clang_cc ?= clang
clang_as ?= clang -x assembler-with-cpp
clang_ar ?= llvm-ar
clang_ranlib ?= llvm-ranlib
clang_warn ?= shadow


#### Terminal Output ####
# t_fg1 - binary/library built
# t_fg2 - warning or removal notice
# t_fg3 - test passed
# t_fg4 - test failed, fatal error
ifneq ($(shell which setterm 2>/dev/null),)
  override t_bold := $(shell setterm --bold on)
  override t_fg0  := $(shell setterm --foreground default)
  override t_fg1  := $(shell setterm --foreground cyan)
  override t_fg2  := $(shell setterm --foreground magenta)
  override t_fg3  := $(shell setterm --foreground green)
  override t_fg4  := $(shell setterm --foreground red)
  override t_end  := $(shell setterm --default)
else
  override t_bold := $(shell echo -e '\e[1m')
  override t_fg0  := $(shell echo -e '\e[39m')
  override t_fg1  := $(shell echo -e '\e[36m')
  override t_fg2  := $(shell echo -e '\e[35m')
  override t_fg3  := $(shell echo -e '\e[32m')
  override t_fg4  := $(shell echo -e '\e[31m')
  override t_end  := $(shell echo -e '\e[m')
endif
override t_info := $(t_bold)$(t_fg1)
override t_warn := $(t_bold)$(t_fg2)
override t_err  := $(t_bold)$(t_fg4)


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(compiler_names)),)
  $(error $(t_err)COMPILER: unknown compiler$(t_end))
endif

CXX = $(or $($(COMPILER)_cxx),c++)
CC = $(or $($(COMPILER)_cc),cc)
AS = $(or $($(COMPILER)_as),as)
AR = $(or $($(COMPILER)_ar),ar)
RANLIB = $(or $($(COMPILER)_ranlib),ranlib)

override c_ptrn := %.c
override asm_ptrn := %.s %.S %.sx
override cxx_ptrn := %.cc %.cp %.cxx %.cpp %.CPP %.c++ %.C

override cxx_standards := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a
override cxx_std := $(addprefix -std=,$(filter $(STANDARD),$(cxx_standards)))
ifeq ($(filter 0 1,$(words $(cxx_std))),)
  $(error $(t_err)STANDARD: multiple C++ standards not allowed$(t_end))
endif

override cc_standards := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18
override cc_std := $(addprefix -std=,$(filter $(STANDARD),$(cc_standards)))
ifeq ($(filter 0 1,$(words $(cc_std))),)
  $(error $(t_err)STANDARD: multiple C standards not allowed$(t_end))
endif

ifneq ($(filter-out $(cxx_standards) $(cc_standards),$(STANDARD)),)
  $(error $(t_err)STANDARD: unknown standard specified$(t_end))
endif


#### Package Handling ####
# syntax: PACKAGES = <pkg name>(:<min version>) ...
override pkg_n = $(word 1,$(subst :, ,$1))
override pkg_v = $(word 2,$(subst :, ,$1))
override check_pkgs =\
$(strip $(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call pkg_n,$x) $(if $(call pkg_v,$x),--atleast-version=$(call pkg_v,$x),--exists) && echo '1'),\
    $(call pkg_n,$x),\
    $(warning $(t_warn)$1: package '$(call pkg_n,$x)'$(if $(call pkg_v,$x), [version >= $(call pkg_v,$x)]) not found$(t_end)))))

override pkgs := $(call check_pkgs,PACKAGES)
ifneq ($(pkgs),)
  override pkg_flags := $(shell $(PKGCONF) $(pkgs) --cflags)
  override pkg_libs := $(shell $(PKGCONF) $(pkgs) --libs)
endif

override test_pkgs := $(call check_pkgs,TEST_PACKAGES)
ifneq ($(test_pkgs),)
  override test_pkg_flags := $(shell $(PKGCONF) $(test_pkgs) --cflags)
  override test_pkg_libs := $(shell $(PKGCONF) $(test_pkgs) --libs)
endif


#### Internal Calculated Values ####
override digits := 1 2 3 4 5 6 7 8 9
override no1-99 := $(digits) $(foreach x,$(digits),$(addprefix $x,0 $(digits)))

override template_labels := $(strip $(foreach x,$(no1-99),$(if $(TEMPLATE$x),TEMPLATE$x)))

# verify template configs
override define check_template_entry  # <1:label>
override $1_labels := $$(strip $$(foreach n,$$(no1-99),$$(if $$($1.FILE$$n),FILE$$n)))
ifeq ($$($1_labels),)
  $$(error $$(t_err)$1: no FILE entries$$(t_end))
else ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(t_err)$1.CMD: command required$$(t_end))
endif
endef
$(foreach x,$(template_labels),$(eval $(call check_template_entry,$x)))

ifneq ($(words $(foreach t,$(template_labels),$($t_labels))),$(words $(sort $(foreach t,$(template_labels),$($t_labels)))))
  $(error $(t_err)multiple templates contain the same FILE entry$(t_end))
endif

# create file entries from templates
$(foreach t,$(template_labels),\
  $(foreach x,$($t_labels),\
    $(eval override VALS := $$($t.$x))\
    $(foreach n,$(wordlist 1,$(words $(VALS)),$(no1-99)),\
      $(eval override VAL$n := $$(word $n,$$(VALS))))\
    $(eval override $x = $($t))\
    $(eval override $x.DEPS = $($t.DEPS))\
    $(eval override $x.CMD = $($t.CMD))))

override lib_labels := $(strip $(foreach x,$(no1-99),$(if $(LIB$x),LIB$x)))
override bin_labels := $(strip $(foreach x,$(no1-99),$(if $(BIN$x),BIN$x)))
override test_labels := $(strip $(foreach x,$(no1-99),$(if $(TEST$x),TEST$x)))
override file_labels := $(strip $(foreach x,$(no1-99),$(if $(FILE$x),FILE$x)))
override ALL_FILES = $(foreach x,$(file_labels),$($x))
override src_labels := $(lib_labels) $(bin_labels) $(test_labels)
override all_labels := $(src_labels) $(file_labels)
override subdir_targets := $(foreach x,$(env_names),$x tests_$x clean_$x) clobber install install-strip
override base_targets := all tests info help clean $(subdir_targets)

override define check_entry  # <1:label>
override $1 := $$(strip $$($1))
ifneq ($$(words $$($1)),1)
  $$(error $$(t_err)$1: spaces not allowed in name$$(t_end))
else ifneq ($$(filter $$($1),$$(base_targets) $$(foreach x,$$(env_names),$1$$($$x_sfx))),)
  $$(error $$(t_err)$1: name conflicts with existing target$$(t_end))
else ifeq ($$(strip $$($1.SRC)),)
  $$(error $$(t_err)$1.SRC: no source files specified$$(t_end))
else ifneq ($$(words $$($1.SRC)),$$(words $$(sort $$($1.SRC))))
  $$(error $$(t_err)$1.SRC: duplicate source files$$(t_end))
endif
override $1_cxx_std := $$(addprefix -std=,$$(filter $$($1.STANDARD),$$(cxx_standards)))
ifeq ($$(filter 0 1,$$(words $$($1_cxx_std))),)
  $$(error $$(t_err)$1.STANDARD: multiple C++ standards not allowed$$(t_end))
endif
override $1_cc_std := $$(addprefix -std=,$$(filter $$($1.STANDARD),$$(cc_standards)))
ifeq ($$(filter 0 1,$$(words $$($1_cc_std))),)
  $$(error $$(t_err)$1.STANDARD: multiple C standards not allowed$$(t_end))
endif
ifneq ($$(filter-out $$(cxx_standards) $$(cc_standards),$$($1.STANDARD)),)
  $$(error $$(t_err)$1.STANDARD: unknown standard specified$$(t_end))
endif
override $1_pkgs := $$(call check_pkgs,$1.PACKAGES)
ifneq ($$($1_pkgs),)
  override $1_pkg_flags := $$(shell $$(PKGCONF) $$($1_pkgs) --cflags)
  override $1_pkg_libs := $$(shell $$(PKGCONF) $$($1_pkgs) --libs)
endif
override $1_lang := $$(if $$(filter $(asm_ptrn),$$($1.SRC)),asm) $$(if $$(filter $(c_ptrn),$$($1.SRC)),c) $$(if $$(filter $(cxx_ptrn),$$($1.SRC)),cxx)
ifneq ($$(filter-out $(cxx_ptrn) $(c_ptrn) $(asm_ptrn),$$($1.SRC)),)
  $$(error $$(t_err)$1.SRC: invalid '$$(filter-out $(cxx_ptrn) $(c_ptrn) $(asm_ptrn),$$($1.SRC))'$$(t_end))
endif
endef
$(foreach x,$(src_labels),$(eval $(call check_entry,$x)))

override define check_bin_entry  # <1:bin label>
$$(foreach x,$$(filter-out %.SRC %.OBJS %.LIBS %.STANDARD %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown binary parameter: $$x$$(t_end)))
endef
$(foreach x,$(bin_labels),$(eval $(call check_bin_entry,$x)))

override define check_lib_entry  # <1:lib label>
$$(foreach x,$$(filter-out %.TYPE %.SRC %.OBJS %.LIBS %.VERSION %.STANDARD %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown library parameter: $$x$$(t_end)))
ifneq ($$(filter %.a %.so,$$($1)),)
  $$(error $$(t_err)$1: library names should not be specified with an extension$$(t_end))
else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
  $$(error $$(t_err)$1.TYPE: only 'static' and/or 'shared' allowed$$(t_end))
else ifeq ($$(strip $$($1.TYPE)),)
  $1.TYPE = static
endif
endef
$(foreach x,$(lib_labels),$(eval $(call check_lib_entry,$x)))

override define check_test_entry  # <1:test label>
$$(foreach x,$$(filter-out %.ARGS %.SRC %.OBJS %.LIBS %.STANDARD %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS %.ASFLAGS %.DEPS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown test parameter: $$x$$(t_end)))
endef
$(foreach x,$(test_labels),$(eval $(call check_test_entry,$x)))

override define check_file_entry  # <1:file label>
$$(foreach x,$$(filter-out %.DEPS %.CMD,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown file parameter: $$x$$(t_end)))
ifeq ($$(strip $$($1.CMD)),)
  $$(error $$(t_err)$1.CMD: command required$$(t_end))
endif
endef
$(foreach x,$(file_labels),$(eval $(call check_file_entry,$x)))

override all_names := $(foreach x,$(all_labels),$($x))
ifneq ($(words $(all_names)),$(words $(sort $(all_names))))
  $(error $(t_err)Duplicate binary/library/test names$(t_end))
endif

# macro to encode path as part of name and remove suffix
override src_bname = $(subst /,__,$(subst ../,,$(basename $1)))

# check for source conflicts like src/file.cc & src/file.cpp
override all_source := $(sort $(foreach x,$(all_labels),$($x.SRC)))
override all_source_base := $(call src_bname,$(all_source))
ifneq ($(words $(all_source_base)),$(words $(sort $(all_source_base))))
  $(error $(t_err)Conflicting source files - each basename must be unique$(t_end))
endif

ifeq ($(filter $(DEFAULT_ENV),$(env_names)),)
  $(error $(t_err)DEFAULT_ENV: invalid value$(t_end))
endif
MAKECMDGOALS ?= $(DEFAULT_ENV)

ifneq ($(words $(BUILD_DIR)),1)
  $(error $(t_err)BUILD_DIR: spaces not allowed$(t_end))
else ifeq ($(filter 0 1,$(words $(OUTPUT_DIR))),)
  $(error $(t_err)OUTPUT_DIR: spaces not allowed$(t_end))
else ifeq ($(filter 0 1,$(words $(BIN_OUTPUT_DIR))),)
  $(error $(t_err)BIN_OUTPUT_DIR: spaces not allowed$(t_end))
else ifeq ($(filter 0 1,$(words $(LIB_OUTPUT_DIR))),)
  $(error $(t_err)LIB_OUTPUT_DIR: spaces not allowed$(t_end))
endif

override static_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter static,$($x.TYPE)),$x)))
override shared_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))
override src_path := $(if $(SOURCE_DIR),$(SOURCE_DIR:%/=%)/)

# environment specific setup
override define setup_env  # <1:build env>
override ENV := $1
override SFX := $$($1_sfx)
override TMP := $$(BUILD_DIR)/$$(ENV)_tmp
override $1_libdir := $$(if $$(LIB_OUTPUT_DIR),$$(LIB_OUTPUT_DIR:%/=%)/)
override $1_bindir := $$(if $$(BIN_OUTPUT_DIR),$$(BIN_OUTPUT_DIR:%/=%)/)

ifneq ($$(filter 1,$$(words $$(filter $$($1_libdir),$$(foreach x,$$(env_names),$$($$x_libdir))))),)
override $1_libs :=\
  $$(foreach x,$$(static_lib_labels),$$($1_libdir)$$($$x).a)\
  $$(foreach x,$$(shared_lib_labels),$$($1_libdir)$$($$x).so$$(if $$($$x.VERSION),.$$($$x.VERSION)))
else
override $1_libs :=\
  $$(foreach x,$$(static_lib_labels),$$($1_libdir)$$($$x)$$($1_sfx).a)\
  $$(foreach x,$$(shared_lib_labels),$$($1_libdir)$$($$x)$$($1_sfx).so$$(if $$($$x.VERSION),.$$($$x.VERSION)))
endif

ifneq ($$(filter 1,$$(words $$(filter $$($1_bindir),$$(foreach x,$$(env_names),$$($$x_bindir))))),)
override $1_bins := $$(foreach x,$$(bin_labels),$$($1_bindir)$$($$x))
else
override $1_bins := $$(foreach x,$$(bin_labels),$$($1_bindir)$$($$x)$$($1_sfx))
endif

override $1_files := $$(foreach x,$$(file_labels),$$($$x))
override $1_tests := $$(foreach x,$$(test_labels),$$($$x)$$($1_sfx))
override $1_build_targets := $$($1_files) $$($1_libs) $$($1_bins) $$($1_tests)
override $1_aliases :=\
  $$(foreach x,$$(all_labels),$$x$$($1_sfx))\
  $$(foreach x,$$(lib_labels),$$($$x)$$($1_sfx))\
  $$(if $$($1_libdir),$$(foreach x,$$(static_lib_labels),$$($$x)$$($1_sfx).a))\
  $$(foreach x,$$(shared_lib_labels),\
    $$(if $$(or $$($1_libdir),$$($$x.VERSION)),$$($$x)$$($1_sfx).so))\
  $$(if $$($1_bindir),$$(foreach x,$$(bin_labels),$$($$x)$$($1_sfx)))
override $1_goals :=\
  $$(sort\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),all) $1,$$(MAKECMDGOALS)),$$($1_build_targets))\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),tests) tests_$1,$$(MAKECMDGOALS)),$$($1_tests))\
    $$(filter $$($1_build_targets) $$($1_aliases),$$(MAKECMDGOALS)))
override $1_links :=\
  $$(foreach x,$$(shared_lib_labels),\
    $$(if $$($$x.VERSION),$$($1_libdir)$$($$x)$$($1_sfx).so)\
    $$(if $$(word 2,$$(subst ., ,$$($$x.VERSION))),\
      $$($1_libdir)$$($$x)$$($1_sfx).so.$$(word 1,$$(subst ., ,$$($$x.VERSION)))))
endef
$(foreach x,$(env_names),$(eval $(call setup_env,$x)))

# setting value processing functions
override format_warn = $(foreach x,$1,$(if $(filter -%,$x),$x,-W$x))
override format_include = $(foreach x,$1,$(if $(filter -%,$x),$x,-I$x))
override format_libs = $(foreach x,$1,$(if $(filter -%,$x),$x,$(if $(filter ./,$(dir $x)),,-L$(dir $x)) -l$(notdir $x)))
override format_define = $(foreach x,$1,$(if $(filter -%,$x),$x,-D'$x'))

# build environment detection
override build_env := $(strip $(foreach x,$(env_names),$(if $($x_goals),$x)))
ifeq ($(filter 0 1,$(words $(build_env))),)
  $(error $(t_err)Targets in multiple environments not allowed$(t_end))
else ifneq ($(build_env),)
  # setup build targets/variables for selected environment
  override ENV := $(build_env)
  override SFX := $($(ENV)_sfx)
  override TMP := $(BUILD_DIR)/$(ENV)_tmp

  override compile_flags := $($(ENV)_flags) $(call format_define,$(DEFINE)) $(call format_include,$(INCLUDE)) $(pkg_flags) $(FLAGS)
  ifeq ($(strip $(CXXFLAGS)),)
    CXXFLAGS = $(cxx_std) $(call format_warn,$(WARN)) $(compile_flags)
  endif
  ifeq ($(strip $(CFLAGS)),)
    CFLAGS = $(cc_std) $(call format_warn,$(WARN_C)) $(compile_flags)
  endif
  ifeq ($(strip $(ASFLAGS)),)
    ASFLAGS = $(compile_flags)
  endif
  ifeq ($(strip $(LDFLAGS)),)
    LDFLAGS = -Wl,--as-needed -L$(or $($(ENV)_libdir),.)
  endif

  override CXXFLAGS-$(ENV) := $(CXXFLAGS)
  override CFLAGS-$(ENV) := $(CFLAGS)
  override ASFLAGS-$(ENV) := $(ASFLAGS)
  override CXXFLAGS-$(ENV)-tests := $(CXXFLAGS) $(test_pkg_flags) $(TEST_FLAGS)
  override CFLAGS-$(ENV)-tests := $(CFLAGS) $(test_pkg_flags) $(TEST_FLAGS)
  override ASFLAGS-$(ENV)-tests := $(ASFLAGS) $(test_pkg_flags) $(TEST_FLAGS)

  $(foreach x,$(src_labels),\
    $(eval override $x_src_objs := $$(addsuffix .o,$$(call src_bname,$$($x.SRC))))\
    $(eval override $x_lib_flags := $$(call format_libs,$$(or $$($x.LIBS),$$(LIBS))) $$(if $$($x_pkgs),$$($x_pkg_libs),$$(pkg_libs)))\
    $(eval override $x_build := $(ENV)$(if $(or $($x.STANDARD),$($x.DEFINE),$($x.INCLUDE),$($x_pkgs),$($x.FLAGS),$($x.CXXFLAGS),$($x.CFLAGS),$($x.ASFLAGS),$($x.DEPS)),-$x,$(if $(and $(strip $(test_pkg_flags) $(TEST_FLAGS)),$(filter $x,$(test_labels))),-tests)))\
    $(if $(or $($x.STANDARD),$($x.DEFINE),$($x.INCLUDE),$($x_pkgs),$($x.FLAGS),$($x.CXXFLAGS),$($x.CFLAGS),$($x.ASFLAGS),$($x.DEPS)),\
      $(eval override $x_compile_flags := $$($(ENV)_flags) $$(call format_define,$$(or $$($x.DEFINE),$$(DEFINE))) $$(call format_include,$$(or $$($x.INCLUDE),$$(INCLUDE))) $$(if $$($x_pkgs),$$($x_pkg_flags),$$(pkg_flags)) $$(or $$($x.FLAGS),$$(FLAGS)))\
      $(eval override CXXFLAGS-$$($x_build) := $$(or $$($x.CXXFLAGS),$$(or $$($x_cxx_std),$$(cxx_std)) $$(call format_warn,$$(WARN)) $$($x_compile_flags)))\
      $(eval override CFLAGS-$$($x_build) := $$(or $$($x.CFLAGS),$$(or $$($x_cc_std),$$(cc_std)) $$(call format_warn,$$(WARN_C)) $$($x_compile_flags)))\
      $(eval override ASFLAGS-$$($x_build) := $$(or $$($x.ASFLAGS),$$($x_compile_flags)))))

  ifneq ($(filter 1,$(words $(filter $($(ENV)_bindir),$(foreach x,$(env_names),$($x_bindir))))),)
  $(foreach x,$(bin_labels),\
    $(eval override $x_name := $$($(ENV)_bindir)$$($x)))
  else
  $(foreach x,$(bin_labels),\
    $(eval override $x_name := $$($(ENV)_bindir)$$($x)$$(SFX)))
  endif

  ifneq ($(filter 1,$(words $(filter $($(ENV)_libdir),$(foreach x,$(env_names),$($x_libdir))))),)
  $(foreach x,$(static_lib_labels),\
    $(eval override $x_name := $$($(ENV)_libdir)$$($x).a))
  $(foreach x,$(shared_lib_labels),\
    $(eval override $x_shared_lib := $$($x).so))
  else
  $(foreach x,$(static_lib_labels),\
    $(eval override $x_name := $$($(ENV)_libdir)$$($x)$$(SFX).a))
  $(foreach x,$(shared_lib_labels),\
    $(eval override $x_shared_lib := $$($x)$$(SFX).so))
  endif

  $(foreach x,$(bin_labels),\
    $(eval override $x_mkdir := $$($(ENV)_bindir)$$(if $$(filter ./,$$(dir $$($x))),,$$(dir $$($x))))\
    $(eval override $x_targets := $x$$(SFX) $$(if $$($(ENV)_bindir),$$($x)$$(SFX)) $$(if $$(SFX),$x $$($x))))
  $(foreach x,$(lib_labels),\
    $(eval override $x_mkdir := $$($(ENV)_libdir)$$(if $$(filter ./,$$(dir $$($x))),,$$(dir $$($x)))))
  $(foreach x,$(static_lib_labels),\
    $(eval override $x_targets := $x$$(SFX) $$($x)$$(SFX) $$(if $$($(ENV)_libdir),$$($x)$$(SFX).a) $$(if $$(SFX),$x $$($x) $$($x).a)))
  $(foreach x,$(shared_lib_labels),\
    $(eval override $x_shared_lib_ver := $$($x_shared_lib)$$(if $$($x.VERSION),.$$($x.VERSION)))\
    $(eval override $x_shared_name := $$($(ENV)_libdir)$$($x_shared_lib_ver))\
    $(eval override $x_shared_targets := $x$$(SFX) $$($x)$$(SFX) $$(if $$(or $$($(ENV)_libdir),$$($x.VERSION)),$$($x)$$(SFX).so) $$(if $$(SFX),$x $$($x) $$($x).so)))
  $(foreach x,$(test_labels),\
    $(eval override $x_targets := $x$$(SFX) $$($x)$$(SFX))\
    $(eval override $x_run := $$(BUILD_DIR)/$$($x_build)/__$x))

  $(foreach x,$(file_labels),\
    $(eval override OUT  := $$($x))\
    $(eval override DEPS := $$($x.DEPS))\
    $(foreach n,$(wordlist 1,$(words $($x.DEPS)),$(no1-99)),\
      $(eval override DEP$n := $$(word $n,$$($x.DEPS))))\
    $(eval override $x_targets := $x$$(SFX))\
    $(eval override $x_command := $$($x.CMD)))

  # binaries depend on lib goals to make sure libs are built first
  override lib_goals :=\
    $(foreach x,$(static_lib_labels),$(if $(filter $($x_targets) $($x_name),$($(ENV)_goals)),$($x_name)))\
    $(foreach x,$(shared_lib_labels),$(if $(filter $($x_shared_targets) $($x_shared_name),$($(ENV)_goals)),$($x_shared_name)))
  # tests depend on lib & bin goals to make sure they always build/run last
  override bin_goals :=\
    $(foreach x,$(bin_labels),$(if $(filter $($x_targets) $($x_name),$($(ENV)_goals)),$($x_name)))
  # if tests are a stated target, build all test binaries before running them
  override test_goals :=\
    $(foreach x,$(test_labels),$(if $(filter $($x_targets) tests tests_$(ENV) $(ENV),$(MAKECMDGOALS)),$($x_run)))
endif


#### Main Targets ####
.PHONY: $(base_targets)

.DEFAULT_GOAL = $(DEFAULT_ENV)
all: $(DEFAULT_ENV)
tests: tests_$(DEFAULT_ENV)

info:
	@echo '$(t_info)==== Build Target Info ====$(t_end)'
	$(if $(filter 0,$(words $(all_labels))),@echo 'No build targets defined')
	$(if $(bin_labels),@echo 'Binaries($(words $(bin_labels))): $(t_bold)$(foreach x,$(bin_labels),$(value $x))$(t_end)')
	$(if $(lib_labels),@echo 'Libraries($(words $(lib_labels))): $(t_bold)$(foreach x,$(lib_labels),$(value $x))$(t_end)')
	$(if $(file_labels),@echo 'Files($(words $(file_labels))): $(t_bold)$(foreach x,$(file_labels),$(value $x))$(t_end)')
	$(if $(test_labels),@echo 'Tests($(words $(test_labels))): $(t_bold)$(foreach x,$(test_labels),$(value $x))$(t_end)')
	@echo

help:
	@echo '$(t_info)==== Command Help ====$(t_end)'
	@echo '$(t_bold)make$(t_end) or $(t_bold)make all$(t_end)   builds default environment ($(t_bold)$(t_fg3)$(DEFAULT_ENV)$(t_end))'
	@echo '$(t_bold)make $(t_fg3)<env>$(t_end)         builds specified environment'
	@echo '                   available: $(t_bold)$(t_fg3)$(env_names)$(t_end)'
	@echo '$(t_bold)make clean$(t_end)         removes all build files except for made binaries/libraries'
	@echo '$(t_bold)make clobber$(t_end)       as clean, but also removes made binaries/libraries'
	@echo '$(t_bold)make tests$(t_end)         builds/runs all tests'
	@echo '$(t_bold)make info$(t_end)          prints build target summary'
	@echo '$(t_bold)make help$(t_end)          prints this information'
	@echo

override define setup_env_targets  # <1:build env>
$1: $$($1_build_targets)
tests_$1: $$($1_tests)

clean_$1:
	@([ -d "$(BUILD_DIR)/$1_tmp" ] && $$(RM) "$$(BUILD_DIR)/$1_tmp/"* && rmdir -- "$$(BUILD_DIR)/$1_tmp") || true
	@$$(RM) "$$(BUILD_DIR)/.$1-cmd-"*
	@for D in "$$(BUILD_DIR)/$1"*; do\
	  ([ -d "$$$$D" ] && echo "$$(t_warn)Cleaning '$$$$D'$$(t_end)" && $$(RM) "$$$$D/"*.mk "$$$$D/"*.o "$$$$D/__TEST"* "$$$$D/.compile_cmd"* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach x,$(env_names),$(eval $(call setup_env_targets,$x)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver" "$(BUILD_DIR)/.packages_ver"* $(foreach x,$(SYMLINKS),"$x")
	@([ -d "$(BUILD_DIR)" ] && rmdir -p -- "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA) $(foreach x,$(env_names),$($x_files)); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(t_warn)Removing '$$X'$(t_end)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach e,$(env_names),$($e_libs) $($e_links) $($e_bins)) core gmon.out $(CLOBBER_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(t_warn)Removing '$$X'$(t_end)" && $(RM) "$$X") || true; done
	@for X in $(filter-out "./",$(sort $(subst /./,/,$(foreach e,$(env_names),$(foreach x,$(bin_labels),"$($e_bindir)$(dir $($x))") $(foreach x,$(lib_labels),"$($e_libdir)$(dir $($x))"))))); do\
	  ([ -d "$$X" ] && rmdir -p --ignore-fail-on-non-empty -- "$$X") || true; done

install: ; $(error $(t_err)Target 'install' not implemented$(t_end))
install-strip: ; $(error $(t_err)Target 'install-strip' not implemented$(t_end))

override define make_subdir_target  # <1:target>
$1: _subdir_$1
.PHONY: _subdir_$1
_subdir_$1:
	@for D in $$(SUBDIRS); do\
	  ([ -d "$$$$D" ] && ($$(MAKE) -C "$$$$D" $1 || true)) || echo "$$(t_warn)SUBDIRS: unknown directory '$$$$D' - skipping$$(t_end)"; done
endef
ifneq ($(strip $(SUBDIRS)),)
  $(foreach x,$(subdir_targets),$(eval $(call make_subdir_target,$x)))
endif


#### Unknown Target Handling ####
.SUFFIXES:
.DEFAULT: ; $(error $(t_err)$(if $(filter $<,$(all_source)),Missing source file '$<','$<' unknown)$(t_end))


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
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs))
override $1_link_cmd := $$(AR) rc '$$($1_name)' $$(strip $$($1_all_objs) $$($1.OBJS))
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-static
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

ifneq ($$($1.DEPS),)
$$($1_all_objs): | $$($1.DEPS)
endif

$$($1_targets): $$($1_name)
$$($1_name): $$($1_all_objs) $$($1.OBJS) $$($1_trigger)
ifneq ($$($1_mkdir),)
	@mkdir -p "$$($1_mkdir)"
endif
	@-$$(RM) "$$@"
	$$($1_link_cmd)
	$$(RANLIB) '$$@'
	@echo "$$(t_info)Static library '$$@' built$$(t_end)"
endef

# shared library build
override define make_shared_lib  # <1:label>
override $1_shared_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)-pic/,$$($1_src_objs))
override $1_shared_link_cmd := $$(strip $$(if $$(filter cxx,$$($1_lang)),$$(CXX) $$(CXXFLAGS-$$($1_build)),$$(CC) $$(CFLAGS-$$($1_build))) $$(LDFLAGS) -fPIC -shared $$($1_shared_objs) $$($1.OBJS) $$($1_lib_flags)) -o '$$($1_shared_name)'
override $1_shared_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-shared
$$(eval $$(call rebuild_check,$$$$($1_shared_trigger),$$$$($1_shared_link_cmd)))

ifneq ($$($1.DEPS),)
$$($1_shared_objs): | $$($1.DEPS)
endif

$$($1_shared_targets): $$($1_shared_name)
$$($1_shared_name): $$($1_shared_objs) $$($1.OBJS) $$($1_shared_trigger)
ifneq ($$($1_mkdir),)
	@mkdir -p "$$($1_mkdir)"
endif
	$$($1_shared_link_cmd)
ifneq ($$($1.VERSION),)
	ln -sf "$$($1_shared_lib_ver)" "$$($$(ENV)_libdir)$$($1_shared_lib)"
ifneq ($$(word 2,$$(subst ., ,$$($1.VERSION))),)
	ln -sf "$$($1_shared_lib_ver)" "$$($$(ENV)_libdir)$$($1_shared_lib).$$(word 1,$$(subst ., ,$$($1.VERSION)))"
endif
endif
	@echo "$$(t_info)Shared library '$$@' built$$(t_end)"
endef

# binary build
override define make_bin  # <1:label>
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs))
override $1_link_cmd := $$(strip $$(if $$(filter cxx,$$($1_lang)),$$(CXX) $$(CXXFLAGS-$$($1_build)),$$(CC) $$(CFLAGS-$$($1_build))) $$(LDFLAGS) $$($1_all_objs) $$($1.OBJS) $$($1_lib_flags)) -o '$$($1_name)'
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

ifneq ($$($1.DEPS),)
$$($1_all_objs): | $$($1.DEPS)
endif

.PHONY: $$($1_targets)
$$($1_targets): $$($1_name)
$$($1_name): $$($1_all_objs) $$($1.OBJS) $$($1_trigger) | $$(lib_goals)
ifneq ($$($1_mkdir),)
	@mkdir -p "$$($1_mkdir)"
endif
	$$($1_link_cmd)
	@echo "$$(t_info)Binary '$$@' built$$(t_end)"
endef

# generic file build
override define make_file  # <1:label>
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1.CMD)))

.PHONY: $$($1_targets)
$$($1_targets): $$($1)
$$($1): $$($1_trigger) $$($1.DEPS)
	$$($1_command)
	@echo "$$(t_info)File '$$@' created$$(t_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define make_test  # <1:label>
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs))
override $1_link_cmd := $$(strip $$(if $$(filter cxx,$$($1_lang)),$$(CXX) $$(CXXFLAGS-$$($1_build)),$$(CC) $$(CFLAGS-$$($1_build))) $$(LDFLAGS) $$($1_all_objs) $$($1.OBJS) $$($1_lib_flags) $$(test_pkg_libs) $$(TEST_LIBS)) -o '$$($1_run)'
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

ifneq ($$($1.DEPS),)
$$($1_all_objs): | $$($1.DEPS)
endif

$$($1_run): $$($1_all_objs) $$($1.OBJS) $$($1_trigger) | $$(lib_goals) $$(bin_goals)
	$$($1_link_cmd)
ifeq ($$(filter tests tests_$$(ENV) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1_run) $$($1.ARGS);\
	EXIT_STATUS=$$$$?;\
	if [[ $$$$EXIT_STATUS -eq 0 ]]; then echo "$$(t_bold) [ $$(t_fg3)PASSED$$(t_fg0) ] - $1$$(SFX) '$$($1)'$$(t_end)"; else echo "$$(t_bold) [ $$(t_fg4)FAILED$$(t_fg0) ] - $1$$(SFX) '$$($1)'$$(t_end)"; exit $$$$EXIT_STATUS; fi
endif

.PHONY: $$($1_targets)
$$($1_targets): $$($1_run) | $$(test_goals)
ifneq ($$(filter tests tests_$$(ENV) $1$$(SFX) $$($1)$$(SFX),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1_run) $$($1.ARGS);\
	if [[ $$$$? -eq 0 ]]; then echo "$$(t_bold) [ $$(t_fg3)PASSED$$(t_fg0) ] - $1$$(SFX) '$$($1)'$$(t_end)"; else echo "$$(t_bold) [ $$(t_fg4)FAILED$$(t_fg0) ] - $1$$(SFX) '$$($1)'$$(t_end)"; $$(RM) "$$($1_run)"; fi
endif
endef


override define make_dep  # <1:path> <2:src> <3:cmd trigger> <4:pkg trigger>
$1/$(call src_bname,$2).o: $(src_path)$2 $1/$3 $$(BUILD_DIR)/.compiler_ver $4 | $$(SYMLINKS)
-include $1/$(call src_bname,$2).mk
endef

override define make_obj  # <1:path> <2:build> <3:flags> <4:src list>
ifneq ($4,)
$1/%.mk: ; @$$(RM) "$$(@:.mk=.o)"

$$(eval $$(call rebuild_check,$1/.compile_cmd_c,$$(strip $$(CC) $$(CFLAGS-$2) $3)))
$(addprefix $1/,$(addsuffix .o,$(call src_bname,$(filter $(c_ptrn),$4)))):
	$$(strip $$(CC) $$(CFLAGS-$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(c_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd_c,$$(pkg_trigger-$2))))

$$(eval $$(call rebuild_check,$1/.compile_cmd_s,$$(strip $$(AS) $$(ASFLAGS-$2) $3)))
$(addprefix $1/,$(addsuffix .o,$(call src_bname,$(filter $(asm_ptrn),$4)))):
	$$(strip $$(AS) $$(ASFLAGS-$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(asm_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd_s,$$(pkg_trigger-$2))))

$$(eval $$(call rebuild_check,$1/.compile_cmd,$$(strip $$(CXX) $$(CXXFLAGS-$2) $3)))
$1/%.o: ; $$(strip $$(CXX) $$(CXXFLAGS-$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter $(cxx_ptrn),$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd,$$(pkg_trigger-$2))))
endif
endef


#### Create Build Targets ####
.DELETE_ON_ERROR:
override define verify_pkgs  # <1:packages> <2:pkgs>
ifneq ($$(strip $$($1)),)
  ifneq ($$(words $$($1)),$$(words $$($2)))
    $$(error $$(t_err)Cannot build because of missing packages$$(t_end))
  endif
endif
endef

ifneq ($(build_env),)
  $(eval $(call verify_pkgs,PACKAGES,pkgs))
  $(foreach x,$(bin_labels) $(lib_labels),$(eval $(call verify_pkgs,$x.PACKAGES,$x_pkgs)))

  $(shell mkdir -p $(TMP))

  # symlink creation rule
  $(foreach x,$(SYMLINKS),$(eval $x: ; @ln -s . "$x"))

  # .compiler_ver rule (rebuild trigger for compiler version upgrades)
  $(eval $(call rebuild_check,$(BUILD_DIR)/.compiler_ver,$(shell $(CC) --version | head -1)))

  # .packages_ver rules (rebuild triggers for package version changes)
  $(if $(pkgs),\
    $(eval override pkg_trigger-$(ENV) := $(BUILD_DIR)/.packages_ver)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver,$(foreach p,$(sort $(pkgs)),$p:$(shell $(PKGCONF) --modversion $p)))))

  $(if $(test_pkgs),\
    $(eval override pkg_trigger-$(ENV)-tests := $(BUILD_DIR)/.packages_ver-tests)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver-tests,$(foreach p,$(sort $(pkgs) $(test_pkgs)),$p:$(shell $(PKGCONF) --modversion $p)))))

  $(foreach x,$(src_labels),$(if $($x_pkgs),\
    $(eval override pkg_trigger-$(ENV)-$x := $(BUILD_DIR)/.packages_ver-$x)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver-$x,$(foreach p,$(sort $($x_pkgs)),$p:$(shell $(PKGCONF) --modversion $p))))))

  # make .o/.mk files for each build path
  # NOTES:
  # - don't put 'call' args on separate lines, this can add spaces to values
  # - object builds are before linking so '<objs>: DEPS' rules don't affect
  #   compile commands by changing '$<' var
  $(foreach b,$(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$($x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b,$b,,$(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$(if $(filter $($x_build),$b),$($x.SRC)))))))

  $(foreach b,$(sort $(foreach x,$(shared_lib_labels),$($x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b-pic,$b,-fPIC,$(sort $(foreach x,$(shared_lib_labels),$(if $(filter $($x_build),$b),$($x.SRC)))))))

  # make binary/library/test build targets
  .PHONY: $(sort $(foreach x,$(lib_labels),$($x_targets) $($x_shared_targets)))
  $(foreach x,$(static_lib_labels),$(eval $(call make_static_lib,$x)))
  $(foreach x,$(shared_lib_labels),$(eval $(call make_shared_lib,$x)))
  $(foreach x,$(bin_labels),$(eval $(call make_bin,$x)))
  $(foreach x,$(file_labels),$(eval $(call make_file,$x)))
  $(foreach x,$(test_labels),$(eval $(call make_test,$x)))
endif

#### END ####
