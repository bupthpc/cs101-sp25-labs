/**
 * Adapted from EECS151 Library
 *    https://www.eecs151.org/files/lib/EECS151.v
 */


module REGISTER #(
    parameter N = 1
) (
    output reg [N-1:0] q,
    input [N-1:0] d,
    input clk
);
  initial q = {N{1'b0}};
  always @(posedge clk) q <= d;
endmodule

module REGISTER_R #(
    parameter N = 1,
    parameter INIT = {N{1'b0}}
) (
    output reg [N-1:0] q,
    input [N-1:0] d,
    input clk,
    input rst
);
  initial q = INIT;
  always @(posedge clk)
    if (rst) q <= INIT;
    else q <= d;
endmodule

module REGISTER_CE #(
    parameter N = 1,
    parameter INIT = {N{1'b0}}
) (
    output reg [N-1:0] q,
    input [N-1:0] d,
    input clk,
    input ce
);
  initial q = INIT;
  always @(posedge clk) if (ce) q <= d;
endmodule

module REGISTER_R_CE #(
    parameter N = 1,
    parameter INIT = {N{1'b0}}
) (
    output reg [N-1:0] q,
    input [N-1:0] d,
    input clk,
    input rst,
    input ce
);
  initial q = INIT;
  always @(posedge clk)
    if (rst) q <= INIT;
    else if (ce) q <= d;
endmodule


/* 
 Memory Blocks.
*/

// Single-port ROM with asynchronous read
module ASYNC_ROM(q, addr);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input  [AWIDTH-1:0] addr; // address
  output [DWIDTH-1:0] q;    // read data

  (* rom_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  assign q = mem[addr];
endmodule // ASYNC_ROM

// Single-port RAM with asynchronous read
module ASYNC_RAM(q, d, addr, we, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input               clk;
  input  [AWIDTH-1:0] addr; // address
  input 	            we;   // write-enable
  input  [DWIDTH-1:0] d;    // write data
  output [DWIDTH-1:0] q;    // read data

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (we)
      mem[addr] <= d;
  end

  assign q = mem[addr];
endmodule // ASYNC_RAM

// Single-port ROM with synchronous read
module SYNC_ROM(q, addr, en, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input 	            clk;
  input               en;   // ram-enable
  input  [AWIDTH-1:0] addr; // address
  output [DWIDTH-1:0] q;    // read data

  (* rom_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  reg [DWIDTH-1:0] read_data_reg;
  always @(posedge clk) begin
    if (en) begin
      read_data_reg <= mem[addr];
    end
  end

  assign q = read_data_reg;
endmodule // SYNC_ROM

// Single-port RAM with synchronous read
module SYNC_RAM(q, d, addr, we, en, clk);
  parameter DWIDTH = 8;           // Data width
  parameter AWIDTH = 8;           // Address width
  parameter DEPTH  = 1 << AWIDTH; // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input               clk;
  input  [AWIDTH-1:0] addr; // address
  input 	            we;   // write-enable
  input               en;   // ram-enable
  input  [DWIDTH-1:0] d;    // write data
  output [DWIDTH-1:0] q;    // read data

  (* ram_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  reg [DWIDTH-1:0] read_data_reg;
  always @(posedge clk) begin
    if (en) begin
      if (we)
        mem[addr] <= d;
      read_data_reg <= mem[addr];
    end
  end

  assign q = read_data_reg;
endmodule // SYNC_RAM

// Dual-port ROM with synchronous read
module SYNC_ROM_DP(q0, addr0, en0, q1, addr1, en1, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input 	            clk;
  input               en0, en1;     // ram-enable
  input  [AWIDTH-1:0] addr0, addr1; // address
  output [DWIDTH-1:0] q0, q1;       // read data

  (* rom_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  reg [DWIDTH-1:0] read_data0_reg;
  reg [DWIDTH-1:0] read_data1_reg;

  always @(posedge clk) begin
    if (en0) begin
      read_data0_reg <= mem[addr0];
    end
  end

  always @(posedge clk) begin
    if (en1) begin
      read_data1_reg <= mem[addr1];
    end
  end

  assign q0 = read_data0_reg;
  assign q1 = read_data1_reg;
endmodule // SYNC_ROM_DP

// Dual-port RAM with asynchronous read
module ASYNC_RAM_DP(q0, d0, addr0, we0, q1, d1, addr1, we1, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input               clk;
  input  [AWIDTH-1:0] addr0, addr1; // address
  input 	            we0, we1;     // write-enable
  input  [DWIDTH-1:0] d0, d1;       // write data
  output [DWIDTH-1:0] q0, q1;       // read data

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (we0)
      mem[addr0] <= d0;
  end

  always @(posedge clk) begin
    if (we1)
      mem[addr1] <= d1;
  end

  assign q0 = mem[addr0];
  assign q1 = mem[addr1];

endmodule // ASYNC_RAM_DP

// Dual-port RAM with synchronous read
module SYNC_RAM_DP(q0, d0, addr0, we0, en0, q1, d1, addr1, we1, en1, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input               clk;
  input  [AWIDTH-1:0] addr0, addr1; // address
  input 	            we0, we1;     // write-enable
  input               en0, en1;     // ram-enable
  input  [DWIDTH-1:0] d0, d1;       // write data
  output [DWIDTH-1:0] q0, q1;       // read data

  (* ram_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  reg [DWIDTH-1:0] read_data0_reg, read_data1_reg;

  always @(posedge clk) begin
    if (en0) begin
      if (we0)
        mem[addr0] <= d0;
      read_data0_reg <= mem[addr0];
    end
  end

  always @(posedge clk) begin
    if (en1) begin
      if (we1)
        mem[addr1] <= d1;
      read_data1_reg <= mem[addr1];
    end
  end

  assign q0 = read_data0_reg;
  assign q1 = read_data1_reg;

endmodule // SYNC_RAM_DP

// Single-port RAM with synchronous read with write byte-enable
module SYNC_RAM_WBE(q, d, addr, en, wbe, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input [DWIDTH-1:0]   d;    // Data input
  input [AWIDTH-1:0]   addr; // Address input
  input [DWIDTH/8-1:0] wbe;  // write-byte-enable
  input en;
  input clk;
  output [DWIDTH-1:0] q;

  (* ram_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  reg [DWIDTH-1:0] read_data_reg;
  always @(posedge clk) begin
    if (en) begin
      for (i = 0; i < DWIDTH/8; i = i+1) begin
        if (wbe[i])
          mem[addr][i*8 +: 8] <= d[i*8 +: 8];
        end
      read_data_reg <= mem[addr];
    end
  end

  assign q = read_data_reg;
endmodule // SYNC_RAM_WBE

// Single-port RAM with asynchronous read with write byte-enable
module ASYNC_RAM_WBE(q, d, addr, en, wbe, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input [DWIDTH-1:0]   d;    // Data input
  input [AWIDTH-1:0]   addr; // Address input
  input [DWIDTH/8-1:0] wbe;  // write-byte-enable
  input en;
  input clk;
  output [DWIDTH-1:0] q;

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (en) begin
      for (i = 0; i < DWIDTH/8; i = i+1) begin
        if (wbe[i])
          mem[addr][i*8 +: 8] <= d[i*8 +: 8];
        end
    end
  end

  assign q = mem[addr];

endmodule // ASYNC_RAM_WBE

// Dual-port RAM with synchronous read with write byte-enable
module SYNC_RAM_DP_WBE(q0, d0, addr0, en0, wbe0, q1, d1, addr1, en1, wbe1, clk);
  parameter DWIDTH = 8;             // Data width
  parameter AWIDTH = 8;             // Address width
  parameter DEPTH  = (1 << AWIDTH); // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";

  input clk;
  input [DWIDTH-1:0]   d0;    // Data input
  input [AWIDTH-1:0]   addr0; // Address input
  input [DWIDTH/8-1:0] wbe0;  // write-byte-enable
  input                en0;
  output [DWIDTH-1:0]  q0;

  input [DWIDTH-1:0]   d1;    // Data input
  input [AWIDTH-1:0]   addr1; // Address input
  input [DWIDTH/8-1:0] wbe1;  // write-byte-enable
  input                en1;
  output [DWIDTH-1:0]  q1;

  (* ram_style = "block" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end


  reg [DWIDTH-1:0] read_data0_reg;
  reg [DWIDTH-1:0] read_data1_reg;

  always @(posedge clk) begin
    if (en0) begin
      for (i = 0; i < 4; i = i+1) begin
        if (wbe0[i])
          mem[addr0][i*8 +: 8] <= d0[i*8 +: 8];
      end
      read_data0_reg <= mem[addr0];
    end
  end

  always @(posedge clk) begin
    if (en1) begin
      for (i = 0; i < 4; i = i+1) begin
        if (wbe1[i])
          mem[addr1][i*8 +: 8] <= d1[i*8 +: 8];
        end
      read_data1_reg <= mem[addr1];
    end
  end

  assign q0 = read_data0_reg;
  assign q1 = read_data1_reg;

endmodule // SYNC_RAM_DP_WBE

// Multi-port RAM with two asynchronous-read ports, one synchronous-write port
module ASYNC_RAM_1W2R(d0, addr0, we0, q1, addr1, q2, addr2, clk);
  parameter DWIDTH = 8;  // Data width
  parameter AWIDTH = 8;  // Address width
  parameter DEPTH = 256; // Memory depth
  parameter MIF_HEX = "";
  parameter MIF_BIN = "";
  input clk;

  input [DWIDTH-1:0] d0;    // Data input
  input [AWIDTH-1:0] addr0; // Address input
  input              we0;   // Write enable

  input [AWIDTH-1:0] addr1; // Address input
  output [DWIDTH-1:0] q1;

  input [AWIDTH-1:0] addr2; // Address input
  output [DWIDTH-1:0] q2;

  (* ram_style = "distributed" *) reg [DWIDTH-1:0] mem [0:DEPTH-1];

  integer i;
  initial begin
    if (MIF_HEX != "") begin
      $readmemh(MIF_HEX, mem);
    end
    else if (MIF_BIN != "") begin
      $readmemb(MIF_BIN, mem);
    end
    else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 0;
      end
    end
  end

  always @(posedge clk) begin
    if (we0)
      mem[addr0] <= d0;
  end

  assign q1 = mem[addr1];
  assign q2 = mem[addr2];

endmodule // ASYNC_RAM_1W2R
