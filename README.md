# Vivadwow
Project template for Verilog Vivado projects but without having the Vivado project structure.

I've been using [vivado-wrapper](https://git.recolic.net/root/vivado-wrapper) for a while but what annoyed me were the build times.
Each time you wanted to generate the bitstream you would need to wait for it to synthesize 
the design even if you ran the synthesis a minute ago. Having just a regular vivado project would
fix that, but then you would have an ugly project structure and in the end vivado just runs tcl scripts for everything.
Heart of this project is a Makefile which runs simple tcl scripts to do basic synthesis and implementation.
Adding support for VHDL is probably quite trivial but I'm not interested in maintaining it.

The example project I have here is just an instantiation of the `xpm_memory_sprom` module. 
But because of how generic it is, you should be able to do more complex projects easily.

## Dependencies
- Vivado - tested using version 2023.2
- [iverilog](https://github.com/steveicarus/iverilog) for simulation
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) for programming

## Usage
Configuration is done in `Makefile` and `scripts/config.tcl`.

- `make sim TARGET=my_module` - Runs the testbench for the module `my_module`. 
  Will look for a file `my_module_tb.v` (or `.sv`) in `src/` or any of its subdirectories. 
  By default chooses `top` module which must be stored in `src/top.v` (or `.sv`).

- `make synth` - Synthesizes the entire design.

- `make impl` or `make bit` - Do PnR and generate the bitstream, which will be put in `build/top.bit`

- `make reports` - Generates various reports and puts them in `build/reports/`. To get all possible reports
make sure to run `make impl` first, otherwise you will just get reports from the synthesis.

- `make prog` - Programs the board using openFPGALoader. 
  Make sure to put the name of the board you are trying to program in `Makefile`'s `BOARD_NAME` variable.

- `make burn` - Programs the board but will write the bitstream into flash, changing this way the default design loaded by the FPGA.
