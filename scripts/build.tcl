# https://projectf.io/posts/vivado-tcl-build-script/

# read design sources (add one line for each file)
read_verilog -sv "top.sv"

# read constraints
read_xdc "arty.xdc"

# synth
synth_design -top "top" -part "xc7a35ticsg324-1L"

# place and route
opt_design
place_design
route_design

# write bitstream
write_bitstream -force "hello.bit"
