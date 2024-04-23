
`timescale 1ns / 1ps
// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
`include "definitions.vh";
// Current Processor
module Processor(
    input wire clk_i,                                                                  // Clock signal 
    input wire rst_i,                                                                  // Reset signal
    input wire [31:0] instruction_i,                                                   // Instruction to be executed comes from memory, later will be fecthed from cache, goes to fetch step
    input wire [31:0] data_i,                                                          // data input comes from memory, later will be taken from cache, goes to execute step as input to memory unit
    input wire data_completed_i,                                                       // data completed input comes from memory, goes to execute step as input to memory unit
    input wire instruction_completed_i,                                                // instruction completed input comes from memory, goes to fetch step
    output wire [31:0] mem_address_o,                                                  // output for instruction memory address comes from fetch step goes to memory 
    output wire [31:0] data_address_o,                                                 // output for data memory address comes from execute step - memory unit, goes to memory
    output wire read_enable_o,                                                         // output for memory, indicates memory unit desire for data, goes o memory (read_enable_o)
    output wire get_instruction_o,                                                     // output for memory, indicates fecth step desire for instruction, goes to memory
    output wire [31:0] write_data_o,                                                   //  data need to be writed to memory, comes from execute step - memory unit
    output wire write_enable_o                                                         // write data enable output that will be conveyed as input to memory, comes from execute step - memory unit
    
);

wire decode_working_info;                                                             // working info for decode stage
wire execute_working_info;                                                            // working info for execute stage
wire [31:0] writebacked_result;                                                       // will be writed to available register
wire [4:0] rd;                                                                        // Destination register
wire [31:0] integer_operand1;                                                         // Operand 1 in integer format
wire [31:0] integer_operand2;                                                         // Operand 2 in integer format
wire [31:0] rs2_value;                                                                // this necessay for some instructions such as memory instructions
wire [31:0] float_operand1;                                                           // Operand 1 in float format
wire [31:0] float_operand2;                                                           // Operand 2 in float format
wire [31:0] float_operand3;                                                           // Operand 3 in float format
wire [31:0]instruction_to_decode;                                                     // this info goes from fetch step to decode step
wire [4:0] instruction_type;                                                          // this info goes from decode step to execute step
wire [3:0] unit_type;                                                                 // this info goes from decode step to execute step
wire [31:0] program_counter;                                                          // this info goes from fetch step to decode step
wire is_branch_instruction;                                                           // this info goes from fetch step to processor
wire is_branch_address_calculated;                                                    // this info goes from execute step to fetch step
wire [31:0] calculated_result;                                                        // calculated result by execute1
wire [31:0] calculated_branch_address;                                                // this info goes from execute step to fetch step
wire reg_write_integer;                                                               // coming from writeback
wire reg_write_float;                                                                 // coming from writeback
wire reg_write_csr;                                                                   // coming from writeback step
wire [1:0] register_selection;                                                        // for decode step register selection
wire [4:0] target_register;                                                           // this info goes from writeback step to decode step
wire [31:0] immediate_value;                                                          // this info goes from decode step to execute step
wire [31:0] program_counter_decode;                                                   // this info goes from decode step to execute step                 
wire [4:0] rd_to_writeback;                                                           // this info goes from execute step to writeback step
wire [1:0] register_selection_execute;                                                // this info goes from execute step to writeback step
wire branch_info;                                                                     // this info comes from execute step, indicates whether branch is taken or not
wire [2:0] write_register_info;                                                       // this info comes from execute step, indicates which register will be writed to writeback step
wire [31:0] forwarded_data;                                                           // this info comes from execute step, indicates forwarded data goes to decode step
wire [4:0] forwarded_rd;                                                              // this info comes from execute step, indicates forwarded register goes to decode step                                 
wire fetch_reset_branch_info;                                                         // this info comes from fetch step,and goes to execute step, branch resolver unit

// Fetch module
FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instruction_i(instruction_i),
    .decode_working_info_i(decode_working_info),
    .instruction_completed_i(instruction_completed_i),
    .calculated_branch_address_i(calculated_branch_address),
    .is_branch_address_calculated_i(is_branch_address_calculated),
    .branch_info_i(branch_info),
    .mem_address_o(mem_address_o),
    .instruction_to_decode_o(instruction_to_decode),
    .fetch_next_instruction_o(get_instruction_o),
    .program_counter_o(program_counter),
    .reset_branch_info_o(fetch_reset_branch_info)
);

// Decode module
DecodeStep decode(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instruction_i(instruction_to_decode),
    .writebacked_result_i(writebacked_result),
    .reg_write_integer_i(reg_write_integer),
    .reg_write_float_i(reg_write_float),
    .reg_write_csr_i(reg_write_csr),
    .target_register_i(target_register),
    .execute_working_info_i(execute_working_info),
    .program_counter_i(program_counter),
    .forwarded_data_i(forwarded_data),
    .forwarded_rd_i(forwarded_rd),
    .branch_info_i(branch_info),
    .rd_o(rd),
    .integer_operand1_o(integer_operand1),
    .integer_operand2_o(integer_operand2),
    .float_operand1_o(float_operand1),
    .float_operand2_o(float_operand2),
    .float_operand3_o(float_operand3),
    .unit_type_o(unit_type),
    .instruction_type_o(instruction_type),
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
    .fetch_reset_branch_info_i(fetch_reset_branch_info),
    .calculated_result_o(calculated_result),
    .execute_working_info_o(execute_working_info),
    .rd_o(rd_to_writeback),
    .register_selection_o(register_selection_execute),
    .is_branch_address_calculated_o(is_branch_address_calculated),
    .calculated_branch_address_o(calculated_branch_address),
    .read_enable_o(read_enable_o),
    .write_enable_o(write_enable_o),
    .mem_address_o(data_address_o),
    .mem_writed_data_o(write_data_o),
    .branch_info_o(branch_info),
    .write_register_info_o(write_register_info),
    .forwarded_data_o(forwarded_data),
    .forwarded_rd_o(forwarded_rd)
);

// Writeback module
WriteBackStep writeback(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .calculated_result_i(calculated_result),
    .rd_i(rd_to_writeback),
    .register_selection_i(register_selection_execute),
    .write_register_info_i(write_register_info),
    .writebacked_result_o(writebacked_result),
    .reg_write_integer_o(reg_write_integer),
    .reg_write_float_o(reg_write_float),
    .reg_write_csr_o(reg_write_csr),
    .rd_o(target_register)
);


endmodule
