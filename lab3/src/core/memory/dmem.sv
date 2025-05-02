module dmem #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 10
) (
    input                 clk,
    input                 en,
    input  [DWIDTH/8-1:0] wbe,   // write byte enable
    input  [  AWIDTH-1:0] addr,
    input  [  DWIDTH-1:0] din,
    output [  DWIDTH-1:0] dout
);

    ASYNC_RAM_WBE #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) mem (
        .clk(clk),
        .en(en),
        .wbe(wbe),
        .addr(addr),
        .d(din),
        .q(dout)
    );

endmodule
