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
reg decode_finished = 1'b0;
wire isWorking;

localparam INS_DESIRE = 1'b0;
localparam INS_RESULT = 1'b1;

reg STATE = INS_DESIRE;

assign isWorking = enable_step_i && decode_finished != 1'b1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                INS_DESIRE :
                    begin
                        $display("DecodeStep: Decoding instruction %h", instruction_i);
                        opcode = instruction_i[6:0];
                        rs1 = instruction_i[19:15];
                        rs2 = instruction_i[24:20];
                        rd = instruction_i[11:7];
                        operand1 = 32'h0;
                        operand2 = 32'h0;
                        immediate = 32'h0;
                        STATE = INS_RESULT;
                    end
                INS_RESULT :
                    begin
                        $display("DecodeStep: Decoding completed");
                        $display("Opcode: %b", opcode);
                        $display("rs1: %d", rs1);
                        $display("rs2: %d", rs2);
                        $display("rd: %d", rd);
                        decode_finished <= 1'b1;
                        STATE = INS_DESIRE;
                    end
            endcase
            
           
        end
end
   
assign decode_finished_o = decode_finished;
assign opcode_o = opcode;
assign rs1_o = rs1;
assign rs2_o = rs2;
assign rd_o = rd;
assign operand1_o = operand1;
assign operand2_o = operand2;
assign immediate_o = immediate;

endmodule