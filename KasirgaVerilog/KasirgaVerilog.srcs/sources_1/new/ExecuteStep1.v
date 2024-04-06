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
    input wire [31:0] operand1_integer_i, // Operand 1 input
    input wire [31:0] operand2_integer_i, // Operand 2 input
    input wire [31:0] operand1_float_i,
    input wire [31:0] operand2_float_i,
    input wire [31:0] operand3_float_i,
    input wire [31:0] immediate_i, // Immediate input
    input wire [3:0] unit_type_i,  // for unit selection input
    input wire [4:0] instruction_type_i, // instruction type
    input wire memory_working_info_i,
    output wire [31:0] calculated_result_o, // resulted
    output wire execute1_finished_o, // Flag for finishing execute step 1
    output wire execute_working_info_o,
    output wire [4:0] rd_o
);

reg [31:0] calculated_result = 32'b0; // reg for assign calculated result to calculated result putput

reg [4:0] rd = 5'b0;

reg execute_working_info = 1'b0;   //  very important info for stalling 

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

wire finished_alu_unit; // finished signal for ALU unit
wire finished_integer_multiplication_unit; // finished signal for integer multiplication unit
wire finished_integer_division_unit; // finished signal for integer division unit
wire finished_floating_point_unit; // finished signal for floating point unit
wire finished_branch_resolver_unit; // finished signal for branch resolver unit
wire finished_control_unit; // finished signal for control unit
wire finished_control_status_unit; // finished signal for control status unit
wire finished_atomic_unit; // finished signal for atomic unit
wire finished_bit_manipulation_unit;// finished signal for bit manipulation unit

//results
wire [31:0] calculated_alu_result;    // alu result reg
wire [31:0] calculated_int_mul_result; // int multiplication unit result reg
wire [31:0] calculated_int_div_result;  // int division unit result reg
wire [31:0] calculated_fpu_result;      // floating point unit result reg
wire [31:0] calculated_branch_result;   // bransh resolver unit result reg
wire [31:0] calculated_bit_manip_result;  //  bit manipulation unit result reg
wire [31:0] calculated_atomic_result;      // atomic unit result reg
wire [31:0] calculated_control_status_result; // control status unit result reg 

reg other_resources = 1'b0;
// Arithmetic Logic Unit module
ArithmeticLogicUnit arithmetic_logic_unit(
    .enable_i(enable_alu_unit),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .aluOp_i(instruction_type_i),
    .other_resources_i(other_resources),
    .result_o(calculated_alu_result)
);

// Integer Multiplication Unit module
IntegerMultiplicationUnit integer_multiplication_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_multiplication_unit),
    .mulOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_mul_result),
    .is_finished_o(finished_integer_multiplication_unit)
);

// Integer Division Unit module
IntegerDivisionUnit integer_division_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_division_unit),
    .divOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_div_result),
    .is_finished_o(finished_integer_division_unit)
);

// Floating Point Unit module
FloatingPointUnit floating_point_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_floating_point_unit)
);

// Branch Resolver Unit module
BranchResolverUnit branch_resolver_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_branch_resolver_unit)
);

// Control Unit module
ControlUnit control_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_unit)
);

// Control Status Unit module
ControlStatusUnit control_status_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_status_unit)
);

// Atomic Unit module
AtomicUnit atomic_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_atomic_unit)
);

// Bit Manipulation Unit module
BitManipulationUnit bit_manipulation_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_bit_manipulation_unit)
);


// ExecuteStep1 module implementation
reg execute1_finished = 1'b0; // Flag for finishing execute step 1 // important change
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 3'b000; // State for desiring instruction
localparam SECOND_CYCLE = 3'b001; // State for instruction result
localparam STALL = 3'b010;        // State for stalling the pipeline

reg [2:0] STATE = FIRST_CYCLE; // State for the module

integer i = 1; // it is just for debugging the instruction number

