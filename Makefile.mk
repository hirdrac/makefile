#
# Makefile.mk - version 1.0 (2019/4/10)
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
#  BIN1.LIBS       additional libraries to link with binary 1
#
#  LIB1            name of library to build (without .a/.so extension)
#  LIB1.TYPE       type of library to build: static(default) and/or shared
#  LIB1.SRC        source files for library 1
#  LIB1.OBJS       additional library 1 object dependencies
#  LIB1.LIBS       additional libraries to link with shared library 1
#
#  TEST1           name of unit test to build
#  TEST1.ARGS      arguments for running test 1 binary
#  TEST1.SRC       source files for unit test 1
#  TEST1.OBJS      additional unit test 1 object dependencies
#  TEST1.LIBS      additional libraries to link with test 1
#
#  STANDARD        language standard(s) of source code
#  COMPILER        compiler to use (gcc,clang)
#  PACKAGES        list of packages for pkg-config
#  INCLUDE         includes needed not covered by pkg-config
#  LIBS            libraries needed not covered by pkg-config
#  TEST_PACKAGES   additional packages for tests (lib linking only)
#  TEST_LIBS       additional libs to link with for all tests
#  DEFINE          defines for compilation
#  OPTIMIZE        options for release & gprof builds
#  DEBUG           options for debug builds
#  PROFILE         options for gprof builds
#  FLAGS           additional compiler flags not otherwise specified
#  WARN            compile warning options
#  WARN_C          C specific warnings
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
#

#### Shell Commands ####
SHELL = /bin/sh
PKGCONF ?= pkg-config
RM ?= rm -f


#### Basic Settings ####
STANDARD ?=
COMPILER ?= $(firstword $(compiler_names))

PACKAGES ?=
INCLUDE ?= -I.
LIBS ?=
TEST_PACKAGES ?=
TEST_LIBS ?=
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

BUILD_DIR ?= build
DEFAULT_ENV ?= $(firstword $(env_names))
OUTPUT_DIR ?=
LIB_OUTPUT_DIR ?= $(OUTPUT_DIR)
BIN_OUTPUT_DIR ?= $(OUTPUT_DIR)
CLEAN_EXTRA ?=
CLOBBER_EXTRA ?=
SUBDIRS ?=

# apply *_EXTRA setting values
$(foreach x,PACKAGES INCLUDE LIBS TEST_PACKAGES TEST_LIBS DEFINE OPTIMIZE DEBUG PROFILE FLAGS WARN WARN_C,$(if $($x_EXTRA),$(eval override $x += $$($x_EXTRA))))


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


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(compiler_names)),)
  $(error COMPILER: unknown compiler)
endif

CXX = $(or $($(COMPILER)_cxx),c++)
CC = $(or $($(COMPILER)_cc),cc)
AR = $(or $($(COMPILER)_ar),ar)
RANLIB = $(or $($(COMPILER)_ranlib),ranlib)
valid_standards := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a
standard_cc := $(filter $(STANDARD),$(valid_standards))
ifneq ($(standard_cc),)
  ifneq ($(words $(standard_cc)),1)
    $(error STANDARD: multiple C++ standards not allowed)
  endif
  CXX += -std=$(standard_cc)
endif

valid_standards_c := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18
standard_c := $(filter $(STANDARD),$(valid_standards_c))
ifneq ($(standard_c),)
  ifneq ($(words $(standard_c)),1)
    $(error STANDARD: multiple C standards not allowed)
  endif
  CC += -std=$(standard_c)
endif

ifneq ($(filter-out $(valid_standards) $(valid_standards_c),$(STANDARD)),)
  $(error STANDARD: unknown standard specified)
endif


#### Package Handling ####
# syntax: PACKAGES = <pkg name>(:<min version>) ...
pkg_n = $(word 1,$(subst :, ,$1))
pkg_v = $(word 2,$(subst :, ,$1))
check_pkgs = \
$(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call pkg_n,$x) $(if $(call pkg_v,$x),--atleast-version=$(call pkg_v,$x),--exists) && echo "1"),\
    $(call pkg_n,$x),\
    $(warning $1: package '$(call pkg_n,$x)'$(if $(call pkg_v,$x), [version >= $(call pkg_v,$x)]) not found)))

