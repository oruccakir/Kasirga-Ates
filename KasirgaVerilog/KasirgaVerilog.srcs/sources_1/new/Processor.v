// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
//`include "C:\Users\orucc\Desktop\Coding_Projects\Kasï¿½rga_Ates_Teknofest\Teknofest-Ates-Processor-Design\KasirgaVerilog\KasirgaVerilog.srcs\sources_1\new\definitions.vh"

module Processor(
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] instruction_i,
    output wire [31:0] mem_address_o
);

// Processor module implementation
reg [31:0] mem_address = 32'h8000_0000;

always @(posedge clk_i) begin
    $display("Processor: Instruction received %h", instruction_i);
    $display("Current address ýn pipeline : %h",mem_address_o);
    mem_address <= mem_address + 32'h4;   
end

assign mem_address_o = mem_address;

// Fetch stage
wire enable_fetch = 1'b1;

FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_fetch),
    .instruction_o(instruction_i)
);
endmodule
