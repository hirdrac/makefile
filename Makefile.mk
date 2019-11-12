#
# Makefile.mk - version 1.4 (2019/11/11)
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
# Makefile assistant for C++ projects
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
#
# Makefile Parameters:
#  BIN1            name of binary to build (up to 99, i.e. BIN2, BIN39, etc.)
#  BIN1.SRC        source files for binary 1 (C/C++ source files, no headers)
#  BIN1.OBJS       additional binary 1 object dependencies (.o,.a files)
#
#  LIB1            name of library to build (without .a/.so extension)
#  LIB1.TYPE       type of library to build: static(default) and/or shared
#  LIB1.SRC        source files for library 1
#  LIB1.OBJS       additional library 1 object dependencies
#  LIB1.VERSION    major(.minor(.patch)) version of shared library 1
#
#  TEST1           name of unit test to build
#  TEST1.ARGS      arguments for running test 1 binary
#  TEST1.SRC       source files for unit test 1
#  TEST1.OBJS      additional unit test 1 object dependencies
#
#  STANDARD        language standard(s) of source code
#  COMPILER        compiler to use (gcc,clang)
#  WARN            compile warning options
#  WARN_C          C specific warnings
#  OPTIMIZE        options for release & gprof builds
#  DEBUG           options for debug builds
#  PROFILE         options for gprof builds
#  PACKAGES        list of packages for pkg-config
#  <X>.PACKAGES    override 'PACKAGES' setting for binary/library/test target
#  INCLUDE         includes needed not covered by pkg-config
#  <X>.INCLUDE     override 'INCLUDE' setting for binary/library/test target
#  LIBS            libraries needed not covered by pkg-config
#  <X>.LIBS        override 'LIBS' setting for binary/library/test target
#  DEFINE          defines for compilation
#  <X>.DEFINE      override 'DEFINE' setting for binary/library/test target
#  FLAGS           additional compiler flags not otherwise specified
#  <X>.FLAGS       override 'FLAGS' setting for binary/library/test target
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
#
# Output Variables:
#  ENV             current build environment
#  SFX             current build environment binary suffix
#

#### Shell Commands ####
SHELL = /bin/sh
PKGCONF ?= pkg-config
RM ?= rm -f --


#### Basic Settings ####
STANDARD ?=
COMPILER ?= $(firstword $(compiler_names))
PACKAGES ?=
INCLUDE ?= -I.
LIBS ?=
DEFINE ?=
OPTIMIZE ?= -O3
DEBUG ?= -g -O1 -DDEBUG
PROFILE ?= -pg
FLAGS ?=
ifndef WARN
  WARN = -Wall -Wextra -Wno-unused-parameter -Wnon-virtual-dtor -Woverloaded-virtual $($(COMPILER)_warn)
  WARN_C ?= -Wall -Wextra -Wno-unused-parameter $($(COMPILER)_warn)
else
  WARN_C ?= $(WARN)
endif
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

# default values to be more obvious if used/handled improperly
override ENV := ENV
override SFX := SFX

# apply *_EXTRA setting values
$(foreach x,PACKAGES INCLUDE LIBS DEFINE OPTIMIZE DEBUG PROFILE FLAGS WARN WARN_C TEST_PACKAGES TEST_LIBS TEST_FLAGS,\
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
gcc_ar ?= gcc-ar
gcc_ranlib ?= gcc-ranlib
gcc_warn ?= -Wshadow=local
clang_cxx ?= clang++
clang_cc ?= clang
clang_ar ?= llvm-ar
clang_ranlib ?= llvm-ranlib
clang_warn ?= -Wshadow


#### Terminal Output ####
# t_fg1 - binary/library built
# t_fg2 - warning or removal notice
# t_fg3 - test passed
# t_fg4 - test failed, fatal error
override t_bold := $(shell setterm --bold on)
override t_fg0  := $(shell setterm --foreground default)
override t_fg1  := $(shell setterm --foreground cyan)
override t_fg2  := $(shell setterm --foreground magenta)
override t_fg3  := $(shell setterm --foreground green)
override t_fg4  := $(shell setterm --foreground red)
override t_info := $(t_bold)$(t_fg1)
override t_warn := $(t_bold)$(t_fg2)
override t_err  := $(t_bold)$(t_fg4)
override t_end  := $(shell setterm --default)


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(compiler_names)),)
  $(error $(t_err)COMPILER: unknown compiler$(t_end))
