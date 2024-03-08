// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
//`include "C:\Users\orucc\Desktop\Coding_Projects\Kas�rga_Ates_Teknofest\Teknofest-Ates-Processor-Design\KasirgaVerilog\KasirgaVerilog.srcs\sources_1\new\definitions.vh"

module Processor(
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] instruction_i,
    output wire [31:0] mem_address_o
);

// Output signals
wire [6:0] opcode; // Opcode
wire [4:0] rs1;// Source register 1
wire [4:0] rs2; // Source register 2 
wire [4:0] rd; // Destination register
wire [31:0] operand1; // Operand 1
wire [31:0] operand2;// Operand 2 
wire [31:0] immediate; // Immediate

// Instruction to decode
wire [31:0]instruction_to_decode;

// Processor module implementation
// Fetch stage
reg enable_fetch = 1'b1;
wire fetch_finished;

FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_fetch),
    .instruction_i(instruction_i),
    .mem_address_o(mem_address_o),
    .fetch_finished_o(fetch_finished),
    .instruction_to_decode_o(instruction_to_decode)
);

// Decode stage
reg enable_decode = 1'b0;
wire decode_finished;

// Decode module
DecodeStep decode(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_decode),
    .instruction_i(instruction_to_decode),
    .opcode_o(opcode),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .rd_o(rd),
    .operand1_o(operand1),
    .operand2_o(operand2),
    .immediate_o(immediate),
    .decode_finished_o(decode_finished)
);

// Execute1 stage
reg enable_execute1 = 1'b0;
wire execute1_finished;

// Execute1 module
ExecuteStep1 execute1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_execute1),
    .instruction_i(instruction_to_decode),
    .opcode_i(opcode),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rd_i(rd),
    .operand1_i(operand1),
    .operand2_i(operand2),
    .immediate_i(immediate),
    .execute1_finished_o(execute1_finished)
);



always@(posedge clk_i) begin

    if(fetch_finished)
    begin
        enable_fetch <= 1'b0;
        fetch.fetch_finished <= 1'b0;
        enable_decode <= 1'b1;
    end
    else if(decode_finished)
    begin
        enable_execute1 <= 1'b1;
        enable_fetch <= 1'b1;
        enable_decode <= 1'b0; 
        decode.decode_finished <= 1'b0;
    end
    else if(execute1_finished)
    begin
        enable_decode <= 1'b1;
        enable_execute1 <= 1'b0;
        execute1.execute1_finished <= 1'b0;
    end
end

endmodule
