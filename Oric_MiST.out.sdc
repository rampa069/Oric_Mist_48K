## Generated SDC file "Oric_MiST.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"

## DATE    "Sun Nov 24 19:25:22 2019"

##
## DEVICE  "EP3C25E144C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_27} -period 37.037 -waveform { 0.000 18.518 } [get_ports {CLOCK_27}]
create_clock -name {oricatmos:oricatmos|ula:inst_ula|ph[2]} -period 1.000 -waveform { 0.000 0.500 } [get_registers {oricatmos:oricatmos|ula:inst_ula|ph[2]}]
create_clock -name {SPI_SCK} -period 1.000 -waveform { 0.000 0.500 } [get_ports {SPI_SCK}]
create_clock -name {oricatmos:oricatmos|ula:inst_ula|c[0]} -period 1.000 -waveform { 0.000 0.500 } [get_registers {oricatmos:oricatmos|ula:inst_ula|c[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 9 -master_clock {CLOCK_27} [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {SPI_SCK}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {SPI_SCK}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {SPI_SCK}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {SPI_SCK}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {SPI_SCK}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {SPI_SCK}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {SPI_SCK}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {SPI_SCK}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|c[0]}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {oricatmos:oricatmos|ula:inst_ula|ph[2]}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

