# Version release history

## 1.12 - general release (2020/4/27)
NEW FEATURES:
* LDFLAGS can be set for specific targets (similar to CFLAGS/CXXFLAGS/ASFLAGS).
* Added RELEASE_FLAGS/DEBUG_FLAGS/PROFILE_FLAGS to add additional compiler flags based on build environment (replacing OPTIMIZE/DEBUG/PROFILE settings).
* Added DEBUG_OPT_LEVEL to control optimization setting value used for debug builds (can be a global or target specific config).
* Added c2x/gnu2x C standard support.

CHANGES:
* TEST_PACKAGES/TEST_LIBS/TEST_FLAGS now always add libraries/flags to test targets and are not overridden by target settings except for CFLAGS/CXXFLAGS/ASFLAGS/LDFLAGS.
* Build environment/compiler config can no longer be overridden (custom Makefile.mk version is probably a better way to handle this).
* Default optimization for debug builds changed to 'g' (-Og).
* Default defines for debug builds (-DDEFINE -D_FORTIFY_SOURCE=1) removed.

FIXES:
* Target SUBSYSTEM config didn't support '-' to clear the value.
* debug/profile test label targets (i.e.: TEST1-g) could execute tests twice.

## 1.11 - general release (2020/4/15)
NEW FEATURES:
* Added Cygwin/MinGW/MSYS shared library building support
   * Shared library source compiled without -fPIC (not used for Windows) so object files can be shared with binary/static library builds.
   * Shared libraries are named with .dll extension, destination same as binaries.
   * Implementation library (<lib name>.dll.a) built with each shared library (necessary for linking in Windows).
   * Added 'SUBSYSTEM' global/target config to set subsystem value for linking (see 'man ld' for --subsystem config details).  Setting ignored on non-Windows platforms.
   * Added 'LIB_PREFIX' output variable for library naming (i.e. LIB1 = $(LIB_PREFIX)test).  This is necessary for libraries to follow OS conventions for naming .dll files (Cygwin uses prefix 'cyg' for shared libraries, MSYS uses 'msys-', for impl/static/other OS libraries 'lib' is used)
* Added support for specifying a full library filename for 'LIBS' global/target setting,  (i.e. LIBS = libtest.so)
* FILE targets with a path in their name will automatically create the path directory like BIN/LIB targets currently do (unlike BIN/LIB targets, however, OUTPUT_DIR is ignored).

CHANGES:
* '.dll' is recognized as a file name extension for various filename checks.
* Output variable 'TMP' changed to 'BUILD_TMP' to avoid issues on Windows platforms.
* Environment specific temp directories (i.e. build/release_tmp) are no longer created by default, but will still be created if referenced to in a target's name (i.e.  FILE1 = $(BUILD_TMP)/output.h)
* Removed checks for old output dir config options BIN_OUTPUT_DIR/LIB_OUTPUT_DIR - new config variables need to be used instead.

FIXES:
* Fixed target variable logic to not treat all variables that start with BIN_ or LIB_ as target labels and trigger false errors.
* Fixed setting 'LDFLAGS' directly not overriding all generated linker flags.

## 1.10 - general release (2020/4/2)
NEW FEATURES:
* Added support for '*' wildcards in file specification settings (.SRC, .DEPS, .OBJS)
* Added an additional configuration style for BIN/LIB entries.
   * Example:
      * BIN_&lt;target&gt;.&lt;setting&gt; = ...
   * where 'target' is the binary name you want to output. This allows setting build targets with a single line.  For example:
      * BIN_prog.SRC = *.cc
   * which makes a binary named 'prog' built with all the .cc source in the base directory.  By default, the output name is the target value in the label, but that can be overridden by setting the name label value directly:
      * BIN_prog = program
      * BIN_prog.SRC = *.cc
   * The new configuration style otherwise works just like numbered BIN/LIB labels.
