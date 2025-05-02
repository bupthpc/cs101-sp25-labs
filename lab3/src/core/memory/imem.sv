// asynchronous read ROM
module imem #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 10,
    parameter PROG_MIF_HEX = ""
) (
    input  [AWIDTH-1:0] raddr,
    output [DWIDTH-1:0] dout
);

  ASYNC_ROM #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH),
        .MIF_HEX(PROG_MIF_HEX)
  ) mem (
    .q(dout),
    .addr(raddr)
  );

endmodule
