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

// Timer Top Level
//
// Implements a countdown timer with edit modes, start/stop control, and blink-based feedback.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second for the input clock.
//
// Ports:
// clk           - Clock input.
// button        - User button inputs for timer control and editing.
// sw            - Switch inputs passed through to the timer.
// led           - LED outputs.
// hours_disp    - Seven-segment output for hours digits.
// minutes_disp  - Seven-segment output for minutes digits.
// seconds_disp  - Seven-segment output for seconds digits.
// blank_hours   - Active-high blanking for hours display.
// blank_minutes - Active-high blanking for minutes display.
// blank_seconds - Active-high blanking for seconds display.
module user_top_timer_v1 #(
    // Constant parameter used to configure internal behavior.
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic       probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input  logic       clk,
    /* verilator lint_off UNUSED */
    input  logic [3:0] button,
    input  logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  // Generates the increment pulse for editing fields.
  logic inc_pulse;

  // Generates repeated button pulses while the button remains held.
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold before repeating
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // 10Hz repeat rate
  ) u_inc_pulse (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  // Produces a decrement pulse for the selected edit field.
  logic dec_pulse;

  // Generates repeated button pulses while the button remains held.
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold before repeating
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // 10Hz repeat rate
  ) u_dec_pulse (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );



  // Detects the rising edge of the start/stop button.
  logic rise_start_stop;

  // Detects a rising edge on the input signal.
  rising_edge_detector u_rise_start_stop (
      .clk   (clk),
      .sig_in(button[0]),
      .rise  (rise_start_stop)
  );


  // Holds the current mode selection from the edit mode selector.
  logic [2:0] mode_enable;

  // Selects which digit editing mode is active based on button input.
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  // Enables edit mode for the current digit selection.
  logic mode_edit;

  // Drive mode_edit from (mode_enable not = 3'b000).
  assign mode_edit = (mode_enable != 3'b000);


  // Holds the current seconds count value.
  logic [5:0] seconds;
  // Holds the current minutes count value.
  logic [5:0] minutes;
  // Holds the current hours count value.
  logic [4:0] hours;



  // Latches whether the rate generator is currently enabled.
  logic running = 1'b0;

  // Indicates when the displayed time has reached zero.
  logic zeroed;
  // Drive zeroed from (hours  equals  5'd0)  and  (minutes  equals  6'd0)  and  (seconds  equals  6'd0).
  assign zeroed = (hours == 5'd0) && (minutes == 6'd0) && (seconds == 6'd0);

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    if (mode_edit || zeroed) begin
      running <= 1'b0;
    end else if (rise_start_stop && !zeroed) begin
      running <= !running;
    end
  end



  // Carries the one-second timing pulse.
  logic tick_1Hz;

  // Generates periodic ticks while run is high and resets when run goes low.
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1hz_tick (
      .clk (clk),
      .run (running),
      .tick(tick_1Hz)
  );



  // Drive seconds_disp from {1'b0, seconds}.
  assign seconds_disp = {1'b0, seconds};
  // Drive minutes_disp from {1'b0, minutes}.
  assign minutes_disp = {1'b0, minutes};
  // Drive hours_disp from {2'b00, hours}.
  assign hours_disp   = {2'b00, hours};


  // Signals a borrow from seconds when seconds roll under.
  logic seconds_borrow;

  // Provide a countdown counter that can be edited and borrowed across digit boundaries.
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(running && tick_1Hz && !zeroed),
      .edit_mode(mode_enable[0]),
      .inc(inc_pulse && mode_enable[0]),
      .dec(dec_pulse && mode_enable[0]),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );


  // Signals a borrow from minutes when minutes roll under.
  logic minutes_borrow;

  // Provide a countdown counter that can be edited and borrowed across digit boundaries.
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(seconds_borrow),
      .edit_mode(mode_enable[1]),
      .inc(inc_pulse && mode_enable[1]),
      .dec(dec_pulse && mode_enable[1]),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );


  /* verilator lint_off UNUSED */
  // Signals a borrow from hours when hours roll under.
  logic hours_borrow;
  /* verilator lint_off UNUSED */

  // Provide a countdown counter that can be edited and borrowed across digit boundaries.
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(minutes_borrow),
      .edit_mode(mode_enable[2]),
      .inc(inc_pulse && mode_enable[2]),
      .dec(dec_pulse && mode_enable[2]),
      .count(hours),
      .borrow_out(hours_borrow)
  );


  // Holds the PWM blanking output used to dim display segments.
  logic pwm_out;

  // Generates PWM output from a counter and selected duty cycle.
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  ((CYCLES_PER_SECOND / 2) * 4 / 5)
  ) u_flash_pwm (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  // Drive blank_seconds from mode_enable[0]  and  not pwm_out.
  assign blank_seconds = mode_enable[0] && !pwm_out;
  // Drive blank_minutes from mode_enable[1]  and  not pwm_out.
  assign blank_minutes = mode_enable[1] && !pwm_out;
  // Drive blank_hours from mode_enable[2]  and  not pwm_out.
  assign blank_hours = mode_enable[2] && !pwm_out;

  // Drive led from 10'b0.
  assign led = 10'b0;

`ifdef FORMAL
  // Drive probe_running from running.
  assign probe_running = running;
  // Drive probe_mode_enable from mode_enable.
  assign probe_mode_enable = mode_enable;
`endif

endmodule
