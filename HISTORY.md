# Version release history
* 1.1
   * added warnings for unknown binary/library/test parameter variables<br>(for example, setting 'BIN1.OBJ' will trigger a warning since the correct variable is 'BIN1.OBJS')
   * PACKAGES changes or package version changes trigger a full rebuild
   * TEST_PACKAGES changes or test package version changes trigger a relink/run of all tests
   * fixes to allow file/directory names starting with '-'
   * added SYMLINKS setting for creating symlinks to the makefile directory to help building source that expects to include headers from different paths

* 1.0
   * first public release
