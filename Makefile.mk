#
# Makefile.mk - version 2.6 (2024/2/16)
# Copyright (C) 2024 Richard Bradley
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
# In addition, the following restrictions apply:
#
# 1. The Software and any modifications made to it may not be used for the
# purpose of training or improving machine learning algorithms, including but
# not limited to artificial intelligence, natural language processing, or data
# mining. This condition applies to any derivatives, modifications, or updates
# based on the Software code. Any usage of the Software in an AI-training
# dataset is considered a breach of this License.
#
# 2. The Software may not be included in any dataset used for training or
# improving machine learning algorithms, including but not limited to
# artificial intelligence, natural language processing, or data mining.
#
# 3. Any person or organization found to be in violation of these restrictions
# will be subject to legal action and may be held liable for any damages
# resulting from such use.
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
#  .gitignore      prints a sample .gitignore file for all targets
#  help            prints command summary
#
# Makefile Parameters:
#  BIN<1-99>       name of binary to build
#  BIN1.SRC        source files for binary 1
#                  (C++/C/Assembly/WindowsRC source files, no headers)
#  BIN1.OBJS       additional binary 1 object dependencies (.o/.a files)
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
#                  use of other vars (BUILD_TMP,DEP1,OUT,etc.) must be escaped
#  TEMPLATE1.FILE1 values used for 'FILE1' creation
#                  referenced by $(VALS) or $(VAL1),$(VAL2),etc. in template
#
#  TEST<1-999>     unit test description (optional)
#  TEST1.ARGS      arguments for running test 1 binary
#  TEST1.SRC       source files for unit test 1
#  TEST1.OBJS      additional unit test 1 object dependencies
#  TEST1.DEPS      additional dependencies for building all test 1 objects
#
#  COMPILER        compiler to use (gcc/clang)
#  LINKER          linker to use instead of default (bfd/gold/lld/mold)
#  CROSS_COMPILE   binutils and gcc toolchain prefix (i.e. arm-linux-gnueabi-)
#  STANDARD        language standard(s) of source code
#  OPT_LEVEL       optimization level for release & profile builds
#  OPT_LEVEL_DEBUG optimization level for debug builds
#  SUBSYSTEM       subsystem value for Windows binary builds
#  WARN            C/C++ compile warning flags (-W optional)
#  WARN_C          C specific warnings (defaults to WARN or C specific list)
#  WARN_CXX        C++ specific warnings (defaults to WARN or C++ specific list)
#  PACKAGES        list of packages for pkg-config
#  PACKAGES_TEST   additional packages for all tests
#  INCLUDE         includes needed not covered by pkg-config (-I optional)
#  INCLUDE_TEST    additional includes for all tests (-I optional)
#  LIBS            libraries needed not covered by pkg-config (-l optional)
#  LIBS_TEST       additional libs for all tests (-l optional)
#  DEFINE          defines for compilation (-D optional)
#  DEFINE_TEST     additional defines for all tests (-D optional)
#  OPTIONS         list of options to enable - use instead of specific flags
#    warn_error    make all compiler warnings into errors
#    pthread       compile with pthreads support
#    lto           enable link-time optimization
#    modern_c++    enable warnings for some old-style C++ syntax (pre C++11)
#    no_rtti       disable C++ RTTI
#    no_except     disable C++ exceptions
#    pedantic      enforces strict ISO C/C++ compliance
#    static_rtlib  statically link with runtime library (libgcc usually)
#    static_stdlib statically link with C++ standard library (libstdc++ usually)
#    mapfile       generate a link map file for binaries & shared libraries
#  OPTIONS_TEST    additional options for all tests
#  FLAGS           additional compiler flags not otherwise specified
#  FLAGS_TEST      additional compiler flags for all tests
#  FLAGS_RELEASE   additional compiler flags for release builds
#  FLAGS_DEBUG     additional compiler flags for debug builds
#  FLAGS_PROFILE   additional compiler flags for profile builds
#  RPATH           directories to search for shared library loading
#  LINK_FLAGS      additional linking flags not otherwise specified
#  *_EXTRA         available for most settings to provide additional values
#
#  <OS>.<VAR>      set WINDOWS/LINUX specific value for any setting
#                  (overrides non-OS specified value)
#
#  BUILD_DIR       directory for generated object/prerequisite files
#  DEFAULT_ENV     default environment to build (release/debug/profile)
#  OUTPUT_DIR      default output directory (defaults to current directory)
#  OUTPUT_BIN_DIR  directory for generated binaries (defaults to OUTPUT_DIR)
#  OUTPUT_LIB_DIR  directory for generated libraries (defaults to OUTPUT_DIR)
#  CLEAN_EXTRA     extra files to delete for 'clean' target
#  CLOBBER_EXTRA   extra files to delete for 'clobber' target
#  SUBDIRS         sub-directories to also make with base targets
#  SYMLINKS        symlinks to create for building
#                  (list of <name> OR <name>=<target>; default target is '.')
#  SOURCE_DIR      source files base directory
#  EXCLUDE_TARGETS labels/files not built by default (wildcard '*' allowed)
#
#  Settings STANDARD/OPT_LEVEL/OPT_LEVEL_DEBUG/SUBSYSTEM/PACKAGES/INCLUDE/
#    LIBS/DEFINE/OPTIONS/FLAGS/RPATH/LINKER/LINK_FLAGS/SOURCE_DIR/
#    WARN/WARN_C/WARN_CXX can be set for specific targets to override global
#    values (ex.: BIN1.FLAGS = -pthread).
#    A value of '-' can be used to clear the setting for the target
#    (note that FLAGS_RELEASE/FLAGS_DEBUG/FLAGS_PROFILE are always applied)
#
#  Filename wildcards '*' or '**'(directory hierarchy search) supported
#    for .SRC/.DEPS/.OBJS/CLEAN_EXTRA/CLOBBER_EXTRA settings
#
#  <X>.LIBS/<X>.OBJS can accept LIB labels of library targets. Library
#    LIBS/PACKAGES/binary will automatically be used in target building.
#    LIBS will perfer shared library for linking if available, OBJS will only
#    allow linking with static libraries.
#    ex.: BIN1.LIBS = LIB1
#
#  <X>.DEPS can accept BIN labels of binary targets. This can be used to make
#    sure a binary is built before a file target command (that requires the
#    binary) is executed.
#    ex.: FILE1.DEPS = BIN1 data_file.txt
#         FILE1.CMD = ./$(DEP1) $(DEP2)
#
#  <X>.SRC2 can be used where <X>.SRC is allowed to specify source for a target
#    that doesn't use SOURCE_DIR for location.
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


#### Default Make Flags ####
ifneq ($(shell which nproc 2>/dev/null),)
  override _threads := $(shell nproc)
  override GNUMAKEFLAGS += --load-average=$(_threads)
endif


#### OS Specific Values ####
override _uname := $(shell uname -s | tr A-Z a-z)
override _windows := $(filter cygwin% mingw% msys%,$(_uname))
override _linux := $(filter linux%,$(_uname))
override _pic_flag := $(if $(_windows),,-fPIC)
override _libprefix := $(if $(filter cygwin%,$(_uname)),cyg,$(if $(filter msys%,$(_uname)),msys-,lib))
override _libext := .$(if $(_windows),dll,so)
override _binext := $(if $(_windows),.exe)
ifneq ($(_windows),)
  $(foreach x,$(filter WINDOWS.%,$(.VARIABLES)),\
    $(eval override $(patsubst WINDOWS.%,%,$x) = $(value $x)))
else ifneq ($(_linux),)
  $(foreach x,$(filter LINUX.%,$(.VARIABLES)),\
    $(eval override $(patsubst LINUX.%,%,$x) = $(value $x)))
endif


#### Basic Settings ####
OPT_LEVEL ?= 3
OPT_LEVEL_DEBUG ?= g
BUILD_DIR ?= build

ifneq ($(strip $(WARN)),-)
  ifneq ($(strip $(WARN)),)
    # override default warnings
    WARN_C ?= $(WARN)
    WARN_CXX ?= $(WARN)
  else
    # default warnings
    override _common_warn := all extra missing-include-dirs no-unused-parameter
    WARN_C ?= $(_common_warn) write-strings $(_$(_compiler)_warn)
    WARN_CXX ?= $(_common_warn) non-virtual-dtor overloaded-virtual $(_$(_compiler)_warn)
  endif
endif

# default values to be more obvious if used/handled improperly
override ENV := ENV_NOT_SET
override SFX := SFX_NOT_SET
override BUILD_TMP := BUILD_TMP_NOT_SET
override LIBPREFIX := lib

# apply *_EXTRA setting values
# (CLEAN_EXTRA/CLOBBER_EXTRA/WARN_EXTRA handled elsewhere)
$(foreach x,WARN_C WARN_CXX PACKAGES PACKAGES_TEST INCLUDE INCLUDE_TEST LIBS LIBS_TEST DEFINE DEFINE_TEST OPTIONS OPTIONS_TEST FLAGS FLAGS_TEST FLAGS_RELEASE FLAGS_DEBUG FLAGS_PROFILE RPATH LINK_FLAGS EXCLUDE_TARGETS,\
  $(if $(strip $($x_EXTRA)),$(eval override $x += $($x_EXTRA))))

