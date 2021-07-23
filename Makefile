# 
# Original version is copyright (c) 2020 Jonas Julian Jensen under MIT License
# Current version modified by Justin Abate, 2021-07
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
#
### Make project and installation-specific changes here #######################
#
# base directory of iCEcube2 installation
ICE2_DIR = /opt/lscc/iCEcube2.2017.08
# base directory of Modelsim intel FPGA starter edition
vsim20_loc = /opt/altera/20.1/modelsim_ase/linuxaloem 
#
PROJ_NAME = led_breathing
PART_CODE = iCE40HX1K
PACKAGE = TQ144
# Input HDL sources
VHD_IN = \
	hdl/reset.vhd \
	hdl/bram_two_port_simple.vhd \
	hdl/sine_rom.vhd \
	hdl/counter.vhd \
	hdl/pwm.vhd \
	hdl/led_breathing.vhd
#
# Input timing and physical constraint files
SDC_IN = phys/led_breathing.sdc
PCF_IN = phys/led_breathing.pcf
#
### Only edit below here as needed ############################################
#
# icecube subdirectory for executables
ICE2_BIN = $(ICE2_DIR)/sbt_backend/bin/linux/opt
# set TCL library reference for packer and timing
export TCL_LIBRARY=$(ICE2_DIR)/sbt_backend/bin/linux/lib/tcl8.4
# load library path
export LD_LIBRARY_PATH=$(ICE2_BIN)/synpwrap:$(ICE2_DIR)/sbt_backend/lib/linux/opt
#
# Temp name is fixed
BUILD_DIR = build
TMP_DIR = Temp
LOG_DIR = _logs
RPT_DIR = _rpts
SYN_DIR = run_synth
IMP_DIR = run_impl
PL_DIR = placed
PK_DIR = packed
RT_DIR = routed
NL_DIR = netlister
TM_DIR = timing
BM_DIR = bitmap
#
# EDIF, constraint SDC, and other output files
EDIF   = $(BUILD_DIR)/$(SYN_DIR)/$(PROJ_NAME).edf
SDC_TP = $(BUILD_DIR)/$(TMP_DIR)/sbt_temp.sdc
SDC_PL = $(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc
SDC_PK = $(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc
ROUTE  = $(BUILD_DIR)/$(IMP_DIR)/$(RT_DIR)/$(PROJ_NAME).route
SBT    = $(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_sbt.vhd
RPT    = $(BUILD_DIR)/$(IMP_DIR)/$(TM_DIR)/$(PROJ_NAME)_routed_timing.rpt
BIN    = $(BUILD_DIR)/$(IMP_DIR)/$(BM_DIR)/$(PROJ_NAME)_bitmap.bin
#
# function runners
SYN_RUN = @echo "\n\e[1;33m$(shell date +"%Y-%m-%d %T"): ======== $(1) ========\e[m\n"; \
	$(ICE2_BIN)/synpwrap/$(1)
ICE_RUN = @echo "\n\e[1;33m$(shell date +"%Y-%m-%d %T"): ======== $(1) ========\e[m\n"; \
	$(ICE2_BIN)/$(1)
#
##
.PHONY: help sim syn imp fpga edifparser sbtplacer packer sbrouter netlister sbtimer bitmap program clean

.ONESHELL:

help:
	@echo "*****************************************************"
	@echo "* Available targets"
	@echo "*"
	@echo "* help         : Print this usage description"
	@echo "*"
	@echo "* sim          : Run Modelsim simulation"
	@echo "* fpga         : Run synthesis, implementation, and iceprog"
	@echo "* program      : Program the FPGA"
	@echo "* "	
	@echo "* syn          : Run Synopsys Synplify for synthesis"
	@echo "* imp          : Run sbtplacer/packer/sbrouter/netlister/sbtimer"
	@echo "*"
	@echo "* edifparser   : Import EDIF from synthesis"
	@echo "* sbtplacer    : Run placer"
	@echo "* packer       : Run packer"
	@echo "* sbrouter     : Run router"
	@echo "* netlister    : Run netlister"
	@echo "* sbtimer      : Generate timing report"
	@echo "* bitmap       : Generate bitstream files"
	@echo "*"
	@echo "* clean        : Delete hardware implementation files"
	@echo "*****************************************************"


# Call Modelsim
sim:
	export PATH=$(vsim20_loc)
	vcom -work work hdl/reset.vhd
	vcom -work work hdl/pwm.vhd
	vcom -work work hdl/counter.vhd
	vcom -work work hdl/sine_rom.vhd
	vcom -work work hdl/led_breathing.vhd
	vcom -work work hdl/led_breathing_tb.vhd
	vsim work.led_breathing_tb -t 1fs -do src/run.do


# Run icecube2 synthesis and implementation
fpga: 
	@make clean
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(LOG_DIR)
	@make syn | tee $(BUILD_DIR)/$(LOG_DIR)/synth.log
	@make imp
	@make program


# Lattice implementation flow wrapper
imp:
	@make edifparser | tee $(BUILD_DIR)/$(LOG_DIR)/edifparser.log
	@make sbtplacer | tee $(BUILD_DIR)/$(LOG_DIR)/sbtplacer.log
	@make packer  | tee $(BUILD_DIR)/$(LOG_DIR)/packer.log
	@make sbrouter | tee $(BUILD_DIR)/$(LOG_DIR)/sbrouter.log
	@make netlister | tee $(BUILD_DIR)/$(LOG_DIR)/netlister.log
	@make sbtimer | tee $(BUILD_DIR)/$(LOG_DIR)/sbtimer.log
	@make bitmap | tee $(BUILD_DIR)/$(LOG_DIR)/bitmap.log


# Synthesis;
# inputs HDL sources from .prj file, outputs an EDIF netlist to $(EDIF)
$(EDIF): $(VHD_IN) $(SDC_IN) $(PCF_IN)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(LOG_DIR)
	@mkdir -p $(BUILD_DIR)/$(RPT_DIR)
	@mkdir -p $(BUILD_DIR)/$(SYN_DIR)

	export SYNPLIFY_PATH=$(ICE2_DIR)/synpbase
	export SBT_DIR=$(BUILD_DIR)/$(SYN_DIR)

	$(call SYN_RUN,synpwrap) -prj "src/$(PROJ_NAME)_syn.prj" \
	-log "$(BUILD_DIR)/$(SYN_DIR)/$(PROJ_NAME).srr"
	@EXIT_CODE=$$?

	@rm -f stdout.log synlog.tcl
	@if [ $$EXIT_CODE -eq 0 ]; then
		echo "$(shell date +"%Y-%m-%d %T"): set EDIF netlist at $(EDIF)"
		cp $(BUILD_DIR)/$(SYN_DIR)/$(PROJ_NAME).srr $(BUILD_DIR)/$(RPT_DIR)/synth_report.srr 
		echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== synpwrap done ========\e[m" 
	else
#		echo "$(shell date +"%Y-%m-%d %T"): gnu make got exit code $$EXIT_CODE" 
		exit $$EXIT_CODE 
	fi

syn: $(EDIF)


# EDIF parser; 
# inputs the EDIF netlist from synthesis 
# outputs timing constraints at $(BUILD_DIR)/Temp/sbt_temp.sdc and library database at $(BUILD_DIR)/$(IMP_DIR)/oadb-*
$(SDC_TP): $(EDIF)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)

	$(call ICE_RUN,edifparser) "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	"$(BUILD_DIR)/$(SYN_DIR)/$(PROJ_NAME).edf " \
	"$(BUILD_DIR)/$(IMP_DIR)" \
	"-p$(PACKAGE)" \
	"-y$(PCF_IN) " \
	"-s$(SDC_IN) " \
	-c \
	--devicename $(PART_CODE)

	@echo "$(shell date +"%Y-%m-%d %T"): set temp constraints at $(SDC_TP)"
	@echo "$(shell date +"%Y-%m-%d %T"): set library database at $(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

edifparser: $(SDC_TP)


# Placer;
# inputs timing constraints from build/Temp/sbt_temp.sdc
# outputs placed constraints at $(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc
$(SDC_PL): $(SDC_TP)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)

	$(call ICE_RUN,sbtplacer) --des-lib "$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--outdir "$(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)" \
	--device-file "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	--package $(PACKAGE) \
	--deviceMarketName $(PART_CODE) \
 	--sdc-file "$(BUILD_DIR)/$(TMP_DIR)/sbt_temp.sdc" \
	--lib-file "$(ICE2_DIR)/sbt_backend/devices/ice40HX1K.lib" \
	--effort_level std \
	--out-sdc-file "$(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc"

	@echo "$(shell date +"%Y-%m-%d %T"): set placement constraints at $(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

sbtplacer: $(SDC_PL)


# Packer;
# input the placer's design database
# output a packed SDC
# Run DRC on the netlist, then pack
# outputs packed constraints (*_packed_constr.sdc) file at $(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)
$(SDC_PK): $(SDC_PL)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)
	
	$(call ICE_RUN,packer) "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	"$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--package $(PACKAGE) \
	--outdir "$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)" \
	--DRC_only \
	--translator "$(ICE2_DIR)/sbt_backend/bin/sdc_translator.tcl" \
	--src_sdc_file "$(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc" \
	--dst_sdc_file "$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc" \
	--devicename $(PART_CODE)

	$(call ICE_RUN,packer) "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	"$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--package $(PACKAGE) \
	--outdir "$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)" \
	--translator "$(ICE2_DIR)/sbt_backend/bin/sdc_translator.tcl" \
	--src_sdc_file "$(BUILD_DIR)/$(IMP_DIR)/$(PL_DIR)/$(PROJ_NAME)_placed_constr.sdc" \
	--dst_sdc_file "$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc" \
	--devicename $(PART_CODE)
	@echo "$(shell date +"%Y-%m-%d %T"): set packed constraints at $(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

packer: $(SDC_PK)


# Router;
# inputs packed constraints, outputs standard delay file (SDF) for use by sbtimer 
$(ROUTE): $(SDC_PK)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(RT_DIR)
	
	$(call ICE_RUN,sbrouter) "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	"$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	"$(ICE2_DIR)/sbt_backend/devices/ice40HX1K.lib" \
	"$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc" \
	--outdir "$(BUILD_DIR)/$(IMP_DIR)/$(RT_DIR)" \
	--sdf_file "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_delays.sdf" \
	--pin_permutation

	@echo "$(shell date +"%Y-%m-%d %T"): set routed delay file at $(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_delays.sdf"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

sbrouter: $(ROUTE)


# Verilog & VHDL netlister
# outputs VHDL and verilog files, and *_routed_constr.sdc
$(SBT): $(ROUTE)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)
	
	$(call ICE_RUN,netlister) --verilog "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_sbt.v" \
	--vhdl "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_sbt.vhd" \
	--lib "$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--view rt \
	--device "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	--splitio \
	--in-sdc-file "$(BUILD_DIR)/$(IMP_DIR)/$(PK_DIR)/$(PROJ_NAME)_packed_constr.sdc" \
	--out-sdc-file "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_constr.sdc"

	@echo "$(shell date +"%Y-%m-%d %T"): set routed constraints at $(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_constr.sdc"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

