
// Module Name: Instructions
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

function automatic logic [6:0] decodeInstruction(input logic [31:0] instruction);
    logic [6:0] opcode = instruction[6:0];
    logic [2:0] funct3 = instruction[14:12];
    logic [6:0] funct7 = instruction[31:25];
    case (opcode)
        7'b0110111: decodeInstruction = LUI;
        7'b0010111: decodeInstruction = AUIPC;
        7'b1101111: decodeInstruction = JAL;
        7'b1100111: decodeInstruction = JALR;
        7'b1100011: begin
            case (funct3)
                3'b000: decodeInstruction = BEQ;
                3'b001: decodeInstruction = BNE;
                3'b100: decodeInstruction = BLT;
                3'b101: decodeInstruction = BGE;
                3'b110: decodeInstruction = BLTU;
                3'b111: decodeInstruction = BGEU;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0000011: begin
            case (funct3)
                3'b000: decodeInstruction = LB;
                3'b001: decodeInstruction = LH;
                3'b010: decodeInstruction = LW;
                3'b100: decodeInstruction = LBU;
                3'b101: decodeInstruction = LHU;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0100011: begin
            case (funct3)
                3'b000: decodeInstruction = SB;
                3'b001: decodeInstruction = SH;
                3'b010: decodeInstruction = SW;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0010011: begin
            case (funct3)
                3'b000: decodeInstruction = ADDI;
                3'b010: decodeInstruction = SLTI;
                3'b011: decodeInstruction = SLTIU;
                3'b100: decodeInstruction = XORI;
                3'b110: decodeInstruction = ORI;
                3'b111: decodeInstruction = ANDI;
                3'b001: decodeInstruction = SLLI;
                3'b101: begin
                    if (funct7 == 7'b0000000)
                        decodeInstruction = SRLI;
                    else if (funct7 == 7'b0100000)
                        decodeInstruction = SRAI;
                    else
                        decodeInstruction = 7'b0;
                end
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0110011: begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000)
                        decodeInstruction = ADD;
                    else if (funct7 == 6'b0100000)
                        decodeInstruction = SUB;
                    else
                        decodeInstruction = 7'b0;
                end
                3'b001: decodeInstruction = SLL;
                3'b010: decodeInstruction = SLT;
                3'b011: decodeInstruction = SLTU;
                3'b100: decodeInstruction = XOR;
                3'b101: begin
                    if (funct7 == 7'b0000000)
                        decodeInstruction = SRL;
                    else if (funct7 == 7'b0100000)
                        decodeInstruction = SRA;
                    else
                        decodeInstruction = 7'b0;
                end
                3'b110: decodeInstruction = OR;
                3'b111: decodeInstruction = AND;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0110011: begin
            case (funct3)
                3'b000: decodeInstruction = MUL;
                3'b001: decodeInstruction = MULH;
                3'b010: decodeInstruction = MULHSU;
                3'b011: decodeInstruction = MULHU;
                3'b100: decodeInstruction = DIV;
                3'b101: decodeInstruction = DIVU;
                3'b110: decodeInstruction = REM;
                3'b111: decodeInstruction = REMU;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0101111: begin
            case (funct7[6:2])
                5'b00010: decodeInstruction = LR.W;
                5'b00011: decodeInstruction = SC.W;
                5'b00001: decodeInstruction = AMOSWAP.W;
                5'b00000: decodeInstruction = AMOADD.W;
                5'b00100: decodeInstruction = AMOXOR.W;
                5'b01100: decodeInstruction = AMOAND.W;
                5'b01000: decodeInstruction = AMOOR.W;
                5'b10000: decodeInstruction = AMOMIN.W;
                5'b10100: decodeInstruction = AMOMAX.W;
                5'b11000: decodeInstruction = AMOMINU.W;
                5'b11100: decodeInstruction = AMOMAXU.W;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0000111: decodeInstruction = FLW;
        7'b0100111: decodeInstruction = FSW;
        7'b1000011: decodeInstruction = FMADD.S;
        7'b1000111: decodeInstruction = FMSUB.S;
        7'b1001011: decodeInstruction = FNMSUB.S;
        7'b1001111: decodeInstruction = FNMADD.S;
        7'b1010011: begin
            case(funct7)
                7'b0000000: decodeInstruction = FADD.S;
                7'b0000100: decodeInstruction = FSUB.S;
                7'b0001000: decodeInstruction = FMUL.S;
                7'b0001100: decodeInstruction = FDIV.S;
                7'b0101100: decodeInstruction = FSQRT.S;
                7'b0010000: begin
                    if (funct3 == 3'b000)
                        decodeInstruction = FSGNJN.S;
                    else if (funct3 == 3'b001)
                        decodeInstruction = FSGNJN.S;
                    else if (funct3 == 3'b010)
                        decodeInstruction = FSGNJX.S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b0010100: begin
                    if(funct3 == 3'b000)
                        decodeInstruction = FMIN.S;
                    else if(funct3 == 3'b001)
                        decodeInstruction = FMAX.S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1100000: begin
                    if(instruction[24:20] == 5'b00000)
                        decodeInstruction = FCVT.W.S;
                    else if(instruction[24:20] == 5'b00001)
                        decodeInstruction = FCVT.WU.S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1110000: begin
                    if(funct3 == 3'b000)
                        decodeInstruction = FMV.X.W;
                    else if (funct3 == 3'b001)
                        decodeInstruction = FCLASS.S;
                    else
                        decodeInstruction = 7'b0;  
                end
                7'b1010000: begin
                    if(funct3 == 3'b010)
                        decodeInstruction = FEQ.S;
                    else if(funct3 == 3'b001)
                        decodeInstruction = FLT.S;
                    else if(funct3 == 3'b000)
                        decodeInstruction = FLE.S;
                    else
                        decodeInstruction = 7'b0;
                    end
                7'b1101000:begin
                    if(instruction[24:20] == 5'b00000)
                        decodeInstruction = FCVT.S.W;
                    else if(instruction[24:20] == 5'b00001)
                        decodeInstruction = FCVT.S.WU;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1111000: decodeInstruction = FMV.W.X;
            endcase
        end  
        default: decodeInstruction = 7'b0; 
    endcase
    
endfunction
    
    


endmodule
