// Purpose: Execute Stage of the pipeline.
// Functionality: This module performs the execute stage of the pipeline.
// File: execute_stage.v

//inout kullanimi?????????????
// nop buyruðu eklenecek
module execute_stage(
    input     wire                                  clk_i,                                      // clock signal
    input     wire                                  rst_i,                                      // reset signal

    //-------------------------------from memory_stage----------------------------------------------
    input     wire                                  is_memory_stage_finished_i,                         // memory stage finished signal for Stall

    
    //-------------------------------from decode_stage----------------------------------------------
    
    //olmali mi
    //input wire [31:0] rs2_value_i,        // rs2 register value comes from decode integer register file



    input      wire             [31:0]              operand1_integer_i,                         // Operand 1 input comes from decode integer register file
    input      wire             [31:0]              operand2_integer_i,                         // Operand 2 input comes from decode integer register file or from another calculation logic
    
    input      wire             [31:0]              operand1_float_i,                           // Operand 1 input comes from decode float register file
    input      wire             [31:0]              operand2_float_i,                           // Operand 2 input comes from decode float register file
    input      wire             [31:0]              operand3_float_i,                           // Operand 3 input comes from decode float register file
    
    input      wire             [31:0]              immediate_value_i,                          // generated immediate value from decode stage
    
    input      wire             [31:0]              program_counter_i,                          // because of address calculate for branch instructions

    input      wire             [4:0]               which_operation_alu_i,                      // which operation should be executed in ALU 31
    input      wire             [1:0]               which_operation_mul_i,                      // which operation should be executed in integer multiplication unit 4
    input      wire             [1:0]               which_operation_div_i,                      // which operation should be executed in integer division unit 4
    input      wire             [2:0]               which_operation_atomic_i,                   // which operation should be executed in atomic unit 11
    input      wire             [4:0]               which_operation_floating_point_i,           // which operation should be executed in floating point unit 23
    input      wire             [4:0]               which_operation_bit_manipulation_i,         // which operation should be executed in bit manipulation unit 32
    input      wire             [3:0]               which_branch_operation_i,                   // which branch operation should be executed in branch resolver unit 11

    input      wire                                 enable_alu_unit_i,                          // enable signal for ALU unit
    input      wire                                 enable_integer_multiplication_unit_i,       // enable signal for integer multiplication unit
    input      wire                                 enable_integer_division_unit_i,             // enable signal for integer division unit
    input      wire                                 enable_atomic_unit_i,                       // enable signal for atomic unit
    input      wire                                 enable_floating_point_unit_i,               // enable signal for floating point unit
    input      wire                                 enable_bit_manipulation_unit,               // enable signal for bit manipulation unit
    input      wire                                 enable_branch_resolver_unit_i,              // enable signal for branch resolver unit
    input      wire                                 enable_control_status_unit_i,               // enable signal for control status unit

    input                                           aq_i,                                       // acquire signal              
    input                                           rl_i,                                       // release signal   
    input                        [4:0]              shamt_i,                                    // shift amount for bit manipulation unit

 /*   input      wire             [3:0]               unit_selection_i,                           // which unit should be executed
    input      wire             [4:0]               process_selection_i,                        // in the unit, which instruction should be executed    
  */
  
    //------------------------------to memory_stage-----------------------------------------------------------------
    /*  
    memory_operation_type_o: should be added to definitions.vh file 
    0 --> nothing
    1 --> write byte
    2 --> write halfword
    3 --> write word
    4 --> read byte
    5 --> read halfword
    6 --> read word
    */
    output      reg             [2:0]               memory_operation_type_o,
    output      reg             [31:0]              memory_write_data_o,                        // data to be written to memory
    output      reg             [31:0]              calculated_memory_address_o,                  // memory address to be read or written
    output      reg                                 extension_mode_o,                           // 0 : zero extension, 1 : sign extension for halfword and byte operations

    output      reg             [31:0]              calculated_result_o,                        // calculated result output, goes to memory step)
    inout       wire            [4:0]               rd_io,                                      // Destination register input from decode step, goes to memory step for write back
    output      reg             [1:0]               register_type_selection_o,                    // 0: integer register file, 1: float register file 2:csr register file ?????

    
    //--------------------------to fetch stage--------------------------------------------------------------
    output      reg                                  is_branched_o,                             // branched or not
    output      reg             [31:0]               branched_address_o,                        // branched address to be fetched right instruction
    
    // to decode stage for sta
    output      reg                                  is_execute_finished_o                       // finish signal


);


