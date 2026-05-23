// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

// Stopwatch Top Level v1
//
// Implements stopwatch functionality with start/stop, lap, and display hold behavior.
// This module is also used by the automated test suite and includes a template-style wrapper.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second for the input clock.
//
// Ports:
// clk           - Clock input.
// button        - User button inputs for stopwatch control.
// sw            - Switch inputs for the stopwatch.
// led           - LED outputs.
// hours_disp    - Seven-segment output for hours digits.
// minutes_disp  - Seven-segment output for minutes digits.
// seconds_disp  - Seven-segment output for seconds digits.
// blank_hours   - Active-high blanking for hours display.
// blank_minutes - Active-high blanking for minutes display.
// blank_seconds - Active-high blanking for seconds display.
module user_top_stopwatch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    // Constant parameter used to configure internal behavior.
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // Indicates when button 0 has a rising edge.
  logic button0_rise;
  // Indicates when button 1 has a rising edge.
  logic button1_rise;

  // Detects a rising edge on the input signal.
  rising_edge_detector u_red0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(button0_rise)
  );

  // Detects a rising edge on the input signal.
  rising_edge_detector u_red1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(button1_rise)
  );



  // Asserts reset for the stopwatch counter when the controller requests it.
  logic counter_rst;
  // Enables the stopwatch counter when running.
  logic counter_enable;
  // Locks lap state after a lap action is requested.
  logic lap_hold;

  // Manages stopwatch start/stop and lap control signals.
  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(button0_rise),
      .rise_lap(button1_rise),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  // Holds the current minutes count value.
  logic [6:0] minutes;
  // Holds the current seconds count value.
  logic [5:0] seconds;
  // Holds the current hundredths-of-a-second count.
  logic [6:0] centiseconds;

  // Accumulates stopwatch time from periodic tick pulses.
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes),
      .seconds(seconds),
      .centiseconds(centiseconds)
  );



  // Captures a snapshot of input data while hold is active.
  snapshot_mux #(
      .WIDTH(21)
  ) u_snashot_mux (
      .clk(clk),
      .hold(lap_hold),
      .d({minutes, 1'b0, seconds, centiseconds}),
      .q({hours_disp, minutes_disp, seconds_disp})
  );



  // Drive led from 10'b0.
  assign led = 10'b0;

  // Drive blank_hours from 1'b0.
  assign blank_hours = 1'b0;
  // Drive blank_minutes from 1'b0.
  assign blank_minutes = 1'b0;
  // Drive blank_seconds from 1'b0.
  assign blank_seconds = 1'b0;

endmodule
