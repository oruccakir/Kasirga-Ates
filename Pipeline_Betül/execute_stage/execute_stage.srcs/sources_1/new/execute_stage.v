// Purpose: Execute Stage of the pipeline.
// Functionality: This module performs the execute stage of the pipeline.
// File: execute_stage.v

// nop buyru?u eklenecek
module execute_stage(
    input                                           clk_i,                                      // clock signal
    input                                           rst_i,                                      // reset signal

    //-------------------------------from memory_stage----------------------------------------------
    input     wire                                  execute_stall_required_i,                            // durdurmak i?in
    output    wire                                  execute_busy_flag_o,   
    //-------------------------------from decode_stage----------------------------------------------
    

    input      wire             [31:0]              operand1_integer_i,                         // Operand 1 input comes from decode integer register file
    input      wire             [31:0]              operand2_integer_i,                         // Operand 2 input comes from decode integer register file or from another calculation logic
    
    input      wire             [31:0]              operand1_float_i,                           // Operand 1 input comes from decode float register file
    input      wire             [31:0]              operand2_float_i,                           // Operand 2 input comes from decode float register file
    input      wire             [31:0]              operand3_float_i,                           // Operand 3 input comes from decode float register file
    
    input      wire             [31:0]              immediate_value_i,                          // generated immediate value from decode stage
    
    input      wire             [31:0]              program_counter_i,                          // because of address calculate for branch instructions

    input      wire             [ 4:0]              which_operation_i,                          // which operation should be executed in ALU 31

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
    input                       [ 4:0]              shamt_i,                                    // shift amount for bit manipulation unit
    input                       [ 2:0]              rm_i,                                       // rounding mode for floating point unit
  
    input       wire            [ 4:0]              rd_i,                                      // Destination register input from decode step, goes to memory step for write back
    output      reg             [ 4:0]              rd_o,
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
    output      reg             [1:0]               register_type_selection_o,                    // 0: integer register file, 1: float register file 2:csr register file ?????

    
    //--------------------------to fetch stage--------------------------------------------------------------
    output      reg                                  is_branched_o,                             // branched or not
    output      reg             [31:0]               branched_address_o                         // branched address to be fetched right instruction
    

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
    .aluOp_i(which_operation_i),
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
    .mulOp_i(which_operation_i),
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
    .divOp_i(which_operation_i),
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
    .atomicOp_i(which_operation_i),
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
    .float_operation_i(which_operation_i),
    .operand1_i(operand1_float_i),
    .operand2_i(operand2_float_i),
    .operand3_i(operand3_float_i),
    .immediate_value_i(immediate_value_i),
    .rm_i(rm_i),
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
    .bmuOp_i(which_operation_i),
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
    .branch_instruction_selection_i(which_operation_i),
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
wire finished_control_status_unit;
control_status_unit csu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_control_status_unit_i(enable_control_status_unit_i),
    .finished_o(finished_control_status_unit)
);

always@(posedge clk_i) begin
    if(rst_i) begin
        rd_o<=0;
        memory_operation_type_o<=0;
        memory_write_data_o<=0;
        calculated_memory_address_o<=0;
        extension_mode_o<=0;
        calculated_result_o<=0;
        register_type_selection_o<=0;
        is_branched_o<=0;
        branched_address_o<=0;
    end else begin
        if(~execute_stall_required_i) begin  // if not busy, change the outputs
            rd_o<=rd_i; // every time
            if(enable_alu_unit_i) begin
                if(finished_alu_unit)begin
                    calculated_memory_address_o<=calculated_memory_address_alu;
                    calculated_result_o<=calculated_result_alu_o;
                    extension_mode_o<=extension_mode_alu_o;
                    memory_operation_type_o<=memory_operation_type_alu_o;
                    register_type_selection_o<=register_type_selection_alu;
                    arithmetic_logic_unit.finished_o<=1'b0; 
                 end      
            end
            else if (enable_integer_multiplication_unit_i) begin
                if(finished_integer_multiplication_unit)begin
                    calculated_result_o<=calculated_result_mul_o;
                    register_type_selection_o<=register_type_selection_mul;
                    floating_point_unit.finished_o<=1'b0;
                end
            end else if (enable_integer_division_unit_i) begin
                if(finished_integer_division_unit) begin
                    calculated_result_o<=calculated_int_div_result;
                    register_type_selection_o<=register_type_selection_div;
                    integer_division_unit.finished_o<=1'b0;
                end
            end else if (enable_atomic_unit_i) begin
                if(finished_atomic_unit) begin
                    calculated_memory_address_o<=calculated_memory_address_atomic;
                    calculated_result_o<=calculated_atomic_result;
                    extension_mode_o<=extension_mode_au_o;
                    memory_operation_type_o<=memory_operation_type_au_o;
                    register_type_selection_o<=register_type_selection_atomic;
                    atomic_unit.finished_o<=1'b0;
                 end          
            end 
            else if (enable_floating_point_unit_i) begin
                if(finished_floating_point_unit)begin
                    calculated_result_o<= calculated_fpu_result;
                    register_type_selection_o<=register_type_selection_floating_point;
                    floating_point_unit.finished_o<=1'b0;
                 end         
            end
            else if (enable_bit_manipulation_unit ) begin
                if(finished_bit_manipulation_unit) begin
                    calculated_result_o <= calculated_bmu_result;
                    register_type_selection_o<=register_type_selection_manipulation;
                    bit_manipulation_unit.finished_o<=1'b0;
                 end       
            end  
            else if (enable_branch_resolver_unit_i) begin
                if(finished_branch_resolver_unit)begin
                    register_type_selection_o<=register_type_selection_branch_resolver;
                    branched_address_o<=branched_address;
                    is_branched_o<=is_branched;
                    branch_resolver_unit.finished_o<=1'b0;
                 end      
            end
            else if (enable_control_status_unit_i) begin
                 if(finished_control_status_unit)begin
                    control_status_unit.finished_o<='b0;
                 end
            end  // else???????????
        end
    end
end

assign execute_busy_flag_o = (enable_alu_unit_i && ~finished_alu_unit) || (enable_atomic_unit_i && ~finished_atomic_unit) || (enable_floating_point_unit_i && ~finished_floating_point_unit) || (enable_bit_manipulation_unit && ~finished_bit_manipulation_unit) || (enable_branch_resolver_unit_i && ~finished_branch_resolver_unit) || (enable_control_status_unit_i && ~finished_control_status_unit) || (enable_integer_division_unit_i && ~finished_integer_division_unit) || (enable_integer_multiplication_unit_i && ~finished_integer_multiplication_unit) ;
           
endmodule