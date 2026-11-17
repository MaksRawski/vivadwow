source scripts/config.tcl

read_xdc $CONSTRAINT

# place and route
opt_design
place_design
route_design

# uncomment the line below to generate a netlist
# write_verilog -force $BUILD_DIR/impl_netlist.v -mode timesim -sdf_anno true
write_checkpoint -force $BUILD_DIR/checkpoints/post_impl.dcp