ifneq ($(strip $(PACKAGES)),)
  override pkgs := $(strip $(call check_pkgs,PACKAGES))
  ifneq ($(pkgs),)
    override FLAGS += $(shell $(PKGCONF) $(pkgs) --cflags)
    override LIBS += $(shell $(PKGCONF) $(pkgs) --libs)
  endif
endif

ifneq ($(strip $(TEST_PACKAGES)),)
  override test_pkgs := $(strip $(call check_pkgs,TEST_PACKAGES))
  ifneq ($(test_pkgs),)
    override TEST_LIBS += $(shell $(PKGCONF) $(test_pkgs) --libs)
  endif
endif


#### Internal Calculated Values ####
# label_nums 1-99
digits := 1 2 3 4 5 6 7 8 9
label_nums := $(digits) $(foreach x,$(digits),$(addprefix $x,0 $(digits)))

lib_labels := $(strip $(foreach x,$(label_nums),$(if $(LIB$x),LIB$x)))
bin_labels := $(strip $(foreach x,$(label_nums),$(if $(BIN$x),BIN$x)))
test_labels := $(strip $(foreach x,$(label_nums),$(if $(TEST$x),TEST$x)))
all_labels := $(lib_labels) $(bin_labels) $(test_labels)

subdir_targets := $(foreach x,$(env_names),$x tests_$x clean_$x) clobber install install-strip
base_targets := all tests clean $(subdir_targets)

# macro to encode path as part of name and remove extension
src_base = $(subst /,__,$(basename $1))

define check_entry  # <1:label>
override $1 := $$(strip $$($1))
ifneq ($$(words $$($1)),1)
  $$(error $1: spaces not allowed in name)
else ifneq ($$(filter $$($1),$$(base_targets) $$(foreach x,$$(env_names),$1$$($$x_sfx))),)
  $$(error $1: name conflicts with existing target)
else ifeq ($$(strip $$($1.SRC)),)
  $$(error $1.SRC: no source files specified)
else ifneq ($$(words $$($1.SRC)),$$(words $$(sort $$($1.SRC))))
  $$(error $1.SRC: duplicate source files)
endif
override $1.src_objs := $$(addsuffix .o,$$(call src_base,$$($1.SRC)))
endef
$(foreach x,$(all_labels),$(eval $(call check_entry,$x)))

define check_lib_entry  # <1:lib label>
ifneq ($$(filter %.a %.so,$$($1)),)
  $$(error $1: library names should not be specified with an extension)
else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
  $$(error $1.TYPE: only 'static' and/or 'shared' allowed)
else ifeq ($$(strip $$($1.TYPE)),)
  $1.TYPE = static
endif
endef
$(foreach x,$(lib_labels),$(eval $(call check_lib_entry,$x)))

static_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter static,$($x.TYPE)),$x)))
shared_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))

all_names := $(foreach x,$(all_labels),$($x))
ifneq ($(words $(all_names)),$(words $(sort $(all_names))))
  $(error Duplicate binary/library/test names)
endif

all_source := $(sort $(foreach x,$(all_labels),$($x.SRC)))
all_source_base := $(call src_base,$(all_source))
ifneq ($(words $(all_source_base)),$(words $(sort $(all_source_base))))
  $(error Conflicting source files - each basename must be unique)
endif

ifeq ($(filter $(DEFAULT_ENV),$(env_names)),)
  $(error DEFAULT_ENV: invalid value)
endif
MAKECMDGOALS ?= $(DEFAULT_ENV)

ifneq ($(words $(BUILD_DIR)),1)
  $(error BUILD_DIR: spaces not allowed)
endif

override lib_out := $(if $(LIB_OUTPUT_DIR),$(LIB_OUTPUT_DIR:%/=%)/)
override bin_out := $(if $(BIN_OUTPUT_DIR),$(BIN_OUTPUT_DIR:%/=%)/)