* Increased max number of FILE & TEST entries to 999 each.
* Improved duplicate name/source error messages by showing duplicate values.
* Added 'TEMPLATE&lt;1-99&gt;.ALL_FILES' output variable - variable contains all files build by the specified template and can be used for dependency rules on a target binary/library (&lt;X&gt;.DEPS setting)
* CROSS_COMPILE setting contribution from Stafford Horne (github:stffrdhrn) - adds a prefix to all compiler commands executed.

CHANGES:
* Disabled &lt;X&gt;.SRC/STANDARD/OPTIONS value checks for non-build targets
* BIN_OUTPUT_DIR/LIB_OUTPUT_DIR settings renamed to OUTPUT_BIN_DIR/OUTPUT_LIB_DIR to avoid conflicts with new BIN/LIB entry style.  For now, a warning will be displayed and the new settings will be set automatically if the old config variables are used but eventually this will be removed.
* Changed the TEST&lt;x&gt; name setting from being a make target to an optional description for the test being run.  Specific tests can still be forced to execute by using the label as a make target (.i.e: make TEST1)

FIXES:
* Fixed package version dependency checking (recompile trigger for when package versions have changed on the system) for isolated builds that default to global package settings

## 1.9 - general release (2020/2/8)
NEW FEATURES:
* Added 'OPT_LEVEL' setting to control value passed to '-O' for release/profile builds (defaults to '3').  Works as both a global & target specific setting.

CHANGES:
* When VERSION is set for a shared library, the internal name of the library (DF_SONAME) is set to libname.so.&lt;MAJOR VERSION&gt;

FIXES:
* fixed creation of shared library links if a path is part of the library name (ex. LIB1 = lib/libname)

## 1.8 - general release (2020/1/11)
NEW FEATURES:
* 'OPTIONS' config added manage common compiler options/features with simplified controls instead of specific compiler flags.  Target specific OPTIONS config also available (ex.: BIN1.OPTIONS).  Values currently supported:
   * warn_error - make all compiler warnings into errors
   * pthread - compile with pthreads support
   * lto - enable link-time optimization
   * modern_c++ - enable warnings for some old-style C++ syntax (pre C++11)
   * no_rtti - disable C++ RTTI
   * no_except - disable C++ exceptions
* Target specific settings can be set to the value '-' to indicate that the setting is cleared for the target.
* Added detection for multiple includes of Makefile.mk.

CHANGES:
* Renamed 'gprof' environment to 'profile'.
* Added '_FORTIFY_SOURCE=1' define to default 'debug' environment config to enable additional checks for some glibc functions. (See 'man feature_test_macros' for details)
* Package configs are no longer checked for non-build targets.
* Improved STANDARD config error output.
* Internal variables are prefixed with '_' to avoid collisions with the main Makefile.

FIXES:
* TEST_FLAGS/TEST_PACKAGES were being ignored for test targets with configs that caused an isolated build.  Fixed behavior has test target specific PACKAGES config overrides global PACKAGES/TEST_PACKAGES and test target specific FLAGS config overrides global FLAGS/TEST_FLAGS.
* Fixed TEST_LIBS/TEST_PACKAGE configured libraries always being used for test targets even when target specific LIBS setting was set.

## 1.7 - general release (2019/12/14)
NEW FEATURES:
* Added target specific STANDARD config (i.e. BIN1.STANDARD = c++17)
* Source files with .S/.sx extension recognized as assembly source.
* An error is reported if target .SRC setting contains an invalid source file
* Added help & info targets for printing command help & build target info

CHANGES:
* Targets with only C or ASM source will now link with the C compiler instead of always using the C++ compiler.
* For color output, ANSI color codes are used directly if 'setterm' isn't available

