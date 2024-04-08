`timescale 1ns / 1ps
// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
include "definitions.vh";

module Processor(
    input wire clk_i, // Clock signal
    input wire rst_i, // Reset signal
    input wire [31:0] instruction_i, // Instruction to be executed
    output wire [31:0] mem_address_o // Memory address
);

wire decode_working_info; // working info for decode stage
wire execute_working_info; // working info for execute stage
wire memory_working_info; // working info for memory stage
wire writeback_working_info; // working info for writeback stage
wire fetch_working_info; // working info for fetch stage


wire [31:0] writebacked_result; // will be writed to available register
wire [6:0] opcode; // Opcode
wire [4:0] rs1;// Source register 1
wire [4:0] rs2; // Source register 2 
wire [4:0] rd; // Destination register
wire [31:0] integer_operand1; // Operand 1 in integer format
wire [31:0] integer_operand2;// Operand 2 in integer format
wire [31:0] float_operand1; // Operand 1 in float format
wire [31:0] float_operand2;  // Operand 2 in float format
wire [31:0] float_operand3; // Operand 3 in float format
wire [31:0] immediate; // Immediate value
// Instruction to decode
wire [31:0]instruction_to_decode;
// get instruction type
wire [4:0] instruction_type;
// get unit type
wire [3:0] unit_type;
// Processor module implementation
// Fetch stage
reg enable_fetch = 1'b1; // enable signal for fetch stage
wire fetch_finished; // fetch finished signal

FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    //.enable_step_i(enable_fetch),
    .instruction_i(instruction_i),
    .decode_working_info_i(decode_working_info),
    .mem_address_o(mem_address_o),
    //.fetch_finished_o(fetch_finished),
    .instruction_to_decode_o(instruction_to_decode),
    .fetch_working_info_o(fetch_working_info)
);

// Decode stage
reg enable_decode = 1'b0; // enable signal for decode stage
wire decode_finished; // decode finished signal
wire reg_write_integer; // coming from writeback
wire reg_write_float; // coming from writeback
wire reg_write_csr;    // coming from writeback step

// Decode module
DecodeStep decode(
    .clk_i(clk_i),
    .rst_i(rst_i),
    //.enable_step_i(fetch_finished),
    .instruction_i(instruction_to_decode),
    .writebacked_result_i(writebacked_result),
    .reg_write_integer_i(reg_write_integer),
    .reg_write_float_i(reg_write_float),
    .reg_write_csr_i(reg_write_csr),
    .execute_working_info_i(execute_working_info),
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
   // .decode_finished_o(decode_finished),
    .decode_working_info_o(decode_working_info)
);

// Execute1 stage
reg enable_execute1 = 1'b0; // enable signal for execute1 stage
wire execute1_finished; // execute1 finished signal

wire [31:0] calculated_result; // calculated result by execute1

// Execute1 module
ExecuteStep1 execute1(
    .clk_i(clk_i),
    .rst_i(rst_i),
   // .enable_step_i(decode_finished),
    .instruction_i(instruction_to_decode),
    .operand1_integer_i(integer_operand1),
    .operand2_integer_i(integer_operand2),
    .operand1_float_i(float_operand1),
    .operand2_float_i(float_operand2),
    .operand3_float_i(float_operand3),
    .immediate_i(immediate),
    .unit_type_i(unit_type),
    .instruction_type_i(instruction_type),
    .memory_working_info_i(memory_working_info),
    .calculated_result_o(calculated_result),
    //.execute1_finished_o(execute1_finished),
    .execute_working_info_o(execute_working_info)
);


// Memory stage
wire [31:0] calculated_result_mem; // calculated result by memory

reg enable_memory = 1'b0; // enable signal for memory stage
wire memory_finished; // memory finished signal
reg mem_read_enable = 1'b0; // memory read enable signal
reg mem_write_enable = 1'b0; // memory write enable signal
wire [31:0] mem_data; // memory data
wire [31:0] mem_address; // memory address

// Memory module
MemoryStep memory(
    .clk_i(clk_i),
    .rst_i(rst_i),
    //.enable_step_i(execute1_finished),
    .mem_read_enable_i(mem_read_enable),
    .mem_write_enable_i(mem_write_enable),
    .calculated_result_i(calculated_result),
    .writeback_working_info_i(writeback_working_info),
    //.memOp_i(opcode),
    .mem_data_o(mem_data),
    .mem_address_o(mem_address),
   // .memory_finished_o(memory_finished),
    .calculated_result_o(calculated_result_mem),
    .memory_working_info_o(memory_working_info)
);

// Writeback stage
reg enable_writeback = 1'b0;    // enable signal for writeback stage
wire writeback_finished; // writeback finished signal

// Writeback module
WriteBackStep writeback(
    .clk_i(clk_i),
    .rst_i(rst_i),
    //.enable_step_i(memory_finished),
    .calculated_result_i(calculated_result_mem),
    .fetch_working_info_i(fetch_working_info),
    //.writeback_finished_o(writeback_finished),
    .writebacked_result_o(writebacked_result),
    .reg_write_integer_o(reg_write_integer),
    .reg_write_float_o(reg_write_float),
    .reg_write_csr_o(reg_write_csr),
    .writeback_working_info_o(writeback_working_info)
);

integer f = 1; // instruction number for fetch
integer d = 1; // instruction number for decode
integer e = 1; // instruction number for execute
integer m = 1; // instruction number for memory
integer w = 1; // instruction number for writeback

/*
    Working principle of the pipeline processor:
*/
/*
always@(posedge clk_i) begin

    if(fetch_finished)
        fetch.fetch_finished = 1'b0;
    
    if(decode_finished)
        decode.decode_finished = 1'b0;
    if(fetch_finished) begin
        enable_fetch = 1'b0;     // if fetch finished, disable fetch stage
        fetch.fetch_finished = 1'b0;  // reset fetch finished signal
        enable_decode = 1'b1;  // enable decode stage
        $display("fetch finished for instruction %d",f); // display the instruction number
        f=f+1; // increment the instruction number
    end
    else if(decode_finished) begin
        enable_decode = 1'b0;  // if decode finished, disable decode stage
        decode.decode_finished = 1'b0; // reset decode finished signal
        enable_execute1 = 1'b1; // enable execute1 stage
        enable_fetch = 1'b1; // for implementing pipeline mechanism
        $display("decode finished forinstruction %d",d); // display the instruction number
        d = d + 1;   // increment the instruction number
    end
    else if(execute1_finished) begin
        enable_execute1 = 1'b0; // if execute1 finished, disable execute1 stage
        execute1.execute1_finished = 1'b0; // reset execute1 finished signal
        enable_memory = 1'b1; // enable memory stage
        if(fetch_finished) begin
            enable_decode = 1'b1; // for implementing stalling mechanism
        end
        $display("execute finished for instruction %d",e); // display the instruction number
        e=e+1; // increment the instruction number
    end 
    else if(memory_finished) begin
        enable_memory = 1'b0;  // if memory finished, disable memory stage
        memory.memory_finished = 1'b0; // reset memory finished signal
        enable_writeback =1'b1; // enable writeback stage
        if(decode_finished) begin
            enable_execute1 = 1'b1;  // for implementing stalling mechanism
        end
        $display("memory finished for instruction %d",m); // display the instruction number
        m=m+1; // increment the instruction number
    end
    else if(writeback_finished) begin
        enable_writeback = 1'b0; // if writeback finished, disable writeback stage
        writeback.writeback_finished = 1'b0; // reset writeback finished signal
        enable_fetch = 1'b1; // enable fetch stage
        if(execute1_finished) begin
            enable_memory = 1'b1; // for implementing stalling mechanism
        end
        $display("writeback finished for instruction %d",w);
        w=w+1;
    end  
    
end // end of always block
*/
endmodule
