`timescale 1ns / 1ns
`include "control_signals.vh"

module tb_alu ();

  parameter DWIDTH = 32;

  reg [DWIDTH-1:0] a, b;
  reg [`ALUOP_WIDTH-1:0] sel;
  wire [DWIDTH-1:0] y;

  // dut
  alu #(
      .DWIDTH(DWIDTH)
  ) ALU (
      .a(a),
      .b(b),
      .sel(sel),
      .y(y)
  );

  integer num_mismatch = 0;

  initial begin
    $dumpfile("tb_alu.vcd");
    $dumpvars(0, tb_alu);

    // test add
    a = 32'h00000000;
    b = 32'h00000001;
    sel = `ALU_ADD;
    #1;
    assert (y === 32'h00000001)
    else begin
      $error("ALU_ADD failed: expected %h, got %h", 32'h00000001, y);
      num_mismatch = num_mismatch + 1;
    end

    // test sub
    a = 32'h00000001;
    b = 32'h00000001;
    sel = `ALU_SUB;
    #1;
    assert (y === 32'h00000000)
    else begin
      $error("ALU_SUB failed: expected %h, got %h", 32'h00000000, y);
      num_mismatch = num_mismatch + 1;
    end

    // test and
    a = 32'hffffffff;
    b = 32'h00001000;
    sel = `ALU_AND;
    #1;
    assert (y === 32'h00001000)
    else begin
      $error("ALU_AND failed: expected %h, got %h", 32'h00001000, y);
      num_mismatch = num_mismatch + 1;
    end

    // test or
    a = 32'h00000000;
    b = 32'h00001000;
    sel = `ALU_OR;
    #1;
    assert (y === 32'h00001000)
    else begin
      $error("ALU_OR failed: expected %h, got %h", 32'h00001000, y);
      num_mismatch = num_mismatch + 1;
    end

    // test xor
    a = 32'hffffffff;
    b = 32'h00001000;
    sel = `ALU_XOR;
    #1;
    assert (y === 32'hffffefff)
    else begin
      $error("ALU_XOR failed: expected %h, got %h", 32'hffffefff, y);
      num_mismatch = num_mismatch + 1;
    end

    // test sll
    a = 32'h00000001;
    b = 32'h00000001;
    sel = `ALU_SLL;
    #1;
    assert (y === 32'h00000002)
    else begin
      $error("ALU_SLL failed: expected %h, got %h", 32'h00000002, y);
      num_mismatch = num_mismatch + 1;
    end

    // test srl
    a = 32'h00000002;
    b = 32'h00000001;
    sel = `ALU_SRL;
    #1;
    assert (y === 32'h00000001)
    else begin
      $error("ALU_SRL failed: expected %h, got %h", 32'h00000001, y);
      num_mismatch = num_mismatch + 1;
    end

    // test sra
    a = 32'h80000000;
    b = 32'h00000001;
    sel = `ALU_SRA;
    #1;
    assert (y === 32'hc0000000)
    else begin
      $error("ALU_SRA failed: expected %h, got %h", 32'hc0000000, y);
      num_mismatch = num_mismatch + 1;
    end

    // test slt
    a = 32'hffffffff;
    b = 32'h00000001;
    sel = `ALU_SLT;
    #1;
    assert (y === 32'h00000001)
    else begin
      $error("ALU_SLT failed: expected %h, got %h", 32'h00000001, y);
      num_mismatch = num_mismatch + 1;
    end

    // test sltu
    a = 32'h00000000;
    b = 32'hffffffff;
    sel = `ALU_SLTU;
    #1;
    assert (y === 32'h00000001)
    else begin
      $error("ALU_SLTU failed: expected %h, got %h", 32'h00000001, y);
      num_mismatch = num_mismatch + 1;
    end

    // test a
    a = 32'h00000000;
    b = 32'h00000001;
    sel = `ALU_A;
    #1;
    assert (y === 32'h00000000)
    else begin
      $error("ALU_A failed: expected %h, got %h", 32'h00000000, y);
      num_mismatch = num_mismatch + 1;
    end

    // test b
    a = 32'h00000000;
    b = 32'h00000001;
    sel = `ALU_B;
    #1;
    assert (y === 32'h00000001)
    else begin
      $error("ALU_B failed: expected %h, got %h", 32'h00000001, y);
      num_mismatch = num_mismatch + 1;
    end

    if (num_mismatch === 0) $display("ALU tests passed");
    else begin
      $display("ALU tests failed: %d mismatches", num_mismatch);
      $fatal();
    end
    $finish;
  end

endmodule