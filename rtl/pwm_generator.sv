`timescale 1ns / 1ps

// PWM Generator
//
// Generates a pulse-width modulated output signal based on an internal counter.
// The PWM output is high for DUTY_CYCLES clock cycles within each PERIOD_CYCLES period.
//
// Parameters:
// PERIOD_CYCLES - Number of clock cycles in one PWM period.
// DUTY_CYCLES   - Number of clock cycles output is high within each period.
// WIDTH         - Bit width needed to store PERIOD_CYCLES.
//
// Ports:
// clk     - Clock input.
// rst     - Synchronous reset input.
// pwm_out - PWM output signal.
module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000,

    // Bit width needed to store PERIOD_CYCLES
    localparam int WIDTH = $clog2(PERIOD_CYCLES) + 1
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  // Stores the current counter value.
  logic [WIDTH-1:0] count;

  // Counts from 0 to PERIOD_CYCLES-1 (parameter PERIOD_CYCLES).
  // Wraps to 0 after reaching PERIOD_CYCLES-1; counter width is WIDTH bits.
  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  // Drive pwm_out from (count < WIDTH'(DUTY_CYCLES)).
  assign pwm_out = (count < WIDTH'(DUTY_CYCLES));

endmodule
