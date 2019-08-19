#
# Makefile.mk - version 1.2 (2019/8/15)
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
#  LIB1.VERSION    major(.minor(.patch)) version of shared library 1
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
#  SYMLINKS        symlinks to the current dir to create for building
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
SYMLINKS ?=

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


#### Terminal Output ####
# term_fg1 - binary/library built
# term_fg2 - warning or removal notice
# term_fg3 - test passed
# term_fg4 - test failed, fatal error
override term_bold := $(shell setterm --bold on)
override term_fg0  := $(shell setterm --foreground default)
override term_fg1  := $(shell setterm --foreground cyan)
override term_fg2  := $(shell setterm --foreground magenta)
override term_fg3  := $(shell setterm --foreground green)
override term_fg4  := $(shell setterm --foreground red)
override term_info := $(term_bold)$(term_fg1)
override term_warn := $(term_bold)$(term_fg2)
override term_err  := $(term_bold)$(term_fg4)
override term_end  := $(shell setterm --default)


#### Compiler/Standard Specific Setup ####
ifeq ($(filter $(COMPILER),$(compiler_names)),)
  $(error $(term_err)COMPILER: unknown compiler$(term_end))
endif

CXX = $(or $($(COMPILER)_cxx),c++)
CC = $(or $($(COMPILER)_cc),cc)
AR = $(or $($(COMPILER)_ar),ar)
RANLIB = $(or $($(COMPILER)_ranlib),ranlib)

override valid_standards := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a
override standard_cc := $(filter $(STANDARD),$(valid_standards))
ifneq ($(standard_cc),)
  ifneq ($(words $(standard_cc)),1)
    $(error $(term_err)STANDARD: multiple C++ standards not allowed$(term_end))
  endif
  CXX += -std=$(standard_cc)
endif

override valid_standards_c := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18
override standard_c := $(filter $(STANDARD),$(valid_standards_c))
ifneq ($(standard_c),)
  ifneq ($(words $(standard_c)),1)
    $(error $(term_err)STANDARD: multiple C standards not allowed$(term_end))
  endif
  CC += -std=$(standard_c)
endif

ifneq ($(filter-out $(valid_standards) $(valid_standards_c),$(STANDARD)),)
  $(error $(term_err)STANDARD: unknown standard specified$(term_end))
endif


#### Package Handling ####
# syntax: PACKAGES = <pkg name>(:<min version>) ...
override pkg_n = $(word 1,$(subst :, ,$1))
override pkg_v = $(word 2,$(subst :, ,$1))
override check_pkgs =\
$(strip $(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call pkg_n,$x) $(if $(call pkg_v,$x),--atleast-version=$(call pkg_v,$x),--exists) && echo "1"),\
    $(call pkg_n,$x),\
    $(warning $(term_warn)$1: package '$(call pkg_n,$x)'$(if $(call pkg_v,$x), [version >= $(call pkg_v,$x)]) not found$(term_end)))))

ifneq ($(strip $(PACKAGES)),)
  override pkgs := $(call check_pkgs,PACKAGES)
  ifneq ($(pkgs),)
    override FLAGS += $(shell $(PKGCONF) $(pkgs) --cflags)
    override LIBS += $(shell $(PKGCONF) $(pkgs) --libs)
  endif
endif

ifneq ($(strip $(TEST_PACKAGES)),)
  override test_pkgs := $(call check_pkgs,TEST_PACKAGES)
  ifneq ($(test_pkgs),)
    override TEST_LIBS += $(shell $(PKGCONF) $(test_pkgs) --libs)
  endif
endif


#### Internal Calculated Values ####
# label_nums 1-99
override digits := 1 2 3 4 5 6 7 8 9
override label_nums := $(digits) $(foreach x,$(digits),$(addprefix $x,0 $(digits)))

override lib_labels := $(strip $(foreach x,$(label_nums),$(if $(LIB$x),LIB$x)))
override bin_labels := $(strip $(foreach x,$(label_nums),$(if $(BIN$x),BIN$x)))
override test_labels := $(strip $(foreach x,$(label_nums),$(if $(TEST$x),TEST$x)))
override all_labels := $(lib_labels) $(bin_labels) $(test_labels)

