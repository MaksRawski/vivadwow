module top_tb;
  reg clk = 0;
  wire [3:0] led;

  top DUT (
      .CLK100MHZ(clk),
      .led(led)
  );

  always #1 clk = ~clk;
  always #4194304 $strobe("%4b", led);

endmodule
