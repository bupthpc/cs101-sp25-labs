`include "opcode.vh"
`include "control_signals.vh"

module controller #(
    parameter DWIDTH = 32
) (
    // instruction input
    input [DWIDTH-1:0] instr,
    // next_pc select
    output reg pc_sel,
    // immediate select
    output reg [`IMM_TYPE_WIDTH-1:0] imm_sel,
    // register file write enable
    output reg rf_we,
    // branch comparator signals
    input br_eq,
    input br_lt,
    output reg br_un,
    // alu inputs select
    output reg a_sel,
    output reg b_sel,
    // alu op signals
    output reg [`ALUOP_WIDTH-1:0] alu_sel,
    // dmem signals
    output reg [`ST_TYPE_WIDTH-1:0] st_sel,
    output reg [`LD_TYPE_WIDTH-1:0] ld_sel,
    // writeback mux select
    output reg [`WB_TYPE_WIDTH-1:0] wb_sel
);

  always @(*) begin

    // TODO: initial values
    // pc_sel   = ;

    // TODO: implement the control logic
    // case (...)

  end

endmodule
