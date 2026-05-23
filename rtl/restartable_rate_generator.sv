`timescale 1ns / 1ps

// Restartable Rate Generator
//
// Generates a single-cycle tick every CYCLE_COUNT clock cycles whenever run is high.
// When run goes low, the internal counter resets so the next run period starts fresh.
//
// Parameters:
// CYCLE_COUNT - Number of clock cycles between output ticks.
//
// Ports:
// clk  - Clock input.
// run  - Enable input to run or pause the rate generator.
// tick - Output pulse that goes high once every CYCLE_COUNT clock cycles while run is high.
module restartable_rate_generator #(
    // Constant parameter used to configure internal behavior.
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  // Becomes true when the internal counter has reached the tick interval threshold.
  logic tick_qualifier;
  // Latches whether the rate generator is currently enabled.
  logic running = 1'b0;

  // Sequential logic triggered on clock rising edge.
  always_ff @(posedge clk) running <= run;

  // Generate tick only when the generator is enabled and the interval has completed.
  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      // Constant parameter used to configure internal behavior.
      localparam int CountWidth = $clog2(CYCLE_COUNT);

      // Resets the internal tick counter when run is low.
      logic rst_count;
      // Enables the internal counter when asserted.
      logic enable_count;
      // Stores the current counter value.
      logic [CountWidth-1:0] count;

      // Counts from 0 to CYCLE_COUNT-1 (parameter CYCLE_COUNT).
      // Wraps to 0 after reaching CYCLE_COUNT-1; counter width is CountWidth bits.
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      // Drive rst_count from not run.
      assign rst_count = !run;
      // Drive enable_count from run.
      assign enable_count = run;

      // Drive tick_qualifier from (count  >=  CountWidth'(CYCLE_COUNT - 1)).
      assign tick_qualifier = (count >= CountWidth'(CYCLE_COUNT - 1));
    end else begin : g_special
      // Drive tick_qualifier from 1'b1.
      assign tick_qualifier = 1'b1;
    end
  endgenerate
endmodule
