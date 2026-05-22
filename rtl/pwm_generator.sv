`timescale 1ns / 1ps

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

  logic [WIDTH-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  assign pwm_out = (count < WIDTH'(DUTY_CYCLES));

endmodule
