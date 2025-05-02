module switches_mmio #(
    parameter FPGA_SWITCH_NUM = 16,
    parameter SWITCHES_BASE_ADDR = 32'h8000_0020
) (
    input clk,
    input rst,

    input [31:0] addr,
    input [31:0] din,
    input [3:0] wbe,
    output [31:0] dout,

    input [FPGA_SWITCH_NUM-1:0] switches
);

    // TODO(Optional): Implement the Switches MMIO module

endmodule