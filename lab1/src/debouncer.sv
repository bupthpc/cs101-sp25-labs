module Debouncer #(
    parameter SAMPLE_CNT_MAX     = 10,
    parameter PULSE_CNT_MAX      = 4,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input  clk,
    input  glitchy_signal,
    output debounced_signal
);

  // TODO: implement this

endmodule
