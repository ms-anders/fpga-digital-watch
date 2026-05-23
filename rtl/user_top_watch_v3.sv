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

// Watch Top Level v3
//
// Implements a watch with mode selection and edit controls for hours, minutes, and seconds.
// Includes PWM-based display blanking depending on the selected mode.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second for the input clock.
//
// Ports:
// clk           - Clock input.
// button        - User button inputs for watch control.
// sw            - Switch inputs for the watch.
// led           - LED outputs.
// hours_disp    - Seven-segment output for hours digits.
// minutes_disp  - Seven-segment output for minutes digits.
// seconds_disp  - Seven-segment output for seconds digits.
// blank_hours   - Active-high blanking for hours display.
// blank_minutes - Active-high blanking for minutes display.
// blank_seconds - Active-high blanking for seconds display.
module user_top_watch_v3 #(
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

  // ----------------------
  // - Core Functionality -
  // ----------------------

  logic seconds_tick;
  // Selects whether the seconds digit is currently being edited.
  logic seconds_edit;
  // Provides a pulse to increment the seconds digit when active.
  logic seconds_inc;
  // Provides a pulse to decrement the seconds digit when active.
  logic seconds_dec;

  // Holds the current seconds count value.
  logic [5:0] seconds;
  // Provide an editable counter that increments or decrements on command.
  editable_counter #(
      .N    (60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Generates periodic ticks while run is high and resets when run goes low.
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );



  // Indicates when the minutes digit should advance because the lower digit wrapped.
  logic minutes_tick;
  // Selects whether the minutes digit is currently being edited.
  logic minutes_edit;
  // Provides a pulse to increment the minutes digit when active.
  logic minutes_inc;
  // Provides a pulse to decrement the minutes digit when active.
  logic minutes_dec;

  // Holds the current minutes count value.
  logic [5:0] minutes;
  // Provide an editable counter that increments or decrements on command.
  editable_counter #(
      .N    (60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );



  // Indicates when the hours digit should advance because the lower digit wrapped.
  logic hours_tick;
  // Selects whether the hours digit is currently being edited.
  logic hours_edit;
  // Provides a pulse to increment the hours digit when active.
  logic hours_inc;
  // Provides a pulse to decrement the hours digit when active.
  logic hours_dec;

  // Holds the current hours count value.
  logic [4:0] hours;
  // Provide an editable counter that increments or decrements on command.
  editable_counter #(
      .N    (24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );



  // Drive minutes_tick from seconds_tick  and  (seconds  >=  6'd59).
  assign minutes_tick = seconds_tick && (seconds >= 6'd59);
  // Drive hours_tick from minutes_tick  and  (minutes  >=  6'd59).
  assign hours_tick = minutes_tick && (minutes >= 6'd59);

  // Drive seconds_disp from {1'b0, seconds}.
  assign seconds_disp = {1'b0, seconds};
  // Drive minutes_disp from {1'b0, minutes}.
  assign minutes_disp = {1'b0, minutes};
  // Drive hours_disp from {2'b0, hours}.
  assign hours_disp = {2'b0, hours};

  // Drive led from 10'b0.
  assign led = 10'b0;



  // ------------------
  // - Mode Selection -
  // ------------------

  logic [2:0] mode_enable;
  // Selects which digit editing mode is active based on button input.
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk        (clk),
      .button     (button[3]),
      .mode_enable(mode_enable)
  );

  // Holds the PWM blanking output used to dim display segments.
  logic pwm_out;
  // Generates PWM output from a counter and selected duty cycle.
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 0.8)
  ) u_digit_pwm (
      .clk    (clk),
      .rst    (1'b0),
      .pwm_out(pwm_out)
  );

  // Select blank_seconds based on the condition (mode_enable == 3'b001).
  assign blank_seconds = (mode_enable == 3'b001) ? !pwm_out : 1'b0;
  // Select blank_minutes based on the condition (mode_enable == 3'b010).
  assign blank_minutes = (mode_enable == 3'b010) ? !pwm_out : 1'b0;
  // Select blank_hours based on the condition (mode_enable == 3'b100).
  assign blank_hours   = (mode_enable == 3'b100) ? !pwm_out : 1'b0;



  // --------------
  // - Edit Logic -
  // --------------


  logic inc_pulse;
  // Generates repeated button pulses while the button remains held.
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_pulse (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  // Produces a decrement pulse for the selected edit field.
  logic dec_pulse;
  // Generates repeated button pulses while the button remains held.
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_pulse (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  // Drive seconds_edit from (mode_enable  equals  3'b001).
  assign seconds_edit = (mode_enable == 3'b001);
  // Drive minutes_edit from (mode_enable  equals  3'b010).
  assign minutes_edit = (mode_enable == 3'b010);
  // Drive hours_edit from (mode_enable  equals  3'b100).
  assign hours_edit   = (mode_enable == 3'b100);

  // Drive seconds_inc from inc_pulse  and  seconds_edit.
  assign seconds_inc  = inc_pulse && seconds_edit;
  // Drive seconds_dec from dec_pulse  and  seconds_edit.
  assign seconds_dec  = dec_pulse && seconds_edit;

  // Drive minutes_inc from inc_pulse  and  minutes_edit.
  assign minutes_inc  = inc_pulse && minutes_edit;
  // Drive minutes_dec from dec_pulse  and  minutes_edit.
  assign minutes_dec  = dec_pulse && minutes_edit;

  // Drive hours_inc from inc_pulse  and  hours_edit.
  assign hours_inc    = inc_pulse && hours_edit;
  // Drive hours_dec from dec_pulse  and  hours_edit.
  assign hours_dec    = dec_pulse && hours_edit;

endmodule
