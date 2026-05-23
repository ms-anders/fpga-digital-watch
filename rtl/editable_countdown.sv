`timescale 1ns / 1ps

// Editable Countdown
//
// Decrements count by 1 on clock cycle when tick is high, wrapping to MAX on underflow
//
// Parameters:
// MAX   - The max value count can have
// WIDTH - Bit width needed to store MAX
//
// Ports:
// clk       - Clock input
// clr       - Clears the count to 0
// tick      - Decrements count when high on a clock posedge
// edit_mode - When high, stops countdown and allows incrementation and decrementation
//             of count using inc and dec
// inc       - When in edit mode, set high to increment count
// dec       - When in edit mode, set high to decrement count
//
// count      - The count stored in the counter
// borrow_out - Goes high when count underflows, allowing borrowing from higher order digits
module editable_countdown #(
    // Constant parameter used to configure internal behavior.
    parameter int MAX   = 59,
    // Constant parameter used to configure internal behavior.
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             clr,
    input  logic             tick,
    input  logic             edit_mode,
    input  logic             inc,
    input  logic             dec,
    output logic [WIDTH-1:0] count,
    output logic             borrow_out
);

  // Holds the enable condition used by downstream logic.
  logic enable;
  // Controls whether the counter should count upward.
  logic up;

  // Counter to control value of count
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk   (clk),
      .rst   (clr),
      .enable(enable),
      .up    (up),
      .count (count)
  );

  // Increment and decrement using buttons only when in edit mode, and do nothing when both inc and dec are high
  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  // Count down when not in edit mode and count not being cleared
  wire tick_event = !edit_mode && tick & !clr;

  // Drive up from inc_event.
  assign up = inc_event;  // Count up on inc_event
  // Drive enable from inc_event  or  dec_event  or  tick_event.
  assign enable = inc_event || dec_event || tick_event;  // Enable counter when an event goes high

  // Drive borrow_out from (count  equals  WIDTH'(0))  and  tick_event.
  assign borrow_out = (count == WIDTH'(0)) && tick_event;  // High when count ticks below 0

endmodule
