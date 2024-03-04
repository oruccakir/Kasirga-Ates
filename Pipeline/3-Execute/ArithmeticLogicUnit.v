// Purpose: Arithmetic Logic Unit (ALU) module for the RISC-V processor.
// Functionality: Performs arithmetic, logical, and comparison operations on two 32-bit operands.
// File: ArithmeticLogicUnit.v

module ArithmeticLogicUnit (
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [2:0] aluOp,
    output wire [31:0] result,
);
    
    // Declare the result wire
    wire [31:0] result;
    
    // Perform the operation based on the aluOp
    assign result = (aluOp == 3'b000) ? operand1 + operand2 : // ADD
                    (aluOp == 3'b001) ? operand1 - operand2 : // SUB
                    (aluOp == 3'b010) ? operand1 & operand2 : // AND
                    (aluOp == 3'b011) ? operand1 | operand2 : // OR
                    (aluOp == 3'b100) ? operand1 ^ operand2 : // XOR
                    (aluOp == 3'b101) ? operand1 << operand2 : // SLL
                    (aluOp == 3'b110) ? operand1 >> operand2 : // SRL
                    (aluOp == 3'b111) ? operand1 < operand2 :  // SLT
                    32'b0; // Default to 0 if aluOp is invalid

    // Assign the result to the output
    assign result = result;

endmodule