# prevent duplicate options being applied to tests
override OPTIONS_TEST := $(filter-out $(OPTIONS),$(OPTIONS_TEST))


#### Terminal Output ####
# _fg1 - binary/library built
# _fg2 - warning or removal notice
# _fg3 - test passed
# _fg4 - test failed or fatal error
ifneq ($(and $(MAKE_TERMOUT),$(MAKE_TERMERR)),)
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
endif


#### Environment Details ####
override _env_names := release debug profile
override _default_env := $(or $(strip $(DEFAULT_ENV)),$(firstword $(_env_names)))
ifeq ($(filter $(_default_env),$(_env_names)),)
  $(error $(_msgErr)DEFAULT_ENV: invalid value$(_end))
endif
MAKECMDGOALS ?= $(_default_env)

override _opt_lvl = $(or $(strip $($1.OPT_LEVEL)),$(strip $(OPT_LEVEL)))
override _debug_opt_lvl = $(or $(strip $($1.OPT_LEVEL_DEBUG)),$(strip $(OPT_LEVEL_DEBUG)))

override _release_uc := RELEASE
override _release_sfx :=
override _release_opt = $(if $(_opt_lvl),-O$(_opt_lvl))
override _debug_uc := DEBUG
override _debug_sfx := -g
override _debug_opt = -g $(if $(_debug_opt_lvl),-O$(_debug_opt_lvl))
override _profile_uc := PROFILE
override _profile_sfx := -pg
override _profile_opt = -pg $(if $(_opt_lvl),-O$(_opt_lvl))


#### Compiler Details ####
override _compiler_names := gcc clang
override _modern_flags := -Wzero-as-null-pointer-constant -Wregister -Wold-style-cast

override _gcc_cxx := g++
override _gcc_cc := gcc
override _gcc_as := gcc -x assembler-with-cpp
override _gcc_ar := gcc-ar
override _gcc_warn := shadow=local
override _gcc_modern := $(_modern_flags) -Wsuggest-override

override _clang_cxx := clang++
override _clang_cc := clang
override _clang_as := clang -x assembler-with-cpp
override _clang_ar := llvm-ar
override _clang_ld := lld
override _clang_warn := shadow
override _clang_modern := $(_modern_flags) -Winconsistent-missing-override

# compiler source file patterns
override _cxx_ptrn := %.cc %.cp %.cxx %.cpp %.CPP %.c++ %.C
override _c_ptrn := %.c
override _asm_ptrn := %.s %.S %.sx
override _rc_ptrn := %.rc

# source files to ignore
override _src_filter := $(if $(_windows),,$(_rc_ptrn))\
  %.h %.hh %.H %.hp %.hxx %.hpp %.HPP %.h++ %.tcc

# compiler allowed standards
override _c_stds := c90 gnu90 c99 gnu99 c11 gnu11 c17 gnu17 c18 gnu18 c2x gnu2x c23 gnu23
override _cxx_stds := c++98 gnu++98 c++03 gnu++03 c++11 gnu++11 c++14 gnu++14 c++17 gnu++17 c++2a gnu++2a c++20 gnu++20 c++2b gnu++2b c++23 gnu++23 c++2c gnu++2c c++26 gnu++26

# compiler functions
override define _check_compiler # <1:compiler name var>
  ifneq ($$(strip $$($1)),)
    ifeq ($$(filter $$($1),$$(_compiler_names)),)
      $$(error $$(_msgErr)$1: unsupported compiler '$$($1)'$$(_end))
    endif
  endif
endef

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
$(foreach x,$($1),\
  $(if $(shell $(PKGCONF) $(call _pkg_n,$x) $(if $(call _pkg_v,$x),--atleast-version=$(call _pkg_v,$x),--exists) && echo '1'),\
    $(call _pkg_n,$x),\
    $(warning $(_msgWarn)$1: package '$(call _pkg_n,$x)'$(if $(call _pkg_v,$x), [version >= $(call _pkg_v,$x)]) not found$(_end))))

override _get_pkg_flags = $(if $1,$(shell $(PKGCONF) $1 --cflags))
override _get_pkg_libs = $(if $1,$(shell $(PKGCONF) $1 --libs))

override define _verify_pkgs  # <1:config pkgs var> <2:valid pkgs>
  ifeq ($$(strip $$($1)),)
  else ifeq ($$(strip $$($1)),-)
  else ifneq ($$(words $$($1)),$$(words $$($2)))
    $$(error $$(_msgErr)Cannot build because of package error$$(_end))
  endif
endef


#### OPTIONS handling ####
override _op_list := warn_error pthread lto modern_c++ no_rtti no_except pedantic static_rtlib static_stdlib mapfile

override define _check_options  # <1:options var> <2:set prefix>
  ifneq ($$(strip $$($1)),)
    ifneq ($$(filter-out $$(_op_list),$$($1)),)
      $$(error $$(_msgErr)$1: unknown '$$(filter-out $$(_op_list),$$($1))'$$(_end))
    endif
    override $2_warn :=\
      $$(if $$(filter warn_error,$$($1)),-Werror)\
      $$(if $$(filter pedantic,$$($1)),-Wpedantic)
    override $2_flags :=\
      $$(if $$(filter pthread,$$($1)),-pthread)\
      $$(if $$(filter lto,$$($1)),-flto=auto)\
      $$(if $$(filter pedantic,$$($1)),-pedantic-errors)
    override $2_link :=\
      $$(if $$(filter static_rtlib,$$($1)),-static-libgcc)
    override $2_cxx_warn := $$($2_warn)\
      $$(if $$(filter modern_c++,$$($1)),$$(_$(_compiler)_modern))
    override $2_cxx_flags := $$($2_flags)\
      $$(if $$(filter no_rtti,$$($1)),-fno-rtti)\
      $$(if $$(filter no_except,$$($1)),-fno-exceptions)
    override $2_cxx_link := $$($2_link)\
      $$(if $$(filter static_stdlib,$$($1)),-static-libstdc++)
  endif
endef


#### Internal Calculated Values ####
override _comma := ,
override _1-9 := 1 2 3 4 5 6 7 8 9
override _10-99 := $(foreach x,$(_1-9),$(addprefix $x,0 $(_1-9)))
override _1-99 := $(_1-9) $(_10-99)
override _1-999 := $(_1-99) $(foreach x,$(_1-9),$(addprefix $x,$(addprefix 0,0 $(_1-9)) $(_10-99)))