# environment specific setup
define setup_env  # <1:build env>
$1_libs := $$(foreach x,$$(static_lib_labels),$$(lib_out)$$($$x)$$($1_sfx).a) $$(foreach x,$$(shared_lib_labels),$$(lib_out)$$($$x)$$($1_sfx).so)
$1_bins := $$(foreach x,$$(bin_labels),$$(bin_out)$$($$x)$$($1_sfx))
$1_tests := $$(foreach x,$$(test_labels),$$($$x)$$($1_sfx))
$1_build_targets := $$($1_libs) $$($1_bins) $$($1_tests)
$1_alias_targets := $$(foreach x,$$(foreach y,$$(lib_labels),$$(lib_out)$$($$y)) $$(lib_labels) $$(bin_labels) $$(test_labels),$$x$$($1_sfx))
$1_goals := $$(if $$(filter $1,$$(MAKECMDGOALS)),$$($1_build_targets),$$(filter $$($1_build_targets) $$($1_alias_targets),$$(MAKECMDGOALS)))
ifneq ($$(filter tests_$1,$$(MAKECMDGOALS)),)
  $1_goals := $$(sort $$($1_goals) $$($1_tests))
endif
endef
$(foreach x,$(env_names),$(eval $(call setup_env,$x)))

ifneq ($(filter all,$(MAKECMDGOALS)),)
  $(eval $(DEFAULT_ENV)_goals := $$($(DEFAULT_ENV)_build_targets))
else ifneq ($(filter tests,$(MAKECMDGOALS)),)
  $(eval $(DEFAULT_ENV)_goals := $$(sort $$($(DEFAULT_ENV)_goals) $$($(DEFAULT_ENV)_tests)))
endif

build_env := $(strip $(foreach x,$(env_names),$(if $($x_goals),$x)))
ifeq ($(filter 0 1,$(words $(build_env))),)
  $(error Targets in multiple environments not allowed)
else ifneq ($(build_env),)
  override SFX := $($(build_env)_sfx)

  CXXFLAGS = $(WARN) $($(build_env)_flags) $(DEFINE) $(INCLUDE) $(FLAGS)
  CFLAGS = $(WARN_C) $($(build_env)_flags) $(DEFINE) $(INCLUDE) $(FLAGS)
  LDFLAGS = -Wl,--as-needed -L$(or $(lib_out),.)

  compile_cmd := $(strip $(CXX) $(CXXFLAGS))
  compile_cmd_c := $(strip $(CC) $(CFLAGS))
  link_cmd := $(strip $(CXX) $(CXXFLAGS) $(LDFLAGS))

  # change BINx,LIBx,TESTx vars to environment specific names
  $(foreach x,$(lib_labels) $(bin_labels) $(test_labels),$(eval override $$x:=$$($x)$(SFX)))

  # generate target names based on environment/output dir
  $(foreach x,$(bin_labels),$(eval override $$x.target:=$$(bin_out)$$($$x)))
  $(foreach x,$(lib_labels),$(eval override $$x.target:=$$(lib_out)$$($$x)))

  # binaries/tests are dependent on libs to make sure libs are built first
  lib_goals := \
    $(foreach x,$(static_lib_labels),$(if $(filter $x$(SFX) $($x.target) $($x.target).a,$($(build_env)_goals)),$($x.target).a)) \
    $(foreach x,$(shared_lib_labels),$(if $(filter $x$(SFX) $($x.target) $($x.target).so,$($(build_env)_goals)),$($x.target).so))
endif

bold1 := $(shell setterm --bold on)
bold0 := $(shell setterm --bold off)


#### Main Targets ####
.PHONY: $(base_targets)

.DEFAULT_GOAL = $(DEFAULT_ENV)
all: $(DEFAULT_ENV)
tests: tests_$(DEFAULT_ENV)

define setup_env_targets  # <1:build env>
$1: $$($1_build_targets)
tests_$1: $$($1_tests)

