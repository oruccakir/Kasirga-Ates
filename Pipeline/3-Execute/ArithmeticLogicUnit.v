// Purpose: Arithmetic Logic Unit (ALU) module for the RISC-V processor.
// Functionality: Performs arithmetic, logical, and comparison operations on two 32-bit operands.
// File: ArithmeticLogicUnit.v

// Include the definitions file
`include "Pipeline\definitions.vh"

module ArithmeticLogicUnit (
    input wire [31:0] operand1_i, // First operand
    input wire [31:0] operand2_i, // Second operand
    input wire [3:0] aluOp_i, // ALU operation
    output wire [31:0] result_o, // Result
);
    
    // Declare the result wire
    wire [31:0] result;
    
    // Perform the operation based on the aluOp


    assign result_o = result; // Assign the result to the output

endmodule