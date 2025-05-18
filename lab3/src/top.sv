module top # (
    parameter CPU_CLOCK_FREQ = 10_000_000, // TODO: try differenct clk freq
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 9600,
    parameter PROG_MIF_HEX = "", // TODO: path/to/your/mif.hex
    parameter FPGA_LED_NUM = 16,
    parameter FPGA_SWITCH_NUM = 16,
    parameter LEDS_BASE_ADDR = 32'h8000_0000,
    parameter UART_CNTL_ADDR = 32'h8000_0010,
    parameter UART_RX_DATA_ADDR = 32'h8000_0014,
    parameter UART_TX_DATA_ADDR = 32'h8000_0018,
    parameter SWITCHES_BASE_ADDR = 32'h8000_0020
) (
    input FPGA_CLOCK_100MHZ,
    input CPU_RESETN,
    output [FPGA_LED_NUM-1:0] FPGA_LEDS,
    input [FPGA_SWITCH_NUM-1:0] FPGA_SWITCHES,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);

    wire cpu_clk;
    wire cpu_rst = ~CPU_RESETN;
    
    // Vivado IP: Clocking Wizard
    // TODO: try different clk freq
    clk_wiz_0 clk_wiz_inst (
        .clk_in1(FPGA_CLOCK_100MHZ),
        .reset(cpu_rst),
        .clk_out1(cpu_clk)
    );

    wire [FPGA_LED_NUM-1:0] leds;
    assign FPGA_LEDS = leds;

    wire serial_in = FPGA_SERIAL_RX;
    wire serial_out;
    assign FPGA_SERIAL_TX = serial_out;

    wire switches = FPGA_SWITCHES;
    
    cpu # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .RESET_PC(RESET_PC),
        .BAUD_RATE(BAUD_RATE),
        .PROG_MIF_HEX(PROG_MIF_HEX),
        .FPGA_LED_NUM(FPGA_LED_NUM),
        .FPGA_SWITCH_NUM(FPGA_SWITCH_NUM),
        .LEDS_BASE_ADDR(LEDS_BASE_ADDR),
        .UART_CNTL_ADDR(UART_CNTL_ADDR),
        .UART_RX_DATA_ADDR(UART_RX_DATA_ADDR),
        .UART_TX_DATA_ADDR(UART_TX_DATA_ADDR),
        .SWITCHES_BASE_ADDR(SWITCHES_BASE_ADDR)
    ) cpu (
        .clk(cpu_clk),
        .rst(cpu_rst),
        .leds(leds),
        .switches(switches),
        .serial_in(serial_in),
        .serial_out(serial_out)
    );

endmodule
