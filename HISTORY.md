# Version release history
## 1.5 - feature release
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
* Added assembly compile support (.s source files).  ASFLAGS, <target>.ASFLAGS settings added to override compile flags.
* Added 'SOURCE_DIR' config to specifically the base directory of all source files.
* Binary/library targets with a directory as part of their name (i.e. BIN1 = bin/prog) will automatically create the directory as needed and will remove the directory with 'clobber'
* Added minimum version check for make (required version is 4.2 or higher)

## 1.4 - general release
* 'ENV' is set with the current build environment, 'SFX' with the binary suffix.  Both variables can be used with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR settings to allow for different directories based on build environment.
* If debug/gprof environment lib/bin output directories are unique (not shared with any other environments) then the binary suffix will be omitted.
* If building non-release target(s), aliases without binary suffix are created to simplify dependency rules.
* Error checking added to prevent OUTPUT_DIR,LIB_OUTPUT_DIR,BIN_OUTPUT_DIR settings from containing spaces.
* Made static library (archive) building less verbose.
* Added support for source files with '../' in their path.
* TESTx-g, TESTx-pg targets now correctly run test binaries even if already built like TESTx targets do.
* Fixed object file rebuild trigger failures on Makefile config change.
* Fixed incorrect object file name in dependency file (dependency checks for header changes weren't working because of this).
* Fixed case where .c files were being compiled as c++ files if the source file was in a sub directory.

## 1.3 - feature release
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

## 1.2 - feature release
* added LIBx.VERSION setting for adding major/minor/patch version to shared libraries built.  If version is specified, symlinks are created for .so & .so.MAJOR_VERSION version(s) of the shared library
* added additional target aliases for binaries/libraries when building with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR set
* added test failure output message
* output messages are now color coded:
   * cyan - binary/library built
   * magenta - file removed, warning
   * green - test passed
   * red - test failed
* unit tests are forced to build/execute after binary builds<br>(previously they were only forced to run after library builds like binaries)

## 1.1.1 - minor bug fix release
* fixed issues with building both shared & static version of a library

## 1.1 - feature release
* added warnings for unknown binary/library/test parameter variables<br>(for example, setting 'BIN1.OBJ' will trigger a warning since the correct variable is 'BIN1.OBJS')
* PACKAGES changes or package version changes trigger a full rebuild
* TEST_PACKAGES changes or test package version changes trigger a relink/run of all tests
* fixes to allow file/directory names starting with '-'
* added SYMLINKS setting for creating symlinks to the makefile directory to help building source that expects to include headers from different paths

## 1.0
* first public release
