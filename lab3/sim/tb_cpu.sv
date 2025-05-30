`timescale 1ns/1ns

`include "opcode.vh"
`include "mem_path.vh"

module tb_cpu();
  reg clk, rst;
  parameter CPU_CLOCK_PERIOD = 10; // 100 MHz
  parameter CPU_CLOCK_FREQ   = 1_000_000_000 / CPU_CLOCK_PERIOD;

  initial clk = 0;
  always #(CPU_CLOCK_PERIOD/2) clk = ~clk;

  // Init PC with 32'h1000_0000
  cpu # (
    .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
    .RESET_PC(32'h1000_0000)
  ) cpu (
    .clk(clk),
    .rst(rst),
    .serial_in(1'b1),
    .serial_out()
  );

  wire [31:0] timeout_cycle = 10;

  // Reset IMem, DMem, and RegFile before running new test
  task reset;
    integer i;
    begin
      for (i = 0; i < `RF_PATH.DEPTH; i = i + 1) begin
        `RF_PATH.mem[i] = 0;
      end
      for (i = 0; i < `DMEM_PATH.DEPTH; i = i + 1) begin
        `DMEM_PATH.mem[i] = 0;
      end
      for (i = 0; i < `IMEM_PATH.DEPTH; i = i + 1) begin
        `IMEM_PATH.mem[i] = 0;
      end
    end
  endtask

  task reset_cpu;
    @(negedge clk);
    rst = 1;
    @(negedge clk);
    rst = 0;
  endtask

  task init_rf;
    integer i;
    begin
      for (i = 1; i < `RF_PATH.DEPTH; i = i + 1) begin
        `RF_PATH.mem[i] = 100 * i + 1;
      end
    end
  endtask

  reg [31:0] cycle;
  reg done;
  reg [31:0]  current_test_id = 0;
  reg [255:0] current_test_type;
  reg [31:0]  current_output;
  reg [31:0]  current_result;
  reg all_tests_passed = 0;


  // Check for timeout
  // If a test does not return correct value in a given timeout cycle,
  // we terminate the testbench
  initial begin
    while (all_tests_passed === 0) begin
      @(posedge clk);
      if (cycle === timeout_cycle) begin
        $display("[Failed] Timeout at [%d] test %s, expected_result = %h, got = %h",
                current_test_id, current_test_type, current_result, current_output);
        $fatal();
      end
    end
  end

  always @(posedge clk) begin
    if (done === 0)
      cycle <= cycle + 1;
    else
      cycle <= 0;
  end

  // Check result of RegFile
  // If the write_back (destination) register has correct value (matches "result"), test passed
  // This is used to test instructions that update RegFile
  task check_result_rf;
    input [31:0]  rf_wa;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`RF_PATH.mem[rf_wa] !== result) begin
        current_output = `RF_PATH.mem[rf_wa];
        @(negedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask

  // Check result of DMem
  // If the memory location of DMem has correct value (matches "result"), test passed
  // This is used to test store instructions
  task check_result_dmem;
    input [31:0]  addr;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`DMEM_PATH.mem[addr] !== result) begin
        current_output = `DMEM_PATH.mem[addr];
        @(negedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask

  integer i;

  reg [4:0]  RD, RS1, RS2;
  reg [31:0] RD1, RD2;
  reg [4:0]  SHAMT;
  reg [31:0] IMM, IMM0, IMM1, IMM2, IMM3;
  reg [14:0] INST_ADDR;
  reg [14:0] DATA_ADDR;
  reg [14:0] DATA_ADDR0, DATA_ADDR1, DATA_ADDR2, DATA_ADDR3;
  reg [14:0] DATA_ADDR4, DATA_ADDR5, DATA_ADDR6, DATA_ADDR7;
  reg [14:0] DATA_ADDR8, DATA_ADDR9;

  reg [31:0] JUMP_ADDR;

  reg [31:0]  BR_TAKEN_OP1  [5:0];
  reg [31:0]  BR_TAKEN_OP2  [5:0];
  reg [31:0]  BR_NTAKEN_OP1 [5:0];
  reg [31:0]  BR_NTAKEN_OP2 [5:0];
  reg [2:0]   BR_TYPE       [5:0];
  reg [255:0] BR_NAME_TK1   [5:0];
  reg [255:0] BR_NAME_TK2   [5:0];
  reg [255:0] BR_NAME_NTK   [5:0];

  initial begin
    $dumpfile("tb_cpu.vcd");
    $dumpvars(0, tb_cpu);

    #0;
    rst = 0;

    // Reset the CPU
    rst = 1;
    // Hold reset for a while
    repeat (10) @(posedge clk);

    @(negedge clk);
    rst = 0;

    // Test R-Type Insts --------------------------------------------------
    // - ADD, SUB, SLL, SLT, SLTU, XOR, OR, AND, SRL, SRA
    // - SLLI, SRLI, SRAI
    reset();

    // We can also use $random to generate random values for testing
    RS1 = 1; RD1 = -100;
    RS2 = 2; RD2 =  200;
    RD  = 3;
    `RF_PATH.mem[RS1] = RD1;
    `RF_PATH.mem[RS2] = RD2;
    SHAMT           = 5'd20;
    INST_ADDR       = 14'h0000;

    `IMEM_PATH.mem[INST_ADDR + 0]  = {`FNC7_0, RS2,   RS1, `FNC_ADD_SUB, 5'd3,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 1]  = {`FNC7_1, RS2,   RS1, `FNC_ADD_SUB, 5'd4,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 2]  = {`FNC7_0, RS2,   RS1, `FNC_SLL,     5'd5,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 3]  = {`FNC7_0, RS2,   RS1, `FNC_SLT,     5'd6,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 4]  = {`FNC7_0, RS2,   RS1, `FNC_SLTU,    5'd7,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 5]  = {`FNC7_0, RS2,   RS1, `FNC_XOR,     5'd8,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 6]  = {`FNC7_0, RS2,   RS1, `FNC_OR,      5'd9,  `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 7]  = {`FNC7_0, RS2,   RS1, `FNC_AND,     5'd10, `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 8]  = {`FNC7_0, RS2,   RS1, `FNC_SRL_SRA, 5'd11, `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 9]  = {`FNC7_1, RS2,   RS1, `FNC_SRL_SRA, 5'd12, `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[INST_ADDR + 10] = {`FNC7_0, SHAMT, RS1, `FNC_SLL,     5'd13, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 11] = {`FNC7_0, SHAMT, RS1, `FNC_SRL_SRA, 5'd14, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 12] = {`FNC7_1, SHAMT, RS1, `FNC_SRL_SRA, 5'd15, `OPC_ARI_ITYPE};

    reset_cpu();

    check_result_rf(5'd3,  32'h00000064, "R-Type ADD");
    check_result_rf(5'd4,  32'hfffffed4, "R-Type SUB");
    check_result_rf(5'd5,  32'hffff9c00, "R-Type SLL");
    check_result_rf(5'd6,  32'h1,        "R-Type SLT");
    check_result_rf(5'd7,  32'h0,        "R-Type SLTU");
    check_result_rf(5'd8,  32'hffffff54, "R-Type XOR");
    check_result_rf(5'd9,  32'hffffffdc, "R-Type OR");
    check_result_rf(5'd10, 32'h00000088, "R-Type AND");
    check_result_rf(5'd11, 32'h00ffffff, "R-Type SRL");
    check_result_rf(5'd12, 32'hffffffff, "R-Type SRA");
    check_result_rf(5'd13, 32'hf9c00000, "R-Type SLLI");
    check_result_rf(5'd14, 32'h00000fff, "R-Type SRLI");
    check_result_rf(5'd15, 32'hffffffff, "R-Type SRAI");

    // Test I-Type Insts --------------------------------------------------
    // - ADDI, SLTI, SLTUI, XORI, ORI, ANDI
    // - LW, LH, LB, LHU, LBU
    // - JALR

    // Test I-type arithmetic instructions
    reset();

    RS1 = 1; RD1 = -100;
    `RF_PATH.mem[RS1] = RD1;
    IMM             = -200;
    INST_ADDR       = 14'h0000;

    `IMEM_PATH.mem[INST_ADDR + 0] = {IMM[11:0], RS1, `FNC_ADD_SUB, 5'd3, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 1] = {IMM[11:0], RS1, `FNC_SLT,     5'd4, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 2] = {IMM[11:0], RS1, `FNC_SLTU,    5'd5, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 3] = {IMM[11:0], RS1, `FNC_XOR,     5'd6, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 4] = {IMM[11:0], RS1, `FNC_OR,      5'd7, `OPC_ARI_ITYPE};
    `IMEM_PATH.mem[INST_ADDR + 5] = {IMM[11:0], RS1, `FNC_AND,     5'd8, `OPC_ARI_ITYPE};

    reset_cpu();

    check_result_rf(5'd3,  32'hfffffed4, "I-Type ADD");
    check_result_rf(5'd4,  32'h00000000, "I-Type SLT");
    check_result_rf(5'd5,  32'h00000000, "I-Type SLTU");
    check_result_rf(5'd6,  32'h000000a4, "I-Type XOR");
    check_result_rf(5'd7,  32'hffffffbc, "I-Type OR");
    check_result_rf(5'd8,  32'hffffff18, "I-Type AND");

    // Test I-type load instructions
    reset();

    `RF_PATH.mem[1] = 32'h3000_0100;
    IMM0            = 32'h0000_0000;
    IMM1            = 32'h0000_0001;
    IMM2            = 32'h0000_0002;
    IMM3            = 32'h0000_0003;
    INST_ADDR       = 14'h0000;
    DATA_ADDR       = (`RF_PATH.mem[1] + IMM0[11:0]) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0] = {IMM0[11:0], 5'd1, `FNC_LW,  5'd2,  `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 1] = {IMM0[11:0], 5'd1, `FNC_LH,  5'd3,  `OPC_LOAD};
    // `IMEM_PATH.mem[INST_ADDR + 3] = {IMM1[11:0], 5'd1, `FNC_LH,  5'd4,  `OPC_LOAD}; // unaligned
    `IMEM_PATH.mem[INST_ADDR + 4] = {IMM2[11:0], 5'd1, `FNC_LH,  5'd5,  `OPC_LOAD};
    // `IMEM_PATH.mem[INST_ADDR + 5] = {IMM3[11:0], 5'd1, `FNC_LH,  5'd6,  `OPC_LOAD}; // unaligned
    `IMEM_PATH.mem[INST_ADDR + 6] = {IMM0[11:0], 5'd1, `FNC_LB,  5'd7,  `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 7] = {IMM1[11:0], 5'd1, `FNC_LB,  5'd8,  `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 8] = {IMM2[11:0], 5'd1, `FNC_LB,  5'd9,  `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 9] = {IMM3[11:0], 5'd1, `FNC_LB,  5'd10, `OPC_LOAD};

    `IMEM_PATH.mem[INST_ADDR + 10] = {IMM0[11:0], 5'd1, `FNC_LHU, 5'd11, `OPC_LOAD};
    // `IMEM_PATH.mem[INST_ADDR + 11] = {IMM1[11:0], 5'd1, `FNC_LHU, 5'd12, `OPC_LOAD}; // unaligned
    `IMEM_PATH.mem[INST_ADDR + 12] = {IMM2[11:0], 5'd1, `FNC_LHU, 5'd13, `OPC_LOAD};
    // `IMEM_PATH.mem[INST_ADDR + 13] = {IMM3[11:0], 5'd1, `FNC_LHU, 5'd14, `OPC_LOAD}; // unaligned

    `IMEM_PATH.mem[INST_ADDR + 14] = {IMM0[11:0], 5'd1, `FNC_LBU, 5'd15, `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 15] = {IMM1[11:0], 5'd1, `FNC_LBU, 5'd16, `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 16] = {IMM2[11:0], 5'd1, `FNC_LBU, 5'd17, `OPC_LOAD};
    `IMEM_PATH.mem[INST_ADDR + 17] = {IMM3[11:0], 5'd1, `FNC_LBU, 5'd18, `OPC_LOAD};

    `DMEM_PATH.mem[DATA_ADDR] = 32'hdeadbeef;

    reset_cpu();

    check_result_rf(5'd2,  32'hdeadbeef, "I-Type LW");

    check_result_rf(5'd3,  32'hffffbeef, "I-Type LH 0");
    // check_result_rf(5'd4,  32'hffffbeef, "I-Type LH 1");
    check_result_rf(5'd5,  32'hffffdead, "I-Type LH 2");
    // check_result_rf(5'd6,  32'hffffdead, "I-Type LH 3");

    check_result_rf(5'd7,  32'hffffffef, "I-Type LB 0");
    check_result_rf(5'd8,  32'hffffffbe, "I-Type LB 1");
    check_result_rf(5'd9,  32'hffffffad, "I-Type LB 2");
    check_result_rf(5'd10, 32'hffffffde, "I-Type LB 3");

    check_result_rf(5'd11, 32'h0000beef, "I-Type LHU 0");
    // check_result_rf(5'd12, 32'h0000beef, "I-Type LHU 1");
    check_result_rf(5'd13, 32'h0000dead, "I-Type LHU 2");
    // check_result_rf(5'd14, 32'h0000dead, "I-Type LHU 3");

    check_result_rf(5'd15, 32'h000000ef, "I-Type LBU 0");
    check_result_rf(5'd16, 32'h000000be, "I-Type LBU 1");
    check_result_rf(5'd17, 32'h000000ad, "I-Type LBU 2");
    check_result_rf(5'd18, 32'h000000de, "I-Type LBU 3");

    // Test S-Type Insts --------------------------------------------------
    // - SW, SH, SB

    reset();

    `RF_PATH.mem[1]  = 32'h12345678;

    `RF_PATH.mem[2]  = 32'h3000_0010;

    `RF_PATH.mem[3]  = 32'h3000_0020;
    `RF_PATH.mem[4]  = 32'h3000_0030;
    `RF_PATH.mem[5]  = 32'h3000_0040;
    `RF_PATH.mem[6]  = 32'h3000_0050;

    `RF_PATH.mem[7]  = 32'h3000_0060;
    `RF_PATH.mem[8]  = 32'h3000_0070;
    `RF_PATH.mem[9]  = 32'h3000_0080;
    `RF_PATH.mem[10] = 32'h3000_0090;

    IMM0 = 32'h0000_0100;
    IMM1 = 32'h0000_0101;
    IMM2 = 32'h0000_0102;
    IMM3 = 32'h0000_0103;

    INST_ADDR = 14'h0000;

    DATA_ADDR0 = (`RF_PATH.mem[2]  + IMM0[11:0]) >> 2;

    DATA_ADDR1 = (`RF_PATH.mem[3]  + IMM0[11:0]) >> 2;
    DATA_ADDR2 = (`RF_PATH.mem[4]  + IMM1[11:0]) >> 2;
    DATA_ADDR3 = (`RF_PATH.mem[5]  + IMM2[11:0]) >> 2;
    DATA_ADDR4 = (`RF_PATH.mem[6]  + IMM3[11:0]) >> 2;

    DATA_ADDR5 = (`RF_PATH.mem[7]  + IMM0[11:0]) >> 2;
    DATA_ADDR6 = (`RF_PATH.mem[8]  + IMM1[11:0]) >> 2;
    DATA_ADDR7 = (`RF_PATH.mem[9]  + IMM2[11:0]) >> 2;
    DATA_ADDR8 = (`RF_PATH.mem[10] + IMM3[11:0]) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0] = {IMM0[11:5], 5'd1, 5'd2,  `FNC_SW, IMM0[4:0], `OPC_STORE};

    `IMEM_PATH.mem[INST_ADDR + 1] = {IMM0[11:5], 5'd1, 5'd3,  `FNC_SH, IMM0[4:0], `OPC_STORE};
    // `IMEM_PATH.mem[INST_ADDR + 2] = {IMM1[11:5], 5'd1, 5'd4,  `FNC_SH, IMM1[4:0], `OPC_STORE}; // unaligned sh
    `IMEM_PATH.mem[INST_ADDR + 3] = {IMM2[11:5], 5'd1, 5'd5,  `FNC_SH, IMM2[4:0], `OPC_STORE};
    // `IMEM_PATH.mem[INST_ADDR + 4] = {IMM3[11:5], 5'd1, 5'd6,  `FNC_SH, IMM3[4:0], `OPC_STORE}; // unaligned sh

    `IMEM_PATH.mem[INST_ADDR + 5] = {IMM0[11:5], 5'd1, 5'd7,  `FNC_SB, IMM0[4:0], `OPC_STORE};
    `IMEM_PATH.mem[INST_ADDR + 6] = {IMM1[11:5], 5'd1, 5'd8,  `FNC_SB, IMM1[4:0], `OPC_STORE};
    `IMEM_PATH.mem[INST_ADDR + 7] = {IMM2[11:5], 5'd1, 5'd9,  `FNC_SB, IMM2[4:0], `OPC_STORE};
    `IMEM_PATH.mem[INST_ADDR + 8] = {IMM3[11:5], 5'd1, 5'd10, `FNC_SB, IMM3[4:0], `OPC_STORE};

    `DMEM_PATH.mem[DATA_ADDR0] = 0;
    `DMEM_PATH.mem[DATA_ADDR1] = 0;
    `DMEM_PATH.mem[DATA_ADDR3] = 0;
    `DMEM_PATH.mem[DATA_ADDR4] = 0;
    `DMEM_PATH.mem[DATA_ADDR5] = 0;
    `DMEM_PATH.mem[DATA_ADDR6] = 0;
    `DMEM_PATH.mem[DATA_ADDR7] = 0;
    `DMEM_PATH.mem[DATA_ADDR8] = 0;

    reset_cpu();

    check_result_dmem(DATA_ADDR0, 32'h12345678, "S-Type SW");

    check_result_dmem(DATA_ADDR1, 32'h00005678, "S-Type SH 1");
    // check_result_dmem(DATA_ADDR2, 32'h00005678, "S-Type SH 2");
    check_result_dmem(DATA_ADDR3, 32'h56780000, "S-Type SH 3");
    // check_result_dmem(DATA_ADDR4, 32'h56780000, "S-Type SH 4");

    check_result_dmem(DATA_ADDR5, 32'h00000078, "S-Type SB 1");
    check_result_dmem(DATA_ADDR6, 32'h00007800, "S-Type SB 2");
    check_result_dmem(DATA_ADDR7, 32'h00780000, "S-Type SB 3");
    check_result_dmem(DATA_ADDR8, 32'h78000000, "S-Type SB 4");

    // Test U-Type Insts --------------------------------------------------
    // - LUI, AUIPC
    reset();

    IMM = 32'h7FFF_0123;
    INST_ADDR = 14'h0000;

    `IMEM_PATH.mem[INST_ADDR + 0] = {IMM[31:12], 5'd3, `OPC_LUI};
    `IMEM_PATH.mem[INST_ADDR + 1] = {IMM[31:12], 5'd4, `OPC_AUIPC};

    reset_cpu();

    check_result_rf(3,  32'h7fff0000, "U-Type LUI");
    check_result_rf(4,  32'h8fff0004, "U-Type AUIPC"); // assume PC is 1000_0004

    // Test J-Type Insts --------------------------------------------------
    // - JAL
    reset();

    `RF_PATH.mem[1] = 100;
    `RF_PATH.mem[2] = 200;
    `RF_PATH.mem[3] = 300;
    `RF_PATH.mem[4] = 400;

    IMM       = 32'h0000_0FF0;
    INST_ADDR = 14'h0000;
    JUMP_ADDR = (32'h1000_0000 + {IMM[20:1], 1'b0}) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0]   = {IMM[20], IMM[10:1], IMM[11], IMM[19:12], 5'd5, `OPC_JAL};
    `IMEM_PATH.mem[INST_ADDR + 1]   = {`FNC7_0, 5'd2, 5'd1, `FNC_ADD_SUB, 5'd6, `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[JUMP_ADDR[13:0]] = {`FNC7_0, 5'd4, 5'd3, `FNC_ADD_SUB, 5'd7, `OPC_ARI_RTYPE};

    reset_cpu();

    check_result_rf(5'd5, 32'h1000_0004, "J-Type JAL");
    check_result_rf(5'd7, 700, "J-Type JAL");
    check_result_rf(5'd6, 0, "J-Type JAL");

    // Test I-Type JALR Insts ---------------------------------------------
    reset();

    `RF_PATH.mem[1] = 32'h1000_0100;
    `RF_PATH.mem[2] = 200;
    `RF_PATH.mem[3] = 300;
    `RF_PATH.mem[4] = 400;

    IMM       = 32'hFFFF_FFF0;
    INST_ADDR = 14'h0000;
    JUMP_ADDR = (`RF_PATH.mem[1] + IMM) >> 2;

    `IMEM_PATH.mem[INST_ADDR + 0]   = {IMM[11:0], 5'd1, 3'b000, 5'd5, `OPC_JALR};
    `IMEM_PATH.mem[INST_ADDR + 1]   = {`FNC7_0,   5'd2, 5'd1, `FNC_ADD_SUB, 5'd6, `OPC_ARI_RTYPE};
    `IMEM_PATH.mem[JUMP_ADDR[13:0]] = {`FNC7_0,   5'd4, 5'd3, `FNC_ADD_SUB, 5'd7, `OPC_ARI_RTYPE};

    reset_cpu();

    check_result_rf(5'd5, 32'h1000_0004, "J-Type JALR");
    check_result_rf(5'd7, 700, "J-Type JALR");
    check_result_rf(5'd6, 0, "J-Type JALR");

    // Test B-Type Insts --------------------------------------------------
    // - BEQ, BNE, BLT, BGE, BLTU, BGEU

    IMM       = 32'h0000_0FF0;
    INST_ADDR = 14'h0000;
    JUMP_ADDR = (32'h1000_0000 + IMM[12:0]) >> 2;

    BR_TYPE[0]     = `FNC_BEQ;
    BR_NAME_TK1[0] = "B-Type BEQ Taken 1";
    BR_NAME_TK2[0] = "B-Type BEQ Taken 2";
    BR_NAME_NTK[0] = "B-Type BEQ Not Taken";

    BR_TAKEN_OP1[0]  = 100; BR_TAKEN_OP2[0]  = 100;
    BR_NTAKEN_OP1[0] = 100; BR_NTAKEN_OP2[0] = 200;

    BR_TYPE[1]       = `FNC_BNE;
    BR_NAME_TK1[1]   = "B-Type BNE Taken 1";
    BR_NAME_TK2[1]   = "B-Type BNE Taken 2";
    BR_NAME_NTK[1]   = "B-Type BNE Not Taken";
    BR_TAKEN_OP1[1]  = 100; BR_TAKEN_OP2[1]  = 200;
    BR_NTAKEN_OP1[1] = 100; BR_NTAKEN_OP2[1] = 100;

    BR_TYPE[2]       = `FNC_BLT;
    BR_NAME_TK1[2]   = "B-Type BLT Taken 1";
    BR_NAME_TK2[2]   = "B-Type BLT Taken 2";
    BR_NAME_NTK[2]   = "B-Type BLT Not Taken";
    BR_TAKEN_OP1[2]  = 100; BR_TAKEN_OP2[2]  = 200;
    BR_NTAKEN_OP1[2] = 200; BR_NTAKEN_OP2[2] = 100;

    BR_TYPE[3]       = `FNC_BGE;
    BR_NAME_TK1[3]   = "B-Type BGE Taken 1";
    BR_NAME_TK2[3]   = "B-Type BGE Taken 2";
    BR_NAME_NTK[3]   = "B-Type BGE Not Taken";
    BR_TAKEN_OP1[3]  = 300; BR_TAKEN_OP2[3]  = 200;
    BR_NTAKEN_OP1[3] = 100; BR_NTAKEN_OP2[3] = 200;

    BR_TYPE[4]       = `FNC_BLTU;
    BR_NAME_TK1[4]   = "B-Type BLTU Taken 1";
    BR_NAME_TK2[4]   = "B-Type BLTU Taken 2";
    BR_NAME_NTK[4]   = "B-Type BLTU Not Taken";
    BR_TAKEN_OP1[4]  = 32'h0000_0001; BR_TAKEN_OP2[4]  = 32'hFFFF_0000;
    BR_NTAKEN_OP1[4] = 32'hFFFF_0000; BR_NTAKEN_OP2[4] = 32'h0000_0001;

    BR_TYPE[5]       = `FNC_BGEU;
    BR_NAME_TK1[5]   = "B-Type BGEU Taken 1";
    BR_NAME_TK2[5]   = "B-Type BGEU Taken 2";
    BR_NAME_NTK[5]   = "B-Type BGEU Not Taken";
    BR_TAKEN_OP1[5]  = 32'hFFFF_0000; BR_TAKEN_OP2[5]  = 32'h0000_0001;
    BR_NTAKEN_OP1[5] = 32'h0000_0001; BR_NTAKEN_OP2[5] = 32'hFFFF_0000;

    for (i = 0; i < 6; i = i + 1) begin
      reset();

      `RF_PATH.mem[1] = BR_TAKEN_OP1[i];
      `RF_PATH.mem[2] = BR_TAKEN_OP2[i];
      `RF_PATH.mem[3] = 300;
      `RF_PATH.mem[4] = 400;

      // Test branch taken
      `IMEM_PATH.mem[INST_ADDR + 0]   = {IMM[12], IMM[10:5], 5'd2, 5'd1, BR_TYPE[i], IMM[4:1], IMM[11], `OPC_BRANCH};
      `IMEM_PATH.mem[INST_ADDR + 1]   = {`FNC7_0, 5'd4, 5'd3, `FNC_ADD_SUB, 5'd5, `OPC_ARI_RTYPE};
      `IMEM_PATH.mem[JUMP_ADDR[13:0]] = {`FNC7_0, 5'd4, 5'd3, `FNC_ADD_SUB, 5'd6, `OPC_ARI_RTYPE};

      reset_cpu();

      check_result_rf(5'd5, 0,   BR_NAME_TK1[i]);
      check_result_rf(5'd6, 700, BR_NAME_TK2[i]);

      reset();

      `RF_PATH.mem[1] = BR_NTAKEN_OP1[i];
      `RF_PATH.mem[2] = BR_NTAKEN_OP2[i];
      `RF_PATH.mem[3] = 300;
      `RF_PATH.mem[4] = 400;

      // Test branch not taken
      `IMEM_PATH.mem[INST_ADDR + 0] = {IMM[12], IMM[10:5], 5'd2, 5'd1, BR_TYPE[i], IMM[4:1], IMM[11], `OPC_BRANCH};
      `IMEM_PATH.mem[INST_ADDR + 1] = {`FNC7_0, 5'd4, 5'd3, `FNC_ADD_SUB, 5'd5, `OPC_ARI_RTYPE};

      reset_cpu();
      check_result_rf(5'd5, 700, BR_NAME_NTK[i]);
    end

    // ... what else?
    all_tests_passed = 1'b1;

    repeat (100) @(posedge clk);
    $display("All tests passed!");
    $finish();
  end
    
endmodule