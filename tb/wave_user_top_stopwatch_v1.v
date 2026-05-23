`timescale 1ns / 1ps
module wave_user_top_stopwatch_v1;
  reg        clk = 0;
  reg  [3:0] button = 4'b0;
  reg  [9:0] sw = 10'b0;
  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_hours;
  wire       blank_minutes;
  wire       blank_seconds;

  // Override CYCLES_PER_SECOND so each simulated second is 10 clock cycles.
  // seconds_tick fires every 100 ns; one simulated minute takes 6000 ns.
  user_top_stopwatch_v1 #(
      .CYCLES_PER_SECOND(1000)
  ) dut (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  always #5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_user_top_stopwatch_v1.vcd");
    $dumpvars(0, wave_user_top_stopwatch_v1);

    #3000 button[0] = 1;

    #3000 button[0] = 0;


    #3000 button[1] = 1;

    #3000 button[1] = 0;

    #3000 button[0] = 1;
    button[1] = 1;

    #3000 button[0] = 0;
    button[1] = 0;

    #3000 button[0] = 1;

    #1000 button[0] = 0;

    #2000 button[1] = 1;

    #1000 button[0] = 0;

    #2000 button[0] = 1;

    #1000 button[0] = 0;

    #2000 button[1] = 1;

    #1000 button[0] = 0;

    #3000 $finish;
  end
endmodule
