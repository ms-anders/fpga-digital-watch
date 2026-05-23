`timescale 1ns / 1ps

// Edit Mode Selector
//
// Cycles through mode values when input button is held (for mode_enable = 3'b000)
// or pressed once (for all other values 3'b001, 3'b010, 3'b100)
//
// Parameters:
// HOLD_CYCLES - How long button should be held before
//               transitioning mode_enable from 3'b000 to 3'b001
//
// Ports:
// clk         - Clock input
// button      - input to switch between mode_enable states
// mode_enable - Output state to determine state of watch
//
module edit_mode_selector #(
    // Constant parameter used to configure internal behavior.
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);

  // Indicates a long button press that should enter edit mode.
  logic long_press;
  // Detects when the button has been held long enough and generates a single pulse.
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk   (clk),
      .button(button),
      .pulse (long_press)
  );

  // Detects a short button press edge event.
  logic press;
  // Detects a rising edge on the input signal.
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  // Tracks whether edit mode is currently active.
  logic armed;
  // Requests exiting edit mode when asserted.
  logic disarm;
  // Use arming latch to enter edit mode after button long press
  arming_latch u_latch (
      .clk   (clk),
      .arm   (long_press),
      .disarm(disarm),
      .armed (armed)
  );

  // Resets the mode counter when the selector is not armed.
  logic reset_counter;
  // Allows the mode counter to step on press events.
  logic enable_counter;
  // Stores the current counter value.
  logic [1:0] count;
  // Counts modulo N (parameter N=3). Wraps to 0 after reaching N-1 (2).
  // The output width for this instance is WIDTH=2 bits (parameter WIDTH=2).
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk   (clk),
      .rst   (reset_counter),
      .enable(enable_counter),
      .count (count)
  );

  // Counter runs only while armed; resets when disarmed
  assign enable_counter = armed && press;
  // Drive reset_counter from not armed.
  assign reset_counter = !armed;

  // Disarm on the press that steps past the last mode
  assign disarm = enable_counter && (count == 2'd2);

  // Output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