# TEMPLATE<1-99>, TEMPLATE_<id> labels
override _template_labels1 := $(filter $(sort $(foreach x,$(filter TEMPLATE%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix TEMPLATE,$(_1-99)))
override _template_labels2 := $(sort $(foreach x,$(filter TEMPLATE_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
override _template_labels := $(strip $(_template_labels1) $(_template_labels2))

# verify template configs
override define _check_template_entry  # <1:label>
  override _$1_labels := $$(subst $1.,,$$(filter $1.FILE%,$$(.VARIABLES)))
  ifeq ($$(_$1_labels),)
    $$(error $$(_msgErr)$1: no FILE entries$$(_end))
  else ifeq ($$(strip $$($1)),)
    $$(error $$(_msgErr)$1 required$$(_end))
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
override _static_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $($x.TYPE),$(if $(filter static,$($x.TYPE)),$x),$x)))
override _shared_lib_labels := $(strip $(foreach x,$(_lib_labels),$(if $(filter shared,$($x.TYPE)),$x)))

# BIN<1-99>, BIN_<id> labels (<id> is the default target)
override _bin_labels1 := $(filter $(sort $(foreach x,$(filter BIN%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix BIN,$(_1-99)))
override _bin_labels2 := $(sort $(foreach x,$(filter BIN_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
$(foreach x,$(_bin_labels2),$(eval $x ?= $(subst BIN_,,$x)))
override _bin_labels := $(strip $(_bin_labels1) $(_bin_labels2))

# FILE<1-999>, FILE_<id> labels
override _file_labels1 := $(filter $(sort $(foreach x,$(filter FILE%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix FILE,$(_1-999)))
override _file_labels2 := $(sort $(foreach x,$(filter FILE_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
override _file_labels := $(strip $(_file_labels1) $(_file_labels2))

# TEST<1-999>, TEST_<id> labels
override _test_labels1 := $(filter $(sort $(foreach x,$(filter TEST%,$(.VARIABLES)),$(word 1,$(subst ., ,$x)))),$(addprefix TEST,$(_1-999)))
override _test_labels2 := $(sort $(foreach x,$(filter TEST_%,$(.VARIABLES)),$(if $(findstring .,$x),$(word 1,$(subst ., ,$x)))))
override _test_labels := $(strip $(_test_labels1) $(_test_labels2))

override _src_labels := $(strip $(_lib_labels) $(_bin_labels) $(_test_labels))
override _all_labels := $(strip $(_src_labels) $(_file_labels))
override _subdir_targets := $(foreach e,$(_env_names),$e tests_$e clean_$e) clobber install install-strip
override _base_targets := all tests info help .gitignore clean $(_subdir_targets)

# strip extra spaces from all names
$(foreach x,$(_all_labels),$(if $($x),$(eval override $x = $(strip $(value $x)))))

# output name check
override define _check_name  # <1:label>
  ifeq ($$($1),)
    $$(error $$(_msgErr)$1 required$$(_end))
  else ifneq ($$(words $$($1)),1)
    $$(error $$(_msgErr)$1: spaces not allowed$$(_end))
  else ifneq ($$(findstring *,$$($1)),)
    $$(error $$(_msgErr)$1: wildcard '*' not allowed$$(_end))
  else ifneq ($$(filter $$($1),$$(_base_targets) $$(foreach e,$$(_env_names),$1$$(_$$e_sfx))),)
    $$(error $$(_msgErr)$1: name conflicts with existing target$$(_end))
  endif
endef
$(foreach x,$(_lib_labels) $(_bin_labels) $(_file_labels),$(eval $(call _check_name,$x)))

# target setting patterns
override _bin_ptrn := %.SRC %.SRC2 %.OBJS %.LIBS %.STANDARD %.OPT_LEVEL %.OPT_LEVEL_DEBUG %.DEFINE %.INCLUDE %.FLAGS %.RPATH %.LINKER %.LINK_FLAGS %.PACKAGES %.OPTIONS %.DEPS %.SUBSYSTEM %.SOURCE_DIR %.WARN %.WARN_C %.WARN_CXX
override _lib_ptrn := %.TYPE %.VERSION $(_bin_ptrn)
override _test_ptrn := %.ARGS $(_bin_ptrn)

# binary entry check
override define _check_bin_entry  # <1:bin label>
  $$(foreach x,$$(filter-out $$(_bin_ptrn),$$(filter $1.%,$$(.VARIABLES))),\
    $$(warning $$(_msgWarn)Unknown binary parameter '$$x'$$(_end)))
  ifneq ($$(filter %.exe,$$($1)),)
    $$(error $$(_msgErr)$1: binary name should not be specified with an extension$$(_end))
  endif
endef
$(foreach x,$(_bin_labels),$(eval $(call _check_bin_entry,$x)))

# library entry check
override define _check_lib_entry  # <1:lib label>
  $$(foreach x,$$(filter-out $$(_lib_ptrn),$$(filter $1.%,$$(.VARIABLES))),\
    $$(warning $$(_msgWarn)Unknown library parameter '$$x'$$(_end)))
  ifneq ($$(filter %.a %.so %.dll,$$($1)),)
    $$(error $$(_msgErr)$1: library name should not be specified with an extension$$(_end))
  else ifneq ($$(filter-out static shared,$$($1.TYPE)),)
    $$(error $$(_msgErr)$1.TYPE: only 'static' and/or 'shared' allowed$$(_end))
  endif
  override _$1_version := $$(strip $$($1.VERSION))
  ifeq ($$(filter 0 1,$$(words $$(_$1_version))),)
    $$(error $$(_msgErr)$1.VERSION: bad value$$(_end))
  endif
  override _$1_major_ver := $$(word 1,$$(subst ., ,$$(_$1_version)))
  override _$1_minor_ver := $$(word 2,$$(subst ., ,$$(_$1_version)))
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

# macro to create object file name from source file (w/paths)
override _src_oname = $(foreach x,$1,$(addsuffix $(if $(filter $(_rc_ptrn),$x),.res,.o),$(subst /,__,$(subst ../,,$(basename $x)))))

# macro to get values that appear multiple times in a list (for error messages)
override _find_dups = $(strip $(foreach x,$(sort $1),$(if $(filter 1,$(words $(filter $x,$1))),,$x)))

# duplicate name check
override _all_names := $(foreach x,$(_lib_labels) $(_bin_labels) $(_file_labels),$($x))
ifneq ($(words $(_all_names)),$(words $(sort $(_all_names))))
  $(error $(_msgErr)Duplicate binary/library/file names [$(_msgWarn)$(call _find_dups,$(_all_names))$(_msgErr)]$(_end))
endif

override define _check_dir # <1:dir var>
  ifeq ($$(filter 0 1,$$(words $$($1))),)
    $$(error $$(_msgErr)$1: spaces not allowed$$(_end))
  else ifneq ($$(findstring *,$$($1)),)
    $$(error $$(_msgErr)$1: wildcard '*' not allowed$$(_end))
  else ifeq ($$(strip $$($1)),-)
    $$(error $$(_msgErr)$1: invalid value$$(_end))
  endif
endef

$(eval $(call _check_dir,BUILD_DIR))
override _build_dir := $(filter-out .,$(strip $(BUILD_DIR:%/=%)))
ifeq ($(_build_dir),)
  $(error $(_msgErr)BUILD_DIR: invalid value$(_end))
endif

$(eval $(call _check_dir,OUTPUT_DIR))
$(eval $(call _check_dir,OUTPUT_BIN_DIR))
$(eval $(call _check_dir,OUTPUT_LIB_DIR))
override _output_bin_dir = $(patsubst %/,%,$(or $(strip $(OUTPUT_BIN_DIR)),$(strip $(OUTPUT_DIR))))
override _output_lib_dir = $(patsubst %/,%,$(or $(strip $(OUTPUT_LIB_DIR)),$(strip $(OUTPUT_DIR))))
  # output dirs can contain variables like '$(ENV)'

$(eval $(call _check_dir,SOURCE_DIR))
override _source_dir = $(if $(SOURCE_DIR),$(filter-out ./,$(SOURCE_DIR:%/=%)/))

override _symlink_name = $(word 1,$(subst =, ,$1))
override _symlink_target = $(or $(word 2,$(subst =, ,$1)),.)
override _symlinks := $(sort $(SYMLINKS))
override _symlinks_names := $(sort $(foreach s,$(_symlinks),$(call _symlink_name,$s)))
ifneq ($(words $(_symlinks)),$(words $(_symlinks_names)))
  $(error $(_msgErr)SYMLINKS: conflicting values$(_end))
endif

override _dir = $(filter-out ./,$(dir $1))

# output target name generation macros - <1:build env> <2:label>
override _gen_bin_name =\
$(if $(call _dir,$($2)),$($2)$(_$1_sfx),$(_$1_bdir)$(notdir $($2))$(_$1_bsfx))
override _gen_bin_aliases =\
$(if $(or $(_$1_bdir),$(call _dir,$($2))),$(notdir $($2))$(_$1_sfx)) \
$(if $(_binext),$(call _gen_bin_name,$1,$2)$(_binext))
override _base_lib_name=\
$(if $(call _dir,$($2)),$($2)$(_$1_sfx),$(_$1_ldir)$(notdir $($2))$(_$1_lsfx))
override _gen_static_lib_name =\
$(call _base_lib_name,$1,$2).a
override _gen_static_lib_aliases =\
$(sort $(notdir $($2))$(_$1_sfx) $(call _base_lib_name,$1,$2)) \
$(if $(or $(_$1_ldir),$(call _dir,$($2))),$(notdir $($2))$(_$1_sfx).a)
override _gen_implib_name =\
$(call _base_lib_name,$1,$2).dll.a
override _gen_shared_lib_name =\
$(if $(_windows),\
$(call _gen_bin_name,$1,$2)$(if $(_$2_major_ver),-$(_$2_major_ver)).dll,\
$(call _base_lib_name,$1,$2).so$(if $(_$2_version),.$(_$2_version)))
override _gen_shared_lib_linkname =\
$(if $(_windows),\
$(call _gen_bin_name,$1,$2)$(if $(_$2_major_ver),-$(_$2_major_ver)).dll,\
$(call _base_lib_name,$1,$2).so$(if $(_$2_major_ver),.$(_$2_major_ver)))
override _gen_shared_lib_aliases =\
$(sort $(notdir $($2))$(_$1_sfx) $(if $(_windows),$(call _gen_bin_name,$1,$2),$(call _base_lib_name,$1,$2))) \
$(if $(or $(if $(_windows),$(_$1_bdir),$(_$1_ldir)),$(call _dir,$($2)),$(_$2_version)),$(notdir $($2))$(_$1_sfx)$(_libext))
override _gen_shared_lib_links =\
$(if $(_windows),,\
$(if $(_$2_version),$(call _base_lib_name,$1,$2).so \
$(if $(_$2_minor_ver),$(call _base_lib_name,$1,$2).so.$(_$2_major_ver))))

# environment specific setup
override define _setup_env0  # <1:build env>
  override ENV := $1
  override SFX := $$(_$1_sfx)
  override BUILD_TMP := $$(_build_dir)/$1_tmp
  override _$1_bdir := $$(if $$(_output_bin_dir),$$(_output_bin_dir)/)
  override _$1_ldir := $$(if $$(_output_lib_dir),$$(_output_lib_dir)/)
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env0,$e)))


# <1:build env> <2:label/file pattern>
override _gen_filter_targets =\
$(foreach x,$(filter $2,$(_bin_labels)),$(call _gen_bin_name,$1,$x) $(call _gen_bin_aliases,$1,$x))\
$(foreach x,$(filter $2,$(_static_lib_labels)),$(call _gen_static_lib_name,$1,$x) $(call _gen_static_lib_aliases,$1,$x))\
$(foreach x,$(filter $2,$(_shared_lib_labels)),$(call _gen_shared_lib_name,$1,$x) $(call _gen_shared_lib_aliases,$1,$x))\
$(foreach x,$(filter $2,$(_file_labels)),$($x))\
$(foreach x,$(filter $2,$(_test_labels)),$x$(_$1_sfx)) $2

override define _setup_env1  # <1:build env>
  override ENV := $1
  override SFX := $$(_$1_sfx)
  override BUILD_TMP := $$(_build_dir)/$1_tmp
  override _$1_lsfx := $$(if $$(filter 1,$$(words $$(filter $$(_$1_ldir),$$(foreach e,$$(_env_names),$$(_$$e_ldir))))),,$$(_$1_sfx))
  override _$1_bsfx := $$(if $$(filter 1,$$(words $$(filter $$(_$1_bdir),$$(foreach e,$$(_env_names),$$(_$$e_bdir))))),,$$(_$1_sfx))

  ifneq ($(_libprefix),lib)
    override LIBPREFIX := $(_libprefix)
  endif
  override _$1_shared_libs := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_name,$1,$$x))
  override _$1_shared_aliases := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_aliases,$1,$$x))
  override _$1_links := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_shared_lib_links,$1,$$x))
  ifneq ($(_libprefix),lib)
    override LIBPREFIX := lib
  endif
  ifneq ($(_windows),)
    override _$1_implibs := $$(foreach x,$$(_shared_lib_labels),$$(call _gen_implib_name,$1,$$x))
  endif

  override _$1_lib_targets :=\
    $$(_$1_shared_libs) $$(_$1_implibs)\
    $$(foreach x,$$(_static_lib_labels),$$(call _gen_static_lib_name,$1,$$x))
  override _$1_bin_targets :=\
    $$(foreach x,$$(_bin_labels),$$(call _gen_bin_name,$1,$$x))

  override _$1_file_targets := $$(foreach x,$$(_file_labels),$$($$x))
  override _$1_test_targets := $$(foreach x,$$(_test_labels),$$x$$(_$1_sfx))
  override _$1_build_targets := $$(_$1_file_targets) $$(_$1_lib_targets) $$(_$1_bin_targets) $$(_$1_test_targets)

  override _$1_filter_targets :=\
    $$(foreach x,$$(EXCLUDE_TARGETS),$$(call _gen_filter_targets,$1,$$(subst *,%,$$x)))

  override _$1_aliases :=\
    $$(foreach x,$$(_all_labels),$$x$$(_$1_sfx))\
    $$(foreach x,$$(_bin_labels),$$(call _gen_bin_aliases,$1,$$x))\
    $$(foreach x,$$(_static_lib_labels),$$(call _gen_static_lib_aliases,$1,$$x))\
    $$(_$1_shared_aliases)
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env1,$e)))


