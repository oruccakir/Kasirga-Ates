`timescale 1ns / 1ps
// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
include "definitions.vh";

module Processor(
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] instruction_i,
    output wire [31:0] mem_address_o
);


wire [31:0] writebacked_result; // will be writed to available register
// Output signals
wire [6:0] opcode; // Opcode
wire [4:0] rs1;// Source register 1
wire [4:0] rs2; // Source register 2 
wire [4:0] rd; // Destination register
wire [31:0] integer_operand1; // Operand 1
wire [31:0] integer_operand2;// Operand 2 
wire [31:0] float_operand1;
wire [31:0] float_operand2;
wire [31:0] float_operand3;
wire [31:0] immediate; // Immediate

///////////////////////////
wire fetch_activate = 1'b1;
wire decode_activate;
wire execute_activate;
wire memory_activate;
wire writeback_activate;
//////////////////////////

// Instruction to decode
wire [31:0]instruction_to_decode;

// get instruction type
wire [4:0] instruction_type;

// get unit type
wire [3:0] unit_type;

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
    .instruction_to_decode_o(instruction_to_decode),
    .decode_activate_o(decode_activate)
);

// Decode stage
reg enable_decode = 1'b0;
wire decode_finished;

wire reg_write_integer; // coming from writeback
wire reg_write_float; // coming from writeback
wire reg_write_csr;    // coming from writeback step

// Decode module
DecodeStep decode(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_decode),
    .instruction_i(instruction_to_decode),
    .writebacked_result_i(writebacked_result),
    .reg_write_integer_i(reg_write_integer),
    .reg_write_float_i(reg_write_float),
    .reg_write_csr_i(reg_write_csr),
    .opcode_o(opcode),
    .rs1_o(rs1),
    .rs2_o(rs2),
    .rd_o(rd),
    .integer_operand1_o(integer_operand1),
    .integer_operand2_o(integer_operand2),
    .float_operand1_o(float_operand1),
    .float_operand2_o(float_operand2),
    .float_operand3_o(float_operand3),
    .immediate_o(immediate),
    .unit_type_o(unit_type),
    .instruction_type_o(instruction_type),
    .decode_finished_o(decode_finished),
    .execute_activate_o(execute_activate)
);

// Execute1 stage
reg enable_execute1 = 1'b0;
wire execute1_finished;

wire [31:0] calculated_result; // calculated result by execute1

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
    .operand1_integer_i(integer_operand1),
    .operand2_integer_i(integer_operand2),
    .operand1_float_i(float_operand1),
    .operand2_float_i(float_operand2),
    .operand3_float_i(float_operand3),
    .immediate_i(immediate),
    .unit_type_i(unit_type),
    .instruction_type_i(instruction_type),
    .calculated_result_o(calculated_result),
    .execute1_finished_o(execute1_finished),
    .memory_activate_o(memory_activate)
);

// Execute2 stage
reg enable_execute2 = 1'b0;
wire execute2_finished;


/*
// Execute2 module
ExecuteStep2 execute2(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_execute2),
    .execute2_finished_o(execute2_finished)
);
*/
// Memory stage

wire [31:0] calculated_result_mem;

reg enable_memory = 1'b0;
wire memory_finished;
reg mem_read_enable = 1'b0;
reg mem_write_enable = 1'b0;
wire [31:0] mem_data;
wire [31:0] mem_address;

// Memory module
MemoryStep memory(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_memory),
    .mem_read_enable_i(mem_read_enable),
    .mem_write_enable_i(mem_write_enable),
    .calculated_result_i(calculated_result),
    //.memOp_i(opcode),
    .mem_data_o(mem_data),
    .mem_address_o(mem_address),
    .memory_finished_o(memory_finished),
    .calculated_result_o(calculated_result_mem),
    .writeback_activate_o(writeback_activate)
);

// Writeback stage
reg enable_writeback = 1'b0;
wire writeback_finished;

// Writeback module
WriteBackStep writeback(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_writeback),
    .calculated_result_i(calculated_result_mem),
    .writeback_finished_o(writeback_finished),
    .writebacked_result_o(writebacked_result),
    .reg_write_integer_o(reg_write_integer),
    .reg_write_float_o(reg_write_float),
    .reg_write_csr_o(reg_write_csr),
    .fetch_activate_o(fetch_activate)
);

integer i = 1;
always@(posedge clk_i) begin

    if(fetch_finished)
    begin
        enable_fetch = 1'b0;
        fetch.fetch_finished = 1'b0;
        enable_decode = 1'b1;
    end
    else if(decode_finished)
    begin
        enable_decode = 1'b0; 
        decode.decode_finished = 1'b0;
        enable_execute1 = 1'b1;
        enable_fetch = 1'b1;
    end
    else if(execute1_finished)
    begin
        enable_execute1 <= 1'b0;
        execute1.execute1_finished <= 1'b0;
        enable_memory <= 1'b1;
        enable_decode <= 1'b1;
    end
    else if(memory_finished)
    begin
        enable_memory <= 1'b0;
        memory.memory_finished <= 1'b0;
        enable_writeback <=1'b1;
        enable_execute1 <= 1'b1;
    end
    else if(writeback_finished)
    begin
        enable_writeback <= 1'b0;
        writeback.writeback_finished <= 1'b0;
        enable_fetch <= 1'b1;
        enable_memory <= 1'b1;
    end
    
end

endmodule
