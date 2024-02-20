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
    localparam LR_W = 46;
    localparam SC_W = 47;
    localparam AMOSWAP_W = 48;
    localparam AMOADD_W = 49;
    localparam AMOXOR_W = 50;
    localparam AMOAND_W = 51;
    localparam AMOOR_W = 52;
    localparam AMOMIN_W = 53;
    localparam AMOMAX_W = 54;
    localparam AMOMINU_W = 55;
    localparam AMOMAXU_W = 56;

    // RV32F Standard Extension for Single-Precision Floating-Point
    localparam FLW = 57;
    localparam FSW = 58;
    localparam FMADD_S = 59;
    localparam FMSUB_S = 60;
    localparam FNMSUB_S = 61;
    localparam FNMADD_S = 62;
    localparam FADD_S = 63;
    localparam FSUB_S = 64;
    localparam FMUL_S = 65;
    localparam FDIV_S = 66;
    localparam FSQRT_S = 67;
    localparam FSGNJ_S = 68;
    localparam FSGNJN_S = 69;
    localparam FSGNJX_S = 70;
    localparam FMIN_S = 71;
    localparam FMAX_S = 72;
    localparam FCVT_W_S = 73;
    localparam FCVT_WU_S = 74;
    localparam FMV_X_W = 75;
    localparam FEQ_S = 76;
    localparam FLT_S = 77;
    localparam FLE_S = 78;
    localparam FCLASS_S = 79;
    localparam FCVT_S_W = 80;
    localparam FCVT_S_WU = 81;
    localparam FMV_W_X = 82;

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
                5'b00010: decodeInstruction = LR_W;
                5'b00011: decodeInstruction = SC_W;
                5'b00001: decodeInstruction = AMOSWAP_W;
                5'b00000: decodeInstruction = AMOADD_W;
                5'b00100: decodeInstruction = AMOXOR_W;
                5'b01100: decodeInstruction = AMOAND_W;
                5'b01000: decodeInstruction = AMOOR_W;
                5'b10000: decodeInstruction = AMOMIN_W;
                5'b10100: decodeInstruction = AMOMAX_W;
                5'b11000: decodeInstruction = AMOMINU_W;
                5'b11100: decodeInstruction = AMOMAXU_W;
                default: decodeInstruction = 7'b0;
            endcase
        end
        7'b0000111: decodeInstruction = FLW;
        7'b0100111: decodeInstruction = FSW;
        7'b1000011: decodeInstruction = FMADD_S;
        7'b1000111: decodeInstruction = FMSUB_S;
        7'b1001011: decodeInstruction = FNMSUB_S;
        7'b1001111: decodeInstruction = FNMADD_S;
        7'b1010011: begin
            case(funct7)
                7'b0000000: decodeInstruction = FADD_S;
                7'b0000100: decodeInstruction = FSUB_S;
                7'b0001000: decodeInstruction = FMUL_S;
                7'b0001100: decodeInstruction = FDIV_S;
                7'b0101100: decodeInstruction = FSQRT_S;
                7'b0010000: begin
                    if (funct3 == 3'b000)
                        decodeInstruction = FSGNJ_S;
                    else if (funct3 == 3'b001)
                        decodeInstruction = FSGNJN_S;
                    else if (funct3 == 3'b010)
                        decodeInstruction = FSGNJX_S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b0010100: begin
                    if(funct3 == 3'b000)
                        decodeInstruction = FMIN_S;
                    else if(funct3 == 3'b001)
                        decodeInstruction = FMAX_S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1100000: begin
                    if(instruction[24:20] == 5'b00000)
                        decodeInstruction = FCVT_W_S;
                    else if(instruction[24:20] == 5'b00001)
                        decodeInstruction = FCVT_WU_S;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1110000: begin
                    if(funct3 == 3'b000)
                        decodeInstruction = FMV_X_W;
                    else if (funct3 == 3'b001)
                        decodeInstruction = FCLASS_S;
                    else
                        decodeInstruction = 7'b0;  
                end
                7'b1010000: begin
                    if(funct3 == 3'b010)
                        decodeInstruction = FEQ_S;
                    else if(funct3 == 3'b001)
                        decodeInstruction = FLT_S;
                    else if(funct3 == 3'b000)
                        decodeInstruction = FLE_S;
                    else
                        decodeInstruction = 7'b0;
                    end
                7'b1101000:begin
                    if(instruction[24:20] == 5'b00000)
                        decodeInstruction = FCVT_S_W;
                    else if(instruction[24:20] == 5'b00001)
                        decodeInstruction = FCVT_S_WU;
                    else
                        decodeInstruction = 7'b0;
                end
                7'b1111000: decodeInstruction = FMV_W_X;
            endcase
        end  
        default: decodeInstruction = 7'b0; 
    endcase
    
endfunction
    

