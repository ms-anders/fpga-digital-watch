`timescale 1ns / 1ps

// Counter that increments or decrements (based on the 'up' input) on every clock cycle
//
// Parameters:
// MAX   - Maximum count value before wrapping around to 0. Default is 2.
// WIDTH - Width of the counter. Default is 2.
//
// Ports:
// clk    - Clock input.
// enable  - When high, the counter will increment/decrement on the rising edge of the clock.
//           otherwise the counter holds its value.
// up      - When high, the counter increments; when low, it decrements.
// count   - The current count value output
module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,    // Clock input
    input logic rst,    // Reset counter when high
    input logic enable, // Enable counting
    input logic up,     // Count direction: 1 for up, 0 for down
    output logic [WIDTH-1:0] count = WIDTH'(0) // Current count value, initialized to 0
);

  // Initialize next_count
  logic [WIDTH-1:0] next_count;

  // truncate MAX to fit within WIDTH bits
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);

  // State Flip Flops
  always_ff @(posedge clk) if (enable) count <= next_count;

  // Next state logic
  always_comb begin
    // If rst is high, set count to 0, otherwise follow count logic
    if (rst) begin
      next_count = WIDTH'(0);
    end else begin
      // Increment if up is high, otherwise decrement
      if (up) begin
        // Increment and wrap around to 0 when exceeding Max
        next_count = (count < Max) ? count + WIDTH'(1) : WIDTH'(0);
      end else begin
        // Decrement and wrap around to Max when falling below 0
        next_count = (count > 0) ? count - WIDTH'(1) : Max;
      end
    end
  end
endmodule
