`timescale 1ns / 1ps

module top_time_display_v1 #(
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

  logic run = 1'b1;

  logic [4:0] hours;
  logic [5:0] mins;
  logic [5:0] secs;

  logic [3:0] digit0, digit1, digit2, digit3, digit4, digit5;

  logic tick, tick_1kHz, tick_25Hz, tick_1Hz;

  hms_counter u_hms (
      .clk    (CLOCK_50),
      .enable (tick),
      .hours  (hours),
      .minutes(mins),
      .seconds(secs)
  );



  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1_000)
  ) u_tick_1kHz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1kHz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_tick_25Hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_25Hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_tick_1Hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1Hz)
  );



  binary_to_bcd u_h_bcd (
      .bin ({2'b0, hours}),
      .tens(digit5),
      .ones(digit4)
  );

  binary_to_bcd u_m_bcd (
      .bin ({1'b0, mins}),
      .tens(digit3),
      .ones(digit2)
  );

  binary_to_bcd u_s_bcd (
      .bin ({1'b0, secs}),
      .tens(digit1),
      .ones(digit0)
  );



  seven_segment u_HEX0 (
      .digit   (digit0),
      .blank   (!run),
      .segments(HEX0)
  );

  seven_segment u_HEX1 (
      .digit   (digit1),
      .blank   (!run),
      .segments(HEX1)
  );

  seven_segment u_HEX2 (
      .digit   (digit2),
      .blank   (!run),
      .segments(HEX2)
  );

  seven_segment u_HEX3 (
      .digit   (digit3),
      .blank   (!run),
      .segments(HEX3)
  );

  seven_segment u_HEX4 (
      .digit   (digit4),
      .blank   (!run),
      .segments(HEX4)
  );

  seven_segment u_HEX5 (
      .digit   (digit5),
      .blank   (!run),
      .segments(HEX5)
  );

  always_comb begin
    unique case (SW)
      2'b00: tick = tick_1Hz;
      2'b01: tick = tick_25Hz;
      2'b10: tick = tick_1kHz;
      2'b11: tick = 1'b1;
    endcase
  end

endmodule
