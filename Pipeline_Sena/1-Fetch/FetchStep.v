`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input clk_i, // Clock input
    input rst_i, // Reset input
    input enable_step_i, // Enable input
    input [31:0] mem_adres_i, // Memory address input
    output reg [31:0] instruction_o // Instruction output
);

reg [31:0] instruction_o_next;

HelperMemory hm(
    .clk_i              (clk_i),
    .adres_i            (mem_adres_i),
    .write_data_enable_i(1'b0),
    .read_data_o        (instruction_o_next)
    );
    
    

always @(posedge clk_i) begin
    if (enable_step_i) begin
        instruction_o <= instruction_o_next;
    end
end

endmodule
