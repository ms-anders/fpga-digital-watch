`timescale 1ns / 1ps

// Time Display Top Level
//
// Converts an internal clock into hour/minute/second display outputs for a six-digit HEX display.
// The selected tick rate is controlled by the SW input and can show real time or faster time bases.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second for the input clock.
//
// Ports:
// CLOCK_50 - 50 MHz clock input.
// SW       - Switch inputs used to select the output tick rate.
// HEX0-HEX5 - Seven-segment display outputs for digit values.
module top_time_display_v1 #(
    // Constant parameter used to configure internal behavior.
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // Enables the tick generation logic whenever asserted.
  logic run = 1'b1;

  // Holds the current hours count value.
  logic [4:0] hours;
  // Holds the current minute count for display conversion.
  logic [5:0] mins;
  // Holds the current second count for display conversion.
  logic [5:0] secs;

  // Holds the BCD digit value for the least-significant display digit.
  logic [3:0] digit0, digit1, digit2, digit3, digit4, digit5;

  // Carries the periodic timing pulse used by counters.
  logic tick, tick_1kHz, tick_25Hz, tick_1Hz;

  // Use the HMS counter to advance hours, minutes, and seconds on each selected tick.
  hms_counter u_hms (
      .clk    (CLOCK_50),
      .enable (tick),
      .hours  (hours),
      .minutes(mins),
      .seconds(secs)
  );



  // 1kHz pulse generator
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1_000)
  ) u_tick_1kHz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1kHz)
  );

  // 25Hz pulse generator
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_tick_25Hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_25Hz)
  );

  // 1Hz pulse generator
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_tick_1Hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1Hz)
  );



  // Converts a binary number to tens and ones BCD digits.
  binary_to_bcd u_h_bcd (
      .bin ({2'b0, hours}),
      .tens(digit5),
      .ones(digit4)
  );

  // Converts a binary number to tens and ones BCD digits.
  binary_to_bcd u_m_bcd (
      .bin ({1'b0, mins}),
      .tens(digit3),
      .ones(digit2)
  );

  // Converts a binary number to tens and ones BCD digits.
  binary_to_bcd u_s_bcd (
      .bin ({1'b0, secs}),
      .tens(digit1),
      .ones(digit0)
  );



  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX0 (
      .digit   (digit0),
      .blank   (!run),
      .segments(HEX0)
  );

  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX1 (
      .digit   (digit1),
      .blank   (!run),
      .segments(HEX1)
  );

  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX2 (
      .digit   (digit2),
      .blank   (!run),
      .segments(HEX2)
  );

  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX3 (
      .digit   (digit3),
      .blank   (!run),
      .segments(HEX3)
  );

  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX4 (
      .digit   (digit4),
      .blank   (!run),
      .segments(HEX4)
  );

  // Encodes a 4-bit digit into seven-segment segment outputs.
  seven_segment u_HEX5 (
      .digit   (digit5),
      .blank   (!run),
      .segments(HEX5)
  );

  // Choose the active tick rate based on the switch setting.
  always_comb begin
    unique case (SW)
      2'b00: tick = tick_1Hz;
      2'b01: tick = tick_25Hz;
      2'b10: tick = tick_1kHz;
      2'b11: tick = 1'b1;
    endcase
  end

endmodule
