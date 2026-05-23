`timescale 1ns / 1ps

// Arming Latch
//
// When arm transitions high, arm transitions high and
// remains high until disarm transitions high, all synchronised
// with the clk input
//
// Ports:
// clk    - Clock input
// arm    - Arm input: set high to arm latch
// disarm - Disarm input: set high to disarm latch
// armed  - Latch output
//
module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed = 1'b0
);

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    if (disarm) armed <= 1'b0;
    else if (arm) armed <= 1'b1;
  end

endmodule
