##############################################################################################
# SYNTHESIS AND IMPLEMENTATION CONFIG IS DONE IN scripts/config.tcl
# if you don't see a variable here it's probably there
#
# make sure these 3 variables here have the same values as the ones in config.tcl
SRC_DIR     := src
BUILD_DIR   := build
TOP_MODULE  := top

# path to vivado binary
VIVADO_BIN := /opt/Xilinx/Vivado/2023.2/bin/vivado

# list of IPs (directories containing HDL files) to include, each must be prefixed with '-y'
IPS := -y/opt/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/

# board name to be used for programming with openFPGALoader
BOARD_NAME := arty_s7_50
##############################################################################################


# NOTE: you can change the target of simulation by running: make sim TARGET=my_module
# this assumes that there is my_module_tb.{v,sv} in SRC_DIR
TARGET = $(TOP_MODULE)
sim: build/tbs/$(TARGET)
	./build/tbs/$(TARGET)

build/tbs/%:
	@mkdir -p build/tbs
	iverilog -g2012 -s $(TARGET)_tb -o build/tbs/$* $(IPS) src/$*_tb.*

$(BUILD_DIR)/checkpoints/post_synth.dcp:
	@mv $(BUILD_DIR)/logs/synth.log $(BUILD_DIR)/logs/synth.backup.log 2> /dev/null || true
	mkdir -p $(BUILD_DIR)/logs
	$(VIVADO_BIN) -mode batch -nojournal -log $(BUILD_DIR)/logs/synth.log -source scripts/synth.tcl

synth: $(BUILD_DIR)/checkpoints/post_synth.dcp

$(BUILD_DIR)/$(TOP_MODULE).bit $(BUILD_DIR)/checkpoints/post_impl.dcp: $(BUILD_DIR)/checkpoints/post_synth.dcp
	@mv $(BUILD_DIR)/logs/impl.log $(BUILD_DIR)/logs/impl.backup.log 2> /dev/null || true
	$(VIVADO_BIN) $(BUILD_DIR)/checkpoints/post_synth.dcp -mode batch -nojournal -log $(BUILD_DIR)/logs/impl.log -source scripts/impl.tcl

# even though semantically those targets are different they will run the same recipe
impl: $(BUILD_DIR)/checkpoints/post_impl.dcp
bit: $(BUILD_DIR)/$(TOP_MODULE).bit

# NOTE: there will be more reports than post_synth_util.rpt
$(BUILD_DIR)/reports/post_synth_util.rpt: $(BUILD_DIR)/checkpoints/post_synth.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_BIN) $(BUILD_DIR)/checkpoints/post_synth.dcp -mode batch -nojournal -nolog -source scripts/synth_reports.tcl

# NOTE: there will be more reports than clock_util.rpt
$(BUILD_DIR)/reports/clock_util.rpt: $(BUILD_DIR)/checkpoints/post_impl.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_BIN) $(BUILD_DIR)/checkpoints/post_impl.dcp -mode batch -nojournal -nolog -source scripts/impl_reports.tcl

# to create a report we need the design to be at least synthesized
# and recipe for post_synth_util.rpt requires synthesis
# additionally if the design is implemented we generate the implementation reports
reports: $(BUILD_DIR)/reports/post_synth_util.rpt
	@[ -e "$(BUILD_DIR)/checkpoints/post_impl.dcp" ] && $(MAKE) $(BUILD_DIR)/reports/clock_util.rpt || true

prog: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader -b $(BOARD_NAME) $(BUILD_DIR)/$(TOP_MODULE).bit

burn: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader -b $(BOARD_NAME) -f $(BUILD_DIR)/$(TOP_MODULE).bit

clean:
	rm -rf $(BUILD_DIR) .Xil

.PHONY: sim synth impl bit prog clean
