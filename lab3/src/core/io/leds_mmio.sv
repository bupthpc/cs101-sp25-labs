module leds_mmio #(
    parameter FPGA_LED_NUM = 16,
    parameter LEDS_BASE_ADDR = 32'h8000_0000
) (
    input clk,
    input rst,

    input [31:0] addr,
    input [31:0] din,
    input [3:0] wbe,
    output [31:0] dout,

    output [FPGA_LED_NUM-1:0] leds
);

    // TODO(Optional): Implement the LEDs MMIO module

endmodule