override subdir_targets := $(foreach x,$(env_names),$x tests_$x clean_$x) clobber install install-strip
override base_targets := all tests clean $(subdir_targets)

override define check_entry  # <1:label>
override $1 := $$(strip $$($1))
ifneq ($$(words $$($1)),1)
  $$(error $$(term_err)$1: spaces not allowed in name$$(term_end))
else ifneq ($$(filter $$($1),$$(base_targets) $$(foreach x,$$(env_names),$1$$($$x_sfx))),)
  $$(error $$(term_err)$1: name conflicts with existing target$$(term_end))
else ifeq ($$(strip $$($1.SRC)),)
  $$(error $$(term_err)$1.SRC: no source files specified$$(term_end))
else ifneq ($$(words $$($1.SRC)),$$(words $$(sort $$($1.SRC))))
  $$(error $$(term_err)$1.SRC: duplicate source files$$(term_end))
endif
endef
$(foreach x,$(all_labels),$(eval $(call check_entry,$x)))

override define check_bin_entry  # <1:bin label>
$$(foreach x,$$(filter-out %.SRC %.OBJS %.LIBS,$$(filter $1.%,$$(.VARIABLES))),$$(warning $$(term_warn)Unknown binary paramater: $$x$$(term_end)))
endef
$(foreach x,$(bin_labels),$(eval $(call check_bin_entry,$x)))

override define check_lib_entry  # <1:lib label>
$$(foreach x,$$(filter-out %.TYPE %.SRC %.OBJS %.LIBS %.VERSION,$$(filter $1.%,$$(.VARIABLES))),$$(warning $$(term_warn)Unknown library paramater: $$x$$(term_end)))
ifneq ($$(filter %.a %.so,$$($1)),)
  $$(error $$(term_err)$1: library names should not be specified with an extension$$(term_end))
else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
  $$(error $$(term_err)$1.TYPE: only 'static' and/or 'shared' allowed$$(term_end))
else ifeq ($$(strip $$($1.TYPE)),)
  $1.TYPE = static
endif
endef
$(foreach x,$(lib_labels),$(eval $(call check_lib_entry,$x)))

override define check_test_entry  # <1:test label>
$$(foreach x,$$(filter-out %.ARGS %.SRC %.OBJS %.LIBS,$$(filter $1.%,$$(.VARIABLES))),$$(warning $$(term_warn)Unknown test paramater: $$x$$(term_end)))
endef
$(foreach x,$(test_labels),$(eval $(call check_test_entry,$x)))

override all_names := $(foreach x,$(all_labels),$($x))
ifneq ($(words $(all_names)),$(words $(sort $(all_names))))
  $(error $(term_err)Duplicate binary/library/test names$(term_end))
endif

# macro to encode path as part of name and remove extension
override src_base = $(subst /,__,$(basename $1))

override all_source := $(sort $(foreach x,$(all_labels),$($x.SRC)))
override all_source_base := $(call src_base,$(all_source))
ifneq ($(words $(all_source_base)),$(words $(sort $(all_source_base))))
  $(error $(term_err)Conflicting source files - each basename must be unique$(term_end))
endif

ifeq ($(filter $(DEFAULT_ENV),$(env_names)),)
  $(error $(term_err)DEFAULT_ENV: invalid value$(term_end))
endif
MAKECMDGOALS ?= $(DEFAULT_ENV)

ifneq ($(words $(BUILD_DIR)),1)
  $(error $(term_err)BUILD_DIR: spaces not allowed$(term_end))
endif