endif

CXX = $(or $($(COMPILER)_cxx),c++)
CC = $(or $($(COMPILER)_cc),cc)
AR = $(or $($(COMPILER)_ar),ar)
RANLIB = $(or $($(COMPILER)_ranlib),ranlib)

override valid_standards := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a
override standard_cc := $(filter $(STANDARD),$(valid_standards))
ifneq ($(standard_cc),)
  ifneq ($(words $(standard_cc)),1)
    $(error $(t_err)STANDARD: multiple C++ standards not allowed$(t_end))
  endif
  override cxx_flags := -std=$(standard_cc)
endif

override valid_standards_c := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18
override standard_c := $(filter $(STANDARD),$(valid_standards_c))
ifneq ($(standard_c),)
  ifneq ($(words $(standard_c)),1)
    $(error $(t_err)STANDARD: multiple C standards not allowed$(t_end))
  endif
  override cc_flags := -std=$(standard_c)
endif

ifneq ($(filter-out $(valid_standards) $(valid_standards_c),$(STANDARD)),)
  $(error $(t_err)STANDARD: unknown standard specified$(t_end))
endif


#### Package Handling ####
# syntax: PACKAGES = <pkg name>(:<min version>) ...
override pkg_n = $(word 1,$(subst :, ,$1))
override pkg_v = $(word 2,$(subst :, ,$1))
override check_pkgs =\
$(strip $(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call pkg_n,$x) $(if $(call pkg_v,$x),--atleast-version=$(call pkg_v,$x),--exists) && echo "1"),\
    $(call pkg_n,$x),\
    $(warning $(t_warn)$1: package '$(call pkg_n,$x)'$(if $(call pkg_v,$x), [version >= $(call pkg_v,$x)]) not found$(t_end)))))

ifneq ($(strip $(PACKAGES)),)
  override pkgs := $(call check_pkgs,PACKAGES)
  ifneq ($(pkgs),)
    override pkg_flags := $(shell $(PKGCONF) $(pkgs) --cflags)
    override pkg_libs := $(shell $(PKGCONF) $(pkgs) --libs)
  endif
endif

ifneq ($(strip $(TEST_PACKAGES)),)
  override test_pkgs := $(call check_pkgs,TEST_PACKAGES)
  ifneq ($(test_pkgs),)
    override test_pkg_flags := $(shell $(PKGCONF) $(test_pkgs) --cflags)
    override test_pkg_libs := $(shell $(PKGCONF) $(test_pkgs) --libs)
  endif
endif


#### Internal Calculated Values ####
override digits := 1 2 3 4 5 6 7 8 9
override no1-99 := $(digits) $(foreach x,$(digits),$(addprefix $x,0 $(digits)))

override lib_labels := $(strip $(foreach x,$(no1-99),$(if $(LIB$x),LIB$x)))
override bin_labels := $(strip $(foreach x,$(no1-99),$(if $(BIN$x),BIN$x)))
override test_labels := $(strip $(foreach x,$(no1-99),$(if $(TEST$x),TEST$x)))
override all_labels := $(lib_labels) $(bin_labels) $(test_labels)

override subdir_targets := $(foreach x,$(env_names),$x tests_$x clean_$x) clobber install install-strip
override base_targets := all tests clean $(subdir_targets)

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
ifneq ($$(strip $$($1.PACKAGES)),)
  override $1_pkgs := $$(call check_pkgs,$1.PACKAGES)
  ifneq ($$($1_pkgs),)
    override $1_pkg_flags := $$(shell $$(PKGCONF) $$($1_pkgs) --cflags)
    override $1_pkg_libs := $$(shell $$(PKGCONF) $$($1_pkgs) --libs)
  endif
endif
endef
$(foreach x,$(all_labels),$(eval $(call check_entry,$x)))

override define check_bin_entry  # <1:bin label>
$$(foreach x,$$(filter-out %.SRC %.OBJS %.LIBS %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown binary paramater: $$x$$(t_end)))
endef
$(foreach x,$(bin_labels),$(eval $(call check_bin_entry,$x)))

