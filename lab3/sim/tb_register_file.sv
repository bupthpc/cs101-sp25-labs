`timescale 1ns / 1ns

`define CLK_PERIOD 10

module tb_register_file ();
  parameter DWIDTH = 32;
  parameter AWIDTH = 5;

  reg clk = 0;
  reg we;
  reg [AWIDTH-1:0] raddr0, raddr1, waddr;
  reg [DWIDTH-1:0] din;
  wire [DWIDTH-1:0] dout0, dout1;

  // dut
  register_file #(
      .DWIDTH(DWIDTH),
      .AWIDTH(AWIDTH)
  ) rf (
      .clk(clk),
      .we(we),
      .raddr0(raddr0),
      .raddr1(raddr1),
      .waddr(waddr),
      .din(din),
      .dout0(dout0),
      .dout1(dout1)
  );

  integer num_mismatch = 0;

  always #(`CLK_PERIOD/2) clk = ~clk;

  initial begin
    $dumpfile("tb_register_file.vcd");
    $dumpvars(0, tb_register_file);

    we = 0;
    raddr0 = 0;
    raddr1 = 0;
    waddr = 0;
    din = 0;

    repeat (2) @(posedge clk);

    if (dout0 !== 32'h0) begin
      $error("dout0 expected 0, got %h", dout0);
      num_mismatch = num_mismatch + 1;
    end
    if (dout1 !== 32'h0) begin
      $error("dout1 expected 0, got %h", dout1);
      num_mismatch = num_mismatch + 1;
    end

    we = 1;
    waddr = 5;
    raddr0 = 5;
    din = 32'hdeadbeef;

    @(posedge clk);
    #1;
    if (dout0 !== 32'hdeadbeef) begin
      $error("dout0 expected deadbeef, got %h", dout0);
      num_mismatch = num_mismatch + 1;
    end

    we = 0;
    raddr1 = 5;
    // asynchroneous read, should immediately read the new value
    if (dout1 !== 32'hdeadbeef) begin
      $error("dout1 expected deadbeef, got %h", dout1);
      num_mismatch = num_mismatch + 1;
    end

    we = 1;
    raddr0 = 0;
    waddr = 0;
    din = 32'hffffffff;

    @(posedge clk);
    #1;
    if (dout0 !== 32'h00000000) begin
      $error("x0 is wired to 0, dout0 expected 00000000, got %h", dout0);
      num_mismatch = num_mismatch + 1;
    end

    if (num_mismatch > 0)
      $fatal();

    $display("Testbench passed");
    $finish;
  end

endmodule