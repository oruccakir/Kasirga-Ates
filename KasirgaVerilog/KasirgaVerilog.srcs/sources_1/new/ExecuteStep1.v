// Purpose: Execute Step 1 of the pipeline.
// Functionality: This module performs the first part of the execute stage of the pipeline.
// File: ExecuteStep1.v

include "definitions.vh";

module ExecuteStep1 (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    input wire [6:0] opcode_i, // Opcode input
    input wire [4:0] rs1_i, // Source register 1 input
    input wire [4:0] rs2_i, // Source register 2 input
    input wire [4:0] rd_i, // Destination register input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input
    input wire [31:0] immediate_i, // Immediate input
    output wire execute1_finished_o // Flag for finishing execute step 1
);

// ExecuteStep1 module implementation
reg execute1_finished = 1'b0; // Flag for finishing execute step 1
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for desiring instruction
localparam SECOND_CYCLE = 1'b1; // State for instruction result

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && execute1_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking)
        begin
            $display("EXECUTE STEP1");
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("-->Executing instruction");
                        STATE <= SECOND_CYCLE; // Go to the second cycle
                    end
                SECOND_CYCLE :
                    begin
                        $display("-->Execution completed");
                        $display("-->Opcode: %b", opcode_i); // Display opcode
                        $display("-->rs1: %d", rs1_i);       // Display source register 1  
                        $display("-->rs2: %d", rs2_i);       // Display source register 2  
                        $display("-->rd: %d", rd_i);         // Display destination register
                        execute1_finished <= 1'b1;       // Set execute1_finished to 1
                        STATE <= FIRST_CYCLE;            // Go to the first cycle
                    end
            endcase
        end
end

assign execute1_finished_o = execute1_finished;

endmodule 