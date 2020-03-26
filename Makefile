export PATH :=/home/rampa/altera/13.1/quartus/bin/:$(PATH)
### programs ###
MAP=quartus_map
FIT=quartus_fit
ASM=quartus_asm
PGM=quartus_pgm

### project ###
PROJECT=Oric_MiST

TODAY = `date +"%m/%d/%y"`

### build rules ###

# all
all:
	@echo Making FPGA programming files ...
	@make map
	@make fit
	@make asm

map:
	@echo Running mapper ...
	@$(MAP) $(PROJECT)

fit:
	@echo Running fitter ...
	@$(FIT) $(PROJECT)

asm:
	@echo Running assembler ...
	@$(ASM) $(PROJECT)

run: 
	@$(PGM) -c USB-Blaster -m jtag -o "p;./output_files/$(PROJECT).sof"

run2: 
	@$(PGM) -c USB-Blaster\(Altera\) -m jtag -o "p;./output_files/$(PROJECT).sof"

# clean
clean:
	@echo clean
	@rm -rf ./output_files/
	@rm -rf ./db/
	@rm -rf ./incremental_db/

release:
	make
	cd ./output_files; cp mist.rbf ../../../bin/cores/mist/core.rbf
