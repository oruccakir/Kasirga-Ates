// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

`include "definitions.vh";
`include "functions.vh";


module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    input wire [31:0] writebacked_result_i, // writebacked result to suitable register
    input wire reg_write_integer_i, //Write data flag for integer register file
    input wire reg_write_float_i, // Write data flag for float register file
    output wire [6:0] opcode_o, // Opcode output
    output wire [4:0] rs1_o, // Source register 1 output
    output wire [4:0] rs2_o, // Source register 2 output
    output wire [4:0] rd_o, // Destination register output
    output wire [31:0] operand1_o, // Operand 1 output
    output wire [31:0] operand2_o, // Operand 2 output
    output wire [31:0] immediate_o, // Immediate output
    output wire [3:0] unit_type_o, // select corrrect unit depends on instruction
    output wire [4:0] instruction_type_o, // hold information of  which instruction
    output wire decode_finished_o // Flag for finishing decode step
);

// Output signals
reg [6:0] opcode = 7'b0; // Opcode
reg [4:0] rs1 = 5'b0;// Source register 1
reg [4:0] rs2 = 5'b0; // Source register 2 
reg [4:0] rs3 = 5'b0; // Source register 3
reg [4:0] rd = 5'b0; // Destination register
wire [31:0] operand1_integer; // Operand 1
wire [31:0] operand2_integer; // Operand 2 
wire [31:0] operand1_float; 
wire [31:0] operand2_float;
wire [31:0] operand3_float; // Operand 3
reg [31:0] immediate = 32'b0; // Immediate

reg [3:0] unit_type = 4'b0000; //default zero will be changed later

reg  [4:0] instruction_type = 5'b00000;

