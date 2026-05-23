`timescale 1ns / 1ps

// Key Synchroniser
//
// Synchronises active-low inputs to the clock through 2 flip flops
//
// Ports:
// clk      - Clock input
// key_n    - Active-low input
// key_sync - Output synchronised to the clock
//
module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,           // active-low, asynchronous
    output logic [3:0] key_sync = 4'b0  // active-high, synchronised
);

  // Holds the synchronized key input value.
  logic [3:0] key = 4'b0;

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    key_sync <= key;
    key <= ~key_n;  // Invert input to cater for active-low input
  end

endmodule
