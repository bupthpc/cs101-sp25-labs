module uart_mmio #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter UART_CNTL_ADDR = 32'h80000010,
    parameter UART_RX_DATA_ADDR = 32'h80000014,
    parameter UART_TX_DATA_ADDR = 32'h80000018
) (
    input clk,
    input rst,

    input [31:0] addr,
    input [31:0] din,
    input [3:0] wbe,
    output reg [31:0] dout,

    input serial_in,
    output serial_out
);

    wire uart_rx_valid, uart_tx_ready;
    reg  uart_rx_ready, uart_tx_valid;
    
    wire [7:0] uart_recv_data;
    wire [7:0] uart_send_data = din[7:0];

    // uart #(
    //     .CLOCK_FREQ(CLOCK_FREQ),
    //     .BAUD_RATE(BAUD_RATE)
    // ) uart_inst (
    //     .clk(clk),
    //     .reset(rst),
    //     .data_in(uart_send_data),
    //     .data_in_valid(uart_tx_valid),
    //     .data_in_ready(uart_tx_ready),
    //     .data_out(uart_recv_data),
    //     .data_out_valid(uart_rx_valid),
    //     .data_out_ready(uart_rx_ready),
    //     .serial_in(serial_in),
    //     .serial_out(serial_out)
    // );

    always @(*) begin
        uart_rx_ready = 1'b0;
        uart_tx_valid = 1'b0;

        case (addr)
            UART_CNTL_ADDR: begin
                // TODO: dout
            end

            UART_RX_DATA_ADDR: begin
                // TODO: dout and handshake
            end

            UART_TX_DATA_ADDR: begin
                // TODO: handshake
            end
        endcase
    end

endmodule