wire finished_alu_unit;
wire [31:0] calculated_result_alu_o;
wire [31:0] calculated_memory_address_alu;
wire register_type_selection_alu;
wire extension_mode_alu_o;
wire [2:0] memory_operation_type_alu_o;
arithmetic_logic_unit alu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_alu_unit_i(enable_alu_unit_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .immediate_value_i(immediate_value_i),
    .program_counter_i(program_counter_i),
    .aluOp_i(which_operation_alu_i),
    .calculated_memory_address_o(calculated_memory_address_alu),
    .calculated_result_o(calculated_result_alu_o),
    .extension_mode_o(extension_mode_alu_o),
    .memory_operation_type_o(memory_operation_type_alu_o),
    .register_type_selection_o(register_type_selection_alu),
    .finished_o(finished_alu_unit)
);



// Integer Multiplication Unit module 
// rs2 ve rs1 degerleri integer register file'dan alinir
wire finished_integer_multiplication_unit;
wire [31:0] calculated_result_mul_o;
wire register_type_selection_mul;
integer_multiplication_unit imu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_integer_multiplication_unit_i(enable_integer_multiplication_unit_i),
    .mulOp_i(which_operation_mul_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_result_mul_o),
    .register_type_selection_o(register_type_selection_mul),
    .finished_o(finished_integer_multiplication_unit)
);


// Integer Division Unit module;
wire finished_integer_division_unit;
wire [31:0] calculated_int_div_result;
wire register_type_selection_div;
integer_division_unit idu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_integer_division_unit_i(enable_integer_division_unit_i),
    .divOp_i(which_operation_div_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_div_result),
    .register_type_selection_o(register_type_selection_div),
    .finished_o(finished_integer_division_unit)
);

// Atomic Unit module  ???????????????????????????????????????
wire finished_atomic_unit;
wire [31:0] calculated_atomic_result;
wire [31:0] calculated_memory_address_atomic;
wire register_type_selection_atomic;
wire extension_mode_au_o;
wire [2:0] memory_operation_type_au_o;
atomic_unit au(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_atomic_unit_i(enable_atomic_unit_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .atomicOp_i(which_operation_atomic_i),
    .aq_i(aq_i),
    .rl_i(rl_i),
    .calculated_memory_address_o(calculated_memory_address_atomic),
    .calculated_result_o(calculated_atomic_result),
    .extension_mode_o(extension_mode_au_o),
    .au_memory_operation_type_o(memory_operation_type_au_o),
    .register_type_selection_o(register_type_selection_atomic),
    .finished_o(finished_atomic_unit)
);

// Floating Point Unit module
wire finished_floating_point_unit;
wire [31:0] calculated_fpu_result;
wire register_type_selection_floating_point;
wire extension_mode_fpu;
wire [31:0] calculated_memory_address_fpu;

floating_point_unit fpu(  // sadece word okur ve yazar
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_floating_point_unit_i(enable_floating_point_unit_i),
    .float_operation_i(which_operation_floating_point_i),
    .operand1_i(operand1_float_i),
    .operand2_i(operand2_float_i),
    .operand3_i(operand3_float_i),
    .immediate_value_i(immediate_value_i),
    .fpu_result_o(calculated_fpu_result),
    .register_type_selection_o(register_type_selection_floating_point),
    .finished_o(finished_floating_point_unit)
);




// Bit Manipulation Unit module
wire finished_bit_manipulation_unit;
wire [31:0] calculated_bmu_result;
wire register_type_selection_manipulation;
bit_manipulation_unit bmu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_bit_manipulation_unit(enable_bit_manipulation_unit),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .immediate_value_i(immediate_value_i),
    .shamt_i(shamt_i),
    .bmuOp_i(which_operation_bit_manipulation_i),
    .result_o(calculated_bmu_result),
    .register_type_selection_o(register_type_selection_manipulation),
    .finished_o(finished_bit_manipulation_unit)
);



