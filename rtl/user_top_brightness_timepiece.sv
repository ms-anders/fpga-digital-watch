`timescale 1ns / 1ps

// Brightness Timepiece Top Level
//
// Wraps a timepiece application and adds a PWM-based blanking signal for display brightness control.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second for the input clock.
//
// Ports:
// clk           - Clock input.
// button        - Button inputs for the wrapped application.
// sw            - Switch inputs for mode and brightness control.
// led           - LED outputs for the wrapped application.
// hours_disp    - Seven-segment output for hours digits.
// minutes_disp  - Seven-segment output for minutes digits.
// seconds_disp  - Seven-segment output for seconds digits.
// blank_hours   - Active-high blanking for the hours display.
// blank_minutes - Active-high blanking for the minutes display.
// blank_seconds - Active-high blanking for the seconds display.
module user_top_brightness_timepiece #(
    // Constant parameter used to configure internal behavior.
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic [3:0] button,
    input  logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic       blank_hours,
    output logic       blank_minutes,
    output logic       blank_seconds
);

  // Holds the blanking condition for the hour display segment.
  logic blank_hours_probe;
  // Holds the blanking condition for the minute display segment.
  logic blank_minutes_probe;
  // Holds the blanking condition for the second display segment.
  logic blank_seconds_probe;

  // Provide the timepiece top-level user interface logic.
  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_app (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours_probe),
      .blank_minutes(blank_minutes_probe),
      .blank_seconds(blank_seconds_probe)
  );

  // Constant parameter used to configure internal behavior.
  localparam int PWMPeriod = CYCLES_PER_SECOND / 1000;
  // Constant parameter used to configure internal behavior.
  localparam int PWMWidth = $clog2(PWMPeriod);

  // Counts through the PWM period to determine output duty.
  logic [PWMWidth-1:0] pwm_count;

  // Counts from 0 to PWMPeriod-1, where PWMPeriod = CYCLES_PER_SECOND / 1000.
  // Wraps to 0 after reaching PWMPeriod-1; count width is PWMWidth bits.
  mod_n_counter #(
      .N    (PWMPeriod),
      .WIDTH(PWMWidth)
  ) u_pwm_counter (
      .clk   (clk),
      .rst   (1'b0),
      .enable(1'b1),
      .count (pwm_count)
  );


  // Selects the PWM duty cycle based on switch inputs.
  logic [1:0] duty_sw;
  // Drive duty_sw from sw[9 : 8].
  assign duty_sw = sw[9:8];

  // Stores the calculated PWM high-time count for the selected duty setting.
  logic [PWMWidth-1:0] duty_cycle;

  // Compute derived signals using current inputs and matrix logic.
  always_comb begin
    unique case (duty_sw)
      2'b00: duty_cycle = PWMWidth'(PWMPeriod / 8);
      2'b01: duty_cycle = PWMWidth'(PWMPeriod / 4);
      2'b11: duty_cycle = PWMWidth'(PWMPeriod / 2);
      2'b10: duty_cycle = PWMWidth'(PWMPeriod);
    endcase
  end

  // Holds the PWM blanking output used to dim display segments.
  logic pwm_out;
  // Select pwm_out based on the condition (sw[9:8] == 2'b10).
  assign pwm_out = (sw[9:8] == 2'b10) ? 1'b1 : (pwm_count < duty_cycle);

  // Drive blank_hours from blank_hours_probe  or  not pwm_out.
  assign blank_hours = blank_hours_probe || !pwm_out;
  // Drive blank_minutes from blank_minutes_probe  or  not pwm_out.
  assign blank_minutes = blank_minutes_probe || !pwm_out;
  // Drive blank_seconds from blank_seconds_probe  or  not pwm_out.
  assign blank_seconds = blank_seconds_probe || !pwm_out;

endmodule