override define check_lib_entry  # <1:lib label>
$$(foreach x,$$(filter-out %.TYPE %.SRC %.OBJS %.LIBS %.VERSION %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown library paramater: $$x$$(t_end)))
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
$$(foreach x,$$(filter-out %.ARGS %.SRC %.OBJS %.LIBS %.DEFINE %.INCLUDE %.FLAGS %.PACKAGES %.CXXFLAGS %.CFLAGS,$$(filter $1.%,$$(.VARIABLES))),\
  $$(warning $$(t_warn)Unknown test paramater: $$x$$(t_end)))
endef
$(foreach x,$(test_labels),$(eval $(call check_test_entry,$x)))

override all_names := $(foreach x,$(all_labels),$($x))
ifneq ($(words $(all_names)),$(words $(sort $(all_names))))
  $(error $(t_err)Duplicate binary/library/test names$(t_end))
endif

# macro to encode path as part of name and remove extension
override src_base = $(subst /,__,$(subst ../,,$(basename $1)))

# check for source conflicts like src/file.cc & src/file.cpp
override all_source := $(sort $(foreach x,$(all_labels),$($x.SRC)))
override all_source_base := $(call src_base,$(all_source))
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

# environment specific setup
override define setup_env  # <1:build env>
override ENV := $1
override SFX := $$($1_sfx)
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

override $1_tests := $$(foreach x,$$(test_labels),$$($$x)$$($1_sfx))
override $1_build_targets := $$($1_libs) $$($1_bins) $$($1_tests)
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

override build_env := $(strip $(foreach x,$(env_names),$(if $($x_goals),$x)))
ifeq ($(filter 0 1,$(words $(build_env))),)
  $(error $(t_err)Targets in multiple environments not allowed$(t_end))
else ifneq ($(build_env),)
  override ENV := $(build_env)
  override SFX := $($(ENV)_sfx)

  CXXFLAGS = $(cxx_flags) $(WARN) $($(ENV)_flags) $(DEFINE) $(INCLUDE) $(pkg_flags) $(FLAGS)
  CFLAGS = $(cc_flags) $(WARN_C) $($(ENV)_flags) $(DEFINE) $(INCLUDE) $(pkg_flags) $(FLAGS)
  LDFLAGS = -Wl,--as-needed -L$(or $($(ENV)_libdir),.)

  # generate target values based on environment/output dir
  override CXXFLAGS-$(ENV) := $(CXXFLAGS)
  override CFLAGS-$(ENV) := $(CFLAGS)
  override CXXFLAGS-$(ENV)-tests := $(CXXFLAGS) $(test_pkg_flags) $(TEST_FLAGS)
  override CFLAGS-$(ENV)-tests := $(CFLAGS) $(test_pkg_flags) $(TEST_FLAGS)

  $(foreach x,$(all_labels),\
    $(eval override $x_src_objs := $$(addsuffix .o,$$(call src_base,$$($x.SRC))))\
    $(eval override $x_build := $(ENV)$(if $(or $($x.DEFINE),$($x.INCLUDE),$($x_pkgs),$($x.FLAGS),$($x.CXXFLAGS),$($x.CFLAGS)),-$x,$(if $(and $(strip $(test_pkg_flags) $(TEST_FLAGS)),$(filter $x,$(test_labels))),-tests)))\
    $(if $(or $($x.DEFINE),$($x.INCLUDE),$($x_pkgs),$($x.FLAGS),$($x.CXXFLAGS),$($x.CFLAGS)),\
      $(eval override CXXFLAGS-$$($x_build) := $$(or $$($x.CXXFLAGS),$$(cxx_flags) $$(WARN) $$($(ENV)_flags) $$(or $$($x.DEFINE),$$(DEFINE)) $$(or $$($x.INCLUDE),$$(INCLUDE)) $$(if $$($x_pkgs),$$($x_pkg_flags),$$(pkg_flags)) $$(or $$($x.FLAGS),$$(FLAGS))))\
      $(eval override CFLAGS-$$($x_build) := $$(or $$($x.CFLAGS),$$(cc_flags) $$(WARN_C) $$($(ENV)_flags) $$(or $$($x.DEFINE),$$(DEFINE)) $$(or $$($x.INCLUDE),$$(INCLUDE)) $$(if $$($x_pkgs),$$($x_pkg_flags),$$(pkg_flags)) $$(or $$($x.FLAGS),$$(FLAGS))))))

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
    $(eval override $x_targets := $x$$(SFX) $$(if $$($(ENV)_bindir),$$($x)$$(SFX)) $$(if $$(SFX),$x $$($x))))
  $(foreach x,$(static_lib_labels),\
    $(eval override $x_targets := $x$$(SFX) $$($x)$$(SFX) $$(if $$($(ENV)_libdir),$$($x)$$(SFX).a) $$(if $$(SFX),$x $$($x) $$($x).a)))
  $(foreach x,$(shared_lib_labels),\
    $(eval override $x_shared_lib_ver := $$($x_shared_lib)$$(if $$($x.VERSION),.$$($x.VERSION)))\
    $(eval override $x_shared_name := $$($(ENV)_libdir)$$($x_shared_lib_ver))\
    $(eval override $x_shared_targets := $x$$(SFX) $$($x)$$(SFX) $$(if $$(or $$($(ENV)_libdir),$$($x.VERSION)),$$($x)$$(SFX).so) $$(if $$(SFX),$x $$($x) $$($x).so)))
  $(foreach x,$(test_labels),\
    $(eval override $x_targets := $x$$(SFX) $$($x)$$(SFX))\
    $(eval override $x_run := $$(BUILD_DIR)/$$($x_build)/__$x))

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

