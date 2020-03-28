# Oric 48K in MiST and SiDi FPGA

Oric-1 and Oric Atmos re-implementation on a modern FPGA.

### Background:

There is one version made and ported by [Gehstock](https://github.com/Gehstock/Mist_FPGA/tree/master/Computer_MiST/OricInFPGA_MiST) at github , but it's far to be functional like an Oric. Gehstock's version for MiST board was realeased as a proof of concept with only 32KB RAM (no oric existed with that memory, only **16K** ,**48K** and **64K**)(64KB is real RAM) so there were errors managing **HIRES** mode) and no way to load audio tapes and lots of graphics errors on screen.

### What can you expect from Oric 48K in MiST and SiDi FPGA ?

This project began in november 2019 with the aim to preserve the Oric's computer family into fpga.

Actually Oric 1, Oric Atmos and Microdisc are fully functional.
* **ULA HCS10017**.
* **VIA 6522**.
* **CPU 6502**.
* Full 64KB of **RAM**.
* Keyboard managed by GI-8912.
* Sound (**AY-3-8910**).
* switchable **ROM** (between 1.1a ATMOS version and 1.0 ORIC 1 version).
* Tape loading working (via audio cable on the RX pin).
* Oric Microdisc implementation vía **CUMULUS**
* Disc Read / Write operations fully supported with IMG (RAW) format.
* Disc Sedoric/OricDOS Operating System Loading fully working

### TODO

 * Debugging, checking for possible bugs at video and improving the core.
 * Enable EDSK fully support with DSK images.

### KNOWN BUGS

   * None at the moment..., but if You find one, let Us know, please.
   
### HOW TO USE AN ORIC 1 & ATMOS WITH MiST, MiSTica and SiDi FPGA boards.

* **Create a directory called ORIC at your sd's root and put inside the disc images to work on**

   * Once the core is launched:
   
   Keyboard Shorcuts:
   * F10 - NMI button, acts like original ORIC NMI
   * F11 - Reset. Use F11 to reboot once a DSK is selected at OSD
   * F12 - OSD Main Menu.

   ![shortcuts](img/shorcuts.jpg?raw=true "Keyboard shortcuts")   
   
   * Activate FDC controller at OSD MENU
   * Select an Image from /ORIC directory, exit OSD and press F11. System will boot inmeddiately

   

## The Oric Fpga preservation TEAM

   * Ron Rodritty:  Team coordination and QA testing.
   * Fernando Mosquera: FPGA guru.
   * Subcritical: Verilog and VHDL.
   * ManuFerHi: Hardware consulting.
   * Chema Enguita: Oric Software gurú
   * SliceBit: Oric hardware Gurú
   * Ramón Martínez:  Oric hardware, Some software, and fpga coding.
   * Slingshot: SDRAM work and advisor.
   
* Kudos to: Sorgelig, Gehstock, DesUBIKado, RetroWiki and friends.

## Software redistribution.
* **SEDORIC 4.0** operating System disk image redistributed with permission from Symoon.
* **Blake's 7** game, redistributed with permission of chema enguita you can download manual and additional info from [Defence force] (http://www.defence-force.org/index.php?page=games&game=blakes7) 
