`timescale 1ns / 1ps

// Snapshot Multiplexer
//
// Captures and holds the value of d when hold is asserted. When hold is deasserted,
// q follows the input d directly. This is useful for freezing display values on a clock boundary.
//
// Parameters:
// WIDTH - Width of the input and output data buses.
//
// Ports:
// clk  - Clock input.
// hold - When high, output q remains at the last sampled value of d.
// d    - Input data bus.
// q    - Output data bus, either the current input or the held snapshot.
module snapshot_mux #(
    // Constant parameter used to configure internal behavior.
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  // Holds the latched input value when snapshot mode is active.
  logic [WIDTH-1:0] snapshot = WIDTH'(0);

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    if (!hold) snapshot <= d;
  end

  // Select q based on the condition (hold).
  assign q = (hold) ? snapshot : d;

endmodule
