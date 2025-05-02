// Asnychronous read, synchronous write
module register_file #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 5
) (
    input clk,
    // read side
    input  [AWIDTH-1:0] raddr0,
    output [DWIDTH-1:0] dout0,
    input  [AWIDTH-1:0] raddr1,
    output [DWIDTH-1:0] dout1,
    // write side
    input we,
    input [AWIDTH-1:0] waddr,
    input [DWIDTH-1:0] din
);

  wire mem_we;

  ASYNC_RAM_1W2R #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .DEPTH(2**AWIDTH)
  ) mem (
        .clk(clk),
        // read side
        .addr1(raddr0),
        .q1(dout0),
        .addr2(raddr1),
        .q2(dout1),
        // write side
        .we0(mem_we),
        .addr0(waddr),
        .d0(din)
  );

  // TODO: Implement the write enable logic
  assign mem_we = 0;

endmodule