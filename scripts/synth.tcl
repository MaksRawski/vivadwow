source scripts/config.tcl

read_verilog $SRC_FILES

synth_design -top $TOP_MODULE -part $PART_NAME
write_checkpoint -force $BUILD_DIR/checkpoints/post_synth.dcp
