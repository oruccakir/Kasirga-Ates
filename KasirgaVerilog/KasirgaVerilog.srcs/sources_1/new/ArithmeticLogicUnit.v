// Purpose: Arithmetic Logic Unit (ALU) module for the RISC-V processor.
// Functionality: Performs arithmetic, logical, and comparison operations on two 32-bit operands.
// File: ArithmeticLogicUnit.v

// Include the definitions file
`include "definitions.vh"

module ArithmeticLogicUnit (
    input wire [31:0] operand1_i, // First operand
    input wire [31:0] operand2_i, // Second operand
    input wire enable_i, // Enable input
    input wire [4:0] aluOp_i, // ALU operation
    output wire [31:0] result_o // Result
);

reg [31:0] result = 32'b0;
// Perform the operation based on the aluOp

always @(posedge enable_i) begin
    case (aluOp_i)
        `ALU_ADD: result = operand1_i + operand2_i; // Addition
        `ALU_SUB: result = operand1_i - operand2_i; // Subtraction
        `ALU_AND: result = operand1_i & operand2_i; // Bitwise AND
        `ALU_OR: result = operand1_i | operand2_i; // Bitwise OR
        `ALU_XOR: result = operand1_i ^ operand2_i; // Bitwise XOR
        `ALU_SLT: result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than
        `ALU_SLTU: result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than unsigned
        `ALU_SLL: result = operand1_i << operand2_i; // Shift left logical
        `ALU_SRL: result = operand1_i >> operand2_i; // Shift right logical
        `ALU_SRA: result = operand1_i >>> operand2_i; // Shift right arithmetic
        `ALU_ADDI : result = operand1_i + operand2_i; // Addition
        `ALU_SLTI : result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than
        `ALU_SLTIU : result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than unsigned
        `ALU_XORI : result = operand1_i ^ operand2_i; // Bitwise XOR
        `ALU_ORI : result = operand1_i | operand2_i; // Bitwise OR
        `ALU_ANDI : result = operand1_i & operand2_i; // Bitwise AND
        `ALU_SLLI : result = operand1_i << operand2_i; // Shift left logical
        `ALU_SRLI : result = operand1_i >> operand2_i; // Shift right logical
        `ALU_SRAI : result = operand1_i >>> operand2_i; // Shift right arithmetic
        default: result = 32'b0; // Default to 0
    endcase
end
assign result_o = result;

endmodule