clean_$1:
	@for D in "$$(BUILD_DIR)/$1" "$$(BUILD_DIR)/$1-pic"; do \
	  ([ -d "$$$$D" ] && echo "$$(bold1)Cleaning '$$$$D'$$(bold0)" && $$(RM) "$$$$D"/*.mk "$$$$D"/*.o "$$$$D"/__TEST* "$$$$D"/.compile_cmd* "$$$$D"/.link_cmd* && rmdir "$$$$D") || true; done

clean: clean_$1
endef
$(foreach x,$(env_names),$(eval $(call setup_env_targets,$x)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver"
	@([ -d "$(BUILD_DIR)" ] && rmdir -p "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA); do \
	  ([ -f "$$X" ] && echo "$(bold1)Removing '$$X'$(bold0)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach x,$(env_names),$($x_libs) $($x_bins)) core gmon.out $(CLOBBER_EXTRA); do \
	  ([ -f "$$X" ] && echo "$(bold1)Removing '$$X'$(bold0)" && $(RM) "$$X") || true; done
ifneq ($(lib_out),)
	@([ -d "$(lib_out)" ] && rmdir -p --ignore-fail-on-non-empty "$(lib_out)") || true
endif
ifneq ($(bin_out),)
	@([ -d "$(bin_out)" ] && rmdir -p --ignore-fail-on-non-empty "$(bin_out)") || true
endif

install: ; $(error Target 'install' not implemented)
install-strip: ; $(error Target 'install-strip' not implemented)

define make_subdir_target  # <1:target>
$1: _subdir_$1
.PHONY: _subdir_$1
_subdir_$1:
	@for D in $$(SUBDIRS); do \
	  ([ -d "$$$$D" ] && ($$(MAKE) -C "$$$$D" $1 || true)) || echo "$$(bold1)SUBDIRS: unknown directory '$$$$D' - skipping$$(bold0)"; done
endef
ifneq ($(strip $(SUBDIRS)),)
  $(foreach x,$(subdir_targets),$(eval $(call make_subdir_target,$x)))
endif


#### Unknown Target Handling ####
.SUFFIXES:
.DEFAULT: ; $(error $(if $(filter $<,$(all_source)),Missing source file '$<','$<' unknown))


#### Build Template Functions ####
define rebuild_check  # <1:trigger text> <2:trigger file>
ifneq ($1,$$(file <$2))
  $$(shell $$(RM) "$2")
endif
$2:
	@mkdir -p "$$(@D)"
	@echo "$1" >$2
endef

define make_static_lib  # <1:label> <2:path>
override $1.all_objs := $$(addprefix $2/,$$($1.src_objs)) $$($1.OBJS)
override $1.link_static_cmd := $$(AR) rv $$($1.target).a $$(strip $$($1.all_objs))
override $1.file := $2/.link_cmd-$1-static
$$(eval $$(call rebuild_check,$$$$($1.link_static_cmd),$$($1.file)))

$$($1.target) $1$$(SFX): $$($1.target).a
$$($1.target).a: $$($1.all_objs) $$($1.file)
ifneq ($$(lib_out),)
	@mkdir -p "$$(lib_out)"
endif
	-$$(RM) "$$@"
	$$($1.link_static_cmd)
	$$(RANLIB) "$$@"
	@echo "$$(bold1)Static library '$$@' built$$(bold0)"
endef

define make_shared_lib  # <1:label> <2:path>
override $1.all_objs := $$(addprefix $2/,$$($1.src_objs)) $$($1.OBJS)
override $1.link_shared_cmd := $$(link_cmd) -fPIC -shared $$(strip $$($1.all_objs) $$($1.LIBS) $$(LIBS)) -o '$$($1.target).so'
override $1.file := $2/.link_cmd-$1-shared
$$(eval $$(call rebuild_check,$$$$($1.link_shared_cmd),$$($1.file)))

$$($1.target) $1$$(SFX): $$($1.target).so
$$($1.target).so: $$($1.all_objs) $$($1.file)
ifneq ($$(lib_out),)
	@mkdir -p "$$(lib_out)"
endif
	$$($1.link_shared_cmd)
	@echo "$$(bold1)Shared library '$$@' built$$(bold0)"
endef

define make_bin  # <1:label> <2:path>
override $1.all_objs := $$(addprefix $2/,$$($1.src_objs)) $$($1.OBJS)
override $1.link_cmd := $$(link_cmd) $$(strip $$($1.all_objs) $$($1.LIBS) $$(LIBS)) -o '$$($1.target)'
override $1.file := $2/.link_cmd-$1
$$(eval $$(call rebuild_check,$$$$($1.link_cmd),$$($1.file)))

.PHONY: $1$$(SFX)
$1$$(SFX): $$($1.target)
$$($1.target): $$($1.all_objs) $$(lib_goals) $$($1.file)
ifneq ($$(bin_out),)
	@mkdir -p "$$(bin_out)"
endif
	$$($1.link_cmd)
	@echo "$$(bold1)Binary '$$@' built$$(bold0)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
define make_test  # <1:label> <2:path>
override $1.run := $2/__$1
override $1.all_objs := $$(addprefix $2/,$$($1.src_objs)) $$($1.OBJS)
override $1.link_cmd := $$(link_cmd) $$(strip $$($1.all_objs) $$($1.LIBS) $$(LIBS) $$(TEST_LIBS)) -o '$$($1.run)'
override $1.file := $2/.link_cmd-$1
$$(eval $$(call rebuild_check,$$$$($1.link_cmd),$$($1.file)))

$$($1.run): $$($1.all_objs) $$(lib_goals) $$($1.file)
	$$($1.link_cmd)
ifeq ($$(filter tests tests_$$(build_env) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1.run) $$($1.ARGS)
	@echo "$$(bold1)Test '$$($1)' passed$$(bold0)"
endif

.PHONY: $$($1) $1$$(SFX)
$$($1) $1$$(SFX): $$($1.run)
ifneq ($$(filter tests tests_$$(build_env) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1.run) $$($1.ARGS)
	@echo "$$(bold1)Test '$$($1)' passed$$(bold0)"
endif
endef


define make_obj  # <1:path> <2:source pattern> <3:compile cmd> <4:trigger file>
$$(eval $$(call rebuild_check,$3,$1/$4))
$1/%.o: $2 ; $3 -MMD -MP -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
endef

define make_dep  # <1:source file> <2:path> <3:trigger file>
$2/$(call src_base,$1).o: $1 $2/$3 $$(BUILD_DIR)/.compiler_ver
-include $2/$(call src_base,$1).mk
endef


#### Create Build Targets ####
.DELETE_ON_ERROR:
ifneq ($(build_env),)
  ifneq ($(strip $(PACKAGES)),)
    ifneq ($(words $(PACKAGES)),$(words $(pkgs)))
      $(error Cannot build because of 'PACKAGES' error)
    endif
  endif

  build_path := $(BUILD_DIR)/$(build_env)
  build_path_pic := $(build_path)-pic

  # .compiler_ver rule (rebuild trigger for compiler version upgrades)
  $(eval $(call rebuild_check,$(shell $(CC) --version | head -1),$(BUILD_DIR)/.compiler_ver))

  # make binary/library/test build targets
  .PHONY: $(foreach x,$(lib_labels),$($x) $x$(SFX))
  $(foreach x,$(static_lib_labels),$(eval $(call make_static_lib,$x,$(build_path))))
  $(foreach x,$(shared_lib_labels),$(eval $(call make_shared_lib,$x,$(build_path_pic))))

  $(foreach x,$(bin_labels),$(eval $(call make_bin,$x,$(build_path))))
  $(foreach x,$(test_labels),$(eval $(call make_test,$x,$(build_path))))

  # set generic .o/.mk rules for each build directory
  $(build_path)/%.mk $(build_path_pic)/%.mk: ; @$(RM) "$(@:.mk=.o)"
  $(eval $(call make_obj,$(build_path),%.c,$(compile_cmd_c),.compile_cmd_c))
  $(eval $(call make_obj,$(build_path_pic),%.c,$(compile_cmd_c) -fPIC,.compile_cmd_c))
  $(eval $(call make_obj,$(build_path),,$(compile_cmd),.compile_cmd))
  $(eval $(call make_obj,$(build_path_pic),,$(compile_cmd) -fPIC,.compile_cmd))

  # set base dependency rules for building each .o/.mk file and then
  #   include .mk files with header file dependency details
  # NOTE: rebuild trigger dependency is after the source file so the source
  #   file is always the first dependency of the object file ('$<' value)
  source := $(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$($x.SRC)))
  source_pic := $(sort $(foreach x,$(shared_lib_labels),$($x.SRC)))

  $(foreach x,$(filter %.c,$(source)),$(eval $(call make_dep,$x,$(build_path),.compile_cmd_c)))
  $(foreach x,$(filter %.c,$(source_pic)),$(eval $(call make_dep,$x,$(build_path_pic),.compile_cmd_c)))
  $(foreach x,$(filter-out %.c,$(source)),$(eval $(call make_dep,$x,$(build_path),.compile_cmd)))
  $(foreach x,$(filter-out %.c,$(source_pic)),$(eval $(call make_dep,$x,$(build_path_pic),.compile_cmd)))
endif

#### END ####
