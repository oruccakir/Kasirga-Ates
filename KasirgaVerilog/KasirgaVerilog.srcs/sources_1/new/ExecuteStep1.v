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
    input wire [3:0] unit_type_i,  // for unit selection input
    input wire [4:0] instruction_type_i, // instruction type
    output wire [31:0] calculated_result_o, // resulted
    output wire execute1_finished_o // Flag for finishing execute step 1
);

wire [31:0] calculated_result;


// ALU module
reg enable_alu_unit = 1'b0; // Enable signal for ALU unit
reg enable_integer_multiplication_unit = 1'b0; // Enable signal for integer multiplication unit
reg enable_integer_division_unit = 1'b0; // Enable signal for integer division unit
reg enable_floating_point_unit = 1'b0; // Enable signal for floating point unit
reg enable_branch_resolver_unit = 1'b0; // Enable signal for branch resolver unit
reg enable_control_unit = 1'b0; // Enable signal for control unit
reg enable_control_status_unit = 1'b0; // Enable signal for control status unit
reg enable_atomic_unit = 1'b0; // Enable signal for atomic unit
reg enable_bit_manipulation_unit = 1'b0; // Enable signal for bit manipulation unit

// Arithmetic Logic Unit module
ArithmeticLogicUnit arithmetic_logic_unit(
    .enable_i(enable_alu_unit),
    .operand1_i(operand1_i),
    .operand2_i(operand2_i),
    .aluOp_i(instruction_type_i),
    .result_o(calculated_result)
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
                        $display("Type %d",instruction_type_i);
                        $display("Unit Type %d",unit_type_i);
                        case(unit_type_i)
                        `ARITHMETIC_LOGIC_UNIT:
                            begin
                                enable_alu_unit <= 1'b1; // Enable ALU unit
                            end
                        `INTEGER_MULTIPLICATION_UNIT:
                            begin
                                // Enable integer multiplication unit
                                enable_integer_multiplication_unit <= 1'b1;
                            end
                        `INTEGER_DIVISION_UNIT:
                            begin
                                // Enable integer division unit
                                enable_integer_division_unit <= 1'b1;
                            end
                        `FLOATING_POINT_UNIT:
                            begin
                                // Enable floating point unit
                                enable_floating_point_unit <= 1'b1;
                            end
                        `BRANCH_RESOLVER_UNIT:
                            begin
                                // Enable branch resolver unit 
                                enable_branch_resolver_unit <= 1'b1;
                            end 
                        `CONTROL_UNIT:
                            begin
                                // Enable control unit
                                enable_control_unit <= 1'b1;
                            end
                        `CONTROL_STATUS_UNIT:
                            begin
                                // Enable control status unit
                                enable_control_status_unit <= 1'b1;
                            end 
                        `ATOMIC_UNIT:
                            begin
                                // Enable atomic unit
                                enable_atomic_unit <= 1'b1;
                            end
                        `BIT_MANIPULATION_UNIT:
                            begin
                                // Enable bit manipulation unit
                                enable_bit_manipulation_unit <= 1'b1;
                            end
                        endcase
                        STATE <= SECOND_CYCLE; // Go to the second cycle
                    end
                SECOND_CYCLE :
                    begin
                        $display("-->Execution completed");
                        $display("Result %d",calculated_result);
                        execute1_finished <= 1'b1;       // Set execute1_finished to 1
                        enable_alu_unit <=0;
                        STATE <= FIRST_CYCLE;            // Go to the first cycle
                    end
            endcase
        end
end

assign execute1_finished_o = execute1_finished;
assign calculated_result_o = calculated_result;

endmodule 