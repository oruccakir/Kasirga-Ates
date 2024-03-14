// Purpose: Integer division unit for the execute stage of the pipeline.
// Functionality: This module performs integer division.
// File: IntegerDivisionUnit.v    

module IntegerDivisionUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output wire [31:0] result_o, // Result output
    output wire is_finished_o
);

reg is_finished = 1'b0;
reg [31:0] result = 32'b0;

always @(posedge clk_i or posedge rst_i)
    begin
        if(rst_i)
            begin
                result <= 32'b0; // Reset the result
            end
        else if(enable_i)
            begin
                result <= operand1_i / operand2_i; // Perform the division
                is_finished <= 1'b1; 
            end
    end
    
assign result_o = result;
assign is_finished_o = is_finished;
endmodule