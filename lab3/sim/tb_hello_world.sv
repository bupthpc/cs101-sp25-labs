`timescale 1ns/1ns

`include "opcode.vh"
`include "mem_path.vh"

module tb_hello_world();
  reg clk, rst;
  parameter CPU_CLOCK_PERIOD = 10;
  parameter CPU_CLOCK_FREQ   = 1_000_000_000 / CPU_CLOCK_PERIOD;
  localparam BAUD_RATE       = 115200;
  localparam BAUD_PERIOD     = 1_000_000_000 / BAUD_RATE;
  localparam FPGA_LED_NUM    = 16;
  localparam TIMEOUT_CYCLE   = 1_000_000;

  initial clk = 0;
  always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

  reg  serial_in;
  wire serial_out;
  wire [FPGA_LED_NUM-1:0] leds;

  cpu # (
    .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
    .RESET_PC(32'h1000_0000),
    .BAUD_RATE(BAUD_RATE),
    .FPGA_LED_NUM(FPGA_LED_NUM),
    .LEDS_BASE_ADDR(32'h8000_0000),
    .UART_CNTL_ADDR(32'h8000_0010),
    .UART_RX_DATA_ADDR(32'h8000_0014),
    .UART_TX_DATA_ADDR(32'h8000_0018)
  ) cpu (
    .clk(clk),
    .rst(rst),
    .leds(leds),
    .serial_in(1'b1),
    .serial_out(serial_out)
  );

  reg [31:0] cycle;
  always @(posedge clk) begin
    if (rst === 1)
      cycle <= 0;
    else
      cycle <= cycle + 1;
  end

  integer i;
  reg [9:0] char_to_host;

  // Host off-chip UART <-- FPGA on-chip UART (transmitter)
  task check_fpga_to_host;
    input [7:0] expected_result;
    begin
        wait (serial_out === 1'b0);
        $display("[time %t, sim. cycle %d] [Host (tb) <-- FPGA_SERIAL_TX] Start bit detected", $time, cycle);

        for (i = 0; i < 10; i = i + 1) begin
            // sample output half-way through the baud period to avoid tricky edge cases
            #(BAUD_PERIOD / 2);
            char_to_host[i] = serial_out;
            #(BAUD_PERIOD / 2);
        end

        $display("[time %t, sim. cycle %d] [Host (tb) <-- FPGA_SERIAL_TX] Got char: start_bit=%b, payload=8'h%h, stop_bit=%b",
                    $time, cycle, char_to_host[0], char_to_host[8:1], char_to_host[9]);
        // if (char_to_host[0] !== 1'b0 || char_to_host[9] !== 1'b1) begin
        //     $error("[time %t, sim. cycle %d] [Host (tb) <-- FPGA_SERIAL_TX] Error: start bit or stop bit is incorrect",
        //                 $time, cycle);
        //     $finish;
        // end
        if (char_to_host[8:1] !== expected_result) begin
            $error("[time %t, sim. cycle %d] [Host (tb) <-- FPGA_SERIAL_TX] Error: payload is incorrect",
                        $time, cycle);
        end
    end
  endtask

  initial begin
    $dumpfile("tb_hello_world.vcd");
    $dumpvars(0, tb_hello_world);

    #1;
    $readmemh("../sw/hello_world/hello_world.hex", `IMEM_PATH.mem, 0, 1024-1);
    $readmemh("../sw/hello_world/hello_world.hex", `DMEM_PATH.mem, 0, 4096-1);

    rst = 1;

    // Hold reset for a while
    repeat (10) @(posedge clk);

    @(negedge clk);
    rst = 0;

    // Delay for some time
    repeat (10) @(posedge clk);

    check_fpga_to_host(8'h48); // 'H'
    check_fpga_to_host(8'h65); // 'e'
    check_fpga_to_host(8'h6C); // 'l'
    check_fpga_to_host(8'h6C); // 'l'
    check_fpga_to_host(8'h6F); // 'o'
    check_fpga_to_host(8'h2C); // ','
    check_fpga_to_host(8'h20); // ' '
    check_fpga_to_host(8'h57); // 'W'
    check_fpga_to_host(8'h6F); // 'o'
    check_fpga_to_host(8'h72); // 'r'
    check_fpga_to_host(8'h6C); // 'l'
    check_fpga_to_host(8'h64); // 'd'
    check_fpga_to_host(8'h21); // '!'
    check_fpga_to_host(8'h0D); // '\r'
    check_fpga_to_host(8'h0A); // '\n'

    $finish;
  end

  initial begin
    repeat (TIMEOUT_CYCLE) @(posedge clk);
    $display("Timeout!");
    $fatal();
  end

endmodule