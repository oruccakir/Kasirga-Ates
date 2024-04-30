
`timescale 1ns / 1ps
// Purpose: Processor module for the pipeline processor.
// Functional Description: This module is the main module for the processor. It is responsible for the execution of the instructions. It is also responsible for the control signals of the pipeline.
// File: Processor.v

// Include the definitions
include "definitions.vh";
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


wire enable_memory_unit;
wire enable_atomic_unit;
wire decode_working_info;                                                             // working info for decode stage
wire execute_working_info;                                                            // working info for execute stage
wire memory_working_info;                                                             // working info for memeory stage
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
wire [31:0] branch_predictor_address;                                                 // this info comes from fetch step, and goes to decode
wire [31:0] branch_predictor_address_to_execute;                                      // this info comes from decode step and goes to execute
wire [ 4:0] rd_to_memory;
wire [31:0] memory_calculated_address;
wire [31:0] memory_write_data;
wire [ 2:0] memory_operation_selection;
wire        memory_extension_mode;
wire        yurut_FPU_en;
wire        yurut_ALU_en;
wire        yurut_IMU_en;
wire        yurut_IDU_en;
wire        yurut_BRU_en;
wire        yurut_CSU_en;
wire        yurut_AU_en;
wire        yurut_BMU_en;
wire        yurut_MU_en;
wire [4:0]  yurut_shamt;
wire        yurut_aq;
wire        yurut_rl;
wire [2:0]  yurut_rm;
wire [31:0] calculated_result_to_writeback;
wire [2:0]  memOp;

FetchStep fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    
    .bellek_deger_i(instruction_i),
    .bellek_gecerli_i(instruction_completed_i),
    .bellek_ps_o(mem_address_o),
    .bellek_istek_o(get_instruction_o),
    
    .coz_bos_i(!decode_working_info),
    .coz_buyruk_o(instruction_to_decode),
    .coz_ps_o(program_counter),
    
    .yurut_ps_i(calculated_branch_address),
    .yurut_ps_gecerli_i(is_branch_address_calculated),
    .yurut_atladi_i(branch_info)
);

// Decode module
DecodeStep decode(
.clk_i(clk_i),
.rst_i(rst_i), 
.execute_working_info_i(execute_working_info),
.forwarded_data_i(forwarded_data),
.forwarded_rd_i(forwarded_rd),     
.writeback_result_i(writebacked_result),
.writeback_address_i(target_register),
.write_integer_file_i(reg_write_integer),
.write_float_file_i(reg_write_float),                  
.getir_buyruk_i(instruction_to_decode),           
.getir_ps_i(program_counter),               
.yurut_FPU_en_o(yurut_FPU_en),
.yurut_ALU_en_o(yurut_ALU_en),
.yurut_IMU_en_o(yurut_IMU_en),
.yurut_IDU_en_o(yurut_IDU_en),
.yurut_BRU_en_o(yurut_BRU_en),
.yurut_CSU_en_o(yurut_CSU_en),
.yurut_AU_en_o(yurut_AU_en),
.yurut_BMU_en_o(yurut_BMU_en),
.yurut_MU_en_o(yurut_MU_en),             
.yurut_islem_secimi_o(instruction_type),      
.yurut_shamt_o(yurut_shamt),
.yurut_rm_o(yurut_rm),
.yurut_aq_o(yurut_aq),
.yurut_rl_o(yurut_rl),               
.yurut_integer_deger1_o(integer_operand1),    
.yurut_integer_deger2_o(integer_operand2),    
.yurut_float_deger1_o(float_operand1),      
.yurut_float_deger2_o(float_operand2),      
.yurut_float_deger3_o(float_operand3),      
.yurut_immidiate_o(immediate_value),  
.yurut_mem_store_data_o(memory_write_data),       
.yurut_ps_yeni_o(program_counter_decode),           
.yurut_rd_adres_o(rd),
.decode_working_info_o(decode_working_info),
.writeback_reg_file_sec_o(register_selection_execute),
.mem_stored_data_o(rs2_value)          
  
);

// Execute1 module
Execute1Step execute1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .execute_stall_required_i(memory_working_info),
  //  .branch_predictor_result_i(........)  decode outputu fetchden gelen
    .operand1_integer_i(integer_operand1),
    .operand2_integer_i(integer_operand2),
    .operand1_float_i(float_operand1),
    .operand2_float_i(float_operand2),
    .operand3_float_i(float_operand3),
    .aq_i(yurut_aq),
    .rl_i(yurut_rl),
    .shamt_i(yurut_shamt),
    .rm_i(yurut_rm),
    .which_operation_i(instruction_type),    
    .immediate_i(immediate_value),
    .pc_i(program_counter_decode),
    .enable_integer_multiplication_unit_i(yurut_IMU_en),
    .enable_integer_division_unit_i(yurut_IDU_en),
    .enable_floating_point_unit_i(yurut_FPU_en),
    .enable_bit_manipulation_unit_i(yurut_BMU_en),
    .enable_control_status_unit_i(yurut_CSU_en),
    .enable_memory_unit_i(yurut_MU_en),
    .enable_atomic_unit_i(yurut_AU_en),
    .enable_arithmetic_logic_unit_i(yurut_ALU_en),
    .register_type_selection_i(register_selection_execute),
    .rd_i(rd),
    .mem_stored_data_i(rs2_value),  //decodan gelecek rs2 de eri memorye yazlacak 
    //.extension_mode_i(),    buyrupa g re decodedan gelecek ve memory a amas ndan sonra gemi letme yap lacak
    //.enable_atomic_unit_o( ),   to memory
    //.enable_memory_unit_o(),    to memory
    .rd_o(rd_to_memory),
    //.memory_operation_type_o()   memory op i in 
    .mem_stored_data_o(memory_write_data),   
    .calculated_memory_address_o(memory_calculated_address),
    .calculated_result_o(calculated_result),
    .register_type_selection_o(register_selection),
    .is_branched_o(branch_info),
   // .branched_address_o(calculated_branch_address),  to fetch
   // .is_branched_address_valid_o(), to fetch 
   // .is_branch_predictor_true_o(),    to fetch
    .execute_busy_flag_o(execute_working_info),
    .forwarded_rd_o(forwarded_rd),
    .forwarded_data_o(forwarded_data),
    .enable_memory_unit_o(enable_memory_unit),
    .enable_atomic_unit_o(enable_atomic_unit),
    .memOp_o(memOp) 
);

MemoryStep memory(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(data_i),
    .mem_address_i(memory_calculated_address),
    .enable_memory_unit_i(enable_memory_unit),
    .enable_atomic_unit_i(enable_atomic_unit),
    .data_completed_i(data_completed_i),
    .memOp_i(memOp),
    .calculated_result_i(calculated_result),
    .rd_i(rd_to_memory),
    .mem_stored_data_i(memory_write_data),
    .register_selection_i(register_selection),
    .mem_data_o(write_data_o),
    .mem_address_o(data_address_o),
    .calculated_result_o(calculated_result_to_writeback),
    .memory_working_info_o(memory_working_info),
    .rd_o(rd_to_writeback),
    .read_enable_o(read_enable_o),
    .write_enable_o(write_enable_o),
    .write_register_info_o(write_register_info)
);

// Writeback module
WriteBackStep writeback(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .calculated_result_i(calculated_result_to_writeback),
    .rd_i(rd_to_writeback),
    .write_register_info_i(write_register_info),
    .writebacked_result_o(writebacked_result),
    .reg_write_integer_o(reg_write_integer),
    .reg_write_float_o(reg_write_float),
    .reg_write_csr_o(reg_write_csr),
    .rd_o(target_register)
);

endmodule