override _filter_targets := $(sort $(foreach e,$(_env_names),$(_$e_filter_targets)))

override define _setup_env2 # <1:build env>
  override _$1_build2_targets := $$(filter-out $$(_filter_targets),$$(_$1_build_targets))
  override _$1_test2_targets := $$(filter-out $$(_filter_targets),$$(_$1_test_targets))
  override _$1_goals := $$(sort\
    $$(if $$(filter $$(if $$(filter $1,$$(_default_env)),all) $1,$$(MAKECMDGOALS)),$$(_$1_build2_targets))\
    $$(if $$(filter $$(if $$(filter $1,$$(_default_env)),tests) tests_$1,$$(MAKECMDGOALS)),$$(_$1_test2_targets))\
    $$(filter $$(_$1_build_targets) $$(sort $$(_$1_aliases)),$$(MAKECMDGOALS)))
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env2,$e)))


# setting value processing functions
override _format_warn = $(foreach x,$1,$(if $(filter -%,$x),$x,-W$x))
override _format_include = $(foreach x,$1,$(if $(filter -%,$x),$x,-I$x))
override _format_define = $(foreach x,$1,$(if $(filter -%,$x),$x,-D'$x'))

override _format_lib_arg =\
$(if $(filter -% %.a,$1),$1,\
$(if $(filter ./,$(dir $1)),,-L$(patsubst %/,%,$(dir $1))) -l$(if $(or $(filter %.so %.dll,$1),$(findstring .so.,$1)),:)$(notdir $1))

override _format_libs = $(foreach x,$1,\
$(call _format_lib_arg,$(if $(filter $x,$(_lib_labels)),$(or $(_$x_shared_linkname),$(_$x_name)),$x)))

# _do_wildcard: <1:file> <2:basedir>
override _do_wildcard =\
$(if $(filter %/**/ **/,$(dir $1)),$(patsubst $(or $2,./)%,%,$(shell find $2$(patsubst %**/,%,$(dir $1)) -name '$(notdir $1)')),\
$(if $(findstring **,$(notdir $1)),$(patsubst $(or $2,./)%,%,$(shell find $2$(call _dir,$1) -name '$(notdir $1)')),\
$(if $(findstring *,$1),$(patsubst $2%,%,$(wildcard $2$1)),$1)))

# build environment detection
override _build_env := $(strip $(foreach e,$(_env_names),$(if $(_$e_goals),$e)))
ifeq ($(filter 0 1,$(words $(_build_env))),)
  $(error $(_msgErr)Targets in multiple environments not allowed$(_end))
