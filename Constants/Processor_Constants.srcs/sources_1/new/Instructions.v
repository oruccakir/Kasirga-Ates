`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2024 08:51:41
// Design Name: 
// Module Name: Instructions
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


module Instructions(

    );

    // RISC-V Instructions
    // RV32I Base Integer Instruction Set
    localparam LUI = 1;
    localparam AUIPC = 2;
    localparam JAL = 3;
    localparam JALR = 4;
    localparam BEQ = 5;
    localparam BNE = 6;
    localparam BLT = 7;
    localparam BGE = 8;
    localparam BLTU = 9;
    localparam BGEU = 10;
    localparam LB = 11;
    localparam LH = 12;
    localparam LW = 13;
    localparam LBU = 14;
    localparam LHU = 15;
    localparam SB = 16;
    localparam SH = 17;
    localparam SW = 18;
    localparam ADDI = 19;
    localparam SLTI = 20;
    localparam SLTIU = 21;
    localparam XORI = 22;
    localparam ORI = 23;
    localparam ANDI = 24;
    localparam SLTI = 25;
    localparam SLTIU = 26;
    localparam XORI = 27;
    localparam ORI = 28;
    localparam ANDI = 29;
    localparam SLLI = 30;
    localparam SRLI = 31;
    localparam SRAI = 32;
    localparam ADD = 33;
    localparam SUB = 34;
    localparam SLL = 35;
    localparam SLT = 36;
    localparam SLTU = 37;
    localparam XOR = 38;
    localparam SRL = 39;
    localparam SRA = 40;
    localparam OR = 41;
    localparam AND = 42;

    // RV32M Standard Extension for Integer Multiplication and Division
    localparam MUL = 43;
    localparam MULH = 44;
    localparam MULHSU = 45;
    localparam MULHU = 46;
    localparam DIV = 47;
    localparam DIVU = 48;
    localparam REM = 49;
    localparam REMU = 50;

    // RV32A Standard Extension for Atomic Instructions
    localparam LR.W = 51;
    localparam SC.W = 52;
    localparam AMOSWAP.W = 53;
    localparam AMOADD.W = 54;
    localparam AMOXOR.W = 55;
    localparam AMOAND.W = 56;
    localparam AMOOR.W = 57;
    localparam AMOMIN.W = 58;
    localparam AMOMAX.W = 59;
    localparam AMOMINU.W = 60;
    localparam AMOMAXU.W = 61;

    // RV32F Standard Extension for Single-Precision Floating-Point
    localparam FLW = 62;
    localparam FSW = 63;
    localparam FMADD.S = 64;
    localparam FMSUB.S = 65;
    localparam FNMSUB.S = 66;
    localparam FNMADD.S = 67;
    localparam FADD.S = 68;
    localparam FSUB.S = 69;
    localparam FMUL.S = 70;
    localparam FDIV.S = 71;
    localparam FSQRT.S = 72;
    localparam FSGNJ.S = 73;
    localparam FSGNJN.S = 74;
    localparam FSGNJX.S = 75;
    localparam FMIN.S = 76;
    localparam FMAX.S = 77;
    localparam FCVT.W.S = 78;
    localparam FCVT.WU.S = 79;
    localparam FMV.X.W = 80;
    localparam FEQ.S = 81;
    localparam FLT.S = 82;
    localparam FLE.S = 83;
    localparam FCLASS.S = 84;
    localparam FCVT.S.W = 85;
    localparam FCVT.S.WU = 86;
    localparam FMV.W.X = 87;


endmodule
