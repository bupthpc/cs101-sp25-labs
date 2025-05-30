`timescale 1ns/100ps

`define CLOCK_PERIOD 10
`define CLOCK_FREQ 100_000_000
`define BAUD_RATE 115_200
`define FIFO_WIDTH 8
`define FIFO_DEPTH 32

/*
    This is a system level testbench that instantiates top (the FPGA design) and an off-chip UART which communicates
    with the FPGA design using the RX and TX serial lines. The testbench can control the receiver and transmitter of the
    off-chip UART with their respective ready/valid interfaces.

    In this testbench, we use the off-chip UART to send a character (ASCII 'A') to the FPGA's on-chip UART (in top).
    Then, the state machine in top gets the received character from the on-chip UART, and sends it back to the off-chip
    UART using the on-chip UART's transmitter. We expect that the received character by the off-chip UART at the end of
    this test will be an 'A'.
*/
module tb_simple_echo();
    // Generate 100 MHz clock
    reg clk = 0;
    always #(`CLOCK_PERIOD/2) clk = ~clk;

    // I/O of top
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;
    reg reset;

    // Our FPGA design
    top #(
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE),
        .FIFO_WIDTH(`FIFO_WIDTH),
        .FIFO_DEPTH(`FIFO_DEPTH)
    ) top (
        .CLK100MHZ(clk),
        .BTNC(reset),
        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX)
    );

    // I/O of the off-chip UART
    reg [7:0] data_in;
    reg data_in_valid;
    wire data_in_ready;
    wire [7:0] data_out;
    wire data_out_valid;
    reg data_out_ready;

    // The off-chip UART (on your desktop/workstation computer)
    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) off_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_TX), // Note these serial connections are the opposite of the connections to top
        .serial_out(FPGA_SERIAL_RX)
    );

    reg done = 0;
    initial begin
        $dumpfile("tb_simple_echo.vcd");
        $dumpvars(0, tb_simple_echo);

        reset = 1'b0;
        data_in = 8'h41; // Represents the character 'A' in ASCII
        data_in_valid = 1'b0;
        data_out_ready = 1'b0;
        repeat (2) @(posedge clk); #1;

        // Pulse the reset signal long enough to be detected by the debouncer in top
        reset = 1'b1;
        repeat (40) @(posedge clk); #1;
        reset = 1'b0;

        //Reset on FPGA should occur on positive edge of reset for 1 cycle

        fork
            begin
                // Wait until the off-chip UART transmitter is ready to transmit
                while (!data_in_ready) @(posedge clk); #1;

                // Once the off-chip UART transmitter is ready, pulse data_in_valid to tell it that
                // we have valid data that we want it to send over the serial line
                // Will set this on negedge to make semantics more clear
                @(negedge clk); #1;
                data_in_valid = 1'b1;
                @(negedge clk); #1;
                data_in_valid = 1'b0;
                $display("off-chip UART about to transmit: %h/%c to the on-chip UART", data_in, data_in);

                // Now the off-chip UART transmitter should be sending the data across FPGA_SERIAL_RX

                // Once all the data reaches the on-chip UART, it should set top/on_chip_uart/data_out_valid high
                while (!top.on_chip_uart.data_out_valid) @(posedge clk); #1;
                $display("on-chip UART received: %h from the off-chip UART", top.on_chip_uart.data_out);

                // Then the state machine in top should pulse top/on_chip_uart/data_out_ready high and send the data
                // it received back through the on-chip UART transmitter.
                while (!top.on_chip_uart.data_in_valid) @(posedge clk); #1;
                $display("on-chip UART about to transmit: %h to the off-chip UART", top.on_chip_uart.data_in);

                // Finally, when the data is echoed back to the off-chip UART, data_out_valid should go high. Now is when
                // the off chip UART can read the data it received and print it out to the user
                while (!data_out_valid) @(posedge clk); #1;
                $display("off-chip UART received: %h/%c from on-chip UART", data_out, data_out);
                data_out_ready = 1'b1;
                @(posedge clk); #1;
                data_out_ready = 1'b0;
                done = 1;
            end
            begin
                repeat (35000) @(posedge clk);
                if (!done) begin
                    $error("Failure: timing out");
                    $fatal();
                end
            end
        join

        repeat (100) @(posedge clk);
        $display("%h/%c should have been sent and %h/%c echoed back", 8'h41, 8'h41, 8'h41, 8'h41);
        $finish();
    end
endmodule