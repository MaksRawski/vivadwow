##############################################################################################
# SYNTHESIS AND IMPLEMENTATION CONFIG IS DONE IN scripts/config.tcl
# if you don't see a variable here it's probably there
#
# make sure these 3 variables here have the same values as the ones in config.tcl
SRC_DIR     := src
TBS_DIR     := tbs
BUILD_DIR   := build
TOP_MODULE  := top

# path to vivado binary
VIVADO_BIN := /opt/Xilinx/Vivado/2023.2/bin/vivado

# board name to be used for programming with openFPGALoader
BOARD_NAME := arty_s7_50
##############################################################################################

all: synth

# NOTE: you can change the target of simulation by running: make sim TARGET=my_module
# this assumes that there is my_module.v in TBS_DIR
TARGET = $(TOP_MODULE)
sim: build/tbs/$(TARGET)
	./build/tbs/$(TARGET)

build/tbs/%: $(TBS_DIR)/%_tb.v $(SRC_DIR)/*
	@mkdir -p build/tbs
	iverilog -Wall -y$(SRC_DIR) -I$(SRC_DIR) -o $@ $<

synth: $(BUILD_DIR)/checkpoints/post_synth.dcp

$(BUILD_DIR)/checkpoints/post_synth.dcp: $(SRC_DIR)/*
	@mv $(BUILD_DIR)/logs/synth.log $(BUILD_DIR)/logs/synth.backup.log 2> /dev/null || true
	mkdir -p $(BUILD_DIR)/logs
	$(VIVADO_BIN) -mode batch -nojournal -log $(BUILD_DIR)/logs/synth.log -source scripts/synth.tcl

impl: $(BUILD_DIR)/checkpoints/post_impl.dcp
$(BUILD_DIR)/checkpoints/post_impl.dcp: $(BUILD_DIR)/checkpoints/post_synth.dcp
	@mv $(BUILD_DIR)/logs/impl.log $(BUILD_DIR)/logs/impl.backup.log 2> /dev/null || true
	$(VIVADO_BIN) $< -mode batch -nojournal -log $(BUILD_DIR)/logs/impl.log -source scripts/impl.tcl

bit: $(BUILD_DIR)/$(TOP_MODULE).bit
$(BUILD_DIR)/$(TOP_MODULE).bit: $(BUILD_DIR)/checkpoints/post_impl.dcp
	@mv $(BUILD_DIR)/logs/bit.log $(BUILD_DIR)/logs/bit.backup.log 2> /dev/null || true
	$(VIVADO_BIN) $< -mode batch -nojournal -log $(BUILD_DIR)/logs/bit.log -source scripts/bit.tcl

gui: $(BUILD_DIR)/vivado_project.xpr
	@mv $(BUILD_DIR)/logs/gui.log $(BUILD_DIR)/logs/gui.backup.log 2> /dev/null || true
	$(VIVADO_BIN) $< -nojournal -log $(BUILD_DIR)/logs/gui.log

$(BUILD_DIR)/vivado_project.xpr: 
	$(VIVADO_BIN) -mode batch -nojournal -log $(BUILD_DIR)/logs/bit.log -source scripts/proj_init.tcl

# to create a report we need the design to be at least synthesized
# and recipe for post_synth_util.rpt requires synthesis
# additionally if the design is implemented we generate the implementation reports
reports: $(BUILD_DIR)/reports/post_synth_util.rpt
	@[ -e "$(BUILD_DIR)/checkpoints/post_impl.dcp" ] && $(MAKE) $(BUILD_DIR)/reports/clock_util.rpt || true

# NOTE: there will be more reports than post_synth_util.rpt
$(BUILD_DIR)/reports/post_synth_util.rpt: $(BUILD_DIR)/checkpoints/post_synth.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_BIN) $(BUILD_DIR)/checkpoints/post_synth.dcp -mode batch -nojournal -nolog -source scripts/synth_reports.tcl

# NOTE: there will be more reports than clock_util.rpt
$(BUILD_DIR)/reports/clock_util.rpt: $(BUILD_DIR)/checkpoints/post_impl.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_BIN) $(BUILD_DIR)/checkpoints/post_impl.dcp -mode batch -nojournal -nolog -source scripts/impl_reports.tcl

prog: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader -b $(BOARD_NAME) $(BUILD_DIR)/$(TOP_MODULE).bit

burn: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader -b $(BOARD_NAME) -f $(BUILD_DIR)/$(TOP_MODULE).bit

clean:
	rm -rf $(BUILD_DIR) .Xil

.PHONY: sim synth impl bit gui prog clean
