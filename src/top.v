module top (
    input clk,
    input [3:0] sw,
    output [3:0] led
);
  reg rsta = 0;
  reg enable = 1;

  // https://docs.xilinx.com/r/en-US/ug953-vivado-7series-libraries/XPM_MEMORY_SPROM
  xpm_memory_sprom #(
      .ADDR_WIDTH_A(4),  // DECIMAL
      .AUTO_SLEEP_TIME(0),  // DECIMAL
      .CASCADE_HEIGHT(0),  // DECIMAL
      .ECC_BIT_RANGE("7:0"),  // String
      .ECC_MODE("no_ecc"),  // String
      .ECC_TYPE("none"),  // String
      .IGNORE_INIT_SYNTH(0),  // DECIMAL
      .MEMORY_INIT_FILE("none"),  // String
      .MEMORY_INIT_PARAM("1,2,3,4,5,6,7,8,9,A,B,C,D,E,F"),  // String
      .MEMORY_OPTIMIZATION("true"),  // String
      .MEMORY_PRIMITIVE("auto"),  // String
      .MEMORY_SIZE(16),  // DECIMAL
      .MESSAGE_CONTROL(0),  // DECIMAL
      .RAM_DECOMP("auto"),  // String
      .READ_DATA_WIDTH_A(4),  // DECIMAL
      .READ_LATENCY_A(2),  // DECIMAL
      .READ_RESET_VALUE_A("0"),  // String
      .RST_MODE_A("SYNC"),  // String
      .SIM_ASSERT_CHK(0),  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_MEM_INIT(1),  // DECIMAL
      .USE_MEM_INIT_MMI(0),  // DECIMAL
      .WAKEUP_TIME("disable_sleep")  // String
  ) xpm_memory_sprom_inst (
      .dbiterra(dbiterra),  // 1-bit output: Leave open.
      .douta   (led),       // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      .sbiterra(sbiterra),  // 1-bit output: Leave open.
      .addra   (sw),        // ADDR_WIDTH_A-bit input: Address for port A read operations.
      .clka    (clka),      // 1-bit input: Clock signal for port A.
      .ena     (enable),    // 1-bit input: Memory enable signal for port A. Must be high on clock
      // cycles when read operations are initiated. Pipelined internally.

      .injectdbiterra(injectdbiterra),  // 1-bit input: Do not change from the provided value.
      .injectsbiterra(injectsbiterra),  // 1-bit input: Do not change from the provided value.
      .regcea(regcea),  // 1-bit input: Do not change from the provided value.
      .rsta(rsta),  // 1-bit input: Reset signal for the final port A output register stage.
                    // Synchronously resets output port douta to the value specified by
                    // parameter READ_RESET_VALUE_A.

      .sleep(sleep)  // 1-bit input: sleep signal to enable the dynamic power saving feature.
  );


endmodule
