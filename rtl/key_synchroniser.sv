`timescale 1ns / 1ps

module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,           // active-low, asynchronous
    output logic [3:0] key_sync = 4'b0  // active-high, synchronised
);

  logic [3:0] key = 4'b0;

  always_ff @(posedge clk) begin
    key_sync <= key;
    key <= ~key_n;
  end

endmodule
