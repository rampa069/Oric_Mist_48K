# Oric 48K in MiST and SiDi FPGA

Trying to implement an Oric-1 and Oric Atmos in a modern FPGA.

### Background:

There was one version made by [Gehstock](https://github.com/Gehstock/Mist_FPGA/tree/master/Computer_MiST/OricInFPGA_MiST) in github , but it is far from be functional as an oric. It only has 32k (no oric existed with that memory, only **16K** ,**48K** and **64K** so there were errors managing **HIRES** mode)  and no way to load tapes.

### What is Working

At the moment the full original machine is working (except tape recording).
* **ULA**.
* **VIA 6522**.
* **CPU 6502**.
* Tape loading working (via audio cable on the RX pin).
* Full 48K of **RAM**.
* Keyboard.
* Sound (**AY-3-8910**).
* switchable **ROM** (between 1.1a ATMOS version and 1.0 ORIC 1 version).

### TODO

 * load roms,tapes and disks from **SD CARD**.
 * Disk controller.
 * Tape recording.

### KNOWN BUGS

   * None at the moment....

## The TEAM

   * Ron Rodritty:  Team coordination and QA testing.
   * Fernando Mosquera: FPGA guru.
   * Subcritical: Verilog and VHDL.
   * ManuFerHi: Hardware consulting.
   * Chema Enguita: Oric gurú
   * SliceBit: Oric hardware Gurú
   * Ramón Martínez:  Oric hardware, Some software, and fpga coding.
   * Slingshot: SDRAM work.
   