reg  [1:0] register_selection = `INTEGER_REGISTER;

// Integer Register File module
IntegerRegisterFile integerRegisterFile(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rd_i(rd),
    .write_data_i(writebacked_result_i),
    .reg_write_i(reg_write_integer_i),
    .read_data1_o(operand1_integer),
    .read_data2_o(operand2_integer)
);


// Float Register File module

FloatRegisterFile floatRegisterFile(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rs3_i(rs3),
    .rd_i(rd),
    .write_data_i(writebacked_result_i),
    .reg_write_i(reg_write_float_i),
    .read_data1_o(operand1_float),
    .read_data2_o(operand2_float),
    .read_data3_o(operand3_float)
);

//Decode modul implementation
reg decode_finished = 1'b0; // Flag for finishing decode step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for first cycle
localparam SECOND_CYCLE = 1'b1; // State for second cycle

reg STATE = FIRST_CYCLE; // State for the module

reg [31:0] imm_generated_operand2 = 32'b0; // imm generated operand2
reg enable_generate = 1'b0;

integer i = 1;

assign isWorking = enable_step_i && decode_finished != 1'b1; // Assign isWorking

// Decode module implementation
always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("DECODE STEP Decoding instruction %h", instruction_i, " for instruction %d",i);
                        $display("Instruction num %d",i);
                        opcode = instruction_i[6:0]; // Extract opcode not that not use <= here 
                        case(opcode)
                            7'b0010011:
                                begin
                                    register_selection <= `INTEGER_REGISTER;
                                    rs1 <= instruction_i[19:15]; // Extract source register 1
                                    rd <= instruction_i[11:7];   // Extract destination register
                                    immediate <= instruction_i[31:20]; // Extract immediate
                                    unit_type <= `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                                    
                                    case(instruction_i[14:12]) // Extract the instruction type
                                        3'b000 : begin
                                             enable_generate = 1'b1;
                                             generate_operand2(instruction_i);
                                             instruction_type <= `ALU_ADDI; // Set the instruction type
                                        end
                                        3'b010 : begin 
                                            enable_generate = 1'b1;
                                            generate_operand2(instruction_i); 
                                            instruction_type <= `ALU_SLTI; // Set the instruction type
                                        end
                                        3'b011 : begin 
                                            enable_generate = 1'b1;
                                             generate_operand2(instruction_i);
                                            instruction_type <= `ALU_SLTIU; // Set the instruction type
                                        end
                                        3'b100 : begin 
                                            enable_generate = 1'b1;
                                            generate_operand2(instruction_i);
                                            instruction_type <= `ALU_XORI; // Set the instruction type
                                        end
                                        3'b110 : begin 
                                            enable_generate = 1'b1;
                                            generate_operand2(instruction_i);
                                            instruction_type <= `ALU_ORI; // Set the instruction type
                                        end
                                        3'b111 : begin
                                            enable_generate = 1'b1;
                                            generate_operand2(instruction_i); 
                                            instruction_type <= `ALU_ANDI; // Set the instruction type
                                        end
                                        3'b001 : instruction_type <= `ALU_SLLI; // Set the instruction type
                                        3'b101 : begin 
                                            if(instruction_i[31:25] == 6'b000000) // Extract the instruction type
                                                instruction_type <= `ALU_SRLI; // Set the instruction type
                                            else
                                                instruction_type <= `ALU_SRAI; // Set the instruction type
                                        end
                                    endcase
                                end
                            7'b0110011:
                                begin
                                    register_selection <= `INTEGER_REGISTER;
                                    enable_generate <=1'b0;
                                    rs1 <= instruction_i[19:15]; // Extract source register 1
                                    rs2 <= instruction_i[24:20]; // Extract source register 2
                                    rd <= instruction_i[11:7];   // Extract destination register
                                    unit_type <= `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                                    case(instruction_i[14:12]) // Extract the instruction type
                                        3'b000 : begin
                                            if(instruction_i[25] == 1'b1) // Extract the instruction type
                                            begin
                                                unit_type <= `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                                instruction_type <= `INT_MUL; // Set the instruction type
                                            end
                                            else if(instruction_i[30] == 1'b0)
                                                instruction_type <= `ALU_ADD; // Set the instruction type
                                            else
                                                instruction_type <= `ALU_SUB; // Set the instruction type
                                        end
                                        3'b001 : begin
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                                instruction_type <= `INT_MULH; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_SLL; // Set the instruction type
                                        end
                                        3'b010 : begin
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                                instruction_type <= `INT_MULHSU; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_SLT; // Set the instruction type
                                        end
                                        3'b011 : begin
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                                instruction_type <= `INT_MULHU; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_SLTU; // Set the instruction type
                                        end
                                        3'b100 : begin instruction_type <= `ALU_XOR; // Set the instruction type
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_DIVISION_UNIT; // Set the unit type
                                                instruction_type <= `INT_DIV; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_XOR; // Set the instruction type
                                        end
                                        3'b101 : begin
                                            if(instruction_i[30] == 1'b0) // Extract the instruction type
                                                instruction_type <= `ALU_SRL; // Set the instruction type
                                            else if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_DIVISION_UNIT; // Set the unit type
                                                instruction_type <= `INT_DIVU; // Set the instruction type
                                            end
                                            else if(instruction_i[30] == 1'b1)
                                                instruction_type <= `ALU_SRA; // Set the instruction type
                                            else
                                                instruction_type <= `ALU_SRL; // Set the instruction type
                                        end
                                        3'b110 : begin
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_DIVISION_UNIT; // Set the unit type
                                                instruction_type <= `INT_REM; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_OR; // Set the instruction type
                                        end
                                        3'b111 : begin
                                            if(instruction_i[25] == 1'b1)
                                            begin
                                                unit_type <= `INTEGER_DIVISION_UNIT; // Set the unit type
                                                instruction_type <= `INT_REMU; // Set the instruction type
                                            end
                                            else
                                                instruction_type <= `ALU_AND; // Set the instruction type
                                        end
                                    endcase
                                end
                        endcase
                        STATE <= SECOND_CYCLE;       // Go to the second cycle
                        end
                SECOND_CYCLE :
                    begin
                        $display("-->Decoding completed for instruction  num %d",i);
                        $display("-->IMM %d",imm_generated_operand2);
                        $display("-->Opcode: %b", opcode); // Display opcode
                        $display("-->rs1: %d", rs1);       // Display source register 1
                        $display("-->rs2: %d", rs2);       // Display source register 2
                        $display("-->rd: %d", rd);         // Display destination register
                        $display("--> Operand1 %d",operand1_integer);  
                        $display("--> Operand2 %d",operand2_integer);     
                        decode_finished <= 1'b1;         // Set the flag for finishing decode step  
                        STATE <= FIRST_CYCLE;            // Go back to the first cycle
                        i=i+1;
                    end
            endcase        
        end
end
   
assign decode_finished_o = decode_finished; // Assign the flag for finishing decode step
assign opcode_o = opcode;                   // Assign the opcode        
assign rs1_o = rs1;                         // Assign source register 1
assign rs2_o = rs2;                         // Assign source register 2
assign rd_o = rd;                           // Assign destination register
assign operand1_o = (register_selection == `INTEGER_REGISTER) ? operand1_integer : operand1_float;
assign operand2_o = (enable_generate && register_selection== `INTEGER_REGISTER) ? imm_generated_operand2 : (enable_generate == 1'b0 && register_selection == `INTEGER_REGISTER) ? operand2_integer : operand2_float;
assign immediate_o = immediate;             // Assign immediate 
assign unit_type_o = unit_type;             // Assign unit type       
assign instruction_type_o = instruction_type; // Assign instruction


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