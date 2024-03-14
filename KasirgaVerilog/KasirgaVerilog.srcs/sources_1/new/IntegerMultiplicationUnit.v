// Purpose: 32-bit integer multiplication unit for the execute stage of the pipeline.
// Functionality: This module performs 32-bit integer multiplication.
// File: IntegerMultiplicationUnit.v

module IntegerMultiplicationUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output wire [31:0] result_o, // Result output
    output wire is_finished_o // finish signal
);
    
reg [31:0] result = 32'b0;
reg is_finished = 1'b0;

wire isWorking;

localparam CYCLE1 = 3'b000;
localparam CYCLE2 = 3'b001;
localparam CYCLE3 = 3'b010;
localparam CYCLE4 = 3'b100;
localparam CYCLE5 = 3'b101;

reg [2:0] STATE = CYCLE1;

assign isWorking = enable_i && is_finished != 1'b1; // Assign isWorking

always @(posedge clk_i or posedge rst_i)
    begin
        if(rst_i)
            begin
                result <= 32'b0; // Reset the result
            end
        else if(isWorking)
            begin
                result = operand1_i * operand2_i;
                is_finished = 1'b1;
            end
    end   

assign result_o = result;
assign is_finished_o = is_finished;

endmodule