`include "control_signals.vh"

module alu #(
    parameter DWIDTH = 32
) (
    input [DWIDTH-1:0] a,
    input [DWIDTH-1:0] b,
    input [`ALUOP_WIDTH-1:0] sel,
    output reg [DWIDTH-1:0] y
);

    always @(*) begin
        case (sel)
            // TODO: Implement more ALU operations
            `ALU_ADD:     y = a + b;
            default:      y = {DWIDTH{1'bx}};
        endcase
    end

endmodule
