`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2024 01:32:04
// Design Name: 
// Module Name: Wall
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


module fulladder( a,b,cin, sum, carry );
    input a;
    input b;
    input cin;
    output sum;
    output carry;
    
    wire t1,t2,t3;
   xor (sum, a, b, cin);
   and  (t1, a, b);
   and  (t2, b, cin);
   and (t3, a, cin);
   or (carry, t1, t2, t3);
    
endmodule

module halfadder(a,b,sum, carry);
    input a;
    input b;
    output carry;
    output sum;
    
    wire t2,t3,t4,t5;
    and g1(carry,a,b);
    not g3(t2,a);
    not g4(t3,b);
    and g5(t4,t2,b);
    and g6(t5,t3,a);
    or g7(sum,t4,t5);
    
endmodule


