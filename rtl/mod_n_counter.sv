`timescale 1ns / 1ps

// Modulo-N Counter
// Counts from 0 to N-1 and then wraps around to 0.
//
// Parameters:
// N     - The modulus of the counter. Default is 4.
// WIDTH - The bit width of the count output. Default is 2 (enough to represent 0-3).
//
// Ports:
// clk    - Clock input.
// rst    - Synchronous reset input. When high, the counter resets to 0 on the next rising edge of the clock.
// enable - When high, the counter will increment on the rising edge of the clock. Otherwise, the counter holds its value.
// count  - The current count value
//
module mod_n_counter #(
    parameter int N = 4,  // Modulus of the counter
    parameter int WIDTH = 2  // Bit width of the count output
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = WIDTH'(0)
);
  // Initialize next_count
  logic [WIDTH-1:0] next_count;

  // Truncate N to fit within WIDTH bits
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);

  always_ff @(posedge clk) begin
    // Synchronous reset: if rst is high, reset count to 0.
    // Otherwise, update count
    if (rst) count <= WIDTH'(0);
    else if (enable) count <= next_count;
  end

  always_comb begin
    // Increment count and wrap around to 0 when exceeding Max
    next_count = (count < Max) ? count + WIDTH'(1) : WIDTH'(0);
  end
endmodule
