`timescale 1ns / 1ps

// Rising Edge Detector
//
// Detects when sig_in transitions from low to high and produces a one-clock-cycle pulse.
//
// Ports:
// clk    - Clock input.
// sig_in - Input signal to monitor for a rising edge.
// rise   - Output pulse that is asserted for one clock cycle on a rising edge.
module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  // Stores the previous sampled value for edge detection.
  logic prev = 0;
  // Captures the signal value for the next clock cycle in the edge detector.
  logic next_prev;

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    prev <= next_prev;
  end

  // Drive next_prev from sig_in.
  assign next_prev = sig_in;

  // Drive rise from (not prev  and  sig_in).
  assign rise = (!prev && sig_in);

endmodule
