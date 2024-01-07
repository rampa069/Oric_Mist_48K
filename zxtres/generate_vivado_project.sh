cd ..
make BOARD=zxtres init
cd zxtres
python3 qpf2xpr.py --demist_zx3a200 --vga_output 3
#python3 qpf2xpr.py --demist_zx3a35 --vga_output 3 > "$LOG" 2>&1
source /opt/Xilinx/Vivado/2022.2/settings64.sh 
vivado -mode tcl -source generate_vivado_project.tcl
