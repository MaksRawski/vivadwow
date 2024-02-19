# all the project/device specific config is done in scripts/config.tcl
# make sure the BUILD_DIR and TOP_MODULE here are the same as the ones in config.tcl
VIVADO_EXEC := /opt/Xilinx/Vivado/2023.2/bin/vivado
BUILD_DIR   := build
TOP_MODULE  := top

# TODO: add sim target which calls iverilog

$(BUILD_DIR)/checkpoints/post_synth.dcp:
	@mv $(BUILD_DIR)/logs/synth.log $(BUILD_DIR)/logs/synth.backup.log 2> /dev/null || true
	mkdir -p $(BUILD_DIR)/logs
	$(VIVADO_EXEC) -mode batch -nojournal -log $(BUILD_DIR)/logs/synth.log -source scripts/synth.tcl

synth: $(BUILD_DIR)/checkpoints/post_synth.dcp

$(BUILD_DIR)/$(TOP_MODULE).bit $(BUILD_DIR)/checkpoints/post_impl.dcp: $(BUILD_DIR)/checkpoints/post_synth.dcp
	@mv $(BUILD_DIR)/logs/impl.log $(BUILD_DIR)/logs/impl.backup.log 2> /dev/null || true
	$(VIVADO_EXEC) $(BUILD_DIR)/checkpoints/post_synth.dcp -mode batch -nojournal -log $(BUILD_DIR)/logs/impl.log -source scripts/impl.tcl

# even though semantically those targets are different they will run the same recipe
impl: $(BUILD_DIR)/checkpoints/post_impl.dcp
bit: $(BUILD_DIR)/$(TOP_MODULE).bit

# NOTE: there will be more reports than post_synth_util.rpt
$(BUILD_DIR)/reports/post_synth_util.rpt: $(BUILD_DIR)/checkpoints/post_synth.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_EXEC) $(BUILD_DIR)/checkpoints/post_synth.dcp -mode batch -nojournal -nolog -source scripts/synth_reports.tcl

# NOTE: there will be more reports than clock_util.rpt
$(BUILD_DIR)/reports/clock_util.rpt: $(BUILD_DIR)/checkpoints/post_impl.dcp
	mkdir -p $(BUILD_DIR)/reports
	$(VIVADO_EXEC) $(BUILD_DIR)/checkpoints/post_impl.dcp -mode batch -nojournal -nolog -source scripts/impl_reports.tcl

# to create a report we need the design to be at least synthesized
# and recipe for post_synth_util.rpt requires synthesis
# additionally if the design is implemented we generate the implementation reports
reports: $(BUILD_DIR)/reports/post_synth_util.rpt
	@[ -e "$(BUILD_DIR)/checkpoints/post_impl.dcp" ] && $(MAKE) $(BUILD_DIR)/reports/clock_util.rpt || true

prog: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader --detect $(BUILD_DIR)/$(TOP_MODULE).bit

burn: $(BUILD_DIR)/$(TOP_MODULE).bit
	openFPGALoader --detect -f $(BUILD_DIR)/$(TOP_MODULE).bit

clean:
	rm -rf build .Xil

.PHONY: sim synth impl bit prog clean
