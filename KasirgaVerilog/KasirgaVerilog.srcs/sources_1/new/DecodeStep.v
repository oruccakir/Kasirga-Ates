// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

include "definitions.vh";

module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    input wire [31:0] writebacked_result_i, // writebacked result to suitable register
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
wire [31:0] operand1; // Operand 1
wire [31:0] operand2; // Operand 2 
wire [31:0] operand3; // Operand 3
reg [31:0] immediate = 32'b0; // Immediate

reg [3:0] unit_type = 4'b0000; //default zero will be changed later

reg  [4:0] instruction_type = 5'b00000;

reg reg_write_integer = 1'b1; //Write data flag for integer register file

// Integer Register File module
IntegerRegisterFile integerRegisterFile(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rd_i(rd),
    .write_data_i(writebacked_result_i),
    .reg_write_i(reg_write_integer),
    .read_data1_o(operand1),
    .read_data2_o(operand2)
);

reg reg_write_float = 1'b0;  // Write data flag for float register file
// Float Register File module
/*
FloatRegisterFile floatRegisterFile(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rs3_i(rs3),
    .rd_i(rd),
    .write_data_i(operand2),
    .reg_write_i(reg_write_float),
    .read_data1_o(operand1),
    .read_data2_o(operand2),
    .read_data3_o(operand3)
);
*/
//Decode modul implementation
reg decode_finished = 1'b0; // Flag for finishing decode step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for first cycle
localparam SECOND_CYCLE = 1'b1; // State for second cycle

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && decode_finished != 1'b1; // Assign isWorking

// Decode module implementation
always @(posedge clk_i) begin
    if(isWorking)
        begin
            $display("DECODE STEP");
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("WriteBackedResult",writebacked_result_i);
                        $display("-->Decoding instruction %h", instruction_i);
                        opcode <= instruction_i[6:0]; // Extract opcode
                        case(opcode)
                            7'b0010011:
                                begin
                                    rs1 <= instruction_i[19:15]; // Extract source register 1
                                    rd <= instruction_i[11:7];   // Extract destination register
                                    immediate <= 32'h0;  
                                    unit_type <= `ARITHMETIC_LOGIC_UNIT;
                                    case(instruction_i[14:12])
                                        3'b000 : instruction_type <= `ALU_ADDI;
                                        3'b010 : instruction_type <= `ALU_SLTI;
                                        3'b011 : instruction_type <= `ALU_SLTIU;
                                        3'b110 : instruction_type <= `ALU_XORI;
                                        3'b111 : instruction_type <= `ALU_ANDI;
                                        3'b001 : instruction_type <= `ALU_SLLI;
                                        3'b101 : instruction_type <= `ALU_ADDI;
                                    endcase
                                end
                        endcase
                        STATE <= SECOND_CYCLE;       // Go to the second cycle
                        end
                SECOND_CYCLE :
                    begin
                        $display("-->Decoding completed");
                        $display("-->Opcode: %b", opcode); // Display opcode
                        $display("-->rs1: %d", rs1);       // Display source register 1
                        $display("-->rs2: %d", rs2);       // Display source register 2
                        $display("-->rd: %d", rd);         // Display destination register
                        decode_finished <= 1'b1;        // Set the flag for finishing decode step  
                        $display("--> Operand1 %d",operand1);  
                        $display("--> Operand2 %d",operand2);     
                        STATE <= FIRST_CYCLE;            // Go back to the first cycle
                    end
            endcase
            
           
        end
end
   
assign decode_finished_o = decode_finished; // Assign the flag for finishing decode step
assign opcode_o = opcode;                   // Assign the opcode        
assign rs1_o = rs1;                         // Assign source register 1
assign rs2_o = rs2;                         // Assign source register 2
assign rd_o = rd;                           // Assign destination register
assign operand1_o = operand1;               // Assign operand 1    
assign operand2_o = operand2;               // Assign operand 2
assign immediate_o = immediate;             // Assign immediate 
assign unit_type_o = unit_type;             // Assign unit type       
assign instruction_type_0 = instruction_type; // Assign instruction
endmodule