override define setup_env_targets  # <1:build env>
$1: $$($1_build_targets)
tests_$1: $$($1_tests)

clean_$1:
	@$$(RM) "$$(BUILD_DIR)/.$1-cmd-"*
	@for D in "$$(BUILD_DIR)/$1"*; do\
	  ([ -d "$$$$D" ] && echo "$$(t_warn)Cleaning '$$$$D'$$(t_end)" && $$(RM) "$$$$D/"*.mk "$$$$D/"*.o "$$$$D/__TEST"* "$$$$D/.compile_cmd"* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach x,$(env_names),$(eval $(call setup_env_targets,$x)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver" "$(BUILD_DIR)/.packages_ver"* $(foreach x,$(SYMLINKS),"$x")
	@([ -d "$(BUILD_DIR)" ] && rmdir -p -- "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(t_warn)Removing '$$X'$(t_end)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach x,$(env_names),$($x_libs) $($x_links) $($x_bins)) core gmon.out $(CLOBBER_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(t_warn)Removing '$$X'$(t_end)" && $(RM) "$$X") || true; done
	@for X in $(foreach x,$(env_names),$(if $($x_libdir),"$($x_libdir)") $(if $($x_bindir),"$($x_bindir)")); do\
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
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs)) $$($1.OBJS)
override $1_link_cmd := $$(AR) rc '$$($1_name)' $$(strip $$($1_all_objs))
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-static
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

$$($1_targets): $$($1_name)
$$($1_name): $$($1_all_objs) $$($1_trigger)
ifneq ($$($$(ENV)_libdir),)
	@mkdir -p "$$($$(ENV)_libdir)"
endif
	@-$$(RM) "$$@"
	$$($1_link_cmd)
	$$(RANLIB) '$$@'
	@echo "$$(t_info)Static library '$$@' built$$(t_end)"
endef

# shared library build
override define make_shared_lib  # <1:label>
override $1_shared_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)-pic/,$$($1_src_objs)) $$($1.OBJS)
override $1_shared_link_cmd := $$(strip $$(CXX) $$(CXXFLAGS-$$($1_build)) $$(LDFLAGS) -fPIC -shared $$($1_shared_objs) $$(if $$($1_pkgs),$$($1_pkg_libs),$$(pkg_libs)) $$(or $$($1.LIBS),$$(LIBS))) -o '$$($1_shared_name)'
override $1_shared_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1-shared
$$(eval $$(call rebuild_check,$$$$($1_shared_trigger),$$$$($1_shared_link_cmd)))

