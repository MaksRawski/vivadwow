source scripts/config.tcl

write_bitstream -force $BUILD_DIR/top.bit
write_checkpoint -force $BUILD_DIR/checkpoints/post_bit.dcp