assign isWorking = enable_step_i && execute1_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin
                rd = rd_i;
                execute1_finished = 1'b0;
                execute_working_info = 1'b1;
                $display("EXECUTE STEP Executing instruction for instruction num %d",i);
                case(unit_type_i)
                    `ARITHMETIC_LOGIC_UNIT: begin
                        enable_alu_unit = 1'b1; // Enable ALU unit
                        $display("ALU Working");
                        case(instruction_type_i)
                            `ALU_ADD : $display("ADD");
                            `ALU_SUB: $display("SUB");
                            `ALU_AND: $display("AND");                            
                            `ALU_OR:  $display("OR");
                            `ALU_XOR: $display("XOR");
                            `ALU_SLL: $display("SLL");
                            `ALU_SRL: $display("SRL");
                            `ALU_SRA: $display("SRA");
                            `ALU_SLT: $display("SLT");
                            `ALU_SLTU: $display("SLTU");
                            `ALU_SLLI: $display("SLLI");
                            `ALU_SRLI: $display("SRLI");
                            `ALU_SRAI: $display("SRAI");
                            `ALU_ADDI: $display("ADDI");
                            `ALU_ANDI: $display("ANDI");
                            `ALU_ORI: $display("ORI");
                            `ALU_XORI: $display("XORI");
                            `ALU_SLTI: $display("SLTI");
                            `ALU_SLTIU: $display("SLTIU");
                        endcase
                    end
                    `INTEGER_MULTIPLICATION_UNIT: begin
                        // Enable integer multiplication unit
                        enable_integer_multiplication_unit = 1'b1;
                        $display("Integer Multiplication Unit working for instruction %d",i);
                        case(instruction_type_i)
                            `INT_MUL: $display("MUL");
                            `INT_MULH: $display("MULH");
                            `INT_MULHSU: $display("MULHSU");
                            `INT_MULHU: $display("MULHU");
                        endcase
                    end
                    `INTEGER_DIVISION_UNIT: begin
                        // Enable integer division unit
                        enable_integer_division_unit = 1'b1;
                        $display("Integer Division Unit working");
                        case(instruction_type_i)
                            `INT_DIV: $display("DIV");
                            `INT_DIVU: $display("DIVU");
                            `INT_REM: $display("REM");
                            `INT_REMU: $display("REMU");
                        endcase
                    end
                    `FLOATING_POINT_UNIT:begin
                        // Enable floating point unit
                        enable_floating_point_unit = 1'b1;
                        $display("Floating Point Unit working");
                    end
                    `BRANCH_RESOLVER_UNIT: begin
                        // Enable branch resolver unit 
                        enable_branch_resolver_unit = 1'b1;
                        $display("Branch Resolver Unit working");
                    end 
                    `CONTROL_UNIT: begin
                        // Enable control unit
                        enable_control_unit = 1'b1;
                        $display("Control Unit working");
                    end
                    `CONTROL_STATUS_UNIT: begin
                        // Enable control status unit
                        enable_control_status_unit = 1'b1;
                        $display("Control Status Unit working");
                    end
                    `ATOMIC_UNIT: begin
                        // Enable atomic unit
                        enable_atomic_unit = 1'b1;
                        $display("Atomic Unit working");
                    end
                    `BIT_MANIPULATION_UNIT: begin
                        // Enable bit manipulation unit
                        enable_bit_manipulation_unit = 1'b1;
                        $display("Bit Manipulation Unit working");
                    end
                    `MEMORY_STEP: begin
                        // for address calculation enable artihmetic logic unit
                        enable_alu_unit = 1'b1; // no importance
                        other_resources = 1'b1;
                        $display("Memory address calculation is being done");
                    end
                endcase
                STATE = SECOND_CYCLE; // Go to the second cycle
            end
            SECOND_CYCLE : begin
                if(memory_working_info_i) begin
                    $display("MEMORY STILL WORKING EXECUTE WAITING");
                    STATE = STALL;
                end
                else begin
                    case(unit_type_i)
                        `ARITHMETIC_LOGIC_UNIT: begin
                            calculated_result = calculated_alu_result;
                            enable_alu_unit = 1'b0;
                            $display("Arithmetic Logic Unit Finished");
                            $display("-->Execution completed for instruction num %d",i);
                            $display("Result after execution %d",calculated_result);
                            i=i+1;
                            execute1_finished = 1'b1; 
                            STATE = FIRST_CYCLE;
                            execute_working_info = 1'b0;
                        end
                        `INTEGER_MULTIPLICATION_UNIT: begin
                            if(finished_integer_multiplication_unit != 1'b1) begin
                                $display("Still integer multiplication");
                                STATE = STALL;
                            end
                            else begin
                                calculated_result = calculated_int_mul_result;
                                enable_integer_multiplication_unit = 1'b0; 
                                integer_multiplication_unit.is_finished = 1'b0;
                                $display("Integer Multiplication Unit Finished for instruction %d",i);
                                $display("-->Execution completed for instruction num %d",i);
                                $display("Result after execution %d",calculated_result);
                                i=i+1;
                                STATE = FIRST_CYCLE;
                                execute_working_info = 1'b0;
                                execute1_finished = 1'b1; 
                            end
                        end
                        `INTEGER_DIVISION_UNIT: begin
                            if(finished_integer_division_unit != 1'b1) begin
                                $display("Still integer division");
                                STATE = STALL;
                            end
                            else begin
                                calculated_result = calculated_int_div_result;
                                enable_integer_division_unit = 1'b0; 
                                integer_division_unit.is_finished = 1'b0;
                                $display("Integer Division Unit Finished for instruction %d",i);
                                $display("-->Execution completed for instruction num %d",i);
                                $display("Result after execution %d",calculated_result);
                                i=i+1;
                                execute1_finished = 1'b1; 
                                STATE = FIRST_CYCLE;
                                execute_working_info = 1'b0;
                            end
                        end
                        `FLOATING_POINT_UNIT:begin
                        end
                        `BRANCH_RESOLVER_UNIT:begin
                        end 
                        `CONTROL_UNIT:begin
                        end
                        `CONTROL_STATUS_UNIT:begin
                        end
                        `ATOMIC_UNIT:begin
                        end
                        `BIT_MANIPULATION_UNIT:begin;
                        end
                        `MEMORY_STEP: begin
                            enable_alu_unit = 1'b0;
                            calculated_result = calculated_alu_result;
                            $display("Target memory address is completed",calculated_result," in hexa %h ",calculated_result);
                            i=i+1;
                            execute1_finished = 1'b1; 
                            STATE = FIRST_CYCLE;
                            execute_working_info = 1'b0;
                            other_resources = 1'b0;
                        end
                    endcase
               end
            end
            STALL: begin
                $display("STALL FOR EXECUTE");
                STATE = SECOND_CYCLE;
            end
        endcase
    end
end

assign execute1_finished_o = execute1_finished;
assign calculated_result_o = calculated_result;
assign execute_working_info_o = execute_working_info;
assign rd_o = rd;


endmodule 