override static_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter static,$($x.TYPE)),$x)))
override shared_lib_labels := $(strip $(foreach x,$(lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))
override lib_out := $(if $(LIB_OUTPUT_DIR),$(LIB_OUTPUT_DIR:%/=%)/)
override bin_out := $(if $(BIN_OUTPUT_DIR),$(BIN_OUTPUT_DIR:%/=%)/)

# environment specific setup
override define setup_env  # <1:build env>
override $1_libs :=\
  $$(foreach x,$$(static_lib_labels),$$(lib_out)$$($$x)$$($1_sfx).a)\
  $$(foreach x,$$(shared_lib_labels),$$(lib_out)$$($$x)$$($1_sfx).so$$(if $$($$x.VERSION),.$$($$x.VERSION)))
override $1_bins := $$(foreach x,$$(bin_labels),$$(bin_out)$$($$x)$$($1_sfx))
override $1_tests := $$(foreach x,$$(test_labels),$$($$x)$$($1_sfx))
override $1_build_targets := $$($1_libs) $$($1_bins) $$($1_tests)
override $1_aliases :=\
  $$(foreach x,$$(all_labels),$$x$$($1_sfx))\
  $$(foreach x,$$(lib_labels),$$($$x)$$($1_sfx))\
  $$(if $$(lib_out),$$(foreach x,$$(static_lib_labels),$$($$x)$$($1_sfx).a))\
  $$(foreach x,$$(shared_lib_labels),\
    $$(if $$(or $$(lib_out),$$($$x.VERSION)),$$($$x)$$($1_sfx).so))\
  $$(if $$(bin_out),$$(foreach x,$$(bin_labels),$$($$x)$$($1_sfx)))
override $1_goals :=\
  $$(sort\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),all) $1,$$(MAKECMDGOALS)),$$($1_build_targets))\
    $$(if $$(filter $$(if $$(filter $1,$$(DEFAULT_ENV)),tests) tests_$1,$$(MAKECMDGOALS)),$$($1_tests))\
    $$(filter $$($1_build_targets) $$($1_aliases),$$(MAKECMDGOALS)))
override $1_links :=\
  $$(foreach x,$$(shared_lib_labels),\
    $$(if $$($$x.VERSION),$$(lib_out)$$($$x)$$($1_sfx).so)\
    $$(if $$(word 2,$$(subst ., ,$$($$x.VERSION))),\
      $$(lib_out)$$($$x)$$($1_sfx).so.$$(word 1,$$(subst ., ,$$($$x.VERSION)))))
endef
$(foreach x,$(env_names),$(eval $(call setup_env,$x)))

override build_env := $(strip $(foreach x,$(env_names),$(if $($x_goals),$x)))
ifeq ($(filter 0 1,$(words $(build_env))),)
  $(error $(term_err)Targets in multiple environments not allowed$(term_end))