// Branch Resolver Unit module
wire finished_branch_resolver_unit;
wire register_type_selection_branch_resolver;
wire is_branched;
wire [31:0] branched_address;
branch_resolver_unit bru(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_branch_resolver_unit_i(enable_branch_resolver_unit_i),
    .branch_instruction_selection_i(which_branch_operation_i),
    .program_counter_i(program_counter_i),
    .immediate_value_i(immediate_value_i),
    .operand1_integer_i(operand1_integer_i),
    .operand2_integer_i(operand2_integer_i),
    .operand1_float_i(operand1_float_i),
    .operand2_float_i(operand2_float_i),
    .operand3_float_i(operand3_float_i),
    .register_type_selection_o(register_type_selection_branch_resolver),
    .branched_address_o(branched_address), // calculated branch address
    .is_branched_o(is_branched),  // branched or not 
    .finished_o(finished_branch_resolver_unit)
);


// Control Status Unit module
control_status_unit csu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_control_status_unit_i(enable_control_status_unit_i)
);

always@(posedge clk_i) begin
    if(rst_i) begin
        is_execute_finished_o <= 0;
    end
    else begin
        if(is_memory_stage_finished_i) begin  // if the memory stage is finished, execute stage results are ready to go to memory stage
            if(enable_alu_unit_i && finished_alu_unit) begin
                calculated_memory_address_o<=calculated_memory_address_alu;
                calculated_result_o<=calculated_result_alu_o;
                extension_mode_o<=extension_mode_alu_o;
                memory_operation_type_o<=memory_operation_type_alu_o;
                register_type_selection_o<=register_type_selection_alu;
                arithmetic_logic_unit.finished_o<=1'b0;   
                is_execute_finished_o<=1'b1;        
            end else if (enable_integer_multiplication_unit_i && finished_integer_multiplication_unit) begin
                calculated_result_o<=calculated_result_mul_o;
                register_type_selection_o<=register_type_selection_mul;
                floating_point_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;        
            end else if (enable_integer_division_unit_i && finished_integer_division_unit ) begin
                calculated_result_o<=calculated_int_div_result;
                register_type_selection_o<=register_type_selection_div;
                integer_division_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;
            end else if (enable_atomic_unit_i  && finished_atomic_unit) begin
                calculated_memory_address_o<=calculated_memory_address_atomic;
                calculated_result_o<=calculated_atomic_result;
                extension_mode_o<=extension_mode_au_o;
                memory_operation_type_o<=memory_operation_type_au_o;
                register_type_selection_o<=register_type_selection_atomic;
                atomic_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;
            end else if (enable_floating_point_unit_i && finished_floating_point_unit) begin
                calculated_result_o<= calculated_fpu_result;
                register_type_selection_o<=register_type_selection_floating_point;
                floating_point_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;
            end else if (enable_bit_manipulation_unit && finished_bit_manipulation_unit) begin
                calculated_result_o <= calculated_bmu_result;
                register_type_selection_o<=register_type_selection_manipulation;
                bit_manipulation_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;
            end else if (enable_branch_resolver_unit_i && finished_branch_resolver_unit) begin
                register_type_selection_o<=register_type_selection_branch_resolver;
                branched_address_o<=branched_address;
                is_branched_o<=is_branched;
                branch_resolver_unit.finished_o<=1'b0;
                is_execute_finished_o<=1'b1;
            end else if (enable_control_status_unit_i) begin
                is_execute_finished_o<=1'b1;
            end else begin // if no unit is enabled or no unit is finished, execute stage is not finished
                is_execute_finished_o<=0;
            end
        end
    end
end
                
endmodule
