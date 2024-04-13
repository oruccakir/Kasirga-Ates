// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

`include "definitions.vh";
module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    input wire [31:0] writebacked_result_i, // writebacked result to suitable register, comes from writeback step
    input wire reg_write_integer_i, //Write data flag for integer register file, comes from writeback step
    input wire reg_write_float_i, // Write data flag for float register file,    comes from writeback step
    input wire reg_write_csr_i,  // Write data flag for csr register file,       comes from writeback step
    input wire [4:0] target_register_i, // this is crucial for writig info to correct register file index, comes from writeback step  
    input wire execute_working_info_i, // execute working info, comes from execute step
    output wire [31:0] program_counter_i, // this comes from fetch step and will be conveyed to decode step as first operand
    output wire [4:0] rd_o, // Destination register output, goes to execute step, Note : this value later comes as target_register_i as input from writeback step
    output wire [31:0] integer_operand1_o, // Operand 1 output, goes to execute step
    output wire [31:0] integer_operand2_o, // Operand 2 output, goes to execute step
    output wire [31:0] float_operand1_o,   // operand 1 for float, goes to execute step
    output wire [31:0] float_operand2_o,  // operand 2 for float, goes to execute step
    output wire [31:0] float_operand3_o,   // operand 3 for float, goes to execute step
    output wire [3:0] unit_type_o, // select corrrect unit depends on instruction, goes to execute step
    output wire [4:0] instruction_type_o, // hold information of  which instruction, goes to execute step
    output wire decode_finished_o, // Flag for finishing decode step
    output wire decode_working_info_o, // output for decoding working info, goes to fetch step
    output wire [31:0] rs2_value_o,     // output for rs2 value, this is important for memory operations, goes to execute
    output wire [1:0] register_selection_o, // output for register selection, important for writeback step, goes to execute step
    output wire [31:0] program_counter_o,    // output for program counter, necessary for brach instructions, goes to execute step
    output wire [31:0] immediate_value_o     // output for immeadiate value, necessart for branch instructions, goes to execute step
);

reg decode_working_info = 1'b0; // very important info for stalling the decode and pipeline, goes to fetch step
reg [6:0] opcode = 7'b0; // Opcode
reg [4:0] rs1 = 5'b0;// Source register 1
reg [4:0] rs2 = 5'b0; // Source register 2 
reg [4:0] rs3 = 5'b0; // Source register 3
reg [4:0] rd = 5'b0; // Destination register, important for writeback step
wire [31:0] operand1_integer; // Operand 1 integer
wire [31:0] operand2_integer; // Operand 2 integer
wire [31:0] operand1_float;  // Operand 1 for float
wire [31:0] operand2_float; // Operand 2 for float
wire [31:0] operand3_float; // Operand 3 float
reg [3:0] unit_type = 4'b0000; //default zero will be changed later, will conveyed to execute step
reg  [4:0] instruction_type = 5'b00000; // instruction type will be conveyed to execute step
reg  [1:0] register_selection = `INTEGER_REGISTER;  // register selection for register file, this later should be conveyed to writeback step for writing the data correct register file
reg [31:0] first_operand = 32'b0; // for some instructions operand1_ineteger are not nesessary, this reg is assigned necessary info
reg [31:0] second_operand = 32'b0; // for some instructions operand2_ineteger are not nesessary, this reg is assigned necessary info
reg enable_first = 1'b0;    // this flag is necessary for assigning integer_operand1
reg [31:0] program_counter = 32'b0;  // necessary for branch instructions, goes to execute step


// Integer Register File module
IntegerRegisterFile integerRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1   
    .rs2_i(rs2), // Source register 2
    .rd_i(target_register_i), // Destination register
    .write_data_i(writebacked_result_i), // Writebacked result
    .reg_write_i(reg_write_integer_i), // Write data flag
    .read_data1_o(operand1_integer),    // Operand 1
    .read_data2_o(operand2_integer)   // Operand 2
);