else ifneq ($(_build_env),)
  # setup build targets/variables for selected environment
  override ENV := $(_build_env)
  override SFX := $(_$(ENV)_sfx)
  override BUILD_TMP := $(_build_dir)/$(ENV)_tmp
  override ALL_FILES := $(foreach x,$(_file_labels),$($x))
  $(foreach t,$(_template_labels),\
    $(eval override $t.ALL_FILES := $(foreach x,$(_$t_labels),$($x))))

  # compiler command setup
  $(eval $(call _check_compiler,COMPILER))
  override _compiler := $(or $(strip $(COMPILER)),$(firstword $(_compiler_names)))

  override _cross_compile := $(strip $(CROSS_COMPILE))
  override _cxx := $(_cross_compile)$(or $(_$(_compiler)_cxx),c++)
  override _cc := $(_cross_compile)$(or $(_$(_compiler)_cc),cc)
  override _as := $(_cross_compile)$(or $(_$(_compiler)_as),as)
  override _ar := $(_cross_compile)$(or $(_$(_compiler)_ar),ar)

  ifneq ($(strip $(LINKER)),-)
    ifneq ($(strip $(LINKER)),ld)
      override _linker := $(or $(strip $(LINKER)),$(_$(_compiler)_ld))
    endif
  endif

  $(eval $(call _check_standard,STANDARD,))
  $(eval $(call _check_options,OPTIONS,_op))
  $(eval $(call _check_options,OPTIONS_TEST,_op_test))

  override _pkgs := $(call _check_pkgs,PACKAGES)
  override _pkgs_test := $(call _check_pkgs,PACKAGES_TEST)

  override _define := $(call _format_define,$(DEFINE))
  override _define_test := $(call _format_define,$(DEFINE_TEST))
  override _include := $(call _format_include,$(INCLUDE))
  override _include_test := $(call _format_include,$(INCLUDE_TEST))
  override _warn_cxx := $(call _format_warn,$(WARN_CXX) $(WARN_EXTRA))
  override _warn_c := $(call _format_warn,$(WARN_C) $(WARN_EXTRA))

  # setup compile flags for each build path
  override _pkg_flags := $(call _get_pkg_flags,$(sort $(_pkgs)))
  override _xflags :=  $(_pkg_flags) $(FLAGS_$(_$(ENV)_uc)) $(FLAGS)
  override _cxxflags_$(ENV) := $(strip $(_cxx_std) $(_$(ENV)_opt) $(_warn_cxx) $(_op_cxx_warn) $(_define) $(_include) $(_op_cxx_flags) $(_xflags))
  override _cflags_$(ENV) := $(strip $(_c_std) $(_$(ENV)_opt) $(_warn_c) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_xflags))
  override _asflags_$(ENV) := $(strip $(_$(ENV)_opt) $(_op_warn) $(_define) $(_include) $(_op_flags) $(_xflags))
  override _rcflags_$(ENV) := $(filter -D% -U% -I%,$(_define) $(_include) $(_op_flags) $(_xflags))
  override _src_path_$(ENV) := $(_source_dir)

  ifneq ($(_test_labels),)
    override _test_xflags := $(if $(_pkgs_test),$(call _get_pkg_flags,$(sort $(_pkgs) $(_pkgs_test))),$(_pkg_flags)) $(FLAGS_$(_$(ENV)_uc)) $(FLAGS) $(FLAGS_TEST)
    override _cxxflags_$(ENV)-tests := $(strip $(_cxx_std) $(_$(ENV)_opt) $(_warn_cxx) $(_op_cxx_warn) $(_op_test_cxx_warn) $(_define) $(_define_test) $(_include) $(_include_test) $(_op_cxx_flags) $(_op_test_cxx_flags) $(_test_xflags))
    override _cflags_$(ENV)-tests := $(strip $(_c_std) $(_$(ENV)_opt) $(_warn_c) $(_op_warn) $(_op_test_warn) $(_define) $(_define_test) $(_include) $(_include_test) $(_op_flags) $(_op_test_flags) $(_test_xflags))
    override _asflags_$(ENV)-tests := $(strip $(_$(ENV)_opt) $(_op_warn) $(_op_test_warn) $(_define) $(_define_test) $(_include) $(_include_test) $(_op_flags) $(_op_test_flags) $(_test_xflags))
    override _rcflags_$(ENV)-tests := $(filter -D% -U% -I%,$(_define) $(_define_test) $(_include) $(_include_test) $(_op_flags) $(_op_test_flags) $(_test_xflags))
    override _src_path_$(ENV)-tests := $(_src_path_$(ENV))
  endif

  ## entry name & alias target assignment
  $(foreach x,$(_file_labels),\
    $(eval override _$x_name := $($x))\
    $(eval override _$x_aliases := $x$(SFX) $(if $(SFX),$x)))

  $(foreach x,$(_bin_labels),\
    $(eval override _$x_name := $(call _gen_bin_name,$(ENV),$x))\
    $(eval override _$x_aliases := $x$(SFX) $(if $(SFX),$x $($x)) $(call _gen_bin_aliases,$(ENV),$x)))

  $(foreach x,$(_static_lib_labels),\
    $(eval override _$x_name := $(call _gen_static_lib_name,$(ENV),$x))\
    $(eval override _$x_aliases := $x$(SFX) $(if $(SFX),$x $($x) $($x).a) $(call _gen_static_lib_aliases,$(ENV),$x)))

  ifneq ($(_libprefix),lib)
    override LIBPREFIX := $(_libprefix)
  endif
  $(foreach x,$(_shared_lib_labels),\
    $(eval override _$x_shared_name := $(call _gen_shared_lib_name,$(ENV),$x))\
    $(eval override _$x_shared_linkname := $(call _gen_shared_lib_linkname,$(ENV),$x))\
    $(eval override _$x_shared_aliases := $x$(SFX) $(if $(SFX),$x $($x) $($x)$(_libext)) $(call _gen_shared_lib_aliases,$(ENV),$x))\
    $(if $(_windows),,\
      $(eval override _$x_soname := $(if $(_$x_major_ver),$(notdir $($x)).so.$(_$x_major_ver)))\
      $(eval override _$x_shared_links := $(call _gen_shared_lib_links,$(ENV),$x))))
  ifneq ($(_libprefix),lib)
    override LIBPREFIX := lib
  endif

  $(if $(_windows),$(foreach x,$(_shared_lib_labels),\
    $(eval override _$x_implib := $(call _gen_implib_name,$(ENV),$x))))

  # .DEPS wildcard & BIN/FILE label translation
  $(foreach x,$(_all_labels),$(eval override _$x_deps := $(foreach d,$($x.DEPS),\
    $(if $(filter $d,$(_bin_labels) $(_file_labels)),$(_$d_name),$(call _do_wildcard,$d,)))))

  ## general entry setting parsing (pre)
  override define _build_entry1  # <1:label> <2:test flag>
    ifneq ($$(strip $$($1.SOURCE_DIR)),-)
      $$(eval $$(call _check_dir,$1.SOURCE_DIR))
      override _$1_source_dir := $$(if $$($1.SOURCE_DIR),$$(filter-out ./,$$($1.SOURCE_DIR:%/=%)/))
      override _src_path_$$(ENV)-$1 := $$(or $$(_$1_source_dir),$$(_src_path_$$(ENV)))
    endif

    override _$1_src := $$(strip $$(filter-out $(_src_filter),$$(foreach x,$$($1.SRC),$$(call _do_wildcard,$$x,$$(_src_path_$$(ENV)-$1)))))
    override _$1_src2 := $$(strip $$(filter-out $(_src_filter),$$(foreach x,$$($1.SRC2),$$(call _do_wildcard,$$x,))))
    ifneq ($$(words $$(_$1_src) $$(_$1_src2)),$$(words $$(sort $$(_$1_src) $$(_$1_src2))))
      $$(error $$(_msgErr)$1: duplicate source files [$$(_msgWarn)$$(call _find_dups,$$(_$1_src))$$(_msgErr)]$$(_end))
    else ifneq ($$(filter-out $(_cxx_ptrn) $(_c_ptrn) $(_asm_ptrn) $(_rc_ptrn),$$(_$1_src) $$(_$1_src2)),)
      $$(error $$(_msgErr)$1: invalid source files [$$(_msgWarn)$$(filter-out $(_cxx_ptrn) $(_c_ptrn) $(_asm_ptrn) $(_rc_ptrn),$$(_$1_src) $$(_$1_src2))$$(_msgErr)]$$(_end))
    endif

    ifneq ($$(findstring *,$$(filter-out $(_src_filter),$$($1.SRC))),)
      ifeq ($$(_$1_src),)
        $$(warning $$(_msgWarn)$1.SRC: no source files match pattern$$(_end))
      endif
    endif
    ifneq ($$(findstring *,$$(filter-out $(_src_filter),$$($1.SRC2))),)
      ifeq ($$(_$1_src2),)
        $$(warning $$(_msgWarn)$1.SRC2: no source files match pattern$$(_end))
      endif
    endif
    ifeq ($$(strip $$(_$1_src) $$(_$1_src2)),)
      $$(error $$(_msgErr)$1: nothing to compile$$(_end))
    endif

    override _$1_lang :=\
      $$(if $$(filter $(_cxx_ptrn),$$(_$1_src) $$(_$1_src2)),cxx)\
      $$(if $$(filter $(_c_ptrn),$$(_$1_src) $$(_$1_src2)),c)\
      $$(if $$(filter $(_asm_ptrn),$$(_$1_src) $$(_$1_src2)),asm)\
      $$(if $$(filter $(_rc_ptrn),$$(_$1_src) $$(_$1_src2)),rc)
    override _$1_src_objs := $$(call _src_oname,$$(_$1_src) $$(_$1_src2))

    ifneq ($$(strip $$($1.OBJS)),-)
      override _$1_objs := $$(filter-out $1,$$($1.OBJS))
      override _$1_other_objs := $$(foreach x,$$(_$1_objs),$$(if $$(filter $$x,$$(_lib_labels)),\
        $$(or $$(_$$x_name),$$(error $$(_msgErr)$1.OBJS: static type required for library '$$x'$$(_end))),$$(call _do_wildcard,$$x,)))
    endif

    ifneq ($$(strip $$($1.SUBSYSTEM)),-)
      override _$1_subsystem := $(if $(_windows),$$(or $$($1.SUBSYSTEM),$$(SUBSYSTEM)))
    endif

    ifeq ($$(strip $$($1.LINKER)),)
      override _$1_linker := $$(_linker)
    else ifneq ($$(strip $$($1.LINKER)),-)
      ifneq ($$(strip $$($1.LINKER)),ld)
        override _$1_linker := $$(or $$(strip $$($1.LINKER)),$$(_$$(_compiler)_ld))
      endif
    endif

    override _$1_link_flags := $$(if $$(_$1_linker),-fuse-ld=$$(_$1_linker))
    ifneq ($$(strip $$($1.RPATH)),-)
      override _$1_link_flags += $$(foreach x,$$(or $$($1.RPATH),$$(RPATH)),-Wl,-rpath=$$x)
    endif
    ifneq ($$(strip $$($1.LINK_FLAGS)),-)
      override _$1_link_flags += $$(or $$($1.LINK_FLAGS),$$(LINK_FLAGS))
    endif

    ifeq ($$(strip $$($1.STANDARD)),)
      override _$1_cxx_std := $$(_cxx_std)
      override _$1_c_std := $$(_c_std)
    else ifneq ($$(strip $$($1.STANDARD)),-)
      $$(eval $$(call _check_standard,$1.STANDARD,_$1))
    endif

    ifeq ($$(strip $$($1.OPTIONS)),)
      override _$1_options := $$(OPTIONS) $(if $2,$$(OPTIONS_TEST))
      override _$1_op_warn := $$(_op_warn) $(if $2,$$(_op_test_warn))
      override _$1_op_flags := $$(_op_flags) $(if $2,$$(_op_test_flags))
      override _$1_op_link := $$(_op_link) $(if $2,$$(_op_test_link))
      override _$1_op_cxx_warn := $$(_op_cxx_warn) $(if $2,$$(_op_test_cxx_warn))
      override _$1_op_cxx_flags := $$(_op_cxx_flags) $(if $2,$$(_op_test_cxx_flags))
      override _$1_op_cxx_link := $$(_op_cxx_link) $(if $2,$$(_op_test_cxx_link))
    else ifneq ($$(strip $$($1.OPTIONS)),-)
      override _$1_options := $$($1.OPTIONS)
      $$(eval $$(call _check_options,$1.OPTIONS,_$1_op))
    endif

    ifneq ($$(strip $$($1.PACKAGES)),-)
      override _$1_pkgs := $$(or $$(call _check_pkgs,$1.PACKAGES),$$(_pkgs) $(if $2,$$(_pkgs_test)))
    endif

    ifneq ($$(strip $$($1.LIBS)),-)
      override _$1_libs := $$(filter-out $1,$$(or $$($1.LIBS),$$(LIBS) $(if $2,$$(LIBS_TEST))))
    endif

    ifneq ($$(strip $$($1.DEFINE)),-)
      override _$1_define := $$(or $$(call _format_define,$$($1.DEFINE)),$$(_define) $(if $2,$$(_define_test)))
    endif

    ifneq ($$(strip $$($1.INCLUDE)),-)
      override _$1_include := $$(or $$(call _format_include,$$($1.INCLUDE)),$$(_include) $(if $2,$$(_include_test)))
    endif

    ifneq ($$(strip $$($1.FLAGS)),-)
      override _$1_flags := $$(or $$($1.FLAGS),$$(FLAGS) $(if $2,$$(FLAGS_TEST)))
    endif

    ifeq ($$(strip $$($1.WARN_C)),)
      ifeq ($$(strip $$($1.WARN)),)
        override _$1_warn_c := $$(_warn_c)
      else ifneq ($$(strip $$($1.WARN)),-)
        override _$1_warn_c := $$(call _format_warn,$$($1.WARN))
      endif
    else ifneq ($$(strip $$($1.WARN_C)),-)
      override _$1_warn_c := $$(call _format_warn,$$($1.WARN_C))
    endif

    ifeq ($$(strip $$($1.WARN_CXX)),)
      ifeq ($$(strip $$($1.WARN)),)
        override _$1_warn_cxx := $$(_warn_cxx)
      else ifneq ($$(strip $$($1.WARN)),-)
        override _$1_warn_cxx := $$(call _format_warn,$$($1.WARN))
      endif
    else ifneq ($$(strip $$($1.WARN_CXX)),-)
      override _$1_warn_cxx := $$(call _format_warn,$$($1.WARN_CXX))
    endif
  endef
  $(foreach x,$(_lib_labels) $(_bin_labels),$(eval $(call _build_entry1,$x,)))
  $(foreach x,$(_test_labels),$(eval $(call _build_entry1,$x,test)))

  ## general entry setting parsing (post)
  override define _build_entry2  # <1:label>
    override _$1_req_pkgs := $$(foreach x,$$(_$1_libs) $$(_$1_objs),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_pkgs)))
    override _$1_req_libs := $$(filter-out $1,$$(foreach x,$$(_$1_libs) $$(_$1_objs),$$(if $$(filter $$x,$$(_lib_labels)),$$(_$$x_libs))))
    override _$1_link_deps := $$(foreach x,$$(_$1_libs),$$(if $$(filter $$x,$$(_lib_labels)),$$(or $$(_$$x_shared_name),$$(_$$x_name))))

    override _$1_xpkgs := $$(sort $$(_$1_pkgs) $$(_$1_req_pkgs))
    ifneq ($$(_$1_xpkgs),)
      override _$1_pkg_libs := $$(call _get_pkg_libs,$$(_$1_xpkgs))
      override _$1_pkg_flags := $$(call _get_pkg_flags,$$(_$1_xpkgs))
    endif

    override _$1_xlibs := $$(call _format_libs,$$(_$1_libs) $$(_$1_req_libs))

    # NOTE: PACKAGES libs after LIBS in case included static lib requires package
    override _$1_xflags := $$(_$1_pkg_flags) $$(FLAGS_$$(_$$(ENV)_uc)) $$(_$1_flags)
    override _cxxflags_$$(ENV)-$1 := $$(strip $$(_$1_cxx_std) $$(call _$$(ENV)_opt,$1) $$(_$1_warn_cxx) $$(_$1_op_cxx_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_cxx_flags) $$(_$1_xflags))
    override _cflags_$$(ENV)-$1 := $$(strip $$(_$1_c_std) $$(call _$$(ENV)_opt,$1) $$(_$1_warn_c) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_xflags))
    override _asflags_$$(ENV)-$1 := $$(strip $$(call _$$(ENV)_opt,$1) $$(_$1_op_warn) $$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_xflags))
    override _rcflags_$$(ENV)-$1 := $$(filter -D% -U% -I%,$$(_$1_define) $$(_$1_include) $$(_$1_op_flags) $$(_$1_xflags))

    override _$1_build := $$(ENV)-$1
    ifeq ($$(_src_path_$$(ENV)-$1),$$(_src_path_$$(ENV)))
      ifeq ($$(_$1_deps),)
        # if compile flags match then use a shared build path
        ifeq ($$(_cxxflags_$$(ENV)-$1),$$(_cxxflags_$$(ENV)-tests))
          ifeq ($$(_cflags_$$(ENV)-$1),$$(_cflags_$$(ENV)-tests))
            override _$1_build := $$(ENV)-tests
          endif
        endif
        ifeq ($$(_cxxflags_$$(ENV)-$1),$$(_cxxflags_$$(ENV)))
          ifeq ($$(_cflags_$$(ENV)-$1),$$(_cflags_$$(ENV)))
            override _$1_build := $$(ENV)
          endif
        endif
      endif
    endif
    override _$1_build_dir := $$(_build_dir)/$$(_$1_build)
    override _$1_all_objs := $$(addprefix $$(_$1_build_dir)/,$$(_$1_src_objs))
  endef
  $(foreach x,$(_src_labels),$(eval $(call _build_entry2,$x)))

  # NOTES:
  # - <label>.DEPS can cause an isolated build even though there are no compile
  #   flag changes (target 'source.o : | dep' rules would affect other builds
  #   without isolation)

  $(foreach x,$(_test_labels),\
    $(eval override _$x_name := __$x)\
    $(eval override _$x_aliases := $x$(SFX))\
    $(eval override _$x_run := $(_$x_build_dir)/$(_$x_name)))

  # halt build for package errors on non-test entries
  $(eval $(call _verify_pkgs,PACKAGES,_pkgs))
  $(foreach x,$(_bin_labels) $(_lib_labels),$(eval $(call _verify_pkgs,$x.PACKAGES,_$x_pkgs)))

  # determine LDFLAGS value for each entry
  $(foreach x,$(_shared_lib_labels) $(_bin_labels) $(_test_labels),\
    $(eval override _$x_ldflags :=\
      -Wl$(_comma)--as-needed$(_comma)--gc-sections\
      $(if $(if $(_windows),$(_$(ENV)_bdir),$(_$(ENV)_ldir)),,-L../..)\
      $(if $(_$x_soname),-Wl$(_comma)-h$(_comma)'$(_$x_soname)')\
      $(if $(_$x_implib),-Wl$(_comma)--out-implib$(_comma)'../../$(_$x_implib)')\
      $(if $(_$x_subsystem),-Wl$(_comma)$--subsystem$(_comma)$(_$x_subsystem))\
      $(if $(filter cxx,$(_$x_lang)),$(_$x_op_cxx_link),$(_$x_op_link))\
      $(_$x_link_flags)))

  # file entry command evaluation
  $(foreach x,$(_file_labels),\
    $(eval override OUT = $($x))\
    $(eval override DEPS = $(or $(_$x_deps),$$(error $$(_msgErr)Cannot use DEPS if $x.DEPS is not set$$(_end))))\
    $(foreach n,$(wordlist 1,$(words $(_$x_deps)),$(_1-99)),\
      $(eval override DEP$n = $(word $n,$(_$x_deps))))\
    $(eval override _$x_command := $(value $x.CMD)))

  # tests depend on lib/bin/file goals to make sure they always build/run last
  override _build_goals :=\
    $(foreach x,$(_shared_lib_labels),$(if $(filter $(_$x_shared_aliases) $(_$x_shared_name),$(_$(ENV)_goals)),$(_$x_shared_name)))\
    $(foreach x,$(_static_lib_labels) $(_bin_labels) $(_file_labels),$(if $(filter $(_$x_aliases) $(_$x_name),$(_$(ENV)_goals)),$(_$x_name)))
  # running tests depends on all tests being built first
  override _test_goals :=\
    $(foreach x,$(_test_labels),$(if $(filter $(_$x_aliases) tests tests_$(ENV) $(ENV),$(MAKECMDGOALS)),$(_$x_run)))
