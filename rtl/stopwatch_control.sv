`timescale 1ns / 1ps

// Stopwatch Control
//
// Controls stopwatch start/stop, lap, and reset behavior based on button edges.
//
// Ports:
// clk             - Clock input.
// rise_start_stop - Pulse when the start/stop button rises.
// rise_lap        - Pulse when the lap button rises.
// counter_rst     - Output reset for the stopwatch counter.
// counter_enable  - Output enable for the stopwatch counter.
// lap_hold        - Output that freezes the display while a lap is held.
module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst = 1'b0,
    output logic counter_enable = 1'b0,
    output logic lap_hold = 1'b0
);

  // Prevent both button presses
  logic start_stop_pulse;
  // Produces the pulse that triggers a lap action.
  logic lap_pulse;

  // Drive start_stop_pulse from rise_start_stop  and  not rise_lap.
  assign start_stop_pulse = rise_start_stop && !rise_lap;
  // Drive lap_pulse from rise_lap  and  not rise_start_stop.
  assign lap_pulse        = rise_lap && !rise_start_stop;


  // Calculates the next reset condition for the stopwatch control state machine.
  logic next_rst;
  // Calculates the next enable state for the stopwatch controller.
  logic next_enable;
  // Calculates the next hold state for the stopwatch controller.
  logic next_hold;

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) begin
    {counter_rst, counter_enable, lap_hold} <= {next_rst, next_enable, next_hold};
  end

  // Next state logic
  assign next_enable = start_stop_pulse ? !counter_enable : counter_enable;
  // Drive next_rst from lap_pulse  and  not counter_enable  and  not lap_hold.
  assign next_rst    = lap_pulse && !counter_enable && !lap_hold;
  // Select next_hold based on the condition (counter_enable && lap_pulse).
  assign next_hold   = (counter_enable && lap_pulse) ? !lap_hold : lap_hold;


endmodule
