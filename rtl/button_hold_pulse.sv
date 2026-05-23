`timescale 1ns / 1ps


// Button Pulse Hold Detector
//
// Outputs high for one clock cycle after input button is held high for HOLD_CYCLES clock cycles
//
// Parameters:
// HOLD_CYCLES - number of clock cycles before single-cycle pulse is generated
//
// Ports:
// clk    - Clock Input
// button - Input signal to monitor hold time of
// pulse  - Output signal where single-cycle pulse is generated
module button_hold_pulse #(
    // Constant parameter used to configure internal behavior.
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  // Indicates that the button has been held long enough to enable repeat behavior.
  logic held;

  // Detect when button is held high for HOLD_CYCLES clock cycles
  // Send output to held
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Detect when held transitions from low to high
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)  // Output one cycle pulse when held transitions low-high
  );

endmodule
