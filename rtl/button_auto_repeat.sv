`timescale 1ns / 1ps

// Button Auto Repeater
//
// Outputs a 1 clock cycle pulse when button first transitions high,
// then repeats this pulse every REPEAT_CYCLES clock cycles after
// button is held high for HOLD_CYCLES
//
// Parameters:
// HOLD_CYCLES   - Number of clock cycles before repetitive puleses start
// REPEAT_CYCLES - Number of clock cycles between repetitive pulses
//
// Ports:
// clk    - Clock input
// button - Input signal to be held for pulses
// pulse  - Output signal of single-cycle pulses
//
module button_auto_repeat #(
    // Constant parameter used to configure internal behavior.
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  // Initialization
  logic rise;
  // Indicates that the button has been held long enough to enable repeat behavior.
  logic held;
  // Carries the repeated pulse train while the button remains held.
  logic pulse_train;

  // Rising edge detector to create first pulse
  rising_edge_detector u_detector (
      .clk   (clk),
      .sig_in(button),
      .rise  (rise)
  );

  // Detect when button has been held high for HOLD_CYCLES clock cycles
  button_hold_detect #(
      // Rate generator takes REPEAT_CYCLES - 1 cycles to generate its first pulse
      // So we use this value for .HOLD_CYCLES to ensure first repeated pulse occurs after
      // exactly HOLD_CYCLES clock cycles
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_hold (
      .clk   (clk),
      .button(button),
      .held  (held) // goes high after HOLD_CYCLES - REPEAT_CYCLES + 1 clock cycles
  );

  // Rate Generator to generate repetitive pulses after held goes high
  // Restarts when held goes low (when button stops being held)
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_gen (
      .clk(clk),
      .run(held),  // pulse train activates after HOLD_CYCLES - REPEAT_CYCLES + 1 clock cycles
      .tick(pulse_train)  // output pulse train
  );

  // Output high when first rising edge is high OR pulse_train and button are high
  assign pulse = rise | (button && pulse_train);

endmodule
