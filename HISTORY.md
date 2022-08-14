# Version release history

## 1.23 - general release (2022/8/9)
CHANGES:
* Added support for TEMPLATE_<id> style labels.

FIXES:
* Fixed a TEMPLATE error message.
* Removed filtering of -include/-imacros flags from linking command (caused an error & wasn't necessary).
* Minor comment fixes/cleanup.

## 1.22 - general release (2022/7/23)
CHANGES:
* EXCLUDE_TARGETS now accepts '*' wildcard.
* LIBS_TEST no longer adds libraries to tests with their own LIBS settings. (use 'TEST1.LIBS = $(LIBS_TEST) ...' for old behavior)
* Library labels are now allowed in global LIBS/LIBS_TEST settings.  In cases where LIBS is used in building a library, the library will always ignore its own lib label.

FIXES:
* Library search directories (-L flags) from pkg-config are no longer 'fixed' because of the build location - this was resulting in some strange library paths on MSys2/MinGW builds where the path could include a drive letter (i.e. -LC:/msys64/mingw64/lib).

## 1.21 - general release (2022/6/20)
CHANGES:
* FILE labels are translated into file targets in <X>.DEPS settings (same as BIN labels).
* CLEAN_EXTRA/CLOBBER_EXTRA now accept wildcards.
* Recursive search '**' wildcard are now allowed as the last directory in a directory path.  (i.e.  python/**/__pycache__)
* Simplified binary/library link commands:
   * Linking done from object build directory to shorten object file names.
   * Some unnecessary compiler flags are removed.

FIXES:
* Commands with a dollar sign or double quote now are properly cached for rebuild comparison checks. (broke in v1.20)

## 1.20 - general release (2022/6/4)
NEW FEATURES:
* Added 'EXCLUDE_TARGETS' for specifying targets to not build by default.

CHANGES:
* Removed 'not implemented' error message for install/install-strip targets so user can specify their own versions.
* Color output is disabled if make stdout/stderr is redirected to a file.

FIXES:
* Stopped creation of build dirs & cache files for targets not built.

## 1.19 - general release (2022/5/18)
CHANGES:
* Static library building improvements
   * 'ranlib' step made part of 'ar' command in archive creation.
   * 'ar' command run in object file directory to simply arguments.
* warning setting improvements
   * Added 'WARN_CXX' setting to control warnings for C++ files without overriding C defaults.
   * Changed 'WARN_EXTRA' to add warnings for both C & C++ files (WARN_C_EXTRA/WARN_CXX_EXTRA can be used for specific file types).

FIXES:
* Removed suggest-final-methods/suggest-final-types warnings from 'modern_c++' option because of false warnings when link-time-optimization isn't enabled.
* Fixed logic to share build directory for tests.

## 1.18 - general release (2021/5/29)
NEW FEATURES:
* Added support for '**' wildcard in <X>.SRC/<X>.OBJ/<X>.DEPS settings that does a directory tree search for all matching files (same behavior as 'find' shell command).<br>
  Example:<br>
    BIN1.SRC = src/**.cc<br>
      (adds all files that match *.cc in src/ and all subdirectories of src/)
* Added 'c++2b','gnu++2b','c++23','gnu++23' to supported STANDARD values.
* New make target '.gitignore' will print a sample .gitignore config file that can be used for your project.

CHANGES:
* Added '--gc-sections' linking flag to (slightly) reduce binary sizes. (-ffunction-sections/-fdata-sections not added to compile flags for now)
* Added 'missing-include-dirs' to default C/C++ warnings.
* Binary target names now automatically include '.exe' extension for Windows builds (was previously just relying on MinGW/Cygwin to add the extension).
* Binary labels (ex: BIN1) are now allowed for all <X>.DEPS settings (built binary name is substituted.)
* $(DEP1),$(DEP2),$(DEPS) output vars for FILE<X>.CMD definition now uses FILE<X>.DEPS setting after wildcards & BIN labels are evaluated.
* Added error checking for binary names to prevent .exe extension from being specified.

## 1.17 - general release (2020/12/27)
CHANGES:
* Removed CXXFLAGS/CFLAGS/ASFLAGS/LDFLAGS usage (global & target specific).  Setting these variables caused other settings to be ignored in unpredictable ways, especially if the variables were set by the environment.

## 1.16.1 - bug fix release (2020/11/17)
FIXES:
* Fixed file entries without FILE&lt;X&gt;.DEPS setting always triggering 'Cannot use DEPS if FILE&lt;X&gt;.DEPS is not set' error.

## 1.16 - general release (2020/11/3)
NEW FEATURES:
* Added OS specific settings (&lt;WINDOWS/LINUX&gt;.&lt;SETTING&gt;).  Example:
   * WINDOWS.BIN1.LIBS = -lgdi32<br>(On Windows, this setting will replace BIN1.LIBS setting value)

CHANGES:
* Added warning messages for when compiler/package/command line cache file changes trigger rebuilding.

FIXES:
* Fixed unnecessary creation of compiler command line cache files for unused source types.  Also disabled creation of compiler version cache file if there are no source file targets.

## 1.15 - general release (2020/10/16)
NEW FEATURES:
* 'SOURCE_DIR' can now set for specific targets.  If set, target will build in isolation.
* Added 'pedantic' option to enforce ISO C/C++ compliance (adds -Wpedantic -pedantic-errors compile flags).
* Added error checking for using $(DEPS) in a file command definition but FILE<X>.DEPS isn't defined.

CHANGES:
* To be consistent with BIN/LIB targets, FILE targets are deleted with 'clobber' instead of the 'clean' target.  (Files created in $(BUILD_TMP) are still deleted with the 'clean' target, however.)
* Added 'write-strings' warning to default C warnings.

FIXES:
* Fixed encoding of '$' in FILE<x>.CMD config.  File targets that need to encode '$' in the command string should use '$$' to prevent it from being evaluated as a make variable.

## 1.14 - general release (2020/7/26)
NEW FEATURES:
* <X>.LIBS (target specific LIBS settings) now accepts library label targets (i.e.: BIN1.LIBS = LIB1) to link with that library as well as include PACKAGES/LIBS from the library automatically.
* <X>.OBJS can also accept library labels like <X>.LIBS but only for static libraries.  (LIBS will prefer shared libraries if available instead of static)

CHANGES:
* Made isolated build check more robust so it will more often use a shared build instead of an unnecessary isolated build.  (does an exact flag comparison instead of just seeing that target settings are used that could generate different values for a compile command)
* Improved error detection of bad values in *_DIR settings (no spaces, no '*' wildcard).

FIXES:
* Fixed 'Unknown binary parameter' warning when setting target specific 'LINK_FLAGS' setting (i.e.: BIN1.LINK_FLAGS = xxx)
* Symlinks created by 'SYMLINKS' setting now are created in the proper directory if 'SOURCE_DIR' is set.
* Fixed wildcards in directory names for source file settings ('BIN1.SRC = */file.cc' now works as expected).

## 1.13 - general release (2020/6/29)
NEW FEATURES:
* FILE_<id>, TEST_<id> now available as file/test labels.
* Added new options:
   * static_rtlib: statically link with libgcc
   * static_stdlib: statically link with libstdc++
* Added new global/target config option 'LINK_FLAGS' - allows additional flags for link command.
* Added 'c++20','gnu++20' to supported STANDARD values.

CHANGES:
* Added additional GCC warning flags for 'modern_c++' option (-Wsuggest-final-methods, -Wsuggest-final-types).
* Various settings renamed to avoid conflicts with target labels or for consistency (no functional differences):
   * TEST_PACKAGES -> PACKAGES_TEST
   * TEST_LIBS     -> LIBS_TEST
   * TEST_FLAGS    -> FLAGS_TEST
   * DEBUG_OPT_LEVEL -> OPT_LEVEL_DEBUG
   * DEBUG_FLAGS     -> FLAGS_DEBUG
   * RELEASE_FLAGS   -> FLAGS_RELEASE
   * PROFILE_FLAGS   -> FLAGS_PROFILE
   * LIB_PREFIX -> LIBPREFIX
* All internal variables changed to start with '_' to avoid any possible conflicts with variables used in the Makefile.  (Variables starting with lower-case letters will never conflict with Makefile.mk internal variables or input/output settings.)

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
* Fixed creation of shared library links if a path is part of the library name (ex. LIB1 = lib/libname).

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

FIXES:
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

FIXES:
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
* Added LIBx.VERSION setting for adding major/minor/patch version to shared libraries built.  If version is specified, symlinks are created for .so & .so.MAJOR_VERSION version(s) of the shared library.
* Added additional target aliases for binaries/libraries when building with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR set.
* Added test failure output message.
* Output messages are now color coded:
   * cyan - binary/library built
   * magenta - file removed, warning
   * green - test passed
   * red - test failed
* Unit tests are forced to build/execute after binary builds<br>(previously they were only forced to run after library builds like binaries).

## 1.1.1 - bug fix release (2019/8/1)
* Fixed issues with building both shared & static version of a library.

## 1.1 - feature release (2019/7/7)
* Added warnings for unknown binary/library/test parameter variables<br>(for example, setting 'BIN1.OBJ' will trigger a warning since the correct variable is 'BIN1.OBJS').
* PACKAGES changes or package version changes trigger a full rebuild.
* TEST_PACKAGES changes or test package version changes trigger a relink/run of all tests.
* Made fixes to allow file/directory names starting with '-'.
* Added SYMLINKS setting for creating symlinks to the makefile directory to help building source that expects to include headers from different paths.

## 1.0 (2019/4/10)
* First public release
