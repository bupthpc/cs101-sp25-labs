module branch_comparator #(
    parameter DWIDTH = 32
) (
    input [DWIDTH-1:0] a,
    input [DWIDTH-1:0] b,
    input br_un,
    output br_eq,
    output br_lt
);

  assign br_eq = (a == b);
  assign br_lt = (br_un) ? (a < b) : ($signed(a) < $signed(b));

endmodule