## 1.6 - general release (2019/12/1)
NEW FEATURES:
* &lt;X&gt;.DEPS (target specific file dependencies) setting added for BIN/LIB/TEST targets - previously only available for FILE/TEMPLATE.  This setting is useful for handling code generated headers where make can't resolve the exact path before compiling.
* Added 'ALL_FILES' output variable (equivalent to '$(FILE1) $(FILE2) ...' for all files defined).  Useful for new &lt;X&gt;.DEPS setting.
* WARN/WARN_C/INCLUDE/LIBS/DEFINE global & target specific settings no longer require compiler specific flags - if not specified, the compiler flag will automatically be added.  For example:
   * DEFINE = NDEBUG  (equivalent to: DEFINE = -D'NDEBUG')
   * INCLUDE = . include  (equivalent to: INCLUDE = -I. -Iinclude)
   * LIBS = m -ldl X11 Xext  (equivalent to: LIBS = -lm -ldl -lX11 -lXext)
   * WARN = all error  (equivalent to: WARN = -Wall -Werror)
* Additionally for LIBS, if a non-compiler flag value is specified that contains a path, then both '-L' and '-l' flags are generated.  For example:
   * LIBS = libs/custom  (equivalent to: LIBS = -Llibs/ -lcustom)

CHANGES:
* INCLUDE global setting no longer has a default value (was -I.) - if this breaks builds then add '.' to your current INCLUDE setting.
* CXXFLAGS/CFLAGS/ASFLAGS/LDFLAGS global settings can now be set in the Makefile without using 'override' (settings not recommended for use since they will override all other settings that generate compiler flags).

BUG FIXES:
* When linking binaries/shared libraries/tests, 'LIBS' libraries are linked before 'PACKAGES' libraries.  This resolves a linking error when linking with static libraries (via the 'LIBS' setting) that require specific packages in the final binary target.
* Spelling fixes to various error messages.

## 1.5 - feature release (2019/11/18)
NEW FEATURES:
* FILEx target added for creating targets from executing a command settings FILEx.CMD,FILEx.DEPS for file target creation command & dependencies.  Helper variables are set to simplify rule creation:<br>OUT  - same as 'FILEx' value<br>DEPS - same as 'FILEx.DEPS' value<br>DEPn - same as n-th value in 'FILEx.DEPS'
   * Config example:<br>FILE1 = parser.c<br>FILE1.DEPS = parser.y<br>FILE1.CMD = yacc $(DEPS) -o $(OUT)
* Added 'TMP' output variable to reference an environment specific temporary directory inside the build directory that can be used for source generation (for FILEx targets).  All tmp contents are deleted by 'clean' rule.
* TEMPLATEx target added for creating multiple file target entries that only vary by a few values.
   * Config settings:
      * TEMPLATE1.FILE1 - value list for creating entry for 'FILE1' for each template FILEx entry, VALS/VAL1/VAL2...VALn are set for each file target instance created
      * TEMPLATE1      - 'FILEx' template config
      * TEMPLATE1.DEPS - 'FILEx.DEPS' template config
      * TEMPLATE1.CMD  - 'FILEx.CMD' template config
   * Template settings (TEMPLATEx,TEMPLATEx.DEPS,TEMPLATEx.CMD) should use $(VARS)/$(VAR1)/$(VAR2)/etc. for their definition to create the final FILEx entries.  Note if output variables ENV/SFX/TMP are used (or FILE entry specific variables like OUT/DEPS/etc.), they should be escaped to show up correctly in generated FILEx entries (i.e. $$(TMP))
   * Config example:<br>TEMPLATE1.FILE1 = aa_parser cfg1/aa.y<br>TEMPLATE1.FILE2 = bb_parser cfg2/bb.y<br>TEMPLATE1 = $$(TMP)/$(VAR1).c<br>TEMPLATE1.DEPS = $(VAR2)<br>TEMPLATE1.CMD = yacc -o $$(OUT) $$(DEP1)
   * This will create file targets equivalent to:<br>FILE1 = $(TMP)/aa_parser.c<br>FILE1.DEPS = cfg/aa.y<br>FILE1.CMD = yacc -o $(OUT) $(DEP1)<br>FILE2 = $(TMP)/bb_parser.c<br>FILE2.DEPS = cfg/aa.y<br>FILE2.CMD = yacc -o $(OUT) $(DEP1)