else ifneq ($(build_env),)
  override SFX := $($(build_env)_sfx)

  CXXFLAGS = $(WARN) $($(build_env)_flags) $(DEFINE) $(INCLUDE) $(FLAGS)
  CFLAGS = $(WARN_C) $($(build_env)_flags) $(DEFINE) $(INCLUDE) $(FLAGS)
  LDFLAGS = -Wl,--as-needed -L$(or $(lib_out),.)

  override build_path := $(BUILD_DIR)/$(build_env)
  override build_path_pic := $(build_path)-pic

  # generate target values based on environment/output dir
  $(foreach x,$(all_labels),\
    $(eval override $$x_src_objs := $$(addsuffix .o,$$(call src_base,$$($$x.SRC)))))
  $(foreach x,$(bin_labels),\
    $(eval override $$x_name := $$(bin_out)$$($$x)$$(SFX))\
    $(eval override $$x_targets := $$x$$(SFX) $$(if $$(bin_out),$$($$x)$$(SFX))))
  $(foreach x,$(static_lib_labels),\
    $(eval override $$x_static_name := $$(lib_out)$$($$x)$$(SFX).a)\
    $(eval override $$x_static_targets := $$x$$(SFX) $$($$x)$$(SFX) $$(if $$(lib_out),$$($$x)$$(SFX).a)))
  $(foreach x,$(shared_lib_labels),\
    $(eval override $$x_shared_lib := $$($$x)$$(SFX).so)\
    $(eval override $$x_shared_lib_ver := $$($$x_shared_lib)$$(if $$($$x.VERSION),.$$($$x.VERSION)))\
    $(eval override $$x_shared_name := $$(lib_out)$$($$x_shared_lib_ver))\
    $(eval override $$x_shared_targets := $$x$$(SFX) $$($$x)$$(SFX) $$(if $$(or $$(lib_out),$$($$x.VERSION)),$$($$x_shared_lib))))
  $(foreach x,$(test_labels),\
    $(eval override $$x_targets := $$x$$(SFX) $$($$x)$$(SFX))\
    $(eval override $$x_run := $$(build_path)/__$$x))

  # binaries depend on lib goals to make sure libs are built first
  override lib_goals :=\
    $(foreach x,$(static_lib_labels),$(if $(filter $($x_static_targets) $($x_static_name),$($(build_env)_goals)),$($x_static_name)))\
    $(foreach x,$(shared_lib_labels),$(if $(filter $($x_shared_targets) $($x_shared_name),$($(build_env)_goals)),$($x_shared_name)))
  # tests depend on lib & bin goals to make sure they always build/run last
  override bin_goals :=\
    $(foreach x,$(bin_labels),$(if $(filter $($x_targets) $($x_name),$($(build_env)_goals)),$($x_name)))
  # if tests are a stated target, build all test binaries before running them
  override test_goals :=\
    $(foreach x,$(test_labels),$(if $(filter $($x_targets) tests tests_$(build_env) $(build_env),$(MAKECMDGOALS)),$($x_run)))
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
	@for D in "$$(BUILD_DIR)/$1" "$$(BUILD_DIR)/$1-pic"; do\
	  ([ -d "$$$$D" ] && echo "$$(term_warn)Cleaning '$$$$D'$$(term_end)" && $$(RM) "$$$$D"/*.mk "$$$$D"/*.o "$$$$D"/__TEST* "$$$$D"/.compile_cmd* "$$$$D"/.link_cmd* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach x,$(env_names),$(eval $(call setup_env_targets,$x)))

clean:
	@$(RM) "$(BUILD_DIR)/.compiler_ver" "$(BUILD_DIR)/.packages_ver" "$(BUILD_DIR)/.test_packages_ver" $(foreach x,$(SYMLINKS),"$x")
	@([ -d "$(BUILD_DIR)" ] && rmdir -p -- "$(BUILD_DIR)") || true
	@for X in $(CLEAN_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(term_warn)Removing '$$X'$(term_end)" && $(RM) "$$X") || true; done

clobber: clean
	@for X in $(foreach x,$(env_names),$($x_libs) $($x_links) $($x_bins)) core gmon.out $(CLOBBER_EXTRA); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(term_warn)Removing '$$X'$(term_end)" && $(RM) "$$X") || true; done
ifneq ($(lib_out),)
	@([ -d "$(lib_out)" ] && rmdir -p --ignore-fail-on-non-empty -- "$(lib_out)") || true
endif
ifneq ($(bin_out),)
	@([ -d "$(bin_out)" ] && rmdir -p --ignore-fail-on-non-empty -- "$(bin_out)") || true
endif

install: ; $(error $(term_err)Target 'install' not implemented$(term_end))
install-strip: ; $(error $(term_err)Target 'install-strip' not implemented$(term_end))

override define make_subdir_target  # <1:target>
$1: _subdir_$1
.PHONY: _subdir_$1
_subdir_$1:
	@for D in $$(SUBDIRS); do\
	  ([ -d "$$$$D" ] && ($$(MAKE) -C "$$$$D" $1 || true)) || echo "$$(term_warn)SUBDIRS: unknown directory '$$$$D' - skipping$$(term_end)"; done
endef
ifneq ($(strip $(SUBDIRS)),)
  $(foreach x,$(subdir_targets),$(eval $(call make_subdir_target,$x)))
endif


#### Unknown Target Handling ####
.SUFFIXES:
.DEFAULT: ; $(error $(term_err)$(if $(filter $<,$(all_source)),Missing source file '$<','$<' unknown)$(term_end))


#### Build Functions ####
override define rebuild_check  # <1:trigger text> <2:trigger file>
ifneq ($1,$$(file <$2))
  $$(shell $$(RM) "$2")
endif
$2:
	@mkdir -p "$$(@D)"
	@echo -n "$1" >$2
endef

# static library build
override define make_static_lib  # <1:label> <2:path>
override $1_static_objs := $$(addprefix $2/,$$($1_src_objs)) $$($1.OBJS)
override $1_static_link_cmd := $$(AR) rv '$$($1_static_name)' $$(strip $$($1_static_objs))
override $1_static_file := $2/.link_cmd-$1-static
$$(eval $$(call rebuild_check,$$$$($1_static_link_cmd),$$$$($1_static_file)))

$$($1_static_targets): $$($1_static_name)
$$($1_static_name): $$($1_static_objs) $$($1_static_file)
ifneq ($$(lib_out),)
	@mkdir -p "$$(lib_out)"
endif
	-$$(RM) "$$@"
	$$($1_static_link_cmd)
	$$(RANLIB) "$$@"
	@echo "$$(term_info)Static library '$$@' built$$(term_end)"
endef

# shared library build
override define make_shared_lib  # <1:label> <2:path>
override $1_shared_objs := $$(addprefix $2/,$$($1_src_objs)) $$($1.OBJS)
override $1_shared_link_cmd := $$(link_cmd) -fPIC -shared $$(strip $$($1_shared_objs) $$($1.LIBS) $$(LIBS)) -o '$$($1_shared_name)'
override $1_shared_file := $2/.link_cmd-$1-shared
$$(eval $$(call rebuild_check,$$$$($1_shared_link_cmd),$$$$($1_shared_file)))

$$($1_shared_targets): $$($1_shared_name)
$$($1_shared_name): $$($1_shared_objs) $$($1_shared_file)
ifneq ($$(lib_out),)
	@mkdir -p "$$(lib_out)"
endif
	$$($1_shared_link_cmd)
ifneq ($$($1.VERSION),)
	ln -sf "$$($1_shared_lib_ver)" "$$(lib_out)$$($1_shared_lib)"
ifneq ($$(word 2,$$(subst ., ,$$($1.VERSION))),)
	ln -sf "$$($1_shared_lib_ver)" "$$(lib_out)$$($1_shared_lib).$$(word 1,$$(subst ., ,$$($1.VERSION)))"
endif
endif
	@echo "$$(term_info)Shared library '$$@' built$$(term_end)"
endef

# binary build
override define make_bin  # <1:label> <2:path>
override $1_all_objs := $$(addprefix $2/,$$($1_src_objs)) $$($1.OBJS)
override $1_link_cmd := $$(link_cmd) $$(strip $$($1_all_objs) $$($1.LIBS) $$(LIBS)) -o '$$($1_name)'
override $1_file := $2/.link_cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_link_cmd),$$$$($1_file)))

.PHONY: $$($1_targets)
$$($1_targets): $$($1_name)
$$($1_name): $$($1_all_objs) $$($1_file) | $$(lib_goals)
ifneq ($$(bin_out),)
	@mkdir -p "$$(bin_out)"
endif
	$$($1_link_cmd)
	@echo "$$(term_info)Binary '$$@' built$$(term_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define make_test  # <1:label> <2:path>
override $1_all_objs := $$(addprefix $2/,$$($1_src_objs)) $$($1.OBJS)
override $1_link_cmd := $$(link_cmd) $$(strip $$($1_all_objs) $$($1.LIBS) $$(LIBS) $$(TEST_LIBS)) -o '$$($1_run)'
override $1_file := $2/.link_cmd-$1
$$(eval $$(call rebuild_check,$$$$($1_link_cmd),$$$$($1_file)))

$$($1_run): $$($1_all_objs) $$($1_file) $$(BUILD_DIR)/.test_packages_ver | $$(lib_goals) $$(bin_goals)
	$$($1_link_cmd)
ifeq ($$(filter tests tests_$$(build_env) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1_run) $$($1.ARGS);\
	EXIT_STATUS=$$$$?;\
	if [[ $$$$EXIT_STATUS -eq 0 ]]; then echo "$$(term_bold) [ $$(term_fg3)PASSED$$(term_fg0) ] - $1$$(SFX) '$$($1)'$$(term_end)"; else echo "$$(term_bold) [ $$(term_fg4)FAILED$$(term_fg0) ] - $1$$(SFX) '$$($1)'$$(term_end)"; exit $$$$EXIT_STATUS; fi
endif

.PHONY: $$($1_targets)
$$($1_targets): $$($1_run) | $$(test_goals)
ifneq ($$(filter tests tests_$$(build_env) $1 $$($1),$$(MAKECMDGOALS)),)
	@LD_LIBRARY_PATH=.:$$$$LD_LIBRARY_PATH ./$$($1_run) $$($1.ARGS);\
	if [[ $$$$? -eq 0 ]]; then echo "$$(term_bold) [ $$(term_fg3)PASSED$$(term_fg0) ] - $1$$(SFX) '$$($1)'$$(term_end)"; else echo "$$(term_bold) [ $$(term_fg4)FAILED$$(term_fg0) ] - $1$$(SFX) '$$($1)'$$(term_end)"; $$(RM) "$$($1_run)"; fi
endif
endef


override define make_dep  # <1:path> <2:source file> <3:trigger file>
$1/$(call src_base,$2).o: $2 $1/$3 $$(BUILD_DIR)/.compiler_ver $$(BUILD_DIR)/.packages_ver | $$(SYMLINKS)
-include $1/$(call src_base,$2).mk
endef

override define make_obj # <1:path> <2:c cmd> <3:c++ cmd> <4:source files>
ifneq ($4,)
$1/%.mk: ; @$$(RM) "$$(@:.mk=.o)"

$$(eval $$(call rebuild_check,$2,$1/.compile_cmd_c))
$1/%.o: %.c ; $2 -MMD -MP -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter %.c,$4),$$(eval $$(call make_dep,$1,$x,.compile_cmd_c)))

$$(eval $$(call rebuild_check,$3,$1/.compile_cmd))
$1/%.o: ; $3 -MMD -MP -MF '$$(@:.o=.mk)' -c -o '$$@' $$<
$(foreach x,$(filter-out %.c,$4),$$(eval $$(call make_dep,$1,$x,.compile_cmd)))
endif
endef


#### Create Build Targets ####
.DELETE_ON_ERROR:
ifneq ($(build_env),)
  ifneq ($(strip $(PACKAGES)),)
    ifneq ($(words $(PACKAGES)),$(words $(pkgs)))
      $(error $(term_err)Cannot build because of 'PACKAGES' error$(term_end))
    endif
  endif

  # symlink creation rule
  $(foreach x,$(SYMLINKS),$(eval $x: ; @ln -s . "$x"))

  # .compiler_ver rule (rebuild trigger for compiler version upgrades)
  $(eval $(call rebuild_check,$(shell $(CC) --version | head -1),$(BUILD_DIR)/.compiler_ver))

  # .packages_ver rule (rebuild trigger for package version changes)
  $(eval $(call rebuild_check,$(foreach x,$(pkgs),$x:$(shell $(PKGCONF) --modversion $x)),$(BUILD_DIR)/.packages_ver))

  # .test_packages_ver rule (relink trigger for test binaries)
  $(eval $(call rebuild_check,$(foreach x,$(test_pkgs),$x:$(shell $(PKGCONF) --modversion $x)),$(BUILD_DIR)/.test_packages_ver))

  # make binary/library/test build targets
  override link_cmd := $(strip $(CXX) $(CXXFLAGS) $(LDFLAGS))
  .PHONY: $(sort $(foreach x,$(lib_labels),$($x_static_targets) $($x_shared_targets)))
  $(foreach x,$(static_lib_labels),$(eval $(call make_static_lib,$x,$(build_path))))
  $(foreach x,$(shared_lib_labels),$(eval $(call make_shared_lib,$x,$(build_path_pic))))
  $(foreach x,$(bin_labels),$(eval $(call make_bin,$x,$(build_path))))
  $(foreach x,$(test_labels),$(eval $(call make_test,$x,$(build_path))))

  # make .o/.mk files for each build path
  override compile_c := $(strip $(CC) $(CFLAGS))
  override compile_cxx := $(strip $(CXX) $(CXXFLAGS))
  $(eval $(call make_obj,$(build_path),$(compile_c),$(compile_cxx),$(sort $(foreach x,$(static_lib_labels) $(bin_labels) $(test_labels),$($x.SRC)))))
  $(eval $(call make_obj,$(build_path_pic),$(compile_c) -fPIC,$(compile_cxx) -fPIC,$(sort $(foreach x,$(shared_lib_labels),$($x.SRC)))))
endif

#### END ####
