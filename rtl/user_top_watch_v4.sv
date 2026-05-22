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

module user_top_watch_v4 #(
    /* verilator lint_off UNUSEDPARAM */
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
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;

  logic [5:0] seconds;
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

  logic run_rate_gen;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1Hz (
      .clk (clk),
      .run (run_rate_gen),
      .tick(seconds_tick)
  );



  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;

  logic [5:0] minutes;
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



  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;

  logic [4:0] hours;
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



  assign minutes_tick = seconds_tick && (seconds >= 6'd59);
  assign hours_tick = minutes_tick && (minutes >= 6'd59);

  assign seconds_disp = {1'b0, seconds};
  assign minutes_disp = {1'b0, minutes};
  assign hours_disp = {2'b0, hours};

  assign led = 10'b0;



  // ------------------
  // - Mode Selection -
  // ------------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk        (clk),
      .button     (button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 0.8)
  ) u_digit_pwm (
      .clk    (clk),
      .rst    (1'b0),
      .pwm_out(pwm_out)
  );

  assign blank_seconds = (mode_enable == 3'b001) ? !pwm_out : 1'b0;
  assign blank_minutes = (mode_enable == 3'b010) ? !pwm_out : 1'b0;
  assign blank_hours   = (mode_enable == 3'b100) ? !pwm_out : 1'b0;



  // --------------
  // - Edit Logic -
  // --------------


  logic inc_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_pulse (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  logic dec_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_pulse (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  assign seconds_edit = (mode_enable == 3'b001);
  assign minutes_edit = (mode_enable == 3'b010);
  assign hours_edit   = (mode_enable == 3'b100);

  assign seconds_inc  = inc_pulse && seconds_edit;
  assign seconds_dec  = dec_pulse && seconds_edit;

  assign minutes_inc  = inc_pulse && minutes_edit;
  assign minutes_dec  = dec_pulse && minutes_edit;

  assign hours_inc    = inc_pulse && hours_edit;
  assign hours_dec    = dec_pulse && hours_edit;

  // ---------------------------------
  // - Accurate Second Setting Logic -
  // ---------------------------------

  assign run_rate_gen = !seconds_edit;

endmodule
