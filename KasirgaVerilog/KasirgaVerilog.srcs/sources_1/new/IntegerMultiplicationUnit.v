// Purpose: 32-bit integer multiplication unit for the execute stage of the pipeline.
// Functionality: This module performs 32-bit integer multiplication.
// File: IntegerMultiplicationUnit.v

module IntegerMultiplicationUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output reg [31:0] result_o // Result output
);
    


always @(posedge clk_i or posedge rst_i)
    begin
        if(rst_i)
            begin
                result_o <= 32'b0; // Reset the result
            end
        else if(enable_i)
            begin
                $display("Integer Multiplication Unit worked");
                result_o <= operand1_i * operand2_i; // Perform the multiplication
            end
    end   



endmodule