endif


#### Main Targets ####
.PHONY: $(_base_targets)

.DEFAULT_GOAL = $(_default_env)
all: $(_default_env)
tests: tests_$(_default_env)

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
	@echo '$(_bold)make$(_end) or $(_bold)make all$(_end)   builds default environment ($(_bold)$(_fg3)$(_default_env)$(_end))'
	@echo '$(_bold)make $(_fg3)<env>$(_end)         builds specified environment'
	@echo '                   available: $(_bold)$(_fg3)$(_env_names)$(_end)'
	@echo '$(_bold)make clean$(_end)         removes all build files except for made binaries/libraries'
	@echo '$(_bold)make clobber$(_end)       as clean, but also removes made binaries/libraries'
	@echo '$(_bold)make tests$(_end)         builds/runs all tests'
	@echo '$(_bold)make info$(_end)          prints build target summary'
	@echo '$(_bold)make .gitignore$(_end)    prints a sample .gitignore file for all targets'
	@echo '$(_bold)make help$(_end)          prints this information'
	@echo

.gitignore:
	@echo '$(_build_dir)/'
	@for X in $(sort $(filter-out $(_build_dir)/%,$(_symlinks_names) $(foreach e,$(_env_names),$(_$e_lib_targets) $(addsuffix $(_binext),$(_$e_bin_targets)) $(_$e_links) $(_$e_file_targets)))); do\
	  echo "$$X"; done

