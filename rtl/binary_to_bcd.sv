`timescale 1ns / 1ps


// Binary to Binary-Coded Decimal (BCD) Converter
// Converts a 7-bit binary number (0-99) to its BCD representation (tens and ones digits).
//
// Ports:
// bin   - 7-bit binary input representing a number from 0 to 99.
// tens  - 4-bit output representing the tens digit in BCD.
// ones  - 4-bit output representing the ones digit in BCD.
module binary_to_bcd (
    input  logic [6:0] bin,
    output logic [3:0] tens,
    output logic [3:0] ones
);
  // Integer division and modulus operations to extract tens and ones digits
  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);
endmodule
