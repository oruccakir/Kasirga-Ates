`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2024 01:10:27
// Design Name: 
// Module Name: mul_in_verilog
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mul_in_verilog(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [63:0] result
    );


assign result = a * b;

endmodule
