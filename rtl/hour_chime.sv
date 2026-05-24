`timescale 1ns / 1ps

// Plays an animation on the output led_out when hours_tick goes high
//
// Parameters:
// CYCLES_PER_SECOND - Number of clock cycles in a second
//
// Ports:
// clk - Clock input
// hours_tick - set high to start animation
// led_out - Animation output
//
module hour_chime #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input        clk,
    input        hours_tick,
    output [9:0] led_out
);

  localparam int Width = $clog2(CYCLES_PER_SECOND);

  logic enable;

  logic [Width-1:0] count;

  // Instantiate counter that counts up to CYCLES_PER_SECOND
  mod_n_counter #(
      .N    (CYCLES_PER_SECOND),
      .WIDTH(Width)
  ) u_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(enable),
      .count(count)
  );

  // Count up when animation is in progress or start animation pulse is sent
  assign enable = (count != Width'(0)) || hours_tick;

  logic [9:0] led;

  // Set LED states for each time interval in led
  always_comb begin
    if ((count > Width'(0)) && (count <= Width'(CYCLES_PER_SECOND / 10))) begin
      led = 10'b00001_10000;
    end else if ((count > Width'(CYCLES_PER_SECOND / 10)) && (count <= Width'(2 * CYCLES_PER_SECOND / 10))) begin
      led = 10'b00011_11000;
    end else if ((count > Width'(2 * CYCLES_PER_SECOND / 10)) && (count <= Width'(3 * CYCLES_PER_SECOND / 10))) begin
      led = 10'b00110_01100;
    end else if ((count > Width'(3 * CYCLES_PER_SECOND / 10)) && (count <= Width'(4 * CYCLES_PER_SECOND / 10))) begin
      led = 10'b01100_00110;
    end else if ((count > Width'(4 * CYCLES_PER_SECOND / 10)) && (count <= Width'(5 * CYCLES_PER_SECOND / 10))) begin
      led = 10'b11000_00011;
    end else if ((count > Width'(5 * CYCLES_PER_SECOND / 10)) && (count <= Width'(6 * CYCLES_PER_SECOND / 10))) begin
      led = 10'b10000_00001;
    end else begin
      led = 10'b00000_00000;
    end
  end

  // Assign output to the led state
  assign led_out = led;

endmodule
