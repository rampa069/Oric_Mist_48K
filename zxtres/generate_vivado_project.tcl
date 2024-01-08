# Create the project and directory structure
create_project -force zxtres ./ -part xc7a200tfbg484-2
#
# Add sources to the project
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/defs_demistify.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/defs_demistify.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/zxtres/zxtres_top.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/zxtres/pll.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/zxtres/pll.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/zxtres/rtl/joydecoder.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/zxtres/rtl/joydecoder.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/psg.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/psg.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/mist.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/user_io.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/user_io.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/data_io.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/data_io.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/mist_video.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/mist_video.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/scandoubler.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/scandoubler.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/osd.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/osd.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/arcade_inputs.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/arcade_inputs.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/video_cleaner.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/video_cleaner.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/rgb2ypbpr.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/rgb2ypbpr.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/cofi.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/sd_card.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/sd_card.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/ide.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/ide.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/ide_fifo.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/ide_fifo.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/cdda_fifo.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/cdda_fifo.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/i2c_master.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/i2c_master.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/i2s.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/i2s.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/spdif.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/spdif.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/mist-modules/dac.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/oricatmos.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/sdram.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/microdisc.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/wd1793.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/T65/T65_Pack.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/T65/T65_MCode.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/T65/T65_ALU.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/T65/T65.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/rom/MICRODIS.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/rom/BASIC10.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/rom/BASIC11A.vhdl}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/Oric.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/ula.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/via6522.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/video.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/keyboard.sv}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/Oric_tap_player.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/Oric_tap_player.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/progressbar.v}
set_property file_type SystemVerilog [get_files  {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/rtl/progressbar.v}]
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/demistify_config_pkg.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/substitute_mcu.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_pkg.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_alu.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_shifter.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_aligner.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_aligner_le.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_decode.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_fetchloadstore.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_hazard.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_debug.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/eightthirtytwo_cpu.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/altera/debug_bridge_jtag.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/altera/debug_virtualjtag.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/EightThirtyTwo/RTL/debug_fifo.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/firmware/controller_rom.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/simple_uart.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/jtag_uart.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/io_ps2_com.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/interrupt_controller.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/timer_controller.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/DeMiSTify/controller/spi_controller.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/firmware/controller_rom1_word.vhd}
add_files -fileset sources_1 {/home/jordi/Documents/Coding/FPGA/Deca_17/_A_WIP/Oric_Mist_48K/firmware/controller_rom2_word.vhd}
add_files -fileset sources_1 {./defs.vh}
add_files -fileset sources_1 {./build_id.vh}
add_files -fileset constrs_1 {./zxtres.xdc}
set_property IS_GLOBAL_INCLUDE true [get_files ./defs.vh]
set_property IS_GLOBAL_INCLUDE true [get_files ./build_id.vh]
set_property IS_GLOBAL_INCLUDE true [get_files ../defs_demistify.v]
set_property top zxtres_top [current_fileset]
set_property -name "include_dirs" -value "[file normalize "../../../modules/jtframe/hdl/inc"] [file normalize "../hdl"]" -objects [current_fileset]
set_property generic {VGA_OUTPUT=3 CLKVIDEO=48 HSTART=128} [current_fileset]
create_run -name sintesis_A35T -part xc7a35tfgg484-2 -flow {Vivado Synthesis 2022} -strategy "Flow_AreaOptimized_high" -report_strategy {Vivado Synthesis Default Reports} -constrset constrs_1
create_run -name demist_zx3a35 -part xc7a35tfgg484-2 -flow {Vivado Implementation 2022} -strategy "Flow_RunPhysOpt" -report_strategy {Vivado Implementation Default Reports} -constrset constrs_1 -parent_run sintesis_A35T
create_run -name sintesis_A100T -part xc7a100tfgg484-2 -flow {Vivado Synthesis 2022} -strategy "Vivado Synthesis Defaults" -report_strategy {Vivado Synthesis Default Reports} -constrset constrs_1
create_run -name demist_zx3a100 -part xc7a100tfgg484-2 -flow {Vivado Implementation 2022} -strategy "Vivado Implementation Defaults" -report_strategy {Vivado Implementation Default Reports} -constrset constrs_1 -parent_run sintesis_A100T
create_run -name sintesis_A200T -part xc7a200tfbg484-2 -flow {Vivado Synthesis 2022} -strategy "Vivado Synthesis Defaults" -report_strategy {Vivado Synthesis Default Reports} -constrset constrs_1
create_run -name demist_zx3a200 -part xc7a200tfbg484-2 -flow {Vivado Implementation 2022} -strategy "Vivado Implementation Defaults" -report_strategy {Vivado Implementation Default Reports} -constrset constrs_1 -parent_run sintesis_A200T
set_property -name "auto_incremental_checkpoint" -value "1" -objects [get_runs sintesis_A200T]
set_property -name "steps.synth_design.args.incremental_mode" -value "off" -objects [get_runs sintesis_A200T]
set_property -name "auto_incremental_checkpoint" -value "1" -objects [get_runs sintesis_A100T]
set_property -name "steps.synth_design.args.incremental_mode" -value "off" -objects [get_runs sintesis_A100T]
set_property -name "auto_incremental_checkpoint" -value "1" -objects [get_runs sintesis_A35T]
set_property -name "steps.synth_design.args.incremental_mode" -value "off" -objects [get_runs sintesis_A35T]
set_property -name "steps.write_bitstream.args.bin_file" -value "1" -objects [get_runs demist_zx3a200]
set_property -name "steps.write_bitstream.args.bin_file" -value "1" -objects [get_runs demist_zx3a100]
set_property -name "steps.write_bitstream.args.bin_file" -value "1" -objects [get_runs demist_zx3a35]

current_run [get_runs sintesis_A200T]
delete_runs "impl_1"
delete_runs "synth_1"
if {[catch {

reset_run sintesis_A200T
launch_runs demist_zx3a200 -to_step write_bitstream

wait_on_run demist_zx3a200

puts "Implementation ZXTRES A200T done!"
} errorstring]} {
put "Error while creating A200T version.
Exiting Vivado"

quit
}
put "Exiting Vivado"
close_project

quit
