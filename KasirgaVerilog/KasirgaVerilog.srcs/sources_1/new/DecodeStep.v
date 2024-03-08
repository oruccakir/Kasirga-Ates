// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    output wire [6:0] opcode_o, // Opcode output
    output wire [4:0] rs1_o, // Source register 1 output
    output wire [4:0] rs2_o, // Source register 2 output
    output wire [4:0] rd_o, // Destination register output
    output wire [31:0] operand1_o, // Operand 1 output
    output wire [31:0] operand2_o, // Operand 2 output
    output wire [31:0] immediate_o, // Immediate output
    output wire decode_finished_o // Flag for finishing decode step
);

// Output signals
reg [6:0] opcode = 0; // Opcode
reg [4:0] rs1 = 0;// Source register 1
reg [4:0] rs2 = 0; // Source register 2 
reg [4:0] rd = 0; // Destination register
reg [31:0] operand1 = 0; // Operand 1
reg [31:0] operand2 = 0;// Operand 2 
reg [31:0] immediate = 0; // Immediate

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
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("DecodeStep: Decoding instruction %h", instruction_i);
                        opcode = instruction_i[6:0]; // Extract opcode
                        rs1 = instruction_i[19:15]; // Extract source register 1
                        rs2 = instruction_i[24:20]; // Extract source register 2
                        rd = instruction_i[11:7];   // Extract destination register
                        operand1 = 32'h0;           // Set operand 1 to 0
                        operand2 = 32'h0;           // Set operand 2 to 0    
                        immediate = 32'h0;          // Set immediate to 0
                        STATE = SECOND_CYCLE;       // Go to the second cycle
                        end
                SECOND_CYCLE :
                    begin
                        $display("DecodeStep: Decoding completed");
                        $display("Opcode: %b", opcode); // Display opcode
                        $display("rs1: %d", rs1);       // Display source register 1
                        $display("rs2: %d", rs2);       // Display source register 2
                        $display("rd: %d", rd);         // Display destination register
                        decode_finished <= 1'b1;        // Set the flag for finishing decode step        
                        STATE = FIRST_CYCLE;            // Go back to the first cycle
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

endmodule