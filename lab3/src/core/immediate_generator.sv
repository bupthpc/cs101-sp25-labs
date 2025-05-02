`include "control_signals.vh"

module immediate_generator (
    input      [               31:7] instr,
    input      [`IMM_TYPE_WIDTH-1:0] imm_sel,
    output reg [               31:0] imm_out
);

  always @(*) begin
    case (imm_sel)
      // TODO: Implement the immediate generation logic
      // `IMM_I: imm_out =  ;
      // `IMM_S: imm_out =  ;
      // `IMM_B: imm_out =  ;
      // `IMM_U: imm_out =  ;
      // `IMM_J: imm_out =  ;

      default: imm_out = {32{1'bx}};
    endcase
  end

endmodule