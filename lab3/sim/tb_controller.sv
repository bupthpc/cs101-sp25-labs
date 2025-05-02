`timescale 1ns / 1ns
`include "control_signals.vh"
`include "opcode.vh"

module tb_controller ();

  parameter DWIDTH = 32;

  reg [DWIDTH-1:0] instr;
  reg br_eq, br_lt;

  wire pc_sel;
  wire [`IMM_TYPE_WIDTH-1:0] imm_sel;
  wire rf_we;
  wire br_un;
  wire a_sel, b_sel;
  wire [`ALUOP_WIDTH-1:0] alu_sel;
  wire [`ST_TYPE_WIDTH-1:0] st_sel;
  wire [`LD_TYPE_WIDTH-1:0] ld_sel;
  wire [`WB_TYPE_WIDTH-1:0] wb_sel;

  // dut
  controller #(
      .DWIDTH(DWIDTH)
  ) CONTROLLER (
      .instr  (instr),
      .pc_sel (pc_sel),
      .imm_sel(imm_sel),
      .rf_we  (rf_we),
      .br_eq  (br_eq),
      .br_lt  (br_lt),
      .br_un  (br_un),
      .a_sel  (a_sel),
      .b_sel  (b_sel),
      .alu_sel(alu_sel),
      .st_sel (st_sel),
      .ld_sel (ld_sel),
      .wb_sel (wb_sel)
  );

  integer num_mismatch = 0;

  initial begin
    $dumpfile("tb_controller.vcd");
    $dumpvars(0, tb_controller);

    // test LUI
    // lui x1, 0x1000
    instr = 32'h010000b7;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_U &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_B &&
            st_sel === 0 &&
            rf_we === 1 &&
            wb_sel === `WB_ALU
    )
    else begin
      $error("LUI failed");
      num_mismatch = num_mismatch + 1;
    end

    // test AUIPC
    // auipc  x1, 0x1
    instr = 32'h00001097;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_U &&
            a_sel === `A_PC &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD &&
            st_sel === 0 &&
            rf_we === 1 &&
            wb_sel === `WB_ALU
    )
    else begin
      $error("AUIPC failed");
      num_mismatch = num_mismatch + 1;
    end

    // test JAL
    // jal x2, 0x100
    instr = 32'h1000016f;
    #1;
    assert (
            pc_sel === `PC_ALU &&
            imm_sel === `IMM_J &&
            a_sel === `A_PC &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD &&
            st_sel === 0 &&
            rf_we === 1 &&
            wb_sel === `WB_PC
    )
    else begin
      $error("JAL failed");
      num_mismatch = num_mismatch + 1;
    end


    // test JALR
    // jalr x3, x2, 0x2
    instr = 32'h002101e7;
    #1;
    assert (
            pc_sel === `PC_ALU &&
            imm_sel === `IMM_I &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD &&
            st_sel === 0 &&
            rf_we === 1 &&
            wb_sel === `WB_PC
    )
    else begin
      $error("JALR failed");
      num_mismatch = num_mismatch + 1;
    end

    // test BRANCH
    // beq x1, x2, 0x4
    instr = 32'h00208263;
    // taken
    br_eq = 1;
    br_lt = 0;
    #1;
    assert (
            pc_sel === `PC_ALU &&
            imm_sel === `IMM_B &&
            rf_we === 0 &&
            st_sel === 0 &&
            a_sel === `A_PC &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD
    )
    else begin
      $error("BEQ(taken) failed");
      num_mismatch = num_mismatch + 1;
    end

    // not taken
    br_eq = 0;
    br_lt = 0;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_B &&
            rf_we === 0 &&
            st_sel === 0 &&
            a_sel === `A_PC &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD
    )
    else begin
      $error("BEQ(not taken) failed");
      num_mismatch = num_mismatch + 1;
    end


    // test STORE
    // sw x1, 4(x2)
    instr = 32'h00112223;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_S &&
            rf_we === 0 &&
            a_sel === `A_REG &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD &&
            st_sel === `ST_WORD
    )
    else begin
      $error("SW failed");
      num_mismatch = num_mismatch + 1;
    end

    // test LOAD
    // lw x1, 4(x2)
    instr = 32'h00412083;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_I &&
            rf_we === 1 &&
            a_sel === `A_REG &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_ADD &&
            st_sel === 0 &&
            ld_sel === `LD_WORD &&
            wb_sel === `WB_MEM
    )
    else begin
      $error("LW failed");
      num_mismatch = num_mismatch + 1;
    end

    // test ARI-RTYPE
    // sub x1, x2, x3
    instr = 32'h403100b3;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            rf_we === 1 &&
            a_sel === `A_REG &&
            b_sel === `B_REG &&
            alu_sel === `ALU_SUB &&
            st_sel === 0 &&
            wb_sel === `WB_ALU
    )
    else begin
      $error("SUB failed");
      num_mismatch = num_mismatch + 1;
    end

    // test ARI-ITYPE
    // srai x1, x2, 2
    instr = 32'h40215093;
    #1;
    assert (
            pc_sel === `PC_PLUS_4 &&
            imm_sel === `IMM_I &&
            rf_we === 1 &&
            a_sel === `A_REG &&
            b_sel === `B_IMM &&
            alu_sel === `ALU_SRA &&
            st_sel === 0 &&
            wb_sel === `WB_ALU
    )
    else begin
      $error("SRAI failed");
      num_mismatch = num_mismatch + 1;
    end

    if (num_mismatch == 0) begin
      $display("All tests passed");
    end else begin
      $display("Failed %0d tests", num_mismatch);
      $fatal();
    end

    $finish;
  end

endmodule