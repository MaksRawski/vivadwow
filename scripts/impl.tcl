source scripts/config.tcl

# place and route
opt_design
place_design
route_design

# uncomment the line below to generate a netlist
# write_verilog -force $BUILD_DIR/impl_netlist.v -mode timesim -sdf_anno true
write_bitstream -force $BUILD_DIR/top.bit
write_checkpoint -force $BUILD_DIR/checkpoints/post_impl.dcp
