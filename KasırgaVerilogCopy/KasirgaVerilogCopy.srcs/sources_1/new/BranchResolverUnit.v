// Purpose: Branch Resolver Unit for the Execute stage of the pipeline.
// Functionality: This module performs the branch resolution of the pipeline.
// File: BranchResolverUnit.v

module BranchResolverUnit (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input [4:0] instruction_type_i,
    input [31:0] program_counter_i,
    input [31:0] immediate_i,
    input wire operand1_i,
    input wire operand2_i,
    output result_o
);

reg [31:0] immediate = 32'b0;
wire [31:0] result_addition;
reg [31:0] result = 32'b0;
wire cout;
RippleCarryAdder32 adder(
    .a(program_counter_i),
    .b(immediate),
    .sum(result_addition),
    .cout(cout)
);


always @(posedge enable_i) begin
    case(instruction_type_i)
        `BRANCH_BEQ: begin
            if(operand1_i != operand2_i)
                immediate = 32'd4;
        end
    endcase

end

assign result_o = result_addition;

endmodule