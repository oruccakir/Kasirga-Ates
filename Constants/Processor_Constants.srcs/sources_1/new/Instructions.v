
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
    localparam SLLI = 25;
    localparam SRLI = 26;
    localparam SRAI = 27;
    localparam ADD = 28;
    localparam SUB = 29;
    localparam SLL = 30;
    localparam SLT = 31;
    localparam SLTU = 32;
    localparam XOR = 33;
    localparam SRL = 34;
    localparam SRA = 35;
    localparam OR = 36;
    localparam AND = 37;

    // RV32M Standard Extension for Integer Multiplication and Division
    localparam MUL = 38;
    localparam MULH = 39;
    localparam MULHSU = 40;
    localparam MULHU = 41;
    localparam DIV = 42;
    localparam DIVU = 43;
    localparam REM = 44;
    localparam REMU = 45;

    // RV32A Standard Extension for Atomic Instructions
    localparam LR.W = 46;
    localparam SC.W = 47;
    localparam AMOSWAP.W = 48;
    localparam AMOADD.W = 49;
    localparam AMOXOR.W = 50;
    localparam AMOAND.W = 51;
    localparam AMOOR.W = 52;
    localparam AMOMIN.W = 53;
    localparam AMOMAX.W = 54;
    localparam AMOMINU.W = 55;
    localparam AMOMAXU.W = 56;

    // RV32F Standard Extension for Single-Precision Floating-Point
    localparam FLW = 57;
    localparam FSW = 58;
    localparam FMADD.S = 59;
    localparam FMSUB.S = 60;
    localparam FNMSUB.S = 61;
    localparam FNMADD.S = 62;
    localparam FADD.S = 63;
    localparam FSUB.S = 64;
    localparam FMUL.S = 65;
    localparam FDIV.S = 66;
    localparam FSQRT.S = 67;
    localparam FSGNJ.S = 68;
    localparam FSGNJN.S = 69;
    localparam FSGNJX.S = 70;
    localparam FMIN.S = 71;
    localparam FMAX.S = 72;
    localparam FCVT.W.S = 73;
    localparam FCVT.WU.S = 74;
    localparam FMV.X.W = 75;
    localparam FEQ.S = 76;
    localparam FLT.S = 77;
    localparam FLE.S = 78;
    localparam FCLASS.S = 79;
    localparam FCVT.S.W = 80;
    localparam FCVT.S.WU = 81;
    localparam FMV.W.X = 82;

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
            if(funct7 == 7'b0000001) begin
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
            else begin
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
                        decodeInstruction = FSGNJ.S;
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