override define _setup_env_targets  # <1:build env>
$1: $$(_$1_build2_targets)
tests_$1: $$(_$1_test2_targets)

clean_$1:
	@([ -d "$$(_build_dir)/$1_tmp" ] && $$(RM) "$$(_build_dir)/$1_tmp/"* && rmdir -- "$$(_build_dir)/$1_tmp") || true
	@$$(RM) "$$(_build_dir)/.$1-cmd-"*
	@for D in "$$(_build_dir)/$1"*; do\
	  ([ -d "$$$$D" ] && echo "$$(_msgWarn)Cleaning '$$$$D'$$(_end)" && $$(RM) "$$$$D/"*.mk "$$$$D/"*.o $(if $(_windows),"$$$$D/"*.res) "$$$$D/__TEST"* "$$$$D/.compile_cmd"* && rmdir -- "$$$$D") || true; done

clean: clean_$1
endef
$(foreach e,$(_env_names),$(eval $(call _setup_env_targets,$e)))


ifneq ($(filter clobber,$(MAKECMDGOALS)),)
  override _clean_files :=\
    $(foreach e,$(_env_names),\
      $(_$e_lib_targets) $(_$e_bin_targets) $(_$e_links) $(_$e_file_targets)\
      $(addsuffix .map,$(_$e_shared_libs) $(_$e_bin_targets)))\
    $(foreach f,$(CLEAN_EXTRA) $(CLOBBER_EXTRA),$(call _do_wildcard,$f)) core gmon.out
  override _clean_dirs :=\
    $(foreach d,$(sort $(filter-out ./,$(foreach e,$(_env_names),$(foreach x,$(_$e_lib_targets) $(_$e_bin_targets) $(_$e_file_targets),$(dir $x))))),"$d")
else ifneq ($(filter clean,$(MAKECMDGOALS)),)
  override _clean_files := $(foreach f,$(CLEAN_EXTRA),$(call _do_wildcard,$f))
endif

clean:
	@$(RM) "$(_build_dir)/".*_ver
	@for X in $(_symlinks_names); do\
	  ([ -h "$$X" ] && $(RM) "$$X") || true; done
	@for X in $(filter-out $(MAKEFILE_LIST),$(_clean_files)); do\
	  (([ -f "$$X" ] || [ -h "$$X" ]) && echo "$(_msgWarn)Removing '$$X'$(_end)" && $(RM) "$$X") || true; done
	@for X in $(_clean_dirs); do\
	  ([ -d "$$X" ] && rmdir -p --ignore-fail-on-non-empty -- "$$X") || true; done
	@([ -d "$(_build_dir)" ] && rmdir -p -- "$(_build_dir)") || true

clobber: clean

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
override _all_src_files = $(foreach x,$(_src_labels),$(addprefix $(or $(_$x_source_dir),$(_source_dir)),$(_$x_src)) $(_$x_src2))
.SUFFIXES:
.DEFAULT: ; $(error $(_msgErr)$(if $(filter $<,$(_all_src_files)),Missing source file '$<','$<' unknown)$(_end))


#### Build Macros ####
override _escape_echo = $(subst ",\",$(subst $,\$,$1))
# "

override define _rebuild_check  # <1:trigger file> <2:trigger text>
$1: | $$(patsubst %/,%,$$(dir $1)) ; @echo "$$(call _escape_echo,$$(strip $2))" >$1
ifneq ($$(strip $$(file <$1)),$$(strip $2))
  ifneq ($$(file <$1),)
    $$(info $$(_msgWarn)$1 changed$$(_end))
    $$(shell $$(RM) "$1")
  endif
endif
endef

override define _rebuild_check_var # <1:trigger file> <2:trigger text var>
$1: | $$(patsubst %/,%,$$(dir $1)) ; @echo "$$(call _escape_echo,$$(strip $$($2)))" >$1
ifneq ($$(strip $$(file <$1)),$$(strip $$($2)))
  ifneq ($$(file <$1),)
    $$(info $$(_msgWarn)$1 changed$$(_end))
    $$(shell $$(RM) "$1")
  endif
endif
endef

# make path of input file - <1:file w/ path>
override _make_path = $(if $(call _dir,$1),@mkdir -p "$(dir $1)")

# fix path to other objects when inside build dir
override _fix_path = $(foreach x,$1,\
$(if $(filter -L%,$(filter-out -L/% -L~%,$x)),-L../../$(patsubst -L%,%,$x),\
$(if $(filter-out /% ~% -%,$x),../../$x,$x)))

# link binary/test/shared lib - <1:label> <2:extra flags> <3:output name>
override _do_link = $(strip $(filter-out -D% -U% -I%,\
$(if $(filter cxx,$(_$1_lang)),\
$(_cxx) $(_$1_cxx_std) $(call _$(ENV)_opt,$1) $(_$1_op_cxx_flags),\
$(_cc) $(_$1_c_std) $(call _$(ENV)_opt,$1) $(_$1_op_flags))\
$(_$1_xflags)) $(_$1_ldflags) $2 $(_$1_src_objs) $(call _fix_path,$(_$1_other_objs) $(_$1_xlibs)) $(_$1_pkg_libs)\
-o '$3' $(if $(filter mapfile,$(_$1_options)),-Wl$(_comma)-Map='$3.map'))

# static library build
override define _make_static_lib  # <1:label>
override _$1_link_cmd := cd '$$(_$1_build_dir)'; $$(_ar) rcs '../../$$(_$1_name)' $$(strip $$(_$1_src_objs) $$(call _fix_path,$$(_$1_other_objs)))
override _$1_trigger := $$(_build_dir)/.$$(ENV)-cmd-$1-static
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
	@echo "$$(_msgInfo)Static library '$$@' built$$(_end)"
endef

# shared library build
override define _make_shared_lib  # <1:label>
override _$1_shared_build_dir := $$(_$1_build_dir)$$(if $$(_pic_flag),-pic)
override _$1_shared_objs := $$(addprefix $$(_$1_shared_build_dir)/,$$(_$1_src_objs))
override _$1_shared_link_cmd := cd '$$(_$1_shared_build_dir)'; $$(call _do_link,$1,$$(_pic_flag) -shared,../../$$(_$1_shared_name))
override _$1_shared_trigger := $$(_build_dir)/.$$(ENV)-cmd-$1-shared
$$(eval $$(call _rebuild_check_var,$$$$(_$1_shared_trigger),_$1_shared_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_shared_objs): | $$(_$1_deps)
endif

.PHONY: $$(_$1_shared_aliases)
$$(_$1_shared_aliases) $$(_$1_implib): $$(_$1_shared_name)
$$(_$1_shared_name): $$(_$1_shared_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_shared_trigger) $$(if $$(_$1_linker),$$(_build_dir)/.$$(_$1_linker)_ver)
	$$(call _make_path,$$@)
	$$(call _make_path,$$(_$1_implib))
	$$(_$1_shared_link_cmd)
	$$(foreach x,$$(_$1_shared_links),ln -sf "$$(notdir $$@)" "$$x";)
	@echo "$$(_msgInfo)Shared library '$$@' built$$(_end)"
endef

# binary build
override define _make_bin  # <1:label>
override _$1_link_cmd := cd '$$(_$1_build_dir)'; $$(call _do_link,$1,,../../$$(_$1_name))
override _$1_trigger := $$(_build_dir)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_all_objs): | $$(_$1_deps)
endif

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_trigger) $$(if $$(_$1_linker),$$(_build_dir)/.$$(_$1_linker)_ver)
	$$(call _make_path,$$@)
	$$(_$1_link_cmd)
	@echo "$$(_msgInfo)Binary '$$@' built$$(_end)"
endef

# generic file build
override define _make_file  # <1:label>
override _$1_trigger := $$(_build_dir)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_command))

.PHONY: $$(_$1_aliases)
$$(_$1_aliases): $$(_$1_name)
$$(_$1_name): $$(_$1_trigger) $$(_$1_deps)
	$$(call _make_path,$$@)
	$$(value _$1_command)
	@echo "$$(_msgInfo)File '$$@' created$$(_end)"
endef


# build unit tests & execute
# - tests are built with a different binary name to make cleaning easier
# - always execute test binary if a test target was specified otherwise only
#     run test if rebuilt
override define _make_test  # <1:label>
override _$1_link_cmd := cd '$$(_$1_build_dir)'; $$(call _do_link,$1,,$$(_$1_name))
override _$1_trigger := $$(_build_dir)/.$$(ENV)-cmd-$1
$$(eval $$(call _rebuild_check_var,$$$$(_$1_trigger),_$1_link_cmd))

ifneq ($$(_$1_deps),)
$$(_$1_all_objs): | $$(_$1_deps)
endif