// Float Register File module
FloatRegisterFile floatRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1
    .rs2_i(rs2), // Source register 2
    .rs3_i(rs3), // Source register 3
    .rd_i(target_register_i), // Destination register
    .write_data_i(writebacked_result_i),    // Writebacked result
    .reg_write_i(reg_write_float_i), // Write data flag
    .read_data1_o(operand1_float), // Operand 1
    .read_data2_o(operand2_float), // Operand 2
    .read_data3_o(operand3_float) // Operand 3
);

reg decode_finished = 1'b0; // Flag for finishing decode step
wire isWorking; // Flag for working
localparam FIRST_CYCLE = 3'b000; // State for first cycle
localparam SECOND_CYCLE = 3'b001; // State for second cycle
localparam STALL = 3'b010;       // stall information for stalling pipeline
reg [2:0] STATE = FIRST_CYCLE; // State for the module
reg [31:0] imm_generated_operand2 = 32'b0; // imm generated operand2
reg enable_generate = 1'b0;              // this is necessary for immediate generator and assigning operand 2 value
integer i = 1; // debugging for which instruction decoded

assign isWorking = enable_step_i && decode_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking) begin
        decode_working_info = 1'b1;
        case(STATE)
            FIRST_CYCLE : begin // First cycle
                program_counter = program_counter_i;
                decode_working_info = 1'b1; // Set the working info for decode step
                enable_generate = 1'b0; 
                enable_first = 1'b0;
                if(execute_working_info_i) begin
                    $display("EXECUTE STILL WORKING DECODE WAITING for instruction ",i);
                    STATE = STALL;
                end
                else begin
                $display("DECODE STEP Decoding instruction %h", instruction_i, " for instruction %d",i); // Display the instruction
                opcode = instruction_i[6:0]; // Extract opcode not that not use <= here 
                case(opcode) // Extract the opcode
                    7'b1101111: begin
                        register_selection = `INTEGER_REGISTER;
                        unit_type = `BRANCH_RESOLVER_UNIT;
                        instruction_type = `BRANCH_JAL;
                        enable_first = 1'b1;
                        enable_generate = 1'b1;
                        first_operand = program_counter_i;
                        second_operand = 32'd4;
                        rd = instruction_i[11:7];
                        imm_generated_operand2[20] = instruction_i[31];
                        imm_generated_operand2[19:12] = instruction_i[19:12];
                        imm_generated_operand2[11] = instruction_i[20];
                        imm_generated_operand2[10:1] = instruction_i[30:21];
                        imm_generated_operand2[0] = 0; // not sure but it works okey
                        if(instruction_i[31] == 1'b0)
                            imm_generated_operand2[31:21] = 11'b0;
                        else
                            imm_generated_operand2[31:21] = 11'b1;
                    end
                    7'b1100111: begin
                        register_selection = `INTEGER_REGISTER;
                        unit_type = `BRANCH_RESOLVER_UNIT;
                        enable_generate = 1'b1;
                        second_operand = 32'd4;
                        rd = instruction_i[11:7];
                        rs1 = instruction_i[19:15];         
                        imm_generated_operand2[11:0] = instruction_i[31:20];
                        if(imm_generated_operand2[11] == 0)
                            imm_generated_operand2[31:12] = 20'b0000000000000000000;
                        else
                            imm_generated_operand2[31:12] = 20'b11111111111111111111;                          
                    end
                    7'b1100011: begin
                        register_selection = `NONE_REGISTER;      
                        rs1 = instruction_i[19:15];
                        rs2 = instruction_i[24:20];
                        unit_type = `BRANCH_RESOLVER_UNIT;
                        imm_generated_operand2[4:1] = instruction_i[11:8];
                        imm_generated_operand2[11] = instruction_i[7];
                        imm_generated_operand2[10:5] = instruction_i[30:25];
                        imm_generated_operand2[12] = instruction_i[31];
                        case(instruction_i[14:12])
                            3'b000: begin
                                instruction_type = `BRANCH_BEQ;
                            end
                            3'b001: begin
                                instruction_type = `BRANCH_BNE;
                            end
                            3'b100: begin
                                instruction_type = `BRANCH_BLT;
                            end
                            3'b101: begin 
                                instruction_type = `BRANCH_BGE;
                            end
                            3'b110: begin 
                                instruction_type = `BRANCH_BLTU;
                            end
                            3'b111: begin
                                 instruction_type = `BRANCH_BGEU;
                            end
                        endcase
                    end
                    7'b0110111: begin
                        register_selection = `INTEGER_REGISTER;
                        rd = instruction_i[11:7];
                        enable_generate = 1'b1;
                        imm_generated_operand2[31:12] = instruction_i[31:12];
                        imm_generated_operand2[11:0] = 12'b0;
                        second_operand = imm_generated_operand2;
                        instruction_type = `NONE_LUI;
                        unit_type = `NONE_UNIT;
                    end
                    7'b0010111: begin
                        $display("AUPIC INSTRUCTON");
                        register_selection = `INTEGER_REGISTER;
                        rd = instruction_i[11:7];
                        enable_generate = 1'b1;
                        enable_first = 1'b1;
                        first_operand = program_counter_i;
                        imm_generated_operand2[31:12] = instruction_i[31:12];
                        imm_generated_operand2[11:0] = 12'b0;
                        second_operand = imm_generated_operand2;
                        instruction_type = `ALU_ADD;
                        unit_type = `ARITHMETIC_LOGIC_UNIT;
                    end
                    7'b0000011: begin
                        enable_generate = 1'b1;    // enable generate       
                        unit_type = `MEMORY_UNIT;
                        register_selection = `INTEGER_REGISTER; // Set the register selection
                        rs1 = instruction_i[19:15]; // Extract source register 1
                        rd = instruction_i[11:7];   // Extract destination register
                        generate_operand2(instruction_i);
                        second_operand = imm_generated_operand2;
                        case(instruction_i[14:12])
                            3'b000 : instruction_type[2:0] = `MEM_LB;
                            3'b001 : instruction_type[2:0] = `MEM_LH;
                            3'b010 : instruction_type[2:0] = `MEM_LW;
                            3'b100 : instruction_type[2:0] = `MEM_LBU;
                            3'b101 : instruction_type[2:0] = `MEM_LHU;
                        endcase
                    end
                    7'b0100011: begin
                        enable_generate = 1'b1;    // enable generate       
                        unit_type = `MEMORY_UNIT;
                        register_selection = `INTEGER_REGISTER; // Set the register selection
                        rs1 = instruction_i[19:15]; // Extract source register 1
                        rs2 = instruction_i[24:20]; // Extract source register 2
                        rd = instruction_i[11:7];   // Extract destination register
                        imm_generated_operand2 [4:0] = instruction_i[11:7]; // Extract immediate
                        imm_generated_operand2 [11:5] = instruction_i[31:25]; // Extract immediate
                        if(instruction_i[31] == 1'b0)
                            imm_generated_operand2[31:12] = 20'b0;
                        else
                            imm_generated_operand2[31:12] = 20'b1;
                        second_operand = imm_generated_operand2;
                        case(instruction_i[14:12])
                            3'b000 : instruction_type[2:0] = `MEM_SB;
                            3'b001 : instruction_type[2:0] = `MEM_SH;
                            3'b010 : instruction_type[2:0] = `MEM_SW;
                        endcase
                    end
                    7'b0010011: begin
                        register_selection = `INTEGER_REGISTER; // Set the register selection
                        rs1 = instruction_i[19:15]; // Extract source register 1
                        rd = instruction_i[11:7];   // Extract destination register
                        unit_type = `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                        enable_generate = 1'b1;    // enable generate                                
                        case(instruction_i[14:12]) // Extract the instruction type
                            3'b000 : begin
                                 generate_operand2(instruction_i); // Generate operand 2
                                 instruction_type = `ALU_ADDI; // Set the instruction type
                            end
                            3'b010 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type = `ALU_SLTI; // Set the instruction type
                            end
                            3'b011 : begin 
                                 generate_operand2(instruction_i); // Generate operand 2
                                instruction_type = `ALU_SLTIU; // Set the instruction type
                            end
                            3'b100 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type = `ALU_XORI; // Set the instruction type
                            end
                            3'b110 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type = `ALU_ORI; // Set the instruction type
                            end
                            3'b111 : begin
                                generate_operand2(instruction_i);  // Generate operand 2
                                instruction_type = `ALU_ANDI; // Set the instruction type
                            end
                            3'b001 : instruction_type = `ALU_SLLI; // Set the instruction type
                            3'b101 : begin 
                                if(instruction_i[31:25] == 6'b000000) // Extract the instruction type
                                    instruction_type = `ALU_SRLI; // Set the instruction type
                                else
                                    instruction_type = `ALU_SRAI; // Set the instruction type
                            end
                        endcase
                        second_operand = imm_generated_operand2;
                    end
                    7'b0110011: begin
                        register_selection = `INTEGER_REGISTER; // Set the register selection
                        enable_generate =1'b0; // disable generate
                        rs1 = instruction_i[19:15]; // Extract source register 1
                        rs2 = instruction_i[24:20]; // Extract source register 2
                        rd = instruction_i[11:7];   // Extract destination register
                        unit_type = `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                        case(instruction_i[14:12]) // Extract the instruction type
                            3'b000 : begin
                                if(instruction_i[25] == 1'b1) // Extract the instruction type
                                begin
                                    unit_type = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type = `INT_MUL; // Set the instruction type
                                end
                                else if(instruction_i[30] == 1'b0)
                                    instruction_type = `ALU_ADD; // Set the instruction type
                                else
                                    instruction_type = `ALU_SUB; // Set the instruction type
                            end
                            3'b001 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type = `INT_MULH; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_SLL; // Set the instruction type
                            end
                            3'b010 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type = `INT_MULHSU; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_SLT; // Set the instruction type
                            end
                            3'b011 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type = `INT_MULHU; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_SLTU; // Set the instruction type
                            end
                            3'b100 : begin instruction_type = `ALU_XOR; // Set the instruction type
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type = `INT_DIV; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_XOR; // Set the instruction type
                            end
                            3'b101 : begin
                                if(instruction_i[25] == 1'b1)
                                   begin
                                    unit_type = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type = `INT_DIVU; // Set the instruction type
                                   end
                                else if(instruction_i[30] == 1'b1)
                                    instruction_type = `ALU_SRA; // Set the instruction type
                                else
                                    instruction_type = `ALU_SRL; // Set the instruction type
                            end
                            3'b110 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type = `INT_REM; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_OR; // Set the instruction type
                            end
                            3'b111 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type = `INT_REMU; // Set the instruction type
                                end
                                else
                                    instruction_type = `ALU_AND; // Set the instruction type
                            end
                        endcase
                    end
                  7'b0101111: begin
                       register_selection = `INTEGER_REGISTER; // set register selection
                       rs1 = instruction_i[19:15]; // Extract source register 1
                       rs2 = instruction_i[24:20]; // Extract source register 2
                       rd = instruction_i[11:7];   // Extract destination register
                       unit_type = `ATOMIC_UNIT;   // set unit type as atomic unit
                       case(instruction_i[31:27])
                            5'b00010: instruction_type = `ATOM_LOAD; // set instruction type
                            5'b00011: instruction_type = `ATOM_STORE; // set instruction type
                            5'b00001: instruction_type = `ATOM_SWAP;   // set instruction type
                            5'b00000: instruction_type = `ATOM_ADD;   // set instruction type
                            5'b00100: instruction_type = `ATOM_XOR;  // set instruction type
                            5'b01100: instruction_type = `ATOM_AND; // set instruction type
                            5'b01000: instruction_type = `ATOM_OR; // set instruction type
                            5'b10000: instruction_type = `ATOM_MIN; // set instruction type
                            5'b10100: instruction_type = `ATOM_MAX; // set instruction type
                            5'b11000: instruction_type = `ATOM_MINU; // set instruction type
                            5'b11100: instruction_type = `ATOM_MAXU; // set instruction type
                      endcase
                end
                7'b0000111: begin
                    register_selection = `FLOAT_REGISTER;
                    rs1 = instruction_i[19:15]; // Extract source register 1
                    rs2 = instruction_i[24:20]; // Extract source register 2
                    rs3 = instruction_i[31:27]; // Extract source register 3
                    rd = instruction_i[11:7];   // Extract destination register
                    instruction_type = `FLT_LOAD; // set instruction type
                    unit_type = `FLOATING_POINT_UNIT; // set unit type
                    generate_operand2(instruction_i); // generate operand 2
                    enable_generate = 1'b1; // enable generate
                end
                7'b0100111: begin
                    register_selection = `FLOAT_REGISTER;
                    rs1 = instruction_i[19:15]; // Extract source register 1
                    rs2 = instruction_i[24:20]; // Extract source register 2
                    rs3 = instruction_i[31:27]; // Extract source register 3
                    rd = instruction_i[11:7];   // Extract destination register
                    instruction_type = `FLT_STORE; // set instruction type
                    unit_type = `FLOATING_POINT_UNIT; // set unit type
                    imm_generated_operand2[4:0] = instruction_i[11:7]; // set value
                    imm_generated_operand2[11:5] = instruction_i[31:25]; // set value
                    if(instruction_i[31] == 1'b0) 
                        imm_generated_operand2[31:12] = 20'b0; // extend with zero
                    else
                        imm_generated_operand2[31:12] = 20'b1; // extend with one                               
                end
                7'b1000011: begin
                   register_selection = `FLOAT_REGISTER;
                   rs1 = instruction_i[19:15]; // Extract source register 1
                   rs2 = instruction_i[24:20]; // Extract source register 2
                   rs3 = instruction_i[31:27]; // Extract source register 3
                   rd = instruction_i[11:7];   // Extract destination register
                   instruction_type = `FLT_FMADD; // set instruction type
                   unit_type = `FLOATING_POINT_UNIT;    // set unit type
               end 
               7'b1000111: begin
                   register_selection = `FLOAT_REGISTER;
                   rs1 = instruction_i[19:15]; // Extract source register 1
                   rs2 = instruction_i[24:20]; // Extract source register 2
                   rs3 = instruction_i[31:27]; // Extract source register 3
                   rd = instruction_i[11:7];   // Extract destination register
                   instruction_type = `FLT_FMSUB;  // set instruction type
                   unit_type = `FLOATING_POINT_UNIT;  // set unit type
               end
               7'b1001011: begin
                   register_selection = `FLOAT_REGISTER;
                   rs1 = instruction_i[19:15]; // Extract source register 1
                   rs2 = instruction_i[24:20]; // Extract source register 2
                   rs3 = instruction_i[31:27]; // Extract source register 3
                   rd = instruction_i[11:7];   // Extract destination register
                   instruction_type = `FLT_FNMSUB;  // set instruction type
                   unit_type = `FLOATING_POINT_UNIT; // set unit type                                
                end
                7'b1001111: begin
                   register_selection = `FLOAT_REGISTER;
                   rs1 = instruction_i[19:15]; // Extract source register 1
                   rs2 = instruction_i[24:20]; // Extract source register 2
                   rs3 = instruction_i[31:27]; // Extract source register 3
                   rd = instruction_i[11:7];   // Extract destination register
                   instruction_type = `FLT_FNMADD; // set instruction type
                   unit_type = `FLOATING_POINT_UNIT; // set unit type                               
                end
                7'b1010011: begin
                   register_selection = `FLOAT_REGISTER;
                   rs1 = instruction_i[19:15]; // Extract source register 1
                   rs2 = instruction_i[24:20]; // Extract source register 2
                   rs3 = instruction_i[31:27]; // Extract source register 3
                   rd = instruction_i[11:7];   // Extract destination register                           
                   unit_type = `FLOATING_POINT_UNIT; // set unit type
                   case(instruction_i[31:25])
                        7'b0000000: instruction_type = `FLT_FADD; // set instruction type
                        7'b0000100: instruction_type = `FLT_FSUB; // set instruction type
                        7'b0001000: instruction_type = `FLT_FMUL; // set instruction type
                        7'b0001100: instruction_type = `FLT_FDIV; // set instruction type
                        7'b0101100: instruction_type = `FLT_FSQRT; // set instruction type
                        7'b0010000:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type = `FLT_FSGNJ; // set instruction type
                                else if(instruction_i[14:12] == 3'b001)
                                    instruction_type = `FLT_FSGNJN;    // set instruction type
                                else  
                                    instruction_type = `FLT_FSGNJX; // set instruction type
                            end
                       7'b0010100:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type = `FLT_FMIN; // set instruction type
                                else
                                    instruction_type = `FLT_FMAX; // set instruction type
                            end
                      7'b1100000:
                            begin
                                if(instruction_i[24:20] == 5'b00000)
                                    instruction_type = `FLT_FCVTW; // set instruction type
                                else
                                    instruction_type = `FLT_FCVTWU; // set instruction type                                          
                            end
                      7'b1110000:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type = `FLT_FMVXW; // set instruction type
                                else
                                    instruction_type = `FLT_FCLASS;    // set instruction type
                            end
                      7'b1010000:
                            begin
                                if(instruction_i[14:12] == 3'b010)
                                    instruction_type = `FLT_FEQ; // set instruction type
                                else if(instruction_i[14:12] == 3'b001)
                                    instruction_type = `FLT_FLT; // set instruction type
                                else 
                                    instruction_type = `FLT_FLE;       // set instruction type               
                            end
                      7'b1101000:
                            begin
                                if(instruction_i[20] == 1'b0)
                                    instruction_type = `FLT_FCVTSW; // set instruction type
                                else 
                                    instruction_type = `FLT_FCVTSWU; // set instruction type
                            end
                       7'b1111000: instruction_type = `FLT_FMVWX; // set instruction type
                   endcase                     
                  end
                endcase
                    // Assign necessory connections                
                    $display("-->Decoding completed for instruction  num %d",i);
                    $display("-->IMM %d",imm_generated_operand2);
                    $display("-->Opcode: %b", opcode); // Display opcode
                    $display("-->rs1: %d", rs1);       // Display source register 1
                    $display("-->rs2: %d", rs2);       // Display source register 2
                    $display("-->rd: %d", rd);         // Display destination register);
                    $display("Operand 1 : ",integerRegisterFile.registers[rs1]);
                    $display("Operand 2 : ",integerRegisterFile.registers[rs2]);
                    decode_finished = 1'b1;         // Set the flag for finishing decode step  
                    STATE = FIRST_CYCLE;            // Go back to the first cycle
                    i=i+1;                        // Increment the instruction number
                    decode_working_info = 1'b0;     // Set the working info to 
                    
                    end //do not forget this
                end
                STALL : begin
                    $display("STALL FOR DECODE"); // Display the stall info
                    STATE = FIRST_CYCLE; // Go to the second cycle
                end 
            endcase        
        end
end
   
assign decode_finished_o = decode_finished; // Assign the flag for finishing decode step
assign rd_o = rd;                           // Assign destination register is important for keeping the target register info for writeback, 
// this info comes later again to this step, goes to execute step
assign integer_operand1_o = (enable_first) ? first_operand : operand1_integer;   // assign operand1 output, goes to execute step
assign integer_operand2_o = (enable_generate) ? second_operand : operand2_integer; // Assign operand 2 depending on the instruction and condition, goes to execute
assign rs2_value_o = operand2_integer;          // assign operand2_integer to rs2_value for memory operations, goes to execute step
assign float_operand1_o = operand1_float;       // Assign float operand 1, goes to execute step
assign float_operand2_o = operand2_float;       // Assign float operand 2, goes to execute step
assign float_operand3_o = operand3_float;       // Assign float operand 3, goes to execute step
assign unit_type_o = unit_type;                 // Assign unit type, goes to execute step, important for which sub module should work       
assign instruction_type_o = instruction_type;   // Assign instruction type, again important for which instruction should work in which sub module
assign decode_working_info_o = decode_working_info; // Assign decode working info, will be conveyed to fetch step for stalling operation
assign register_selection_o = register_selection;  // Assign register selection info, will be conveyed to execute step
assign program_counter_o = program_counter;       // Assign program counter, goes to execute step
assign immediate_value_o = imm_generated_operand2; // Assign immediate value, goes to execute step


/*
    * Task to generate operand2
    * @param instruction_i
*/
task generate_operand2(
    input [31:0] instruction_i
);

    begin
        imm_generated_operand2[11:0] = instruction_i[31:20]; // set value
        if(instruction_i[31] == 1'b0)
            imm_generated_operand2[31:12] = 20'b0; // extend with zero
        else
            imm_generated_operand2[31:12] = 20'b1; // extend with one
    end
endtask



endmodule