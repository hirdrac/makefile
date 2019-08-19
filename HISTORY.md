# Version release history
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
