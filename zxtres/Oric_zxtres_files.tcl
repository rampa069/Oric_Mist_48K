set_global_assignment -name QIP_FILE ../Oric.qip
set_global_assignment -name VHDL_FILE ../demistify_config_pkg.vhd
set_global_assignment -name QIP_FILE ../DeMiSTify/controller/controller.qip
set_global_assignment -name VHDL_FILE ../firmware/controller_rom1_word.vhd
set_global_assignment -name VHDL_FILE ../firmware/controller_rom2_word.vhd
set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:../build_id.tcl
