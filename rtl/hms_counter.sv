`timescale 1ns / 1ps

// Hours:Minutes:Seconds (HMS) Counter
// Counts upwards in hours, minutes, and seconds by default,
// with rollover from seconds to minutes and minutes to hours.
// Acts as a triple counter
//
// Parameters:
// N_HOURS   - Number of hours before rolling over to 0. Default is 24.
// N_MINUTES - Number of minutes before rolling over to 0 and incrementing hours. Default is 60.
// N_SECONDS - Number of seconds before rolling over to 0 and incrementing minutes. Default is 60.
// W_HOURS   - Bit width for hours output. Default is 5 (enough to represent 0-23).
// W_MINUTES - Bit width for minutes output. Default is 6 (enough to represent 0-59).
// W_SECONDS - Bit width for seconds output. Default is 6 (enough to represent 0-59).
//
// Ports:
// clk     - Clock input.
// enable  - When high, the counter will increment on the rising edge of the clock.
//           otherwise the counter holds its value.
// hours   - Current hours count output.
// minutes - Current minutes count output.
// seconds - Current seconds count output.
module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds

    // Output port widths
    parameter int W_HOURS   = 5,  // Enough bits to represent 0-23
    parameter int W_MINUTES = 6,  // Enough bits to represent 0-59
    parameter int W_SECONDS = 6   // Enough bits to represent 0-59
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  // Maximum values for minutes and seconds,
  // truncated to fit within their respective widths
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  //Initialize rollover signals
  logic second_rollover, minute_rollover;

  // Instantiate three up_down_counters for hours, minutes, and seconds
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk   (clk),
      .enable(enable && minute_rollover),  // Increment hours only when minutes roll over
      .up    (1'b1),                       // Always count up
      .count (hours)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk   (clk),
      .enable(enable && second_rollover),  // Increment minutes only when seconds roll over
      .up    (1'b1),                       // Always count up
      .count (minutes)
  );

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk   (clk),
      .enable(enable),  // Increment seconds on every clock cycle when enabled
      .up    (1'b1),    // Always count up
      .count (seconds)
  );

  // Rollover logic: seconds roll over when they reach MaxSeconds, 
  // minutes roll over when they reach MaxMinutes and seconds roll over
  assign second_rollover = enable && (seconds == MaxSeconds);
  assign minute_rollover = enable && (minutes == MaxMinutes) && second_rollover;

endmodule
