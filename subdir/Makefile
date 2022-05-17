# call Makefile in base directory if 'make' is executed here
base_dir := ..

%: ; @$(MAKE) -C $(base_dir)$(MAKEFLAGS) $@
# NOTE: doesn't work for targets that match a file in the current directory
#  (can't do wildcard .PHONY)

# make sure these targets always work
targets := all clean clobber tests info help release debug profile
.PHONY: $(targets)
$(targets): ; @$(MAKE) -C $(base_dir)$(MAKEFLAGS) $@

## END
