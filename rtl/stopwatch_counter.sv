`timescale 1ns / 1ps

// Stopwatch Counter
//
// Counts minutes, seconds, and centiseconds based on a periodic tick derived from the clock.
// This module is suitable for stopwatch timing when connected to a 50 MHz clock or similar.
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in one second.
//
// Ports:
// clk          - Clock input.
// rst          - Synchronous reset input. Takes priority over enable.
// enable       - When high, the counter runs and updates on tick events.
// minutes      - Minutes count output.
// seconds      - Seconds count output.
// centiseconds - Hundredths-of-a-second count output.
module stopwatch_counter #(
    // Constant parameter used to configure internal behavior.
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic       rst,          // Takes priority over enable
    input  logic       enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // Hundredths of a second
);


  // Carries the periodic timing pulse used by counters.
  logic tick;

  // Generates periodic ticks while run is high and resets when run goes low.
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_rate_gen (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );


  // Chains multiple counters for higher-place timing digits.
  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_casc_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable && tick && !rst),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );




endmodule
