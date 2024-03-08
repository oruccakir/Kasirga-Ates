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
    .decode_finished_o(decode_finished)
);



always@(posedge clk_i) begin

    if(fetch_finished)
    begin
        enable_fetch <= 1'b0;
        fetch.fetch_finished <= 1'b0;
        enable_decode <= 1'b1;
    end
    if(decode_finished)
    begin
        enable_fetch <= 1'b1;
        enable_decode <= 1'b0; 
        decode.decode_finished <= 1'b0;
    end
end

endmodule
