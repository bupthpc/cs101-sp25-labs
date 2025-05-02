module top #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter FIFO_WIDTH = 8,
    parameter FIFO_DEPTH = 32
)(
    input CLK100MHZ,
    input BTNC, // center button for reset
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    wire rst = BTNC;

    reg [7:0] data_in;
    wire [7:0] data_out;
    wire data_in_valid, data_in_ready, data_out_valid, data_out_ready;

    // This UART is on the FPGA and communicates with your desktop
    // using the FPGA_SERIAL_TX, and FPGA_SERIAL_RX signals. The ready/valid
    // interface for this UART is used on the FPGA design.
    uart # (
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(CLK100MHZ),
        .reset(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    // loopback fifo
    wire fifo_wr_en, fifo_full, fifo_rd_en, fifo_empty;
    wire [FIFO_WIDTH-1:0] fifo_din, fifo_dout;
    wire fifo_dout_valid;

    fifo #(
        .WIDTH(FIFO_WIDTH),
        .DEPTH(FIFO_DEPTH)
    ) buffer (
        .clk(CLK100MHZ),
        .rst(rst),
        .wr_en(fifo_wr_en),
        .din(fifo_din),
        .full(fifo_full),
        .rd_en(fifo_rd_en),
        .dout(fifo_dout),
        .empty(fifo_empty)
    );

    // TODO: Implement the logic to connect the UART to the FIFO

    
endmodule