$$(_$1_run): $$(_$1_all_objs) $$(_$1_other_objs) $$(_$1_link_deps) $$(_$1_trigger) $$(if $$(_$1_linker),$$(_build_dir)/.$$(_$1_linker)_ver) | $$(_build_goals)
	$$(_$1_link_cmd)
ifeq ($$(filter $$(_$1_aliases) tests tests_$$(ENV),$$(MAKECMDGOALS)),)
	@$(if $(_windows),PATH,LD_LIBRARY_PATH)=$(or $(if $(_windows),$(_output_bin_dir),$(_output_lib_dir)),.):$$$$$(if $(_windows),PATH,LD_LIBRARY_PATH) ./$$(_$1_run) $$($1.ARGS);\
	EXIT_STATUS=$$$$?;\
	if [[ $$$$EXIT_STATUS -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; exit $$$$EXIT_STATUS; fi
endif

.PHONY: $1$$(SFX)
$1$$(SFX): $$(_$1_run) | $$(_test_goals)
ifneq ($$(filter $$(_$1_aliases) tests tests_$$(ENV),$$(MAKECMDGOALS)),)
	@$(if $(_windows),PATH,LD_LIBRARY_PATH)=$(or $(if $(_windows),$(_output_bin_dir),$(_output_lib_dir)),.):$$$$$(if $(_windows),PATH,LD_LIBRARY_PATH) ./$$(_$1_run) $$($1.ARGS);\
	if [[ $$$$? -eq 0 ]]; then echo "$$(_bold) [ $$(_fg3)PASSED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; else echo "$$(_bold) [ $$(_fg4)FAILED$$(_fg0) ] - $1$$(SFX)$$(if $$($1), '$$($1)')$$(_end)"; $$(RM) "$$(_$1_run)"; fi
endif
endef


override define _make_dep  # <1:path> <2:build> <3:source dir> <4:src file> <5:cmd file>
$1/$(call _src_oname,$4): $3$4 $1/$5 $$(_triggers_$2)
-include $1/$(call _src_oname,$4).mk
endef


override define _make_objs  # <1:path> <2:build> <3:flags> <4:src list> <5:src2 list>
$1: ; @mkdir -p "$$@"
$1/%.mk: ; @$$(RM) "$$(basename $$@)"

ifneq ($(words $4 $5),$(words $(sort $(call _src_oname,$4 $5))))
  $$(error $$(_msgErr)Conflicting object files for $2 - each source file basename must be unique$$(_end))
endif

ifneq ($(filter $(_cxx_ptrn),$4 $5),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd,$$(strip $$(_cxx) $$(_cxxflags_$2) $3)))
$(addprefix $1/,$(call _src_oname,$(filter $(_cxx_ptrn),$4 $5))): | $1
	$$(strip $$(_cxx) $$(_cxxflags_$2) $3) -MMD -MP -MF '$$@.mk' -c -o '$$@' $$<
$(foreach x,$(filter $(_cxx_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$$(_src_path_$2),$x,.compile_cmd)))
$(foreach x,$(filter $(_cxx_ptrn),$5),\
  $$(eval $$(call _make_dep,$1,$2,,$x,.compile_cmd)))
endif

ifneq ($(filter $(_c_ptrn),$4 $5),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd_c,$$(strip $$(_cc) $$(_cflags_$2) $3)))
$(addprefix $1/,$(call _src_oname,$(filter $(_c_ptrn),$4 $5))): | $1
	$$(strip $$(_cc) $$(_cflags_$2) $3) -MMD -MP -MF '$$@.mk' -c -o '$$@' $$<
$(foreach x,$(filter $(_c_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$$(_src_path_$2),$x,.compile_cmd_c)))
$(foreach x,$(filter $(_c_ptrn),$5),\
  $$(eval $$(call _make_dep,$1,$2,,$x,.compile_cmd_c)))
endif

ifneq ($(filter $(_asm_ptrn),$4 $5),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd_s,$$(strip $$(_as) $$(_asflags_$2) $3)))
$(addprefix $1/,$(call _src_oname,$(filter $(_asm_ptrn),$4 $5))): | $1
	$$(strip $$(_as) $$(_asflags_$2) $3) -MMD -MP -MF '$$@.mk' -c -o '$$@' $$<
$(foreach x,$(filter $(_asm_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$$(_src_path_$2),$x,.compile_cmd_s)))
$(foreach x,$(filter $(_asm_ptrn),$5),\
  $$(eval $$(call _make_dep,$1,$2,,$x,.compile_cmd_s)))
endif

ifneq ($(filter $(_rc_ptrn),$4 $5),)
$$(eval $$(call _rebuild_check,$1/.compile_cmd_rc,$$(strip windres $$(_rcflags_$2) $3) -O coff))
$(addprefix $1/,$(call _src_oname,$(filter $(_rc_ptrn),$4 $5))): | $1
	$$(strip cpp $$(_rcflags_$2) $3) -MT '$$@' -MM -MP -MF '$$@.mk' $$<
	$$(strip windres $$(_rcflags_$2) $3) -O coff -o '$$@' $$<
$(foreach x,$(filter $(_rc_ptrn),$4),\
  $$(eval $$(call _make_dep,$1,$2,$$(_src_path_$2),$x,.compile_cmd_rc)))
$(foreach x,$(filter $(_rc_ptrn),$5),\
  $$(eval $$(call _make_dep,$1,$2,,$x,.compile_cmd_rc)))
endif
endef


override _nonpic_labels := $(if $(_pic_flag),$(_static_lib_labels),$(_lib_labels)) $(_bin_labels) $(_test_labels)
override _pic_labels := $(if $(_pic_flag),$(_shared_lib_labels))

override _get_src = $(sort $(foreach x,$(_nonpic_labels),$(if $(filter $(_$x_build),$1),$(_$x_src))))
override _get_src2 = $(sort $(foreach x,$(_nonpic_labels),$(if $(filter $(_$x_build),$1),$(_$x_src2))))
override _get_pic_src = $(sort $(foreach x,$(_pic_labels),$(if $(filter $(_$x_build),$1),$(_$x_src))))
override _get_pic_src2 = $(sort $(foreach x,$(_pic_labels),$(if $(filter $(_$x_build),$1),$(_$x_src2))))


#### Create Build Targets ####
.DELETE_ON_ERROR:
ifneq ($(_build_env),)
  $(_build_dir): ; @mkdir -p "$@"

  # symlink creation
  $(foreach x,$(_symlinks),\
    $(shell if [[ -h $(call _symlink_name,$x) || ! -e $(call _symlink_name,$x) ]]; then ln -sfn $(call _symlink_target,$x) "$(call _symlink_name,$x)"; fi))

  ifneq ($(_src_labels),)
    # rebuild trigger for compiler version change
    $(eval $(call _rebuild_check,$(_build_dir)/.$(_compiler)_ver,$(shell $(_cc) --version | head -1)))

    # package version change triggers
    $(foreach p,$(sort $(foreach x,$(_src_labels),$(_$x_xpkgs))),\
      $(eval $(call _rebuild_check,$(_build_dir)/.pkg_$p_ver,$(shell $(PKGCONF) $p --modversion))))

    override _triggers_$(ENV) := $(_build_dir)/.$(_compiler)_ver $(foreach p,$(_pkgs),$(_build_dir)/.pkg_$p_ver)
    override _triggers_$(ENV)-tests := $(_build_dir)/.$(_compiler)_ver $(foreach p,$(_pkgs) $(_pkgs_test),$(_build_dir)/.pkg_$p_ver)
    $(foreach x,$(_src_labels),\
      $(eval override _triggers_$(ENV)-$x := $(_build_dir)/.$(_compiler)_ver $(foreach p,$(_$x_xpkgs),$(_build_dir)/.pkg_$p_ver)))

    # linker version change triggers
    $(foreach i,$(sort $(foreach x,$(_src_labels),$(_$x_linker))),\
      $(eval $(call _rebuild_check,$(_build_dir)/.$i_ver,$(shell ld.$i --version | head -1))))

    # make .o/.mk files for each build path
    $(foreach b,$(sort $(foreach x,$(_nonpic_labels),$(_$x_build))),\
      $(eval $(call _make_objs,$(_build_dir)/$b,$b,,$(call _get_src,$b),$(call _get_src2,$b))))

    # use unique build path for all PIC compiled code
    $(foreach b,$(sort $(foreach x,$(_pic_labels),$(_$x_build))),\
      $(eval $(call _make_objs,$(_build_dir)/$b-pic,$b,$(_pic_flag),$(call _get_pic_src,$b),$(call _get_pic_src2,$b))))
  endif

  # make binary/library/test build targets
  $(foreach x,$(_static_lib_labels),$(eval $(call _make_static_lib,$x)))
  $(foreach x,$(_shared_lib_labels),$(eval $(call _make_shared_lib,$x)))
  $(foreach x,$(_bin_labels),$(eval $(call _make_bin,$x)))
  $(foreach x,$(_file_labels),$(eval $(call _make_file,$x)))
  $(foreach x,$(_test_labels),$(eval $(call _make_test,$x)))
endif

#### END ####
