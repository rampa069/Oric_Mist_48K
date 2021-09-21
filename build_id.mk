DEMISTIFYPATH=DeMiSTify
include $(DEMISTIFYPATH)/site.mk

.PHONY: build_id.v
build_id.v: mist/build_id_verilog.tcl
	$(Q13)/quartus_sh -t mist/build_id_verilog.tcl

