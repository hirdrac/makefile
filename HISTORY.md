# Version release history
* 1.4 - general release
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

* 1.3 - feature release
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

* 1.2 - feature release
   * added LIBx.VERSION setting for adding major/minor/patch version to shared libraries built.  If version is specified, symlinks are created for .so & .so.MAJOR_VERSION version(s) of the shared library
   * added additional target aliases for binaries/libraries when building with OUTPUT_DIR/LIB_OUTPUT_DIR/BIN_OUTPUT_DIR set
   * added test failure output message
   * output messages are now color coded:
      * cyan - binary/library built
      * magenta - file removed, warning
      * green - test passed
      * red - test failed
   * unit tests are forced to build/execute after binary builds<br>(previously they were only forced to run after library builds like binaries)

* 1.1.1 - minor bug fix release
   * fixed issues with building both shared & static version of a library

* 1.1 - feature release
   * added warnings for unknown binary/library/test parameter variables<br>(for example, setting 'BIN1.OBJ' will trigger a warning since the correct variable is 'BIN1.OBJS')
   * PACKAGES changes or package version changes trigger a full rebuild
   * TEST_PACKAGES changes or test package version changes trigger a relink/run of all tests
   * fixes to allow file/directory names starting with '-'
   * added SYMLINKS setting for creating symlinks to the makefile directory to help building source that expects to include headers from different paths

* 1.0
   * first public release
