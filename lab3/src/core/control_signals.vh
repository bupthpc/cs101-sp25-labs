`ifndef CONTROL_SIGNALS
`define CONTROL_SIGNALS

`define    ALUOP_NUM       12
`define    ALUOP_WIDTH     $clog2(`ALUOP_NUM)
`define    ALU_ADD         4'b0000
`define    ALU_SUB         4'b0001
`define    ALU_AND         4'b0010
`define    ALU_OR          4'b0011
`define    ALU_XOR         4'b0100
`define    ALU_SLL         4'b0101  // Shift Left Logical
`define    ALU_SRL         4'b0110  // Shift Right Logical
`define    ALU_SRA         4'b0111  // Shift Right Arithmetic
`define    ALU_SLT         4'b1000  // Set Less Than
`define    ALU_SLTU        4'b1001  // Set Less Than Unsigned
`define    ALU_A           4'b1010  // Copy A 
`define    ALU_B           4'b1011  // Copy B
          
`define    IMM_TYPE_NUM      5
`define    IMM_TYPE_WIDTH    $clog2(`IMM_TYPE_NUM)
`define    IMM_I             3'b000
`define    IMM_S             3'b001
`define    IMM_B             3'b010
`define    IMM_U             3'b011
`define    IMM_J             3'b100


`define    ST_TYPE_NUM    3
`define    ST_TYPE_WIDTH  $clog2(`ST_TYPE_NUM)
`define    ST_BYTE        2'b01
`define    ST_HALF        2'b10
`define    ST_WORD        2'b11

`define    LD_TYPE_NUM    5
`define    LD_TYPE_WIDTH  $clog2(`LD_TYPE_NUM)
`define    LD_BYTE        3'b000
`define    LD_BYTE_UN     3'b100
`define    LD_HALF        3'b001
`define    LD_HALF_UN     3'b101
`define    LD_WORD        3'b010

`define    A_REG          1'b0
`define    A_PC           1'b1
`define    B_REG          1'b0
`define    B_IMM          1'b1

`define    PC_PLUS_4      1'b0
`define    PC_ALU         1'b1

`define    WB_TYPE_NUM    3
`define    WB_TYPE_WIDTH  $clog2(`WB_TYPE_NUM)
`define    WB_MEM         2'b00
`define    WB_ALU         2'b01
`define    WB_PC          2'b10

`endif
