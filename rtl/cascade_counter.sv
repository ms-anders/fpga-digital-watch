`timescale 1ns / 1ps

// Cascade counter
//
// count0 counts to N0 before count1 increments, repeats until count1 reaches N1,
// where count2 increments. Repeats until count2 reaches N2, where all counts reset
//
// Parameters:
// N2 - Maximum value for count2 to count to
// N1 - Maximum value for count1 to count to
// N0 - Maximum value for count0 to count to
//
// W2 - Bit Width needed to store N2
// W1 - Bit Width needed to store N1
// W0 - Bit Width needed to store N0
//
// Ports:
// clk    - Clock input
// rst    - Set high to reset all counts to 0
// enable - Set high to count up, otherwise dont count and retain count values
// count2 - Third digit output
// count1 - Second digit output
// count0 - First digit output
module cascade_counter #(
    // Constant parameter used to configure internal behavior.
    parameter int N2 = 3,
    // Constant parameter used to configure internal behavior.
    parameter int N1 = 4,
    // Constant parameter used to configure internal behavior.
    parameter int N0 = 5,


    // Output port widths
    parameter int W2 = 2,
    // Constant parameter used to configure internal behavior.
    parameter int W1 = 2,
    // Constant parameter used to configure internal behavior.
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  // Set max values of count variables (counts never reach their N value, but reset to 0)
  localparam logic [W1-1:0] Max1 = W1'(N1 - 1);
  // Constant parameter used to configure internal behavior.
  localparam logic [W0-1:0] Max0 = W0'(N0 - 1);

  // Initialization
  logic enable1;
  // Holds the enable2 signal for later use.
  logic enable2;

  // Drive enable1 from enable  and  (count0  >=  Max0).
  assign enable1 = enable && (count0 >= Max0);  // Increment count1 when count0 reaches its max val
  // Drive enable2 from enable1  and  (count1  >=  Max1)  and  (count0  >=  Max0).
  assign enable2 = enable1 && (count1 >= Max1) && (count0 >= Max0); // Increment count2 when count1 reaches its max val

  // First digit counter
  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) counter_0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  // Second digit counter
  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) counter_1 (
      .clk(clk),
      .rst(rst),
      .enable(enable1),
      .count(count1)
  );

  // Third digit counter
  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) counter_2 (
      .clk(clk),
      .rst(rst),
      .enable(enable2),
      .count(count2)
  );


endmodule
