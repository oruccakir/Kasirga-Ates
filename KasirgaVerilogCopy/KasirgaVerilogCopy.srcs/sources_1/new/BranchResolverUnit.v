// Purpose: Branch Resolver Unit for the Execute stage of the pipeline.
// Functionality: This module performs the branch resolution of the pipeline.
// File: BranchResolverUnit.v

module BranchResolverUnit (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [4:0] instruction_type_i,
    input wire [31:0] program_counter_i,
    input wire [31:0] immediate_value_i,
    input wire [31:0] operand1_i,
    input wire [31:0] operand2_i,
    input wire fetch_reset_branch_info_i,
    output wire [31:0] result_o,
    output wire is_finished_o,
    output wire branch_info_o
);

reg is_finished = 1'b0;
reg branch_info = 1'b0;
reg [31:0] immediate_value = 32'b0;
reg [31:0] program_counter_or_rs1 = 32'b0;
wire [31:0] result_addition;
wire cout;
RippleCarryAdder32 adder(
    .a(program_counter_or_rs1),
    .b(immediate_value),
    .sum(result_addition),
    .cout(cout)
);

always@(posedge (fetch_reset_branch_info_i)) begin
    branch_info = `BRANCH_NOT_TAKEN;
    $display("Branch Completed");
end

always @(posedge enable_i) begin
    case(instruction_type_i)
        `BRANCH_BEQ: begin
            program_counter_or_rs1 = program_counter_i;
            if(operand1_i != operand2_i) begin
                immediate_value = 32'd4;
                branch_info = `BRANCH_NOT_TAKEN;
            end
            else begin
                branch_info = `BRANCH_TAKEN;
                immediate_value = immediate_value_i;
            end
        end
        `BRANCH_BNE: begin
            program_counter_or_rs1 = program_counter_i;
            if(operand1_i == operand2_i) begin
                branch_info = `BRANCH_NOT_TAKEN;
                immediate_value = 32'd4;
            end
            else begin
                branch_info = `BRANCH_TAKEN;
                immediate_value = immediate_value_i;
            end
        end
        `BRANCH_BLT: begin
            program_counter_or_rs1 = program_counter_i;
            if(operand1_i >= operand2_i) begin
                immediate_value = 32'd4;
                branch_info = `BRANCH_NOT_TAKEN;
            end
            else begin
                branch_info = `BRANCH_TAKEN;
                immediate_value = immediate_value_i;
            end
        end
        `BRANCH_BGE: begin
            program_counter_or_rs1 = program_counter_i;
            if(operand1_i < operand2_i) begin
                branch_info = `BRANCH_NOT_TAKEN;
                immediate_value = 32'd4;
            end
            else begin
                branch_info = `BRANCH_TAKEN;
                immediate_value = immediate_value_i;
            end
        end
        `BRANCH_JAL: begin
            branch_info = `BRANCH_TAKEN;
            program_counter_or_rs1 = program_counter_i;
            immediate_value = immediate_value_i;
        end
        `BRANCH_JALR: begin
            branch_info = `BRANCH_TAKEN;
            program_counter_or_rs1 = operand1_i;
            immediate_value = immediate_value_i;
        end
    endcase

end

assign is_finished_o = is_finished;
assign result_o = result_addition;
assign branch_info_o = branch_info;

endmodule