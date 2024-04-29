
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2024 01:35:22
// Design Name: 
// Module Name: adder
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


module RippleCarryAdder32(  
    input [31:0]a, 
    input [31:0]b,
    output [31:0]sum,
    output cout
);

wire t1,t2, t3,t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24, t25, t26, t27, t28, t29, t30, t31; 
halfadder f1(a[0], b[0], sum[0], t1);
fulladder f2(a[1], b[1], t1, sum[1], t2);
fulladder f3(a[2], b[2], t2, sum[2], t3);
fulladder f4(a[3], b[3], t3, sum[3], t4);
fulladder f5(a[4], b[4], t4, sum[4], t5);
fulladder f6(a[5], b[5], t5, sum[5], t6);
fulladder f7(a[6], b[6], t6, sum[6], t7);
fulladder f8(a[7], b[7], t7, sum[7], t8);
fulladder f9(a[8], b[8], t8, sum[8], t9);
fulladder f10(a[9], b[9], t9, sum[9], t10);
fulladder f11(a[10], b[10], t10, sum[10], t11);
fulladder f12(a[11], b[11], t11, sum[11], t12);
fulladder f13(a[12], b[12], t12, sum[12], t13);
fulladder f14(a[13], b[13], t13, sum[13], t14);
fulladder f15(a[14], b[14], t14, sum[14], t15);
fulladder f16(a[15], b[15], t15, sum[15], t16);
fulladder f21(a[16], b[16], t16, sum[16], t17);
fulladder f22(a[17], b[17], t17, sum[17], t18);
fulladder f23(a[18], b[18], t18, sum[18], t19);
fulladder f24(a[19], b[19], t19, sum[19], t20);
fulladder f25(a[20], b[20], t20, sum[20], t21);
fulladder f26(a[21], b[21], t21, sum[21], t22);
fulladder f27(a[22], b[22], t22, sum[22], t23);
fulladder f28(a[23], b[23], t23, sum[23], t24);
fulladder f119(a[24], b[24], t24, sum[24], t25);
fulladder f29(a[25], b[25], t25, sum[25], t26);
fulladder f30(a[26], b[26], t26, sum[26], t27);
fulladder f31(a[27], b[27], t27, sum[27], t28);
fulladder f32(a[28], b[28], t28, sum[28], t29);
fulladder f33(a[29], b[29], t29, sum[29], t30);
fulladder f34(a[30], b[30], t30, sum[30], t31);
fulladder f35(a[31], b[31], t31, sum[31], cout);
endmodule

