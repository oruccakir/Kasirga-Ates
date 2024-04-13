`timescale 1ns / 1ps
// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
include "definitions.vh";

module Processor(
    input wire clk_i, // Clock signal 
    input wire rst_i, // Reset signal
    input wire [31:0] instruction_i, // Instruction to be executed comes from memory, later will be fecthed from cache, goes to fetch step
    input wire [31:0] data_i,        // data input comes from memory, later will be taken from cache, goes to execute step as input to memory unit
    input wire data_completed_i,     // data completed input comes from memory, goes to execute step as input to memory unit
    input wire instruction_completed_i, // instruction completed input comes from memory, goes to fetch step
    output wire [31:0] mem_address_o,  // output for instruction memory address comes from fetch step goes to memory 
    output wire [31:0] data_address_o, // output for data memory address comes from execute step - memory unit, goes to memory
    output wire read_enable_o,            // output for memory, indicates memory unit desire for data, goes o memory (read_enable_o)
    output wire get_instruction_o,     // output for memory, indicates fecth step desire for instruction, goes to memory
    output wire [31:0] write_data_o, //  data need to be writed to memory, comes from execute step - memory unit
    output wire write_enable_o // write data enable output that will be conveyed as input to memory, comes from execute step - memory unit
    
);

wire decode_working_info; // working info for decode stage
wire execute_working_info; // working info for execute stage
wire fetch_working_info; // working info for fetch stage
wire [31:0] writebacked_result; // will be writed to available register
wire [4:0] rd; // Destination register
wire [31:0] integer_operand1; // Operand 1 in integer format
wire [31:0] integer_operand2;// Operand 2 in integer format
wire [31:0] rs2_value;
wire [31:0] float_operand1; // Operand 1 in float format
wire [31:0] float_operand2;  // Operand 2 in float format
wire [31:0] float_operand3; // Operand 3 in float format
wire [31:0]instruction_to_decode;
wire [4:0] instruction_type;
wire [3:0] unit_type;
reg enable_fetch = 1'b1; // enable signal for fetch stage
wire fetch_finished; // fetch finished signal
wire [31:0] program_counter;
wire is_branch_instruction;
wire is_branch_address_calculated;
wire [31:0] calculated_result; // calculated result by execute1
wire [31:0] calculated_branch_address;
// Decode stage
reg enable_decode = 1'b0; // enable signal for decode stage
wire decode_finished; // decode finished signal
wire reg_write_integer; // coming from writeback
wire reg_write_float; // coming from writeback
wire reg_write_csr;    // coming from writeback step
wire [1:0] register_selection;  // for decode step register selection
wire [4:0] target_register;
wire [31:0] immediate_value;
wire [31:0] program_counter_decode;
// Execute1 stage
reg enable_execute1 = 1'b0; // enable signal for execute1 stage
wire execute1_finished; // execute1 finished signal
wire [4:0] rd_to_writeback;
wire [1:0] register_selection_execute;


FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_fetch),
    .instruction_i(instruction_i),
    .decode_working_info_i(decode_working_info),
    .instruction_completed_i(instruction_completed_i),
    .calculated_branch_address_i(calculated_branch_address),
    .is_branch_address_calculated_i(is_branch_address_calculated),
    .mem_address_o(mem_address_o),
    .fetch_finished_o(fetch_finished),
    .instruction_to_decode_o(instruction_to_decode),
    .get_instruction_o(get_instruction_o),
    .program_counter_o(program_counter),
    .is_branch_instruction_o(is_branch_instruction)
);

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
    .target_register_i(target_register),
    .execute_working_info_i(execute_working_info),
    .program_counter_i(program_counter),
    .rd_o(rd),
    .integer_operand1_o(integer_operand1),
    .integer_operand2_o(integer_operand2),
    .float_operand1_o(float_operand1),
    .float_operand2_o(float_operand2),
    .float_operand3_o(float_operand3),
    .unit_type_o(unit_type),
    .instruction_type_o(instruction_type),
    .decode_finished_o(decode_finished),
    .decode_working_info_o(decode_working_info),
    .rs2_value_o(rs2_value),
    .register_selection_o(register_selection),
    .program_counter_o(program_counter_decode),
    .immediate_value_o(immediate_value)
);

// Execute1 module
ExecuteStep1 execute1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_step_i(enable_execute1),
    .data_i(data_i),
    .data_completed_i(data_completed_i),
    .rd_i(rd),
    .operand1_integer_i(integer_operand1),
    .operand2_integer_i(integer_operand2),
    .rs2_value_i(rs2_value),
    .operand1_float_i(float_operand1),
    .operand2_float_i(float_operand2),
    .operand3_float_i(float_operand3),
    .unit_type_i(unit_type),
    .instruction_type_i(instruction_type),
    .register_selection_i(register_selection),
    .program_counter_i(program_counter_decode),
    .immediate_value_i(immediate_value),
    .calculated_result_o(calculated_result),
    .execute1_finished_o(execute1_finished),
    .execute_working_info_o(execute_working_info),
    .rd_o(rd_to_writeback),
    .register_selection_o(register_selection_execute),
    .is_branch_address_calculated_o(is_branch_address_calculated),
    .calculated_branch_address_o(calculated_branch_address),
    .read_enable_o(read_enable_o),
    .write_enable_o(write_enable_o),
    .mem_address_o(data_address_o),
    .mem_writed_data_o(write_data_o)
);

// Writeback module
WriteBackStep writeback(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .calculated_result_i(calculated_result),
    .rd_i(rd_to_writeback),
    .register_selection_i(register_selection),
    .writebacked_result_o(writebacked_result),
    .reg_write_integer_o(reg_write_integer),
    .reg_write_float_o(reg_write_float),
    .reg_write_csr_o(reg_write_csr),
    .rd_o(target_register)
);

integer f = 1; // instruction number for fetch
integer d = 1; // instruction number for decode
integer e = 1; // instruction number for execute
integer w = 1; // instruction number for writeback


always@(posedge clk_i) begin

    if(fetch_finished) begin
        enable_fetch = 1'b0;     // if fetch finished, disable fetch stage
        enable_decode = 1'b1;  // enable decode stage
        fetch.fetch_finished = 1'b0;  // reset fetch finished signal
        $display("fetch finished for instruction %d",f); // display the instruction number
        f=f+1; // increment the instruction number
    end
    else if(decode_finished) begin
        enable_decode = 1'b0;  // if decode finished, disable decode stage
        decode.decode_finished = 1'b0; // reset decode finished signal
        enable_execute1 = 1'b1; // enable execute1 stage
        if(is_branch_instruction == 1'b0) // if this is branch instruction then not run fetch wait execute step
            enable_fetch = 1'b1; // for implementing pipeline mechanism
        $display("decode finished for instruction %d",d); // display the instruction number
        d = d + 1;   // increment the instruction number
    end
    else if(execute1_finished) begin
        enable_execute1 = 1'b0; // if execute1 finished, disable execute1 stage
        execute1.execute1_finished = 1'b0; // reset execute1 finished signal
        if(fetch_finished) begin
            if(is_branch_instruction == 1'b0) begin // if this is branch instruction then not run decode wait execute step
                enable_decode = 1'b1; // for implementing stalling mechanism
            end
        end
        $display("execute finished for instruction %d",e); // display the instruction number
        e=e+1; // increment the instruction number
    end 
    else if(is_branch_instruction == 1'b0)
        enable_fetch = 1'b1;

end

endmodule
