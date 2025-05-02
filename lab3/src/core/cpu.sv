module cpu # (
    parameter CPU_CLOCK_FREQ = 100_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200,
    parameter PROG_MIF_HEX = "",
    parameter FPGA_LED_NUM = 16,
    parameter FPGA_SWITCH_NUM = 16,
    parameter LEDS_BASE_ADDR = 32'h8000_0000,
    parameter UART_CNTL_ADDR = 32'h8000_0010,
    parameter UART_RX_DATA_ADDR = 32'h8000_0014,
    parameter UART_TX_DATA_ADDR = 32'h8000_0018,
    parameter SWITCHES_BASE_ADDR = 32'h8000_0020
) (
    input clk,
    input rst,
    output [FPGA_LED_NUM-1:0] leds,
    input [FPGA_SWITCH_NUM-1:0] switches,
    input serial_in,
    output serial_out
);
    localparam DWIDTH = 32;

    wire [DWIDTH-1:0] instr;
    reg [DWIDTH-1:0] wb_data; // write back

    //**************** PC ****************
    wire [DWIDTH-1:0] pc;
    reg [DWIDTH-1:0] next_pc;
    wire [DWIDTH-1:0] pc_plus_4 = pc + 4;
    REGISTER_R #(
        .N(DWIDTH),
        .INIT(RESET_PC)
    ) pc_reg (
        .q(pc),
        .d(next_pc),
        .rst(rst),
        .clk(clk)
    );

    //**************** Instruction Memory ****************
    localparam IMEM_AWIDTH = 10;
    wire [IMEM_AWIDTH-1:0] imem_raddr;
    wire [DWIDTH-1:0] imem_dout;

    imem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(IMEM_AWIDTH),
        .PROG_MIF_HEX(PROG_MIF_HEX)
    ) imem_inst (
        .raddr(imem_raddr),
        .dout(imem_dout)
    );

    
    //**************** Data Memory ****************
    localparam DMEM_AWIDTH = 12;
    wire [DMEM_AWIDTH-1:0] dmem_addr;
    wire [DWIDTH/8-1:0] dmem_wbe;
    wire [DWIDTH-1:0] dmem_din, dmem_dout;
    wire dmem_en;

    dmem #(
        .DWIDTH(DWIDTH),
        .AWIDTH(DMEM_AWIDTH)
    ) dmem_inst (
        .addr(dmem_addr),
        .wbe(dmem_wbe),
        .din(dmem_din),
        .dout(dmem_dout),
        .en(dmem_en),
        .clk(clk)
    );


    //**************** Register File ****************
    localparam RF_AWDITH = 5;
    wire [RF_AWDITH-1:0] rf_waddr, rf_raddr0, rf_raddr1;
    reg [DWIDTH-1:0] rf_din;
    wire [DWIDTH-1:0] rf_dout0, rf_dout1;
    wire rf_we;

    register_file #(
        .DWIDTH(DWIDTH),
        .AWIDTH(RF_AWDITH)
    ) rf_inst (
        .raddr0(rf_raddr0),
        .raddr1(rf_raddr1),
        .dout0(rf_dout0),
        .dout1(rf_dout1),
        .waddr(rf_waddr),
        .din(rf_din),
        .we(rf_we),
        .clk(clk)
    );

    //**************** ALU ****************
    reg [DWIDTH-1:0] alu_a, alu_b;
    wire [DWIDTH-1:0] alu_out;
    wire [`ALUOP_WIDTH-1:0] alu_sel;
    alu #(
        .DWIDTH(DWIDTH)
    ) alu_inst (
        .a(alu_a),
        .b(alu_b),
        .y(alu_out),
        .sel(alu_sel)
    );

    //**************** Immediate Generator ****************
    wire [`IMM_TYPE_WIDTH-1:0] imm_sel;
    wire [DWIDTH-1:0] imm_out;
    immediate_generator immgen_inst (
        .instr(instr[31:7]),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    //**************** Branch Comparator ****************
    wire [DWIDTH-1:0] br_a, br_b;
    wire br_un, br_eq, br_lt;
    branch_comparator #(
        .DWIDTH(DWIDTH)
    ) br_comp_inst (
        .a(br_a),
        .b(br_b),
        .br_un(br_un),
        .br_eq(br_eq),
        .br_lt(br_lt)
    );

    //**************** Control Unit ****************
    wire cntl_pc_sel;
    wire [`IMM_TYPE_WIDTH-1:0] cntl_imm_sel;
    wire cntl_rf_we;
    wire cntl_br_eq, cntl_br_lt, cntl_br_un;
    wire cntl_a_sel, cntl_b_sel;
    wire [`ALUOP_WIDTH-1:0] cntl_alu_sel;
    wire [`ST_TYPE_WIDTH-1:0] cntl_st_sel;
    wire [`LD_TYPE_WIDTH-1:0] cntl_ld_sel;
    wire [`WB_TYPE_WIDTH-1:0] cntl_wb_sel;

    controller # (
        .DWIDTH(DWIDTH)
    ) cntl_inst (
        .instr(instr),
        .pc_sel(cntl_pc_sel),
        .imm_sel(cntl_imm_sel),
        .rf_we(cntl_rf_we),
        .br_eq(cntl_br_eq),
        .br_lt(cntl_br_lt),
        .br_un(cntl_br_un),
        .a_sel(cntl_a_sel),
        .b_sel(cntl_b_sel),
        .alu_sel(cntl_alu_sel),
        .st_sel(cntl_st_sel),
        .ld_sel(cntl_ld_sel),
        .wb_sel(cntl_wb_sel)
    );


    //**************** Connections **************** 

    //******** next pc logic ********
    // TODO: connect the next pc logic

    //******** immediate logic ********
    // TODO: connect the immediate logic

    //******** register file ********
    // TODO: connect the register file

    //******** branch comparator ********
    // TODO: connect the branch comparator

    //******** ALU ********
    // TODO: connect the ALU

    //******** instruction memory ********
    // TODO: connect the instruction memory


    //**************************************************
    //**************** memory mapped io ****************
    //**************************************************
    reg [DWIDTH-1:0] mmio_addr, mmio_din, mmio_dout;
    reg [DWIDTH/8-1:0] mmio_wbe;

    reg [DWIDTH-1:0] mmio_dout_inner; // which device?

    assign mmio_addr = alu_out;

    // sw, sh, sb
    always @(*) begin
        case (cntl_st_sel)
            `ST_WORD: begin
                mmio_wbe = 4'b1111;
                mmio_din = rf_dout1;
            end
            `ST_HALF: begin
                case (alu_out[1:0])
                    2'b00: begin
                        mmio_wbe = 4'b0011;
                        mmio_din = rf_dout1;
                    end
                    2'b10: begin
                        mmio_wbe = 4'b1100;
                        mmio_din = rf_dout1 << 16;
                    end
                endcase
            end
            `ST_BYTE: begin
                case (alu_out[1:0])
                    2'b00: begin
                        mmio_wbe = 4'b0001;
                        mmio_din = rf_dout1;
                    end
                    2'b01: begin
                        mmio_wbe = 4'b0010;
                        mmio_din = rf_dout1 << 8;
                    end
                    2'b10: begin
                        mmio_wbe = 4'b0100;
                        mmio_din = rf_dout1 << 16;
                    end
                    2'b11: begin
                        mmio_wbe = 4'b1000;
                        mmio_din = rf_dout1 << 24;
                    end
                endcase
            end
        endcase
    end
    
    // lw, lh, lhu, lb, lbu
    always @(*) begin
        case (cntl_ld_sel)
            `LD_WORD: begin
                mmio_dout = mmio_dout_inner;
            end
            `LD_HALF: begin
                case (alu_out[1:0])
                    2'b00: mmio_dout = {{16{mmio_dout_inner[15]}}, mmio_dout_inner[15:0]};
                    2'b10: mmio_dout = {{16{mmio_dout_inner[31]}}, mmio_dout_inner[31:16]};
                endcase
            end
            `LD_HALF_UN: begin
                case (alu_out[1:0])
                    2'b00: mmio_dout = {{16{1'b0}}, mmio_dout_inner[15:0]};
                    2'b10: mmio_dout = {{16{1'b0}}, mmio_dout_inner[31:16]};
                endcase
            end
            `LD_BYTE: begin
                case (alu_out[1:0])
                    2'b00: mmio_dout = {{24{mmio_dout_inner[7]}}, mmio_dout_inner[7:0]};
                    2'b01: mmio_dout = {{24{mmio_dout_inner[15]}}, mmio_dout_inner[15:8]};
                    2'b10: mmio_dout = {{24{mmio_dout_inner[23]}}, mmio_dout_inner[23:16]};
                    2'b11: mmio_dout = {{24{mmio_dout_inner[31]}}, mmio_dout_inner[31:24]};
                endcase
            end
            `LD_BYTE_UN: begin
                case (alu_out[1:0])
                    2'b00: mmio_dout = {{24{1'b0}}, mmio_dout_inner[7:0]};
                    2'b01: mmio_dout = {{24{1'b0}}, mmio_dout_inner[15:8]};
                    2'b10: mmio_dout = {{24{1'b0}}, mmio_dout_inner[23:16]};
                    2'b11: mmio_dout = {{24{1'b0}}, mmio_dout_inner[31:24]};
                endcase
            end
        endcase
    end

    //******** data memory ********
    assign dmem_en = (mmio_addr[31] == 1'b1) ? 1'b0 : 1'b1; // The MSB of the address is 1 for MMIO
    assign dmem_addr = mmio_addr[DWIDTH-1:2];
    assign dmem_wbe = mmio_wbe;
    assign dmem_din = mmio_din;

    //******** uart ********
    wire [DWIDTH-1:0] uart_mmio_dout;

    uart_mmio #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .UART_CNTL_ADDR(UART_CNTL_ADDR),
        .UART_RX_DATA_ADDR(UART_RX_DATA_ADDR),
        .UART_TX_DATA_ADDR(UART_TX_DATA_ADDR)
    ) uart_mmio_inst (
        .addr(mmio_addr),
        .din(mmio_din),
        .wbe(mmio_wbe),
        .dout(uart_mmio_dout),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .rst(rst),
        .clk(clk)
    );

    //******** leds ********
    wire [DWIDTH-1:0] leds_mmio_dout;

    leds_mmio #(
        .FPGA_LED_NUM(FPGA_LED_NUM),
        .LEDS_BASE_ADDR(LEDS_BASE_ADDR)
    ) leds_mmio_inst (
        .addr(mmio_addr),
        .din(mmio_din),
        .wbe(mmio_wbe),
        .dout(leds_mmio_dout),
        .leds(leds),
        .rst(rst),
        .clk(clk)
    );

    //******** switches ********
    wire [DWIDTH-1:0] switches_mmio_dout;

    switches_mmio #(
        .FPGA_SWITCH_NUM(FPGA_SWITCH_NUM),
        .SWITCHES_BASE_ADDR(SWITCHES_BASE_ADDR)
    ) switches_mmio_inst (
        .addr(mmio_addr),
        .din(mmio_din),
        .wbe(mmio_wbe),
        .dout(switches_mmio_dout),
        .switches(switches),
        .rst(rst),
        .clk(clk)
    );

    //******** mmio dout select logic ********
    always @(*) begin
        if (mmio_addr[31:16] === 16'h8000) begin
            case (mmio_addr[7:4])
                4'h0: mmio_dout_inner = leds_mmio_dout;
                4'h1: mmio_dout_inner = uart_mmio_dout;
                4'h2: mmio_dout_inner = switches_mmio_dout;
            endcase
        end
        else begin
            mmio_dout_inner = dmem_dout;
        end
    end

    //******** write back ********
    // TODO: connect the write back logic

endmodule
