`timescale 1ns / 1ps

// Seven segment display decoder for hexadecimal digits (0-F).
//
// Parameters:
// ACTIVE_LOW - 1 for active low segments, 0 for active high segments. Default is 1 (active low).
//
// Ports:
// digit -      4-bit input representing the hexadecimal digit to display (0-F).
// blank -      If high, all segments will be turned off regardless of the digit input.
// segments  -  7-bit segment output [g,f,e,d,c,b,a], given by the mapping below:
//
//                ———a———
//               |       |
//               f       b
//               |       |
//                ———g———
//               |       |
//               e       c
//               |       |
//                ———d———
//
module seven_segment #(
    // Constant parameter used to configure internal behavior.
    parameter int ACTIVE_LOW = 1
) (
    input  logic [3:0] digit,
    input  logic       blank,
    output logic [6:0] segments
);

  // Stores the active-high seven-segment pattern before inversion if needed.
  logic [6:0] segments_active_high;
  // Compute derived signals using current inputs and matrix logic.
  always_comb begin
    if (blank || $isunknown(digit)) begin
      segments_active_high = 7'b0000000;  // All segments off
    end else begin
      unique case (digit)
        4'h0: segments_active_high = 7'b0111111;  // a,b,c,d,e,f
        4'h1: segments_active_high = 7'b0000110;  // b,c
        4'h2: segments_active_high = 7'b1011011;  // a,b,d,e,g
        4'h3: segments_active_high = 7'b1001111;  // a,b,c,d,g
        4'h4: segments_active_high = 7'b1100110;  // b,c,f,g
        4'h5: segments_active_high = 7'b1101101;  // a,c,d,f,g
        4'h6: segments_active_high = 7'b1111101;  // a,c,d,e,f,g
        4'h7: segments_active_high = 7'b0000111;  // a,b,c
        4'h8: segments_active_high = 7'b1111111;  // a,b,c,d,e,f,g
        4'h9: segments_active_high = 7'b1101111;  // a,b,c,d,f,g
        4'ha: segments_active_high = 7'b1110111;  // a,b,c,e,f,g
        4'hb: segments_active_high = 7'b1111100;  // c,d,e,f,g
        4'hc: segments_active_high = 7'b0111001;  // a,d,e,f
        4'hd: segments_active_high = 7'b1011110;  // b,c,d,e,g
        4'he: segments_active_high = 7'b1111001;  // a,d,e,f,g
        4'hf: segments_active_high = 7'b1110001;  // a,e,f,g
      endcase
    end
  end

  // Flip all bits of segments_active_high if ACTIVE_LOW is high
  assign segments = ACTIVE_LOW != 0 ? ~segments_active_high : segments_active_high;

endmodule
