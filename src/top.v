module top (
    input        CLK100MHZ,
    output [3:0] led
);

  reg [24:0] counter = 0;
  always @(posedge CLK100MHZ) counter <= counter + 1;
  assign led = counter[24:21];

endmodule
