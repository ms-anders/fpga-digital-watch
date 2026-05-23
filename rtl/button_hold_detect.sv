`timescale 1ns / 1ps


// Button Hold Detector
//
// Detects when a signal has been held high for HOLD_CYCLES clock cycles
//
// Parameters:
// HOLD_CYCLES - number of clock cycles before held output goes high
//
// Ports:
// clk    - Clock Input
// button - Input signal to detect hold length
// held   - Output signal that is held high after specified clock cycles
//
module button_hold_detect #(
    // Constant parameter used to configure internal behavior.
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  // Initialise counter width and max count
  localparam int CountMax = HOLD_CYCLES;
  // Constant parameter used to configure internal behavior.
  localparam int CountWidth = $clog2(CountMax + 1);

  // Initialise counter inputs and outputs
  logic count_rst;
  // Enables the internal counter when asserted.
  logic count_enable;
  // Stores the current counter value.
  logic [CountWidth-1:0] count;

  // Mod N Counter counts up to CountMax then stops, taking CountMax clock cycles
  mod_n_counter #(
      .N    (CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk   (clk),
      .rst   (count_rst),
      .enable(count_enable),
      .count (count)
  );

  // Drive count_enable from (button  and  not held).
  assign count_enable = (button && !held); // Continue counting until held goes high (count >= CountMax)
  // Drive count_rst from not button.
  assign count_rst = !button;  // Reset counter when input signal is no longer high

  // Drive held from (count  >=  CountWidth'(CountMax)).
  assign held = (count >= CountWidth'(CountMax));  // goes high after CountMax clock cycles

endmodule