netlister: $(SBT)


# Static timing analysis report
$(RPT): $(SBT)

	$(call RUN,SB Timer)
	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(TM_DIR)

	$(call ICE_RUN,sbtimer) --des-lib "$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--lib-file "$(ICE2_DIR)/sbt_backend/devices/ice40HX1K.lib" \
	--sdc-file "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_constr.sdc" \
	--sdf-file "$(BUILD_DIR)/$(IMP_DIR)/$(NL_DIR)/$(PROJ_NAME)_routed_delays.sdf" \
	--report-file "$(BUILD_DIR)/$(IMP_DIR)/$(TM_DIR)/$(PROJ_NAME)_routed_timing.rpt" \
	--device-file "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	--timing-summary

	@echo "$(shell date +"%Y-%m-%d %T"): set timing report at $(BUILD_DIR)/$(IMP_DIR)/$(TM_DIR)/$(PROJ_NAME)_routed_timing.rpt"
	@cp $(BUILD_DIR)/$(IMP_DIR)/$(TM_DIR)/$(PROJ_NAME)_routed_timing.rpt $(BUILD_DIR)/$(RPT_DIR)/timing_report.rpt
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

sbtimer: $(RPT)


# Generate bitstream BIN
$(BIN): $(RPT)

	@mkdir -p $(BUILD_DIR)/$(IMP_DIR)/$(BM_DIR)

	$(call ICE_RUN,bitmap) "$(ICE2_DIR)/sbt_backend/devices/ICE40P01.dev" \
	--design "$(BUILD_DIR)/$(IMP_DIR)/oadb-$(PROJ_NAME)" \
	--device_name $(PART_CODE) \
	--package $(PACKAGE) \
	--outdir "$(BUILD_DIR)/$(IMP_DIR)/$(BM_DIR)" \
	--low_power on \
	--init_ram on \
	--init_ram_bank 1111 \
	--frequency low \
	--warm_boot on

	@rm -r $(BUILD_DIR)/$(TMP_DIR)
	@echo "$(shell date +"%Y-%m-%d %T"): set BIN file at $(BUILD_DIR)/$(IMP_DIR)/$(BM_DIR)/$(PROJ_NAME).bin"
	@echo "\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== DONE ========\e[m"

bitmap: $(BIN)


# Program icestick with Yosys icestorm programmer
program :
	iceprog -b $(BIN)



clean:
	@rm -f transcript vsim.wlf
	@rm -rf $(BUILD_DIR) work/