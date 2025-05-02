`timescale 1ns / 1ns
`include "control_signals.vh"

module tb_immediate_generator ();

  reg  [31:0] instr;
  reg  [ 2:0] imm_sel;
  wire [31:0] imm_out;

  immediate_generator immgen (
      .instr  (instr[31:7]),
      .imm_sel(imm_sel),
      .imm_out(imm_out)
  );

  integer num_mismatches = 0;

  initial begin
    $dumpfile("tb_immediate_generator.vcd");
    $dumpvars(0, tb_immediate_generator);

    // Test I-type
    // ADDI x1, x0, 0x1
    // 0000 0000 0001 | 0000 0 | 000 | 0000 1 | 001 0011
    // 00100093
    instr   = 32'h00100093;
    imm_sel = `IMM_I;
    #1;
    assert (imm_out === 32'h00000001)
    else begin
      $error("I-type failed: expected %h, got %h", 32'h00000001, imm_out);
      num_mismatches = num_mismatches + 1;
    end

    // Test S-type
    // SW x1, 2(x0)
    // 0000 000 | 0 0001 | 0000 0 | 010 | 0001 0 | 010 0011
    // 00102123

    instr   = 32'h00102123;
    imm_sel = `IMM_S;
    #1;
    assert (imm_out === 32'h00000002)
    else begin
      $error("S-type failed: expected %h, got %h", 32'h00000002, imm_out);
      num_mismatches = num_mismatches + 1;
    end

    // Test B-type
    // BEQ x1, x0, 0x4
    // 0000 000 | 0 0001 | 0000 0 | 000 | 0010 0 | 110 0011
    instr   = 32'h00100263;
    imm_sel = `IMM_B;
    #1;
    assert (imm_out === 32'h00000004)
    else begin
      $error("B-type failed: expected %h, got %h", 32'h00000004, imm_out);
      num_mismatches = num_mismatches + 1;
    end

    // Test U-type
    // AUIPC x1, 0x1000
    // 0000 0000 0000 0000 0001 | 0000 1 | 001 0111
    instr   = 32'h00001097;
    imm_sel = `IMM_U;
    #1;
    assert (imm_out === 32'h00001000)
    else begin
      $error("U-type failed: expected %h, got %h", 32'h00001000, imm_out);
      num_mismatches = num_mismatches + 1;
    end

    // Test J-type
    // JAL x1, 0x8
    // imm: 0000 0000 0000 0000 0000 0000 0000 1000 -> imm[3] = 1
    // 0000 0000 1000 0000 0000 | 0000 1 | 110 1111
    instr   = 32'h008000ef;
    imm_sel = `IMM_J;
    #1;
    assert (imm_out === 32'h00000008)
    else begin
      $error("J-type failed: expected %h, got %h", 32'h00000008, imm_out);
      num_mismatches = num_mismatches + 1;
    end

    if (num_mismatches == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Number of mismatches: %d", num_mismatches);
      $fatal();
    end
  end

endmodule