$$($1_shared_targets): $$($1_shared_name)
$$($1_shared_name): $$($1_shared_objs) $$($1_shared_trigger)
ifneq ($$($$(ENV)_libdir),)
	@mkdir -p "$$($$(ENV)_libdir)"
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
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs)) $$($1.OBJS)
override $1_link_cmd := $$(strip $$(CXX) $$(CXXFLAGS-$$($1_build)) $$(LDFLAGS) $$($1_all_objs) $$(if $$($1_pkgs),$$($1_pkg_libs),$$(pkg_libs)) $$(or $$($1.LIBS),$$(LIBS))) -o '$$($1_name)'
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

.PHONY: $$($1_targets)
$$($1_targets): $$($1_name)
$$($1_name): $$($1_all_objs) $$($1_trigger) | $$(lib_goals)
ifneq ($$($$(ENV)_bindir),)
	@mkdir -p "$$($$(ENV)_bindir)"
endif
	$$($1_link_cmd)
	@echo "$$(t_info)Binary '$$@' built$$(t_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define make_test  # <1:label>
override $1_all_objs := $$(addprefix $$(BUILD_DIR)/$$($1_build)/,$$($1_src_objs)) $$($1.OBJS)
override $1_link_cmd := $$(strip $$(CXX) $$(CXXFLAGS-$$($1_build)) $$(LDFLAGS) $$($1_all_objs) $$(if $$($1_pkgs),$$($1_pkg_libs),$$(pkg_libs)) $$(or $$($1.LIBS),$$(LIBS)) $$(test_pkg_libs) $$(TEST_LIBS)) -o '$$($1_run)'
override $1_trigger := $$(BUILD_DIR)/.$$(ENV)-cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_trigger),$$$$($1_link_cmd)))

$$($1_run): $$($1_all_objs) $$($1_trigger) | $$(lib_goals) $$(bin_goals)
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
$1/$(call src_base,$2).o: $2 $1/$3 $$(BUILD_DIR)/.compiler_ver $4 | $$(SYMLINKS)
-include $1/$(call src_base,$2).mk
endef

override define make_obj  # <1:path> <2:build> <3:flags> <4:src list>
ifneq ($4,)
$1/%.mk: ; @$$(RM) "$$(@:.mk=.o)"

$$(eval $$(call rebuild_check,$1/.compile_cmd_c,$$(strip $$(CC) $$(CFLAGS-$2) $3)))
$(addprefix $1/,$(addsuffix .o,$(call src_base,$(filter %.c,$4)))):
	$$(strip $$(CC) $$(CFLAGS-$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter %.c,$4),\
  $$(eval $$(call make_dep,$1,$x,.compile_cmd_c,$$(pkg_trigger-$2))))

$$(eval $$(call rebuild_check,$1/.compile_cmd,$$(strip $$(CXX) $$(CXXFLAGS-$2) $3)))
$1/%.o: ; $$(strip $$(CXX) $$(CXXFLAGS-$2) $3) -MMD -MP -MT '$$@' -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter-out %.c,$4),\
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

  $(foreach x,$(all_labels),$(if $($x_pkgs),\
    $(eval override pkg_trigger-$(ENV)-$x := $(BUILD_DIR)/.packages_ver-$x)\
    $(eval $(call rebuild_check,$(BUILD_DIR)/.packages_ver-$x,$(foreach p,$(sort $($x_pkgs)),$p:$(shell $(PKGCONF) --modversion $p))))))

  # make binary/library/test build targets
  .PHONY: $(sort $(foreach x,$(lib_labels),$($x_targets) $($x_shared_targets)))
  $(foreach x,$(static_lib_labels),$(eval $(call make_static_lib,$x)))
  $(foreach x,$(shared_lib_labels),$(eval $(call make_shared_lib,$x)))
  $(foreach x,$(bin_labels),$(eval $(call make_bin,$x)))
  $(foreach x,$(test_labels),$(eval $(call make_test,$x)))

  # make .o/.mk files for each build path
  # (don't put 'call' args on separate lines, this can add spaces to values)
  $(foreach b,$(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$($x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b,$b,,$(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$(if $(filter $($x_build),$b),$($x.SRC)))))))

  $(foreach b,$(sort $(foreach x,$(shared_lib_labels),$($x_build))),\
    $(eval $(call make_obj,$$(BUILD_DIR)/$b-pic,$b,-fPIC,$(sort $(foreach x,$(shared_lib_labels),$(if $(filter $($x_build),$b),$($x.SRC)))))))
endif

#### END ####
