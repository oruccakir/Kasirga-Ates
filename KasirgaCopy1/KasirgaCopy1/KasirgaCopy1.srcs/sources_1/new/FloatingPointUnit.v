// Purpose: Floating point unit for the execute stage of the pipeline.
// Functionality: This module performs floating point operations.
// File: FloatingPointUnit.v

module FloatingPointUnit (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [4:0] floatOp_i, // Floating point operation input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input
    input wire [31:0] operand3_i, // Operand 3 input
    output wire [31:0] result_o // Result output
);

reg enable_float_multiplication = 1'b0; // Enable float multiplication
reg enable_float_division = 1'b0; // Enable float division
// Floting multiplication unit
FloatMultiplicationUnit fmulUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_multiplication), // Enable input
    .operand1_i(operand1_i), // Operand 1 input
    .operand2_i(operand2_i), // Operand 2 input
    .result_o(result_o) // Result output
);

// Floating division unit
FloatingDivisionUnit fdivUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_division), // Enable input
    .operand1_i(operand1_i), // Operand 1 input
    .operand2_i(operand2_i), // Operand 2 input
    .result_o(result_o) // Result output
);

endmodule