* Added assembly compile support (.s source files).  ASFLAGS, &lt;target&gt;.ASFLAGS settings added to override compile flags.
* Added 'SOURCE_DIR' config to specifically the base directory of all source files.
* Binary/library targets with a directory as part of their name (i.e. BIN1 = bin/prog) will automatically create the directory as needed and will remove the directory with 'clobber'
* Added minimum version check for make (required version is 4.2 or higher)

## 1.4 - general release (2019/11/11)
NEW FEATURES:
* 'ENV' is set with the current build environment, 'SFX' with the binary suffix.  Both variables can be used with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR settings to allow for different directories based on build environment.
* If debug/gprof environment lib/bin output directories are unique (not shared with any other environments) then the binary suffix will be omitted.
* If building non-release target(s), aliases without binary suffix are created to simplify dependency rules.
* Error checking added to prevent OUTPUT_DIR,LIB_OUTPUT_DIR,BIN_OUTPUT_DIR settings from containing spaces.
* Made static library (archive) building less verbose.
* Added support for source files with '../' in their path.

BUG FIXES:
* TESTx-g, TESTx-pg targets now correctly run test binaries even if already built like TESTx targets do.
* Fixed object file rebuild trigger failures on Makefile config change.
* Fixed incorrect object file name in dependency file (dependency checks for header changes weren't working because of this).
* Fixed case where .c files were being compiled as c++ files if the source file was in a sub directory.

## 1.3 - feature release (2019/10/4)
* binary/library/test specific compile configs possible:
   * BIN1.DEFINE - overrides DEFINE for BIN1 only
   * BIN1.INCLUDE
   * BIN1.FLAGS
   * BIN1.PACKAGES
   * BIN1.CXXFLAGS
   * BIN1.CFLAGS
   * if any of these options are used, all objects for the target are built in a separate build directory and not shared with other binary/library/test targets
* STANDARD specified flags (-std=xxx) are part for normal CXXFLAGS/CFLAGS now and not added to CXX/CC variables (this only matters if you explicitly override CXXFLAGS/CFLAGS)
* Added TEST_FLAGS settings to allow test only compile flags
* TEST_PACKAGES can now set test only compile flags and not just libraries
* Target specific LIBS config (i.e. BIN1.LIBS) now overrides default 'LIBS' config instead of just adding additional libraries to link with (this behavior matches other target specific configs added in this release)

## 1.2 - feature release (2019/8/15)
* added LIBx.VERSION setting for adding major/minor/patch version to shared libraries built.  If version is specified, symlinks are created for .so & .so.MAJOR_VERSION version(s) of the shared library
* added additional target aliases for binaries/libraries when building with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR set
* added test failure output message
* output messages are now color coded:
   * cyan - binary/library built
   * magenta - file removed, warning
   * green - test passed
   * red - test failed
* unit tests are forced to build/execute after binary builds<br>(previously they were only forced to run after library builds like binaries)

## 1.1.1 - minor bug fix release (2019/8/1)
* fixed issues with building both shared & static version of a library

## 1.1 - feature release (2019/7/7)
* added warnings for unknown binary/library/test parameter variables<br>(for example, setting 'BIN1.OBJ' will trigger a warning since the correct variable is 'BIN1.OBJS')
* PACKAGES changes or package version changes trigger a full rebuild
* TEST_PACKAGES changes or test package version changes trigger a relink/run of all tests
* fixes to allow file/directory names starting with '-'
* added SYMLINKS setting for creating symlinks to the makefile directory to help building source that expects to include headers from different paths

## 1.0 (2019/4/10)
* first public release
