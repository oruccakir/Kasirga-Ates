// Purpose: Execute Stage of the pipeline.
// Functionality: This module performs the execute stage of the pipeline.
// File: execute_stage.v

// nop buyru?u eklenecek
module Execute1Step(
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
    output      reg             [31:0]               branched_address_o,                        // branched address to be fetched right instruction
    output      reg                                  is_branched_address_valid_o

);


wire finished_alu_unit;
wire [31:0] calculated_result_alu_o;
wire [31:0] calculated_memory_address_alu;
wire register_type_selection_alu;
wire extension_mode_alu_o;
wire [2:0] memory_operation_type_alu_o;
ArithmeticLogicUnit alu(
    //.clk_i(clk_i),
    //.rst_i(rst_i),
    .enable_i(enable_alu_unit_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    //.immediate_value_i(immediate_value_i),
    //.program_counter_i(program_counter_i),
    .aluOp_i(which_operation_i),
    //.calculated_memory_address_o(calculated_memory_address_alu),
    .result_o(calculated_result_alu_o),
    //.extension_mode_o(extension_mode_alu_o),
    //.memory_operation_type_o(memory_operation_type_alu_o),
    //.register_type_selection_o(register_type_selection_alu),
    .is_finished_o(finished_alu_unit)
);

/*
ArithmeticLogicUnit alu(
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
);*/



// Integer Multiplication Unit module 
// rs2 ve rs1 degerleri integer register file'dan alinir
wire finished_integer_multiplication_unit;
wire [31:0] calculated_result_mul_o;
wire register_type_selection_mul;
IntegerMultiplicationUnit imu(
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
IntegerDivisionUnit idu(
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
AtomicUnit au(
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

FloatingPointUnit fpu(  // sadece word okur ve yazar
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
BitManipulationUnit bmu(
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
wire is_branched_address_valid;
BranchResolverUnit bru(
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
    .finished_o(finished_branch_resolver_unit),
    .is_branched_address_valid_o(is_branched_address_valid)
);


// Control Status Unit module
wire finished_control_status_unit;
ControlStatusUnit csu(
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
      //  execute_busy_flag_o<=0;

    end else begin
        if(1) begin  // if not busy, change the outputs
            $display("stall");
            rd_o<=rd_i; // every time
           // execute_busy_flag_o<=enable_alu_unit_i && ~finished_alu_unit || enable_atomic_unit_i && ~finished_atomic_unit || enable_floating_point_unit_i && ~finished_floating_point_unit || enable_bit_manipulation_unit && ~finished_bit_manipulation_unit || enable_branch_resolver_unit_i && ~finished_branch_resolver_unit || enable_control_status_unit_i && ~finished_control_status_unit || enable_integer_division_unit_i && ~finished_integer_division_unit || enable_integer_multiplication_unit_i && ~finished_integer_multiplication_unit ;
            if(enable_alu_unit_i) begin
                $display("enable", calculated_result_alu_o);
                if(finished_alu_unit)begin
                    calculated_memory_address_o=calculated_memory_address_alu;
                    calculated_result_o=calculated_result_alu_o;
                    extension_mode_o=extension_mode_alu_o;
                    memory_operation_type_o=memory_operation_type_alu_o;
                    register_type_selection_o=register_type_selection_alu;
                    alu.is_finished=1'b0;
                    $display("finished", calculated_result_alu_o); 
                 end      
            end
            else if (enable_integer_multiplication_unit_i) begin
                if(finished_integer_multiplication_unit)begin
                    calculated_result_o<=calculated_result_mul_o;
                    register_type_selection_o<=register_type_selection_mul;
                    imu.finished_o<=1'b0;
                end
            end else if (enable_integer_division_unit_i) begin
                if(finished_integer_division_unit) begin
                    calculated_result_o<=calculated_int_div_result;
                    register_type_selection_o<=register_type_selection_div;
                    idu.finished_o<=1'b0;
                end
            end else if (enable_atomic_unit_i) begin
                if(finished_atomic_unit) begin
                    calculated_memory_address_o<=calculated_memory_address_atomic;
                    calculated_result_o<=calculated_atomic_result;
                    extension_mode_o<=extension_mode_au_o;
                    memory_operation_type_o<=memory_operation_type_au_o;
                    register_type_selection_o<=register_type_selection_atomic;
                    au.finished_o<=1'b0;
                 end          
            end 
            else if (enable_floating_point_unit_i) begin
                if(finished_floating_point_unit)begin
                    calculated_result_o<= calculated_fpu_result;
                    register_type_selection_o<=register_type_selection_floating_point;
                    fpu.finished_o<=1'b0;
                 end         
            end
            else if (enable_bit_manipulation_unit ) begin
                if(finished_bit_manipulation_unit) begin
                    calculated_result_o <= calculated_bmu_result;
                    register_type_selection_o<=register_type_selection_manipulation;
                    bmu.finished_o<=1'b0;
                 end       
            end  
            else if (enable_branch_resolver_unit_i) begin
                if(finished_branch_resolver_unit)begin
                    register_type_selection_o<=register_type_selection_branch_resolver;
                    branched_address_o<=branched_address;
                    is_branched_o<=is_branched;
                    is_branched_address_valid_o<=is_branched_address_valid;
                    bru.finished_o<=1'b0;
                 end      
            end
            else if (enable_control_status_unit_i) begin
                 if(finished_control_status_unit)begin
                    csu.finished_o<='b0;
                 end
            end 
        end
    end
end

assign execute_busy_flag_o = enable_alu_unit_i && ~finished_alu_unit || enable_atomic_unit_i && ~finished_atomic_unit || enable_floating_point_unit_i && ~finished_floating_point_unit || enable_bit_manipulation_unit && ~finished_bit_manipulation_unit || enable_branch_resolver_unit_i && ~finished_branch_resolver_unit || enable_control_status_unit_i && ~finished_control_status_unit || enable_integer_division_unit_i && ~finished_integer_division_unit || enable_integer_multiplication_unit_i && ~finished_integer_multiplication_unit ;
           
endmodule


/*
// Purpose: Execute Step 1 of the pipeline.
// Functionality: This module performs the first part of the execute stage of the pipeline.
// File: ExecuteStep1.v

`include "definitions.vh";

module ExecuteStep1 (
    input wire clk_i,                                                               // Clock input
    input wire rst_i,                                                               // Reset input
    input wire data_completed_i,                                                    // data completed comes from helper memory
    input wire [31:0] data_i,                                                       // comes from memory that will assign to calculated result 
    input wire [4:0] rd_i,                                                          // Destination register input from decode step
    input wire [31:0] operand1_integer_i,                                           // Operand 1 input comes from decode integer register file
    input wire [31:0] operand2_integer_i,                                           // Operand 2 input comes from decode integer register file or from another calculation logic
    input wire [31:0] rs2_value_i,                                                  // rs2 register value comes from decode integer register file
    input wire [31:0] operand1_float_i,                                             // Operand 1 input comes from decode float register file
    input wire [31:0] operand2_float_i,                                             // Operand 2 input comes from decode float register file
    input wire [31:0] operand3_float_i,                                             // Operand 3 input comes from decode float register file
    input wire [3:0] unit_type_i,                                                   // for unit selection input comes from decode step for unit selection
    input wire [4:0] instruction_type_i,                                            // instruction type it works inside of unit type selection logic depending on definitions step
    input wire [1:0] register_selection_i,                                          // register selection info, comes from decode step
    input wire [31:0] program_counter_i,                                            // comes from decode for branch instructions and for other necessary instructions
    input wire [31:0] immediate_value_i,                                            // comes from decode step for branch and other instructions
    input wire fetch_reset_branch_info_i,                                           // comes from fetch step to reset branch info signal
    input wire [31:0] branch_predictor_address_i,                                   // comes from fetch step via decode step
    output wire [31:0] calculated_result_o,                                         // calculated result output, goes to writeback stage
    output wire execute_working_info_o,                                             // Execute step working info, goes to decode step
    output wire [4:0] rd_o,                                                         // Target register info, goes to writeback step
    output wire [1:0] register_selection_o,                                         // this info comes from decode step as input goes to memory step as output
    output wire is_branch_address_calculated_o,                                     // this goes to fetch step for branch address calculation, indicating whether completed or not
    output wire [31:0] calculated_branch_address_o,                                 // this goes to fetch step for branch address calculation, gives calculated branch address
    output wire [31:0] data_address_o,                                              // comes from memory that will assign to calculated result 
    output wire read_enable_o,                                                      // read enable output goes to processor from there goes to memory
    output wire write_enable_o,                                                     // write enable output goes to processor from there goes to memory
    output wire [31:0] mem_address_o,                                               // Memory address output goes to memory
    output wire [31:0] mem_writed_data_o,                                           // Memory data output goes to memory
    output wire branch_info_o,                                                      // comes from branch resolver unit as output and goes to fetch step 
    output wire [2:0] write_register_info_o,                                        // goes to writeback step for writing process
    output wire [31:0] forwarded_data_o,                                            // forwarded data goes to decode stage
    output wire [4:0] forwarded_rd_o                                                // forwarded rd goes to decode stage
);


reg [31:0] calculated_result;                                                       // reg for assign calculated result to calculated result output goes to memory step
reg [4:0] rd;                                                                       // target register index, goes to memory step
reg execute_working_info;                                                           //very important info for stalling goes to decode step
reg [1:0]register_selection;                                                        // register selection info goes to memory step

reg execute1_finished;                                                              // Flag for finishing execute step 1, just fır debugging
integer i = -2;                                                                     // it is just for debugging the instruction number 
                        
reg [1:0] register_selection_next;                                                  // next register for register selection
reg [3:0] unit_type_next;                                                           // next register for unit type
reg [31:0] calculated_result_next;                                                  // next register for calculated result
reg [4:0] rd_next;                                                                  // next register for rd 
reg [4:0] forwarded_rd;                                                             // forwarded rd goes to decode stage
reg [2:0] write_register_info;                                                      // write register info goes to writeback stage

reg enable_alu_unit;                                                                // Enable signal for ALU unit
reg enable_integer_multiplication_unit;                                             // Enable signal for integer multiplication unit
reg enable_integer_division_unit;                                                   // Enable signal for integer division unit
reg enable_floating_point_unit;                                                     // Enable signal for floating point unit
reg enable_branch_resolver_unit;                                                    // Enable signal for branch resolver unit
reg enable_control_unit;                                                            // Enable signal for control unit
reg enable_control_status_unit;                                                     // Enable signal for control status unit
reg enable_atomic_unit;                                                             // Enable signal for atomic unit
reg enable_bit_manipulation_unit;                                                   // Enable signal for bit manipulation unit
reg enable_memory_unit;                                                             // Enable signal for memory unit
reg is_branch_address_calculated;                                                   // for branch instructions indicate branch calculation is completed or not
reg other_resources;                                                                // sometimes we can use arithmetic logic for another units, this is for that purpose

wire finished_alu_unit;                                                             // finished signal for ALU unit
wire finished_integer_multiplication_unit;                                          // finished signal for integer multiplication unit
wire finished_integer_division_unit;                                                // finished signal for integer division unit
wire finished_floating_point_unit;                                                  // finished signal for floating point unit
wire finished_branch_resolver_unit;                                                 // finished signal for branch resolver unit
wire finished_control_unit;                                                         // finished signal for control unit
wire finished_control_status_unit;                                                  // finished signal for control status unit
wire finished_atomic_unit;                                                          // finished signal for atomic unit
wire finished_bit_manipulation_unit;                                                // finished signal for bit manipulation unit
wire finished_memory_unit;                                                          // finished signal for memory unit

//results
wire [31:0] calculated_alu_result;                                                  // alu result reg
wire [31:0] calculated_int_mul_result;                                              // int multiplication unit result reg
wire [31:0] calculated_int_div_result;                                              // int division unit result reg
wire [31:0] calculated_fpu_result;                                                  // floating point unit result reg
wire [31:0] calculated_branch_result;                                               // bransh resolver unit result reg
wire [31:0] calculated_bit_manip_result;                                            // bit manipulation unit result reg
wire [31:0] calculated_atomic_result;                                               // atomic unit result reg
wire [31:0] calculated_control_status_result;                                       // control status unit result reg 
wire [31:0] calculated_memory_unit_result;                                          // memory_unit result reg

wire integer_multiplication_unit_working_info;                                      // integer multiplication unit working info, nexessary for updating excepted working info
wire integer_division_unit_working_info;                                            // integer division unit working info, nexessary for updating excepted working info
wire memory_unit_working_info;                                                      // memory unit working info, nexessary for updating excepted working info
wire floating_point_unit_working_info;                                              // floating point unit working info, nexessary for updating excepted working info
wire bit_manipulation_unit_working_info;                                            // bit manipulation unit working info, nexessary for updating excepted working info
wire atomic_unit_working_info;                                                      // atomic unit working info, nexessary for updating excepted working info
wire branch_resolver_working_info;                                                  // branch resolver working info, necessary for updating excepted working info



// Arithmetic Logic Unit module
ArithmeticLogicUnit arithmetic_logic_unit(
    .enable_i(enable_alu_unit),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .aluOp_i(instruction_type_i),
    .other_resources_i(other_resources),
    .result_o(calculated_alu_result),
    .is_finished_o(finished_alu_unit)
);

// Integer Multiplication Unit module
IntegerMultiplicationUnit integer_multiplication_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_multiplication_unit),
    .mulOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_mul_result),
    .is_finished_o(finished_integer_multiplication_unit)
);

// Integer Division Unit module
IntegerDivisionUnit integer_division_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_division_unit),
    .divOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_div_result),
    .is_finished_o(finished_integer_division_unit)
);

// Floating Point Unit module
FloatingPointUnit floating_point_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_floating_point_unit)
);

// Branch Resolver Unit module
BranchResolverUnit branch_resolver_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_branch_resolver_unit),
    .instruction_type_i(instruction_type_i),
    .program_counter_i(program_counter_i),
    .immediate_value_i(immediate_value_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .fetch_reset_branch_info_i(fetch_reset_branch_info_i),
    .branch_predictor_address_i(branch_predictor_address_i),
    .result_o(calculated_branch_result),
    .branch_info_o(branch_info_o),
    .is_finished_o(finished_branch_resolver_unit)
);

// Control Unit module
ControlUnit control_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_unit)
);

// Control Status Unit module
ControlStatusUnit control_status_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_status_unit)
);

// Atomic Unit module
AtomicUnit atomic_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_atomic_unit)
);

// Bit Manipulation Unit module
BitManipulationUnit bit_manipulation_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_bit_manipulation_unit)
);

// Memory Unit
MemoryUnit memory_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_memory_unit),
    .data_i(data_i),
    .data_completed_i(data_completed_i),
    .memOp_i(instruction_type_i[2:0]),
    .mem_stored_data_i(rs2_value_i),
    .calculated_memory_address_i(calculated_alu_result),
    .mem_data_o(mem_writed_data_o),
    .mem_address_o(mem_address_o),
    .write_enable_o(write_enable_o),
    .read_enable_o(read_enable_o),
    .mem_data_for_writeback_o(calculated_memory_unit_result),
    .is_finished_o(finished_memory_unit)
);



always@(*) begin
    register_selection_next = register_selection_i;                               // assign register selection
    unit_type_next = unit_type_i;                                                 // assign unit type
    rd_next = rd_i;                                                               // assign target register
end


// debugging purposes
always@(*) begin
    $display("@@EXECUTE STAGE Executed instruction %h ", program_counter_i);
    //unit_type = unit_type_i;
    $display("----> UNIT : ");
    case(unit_type_i)
        `NONE_UNIT : begin
            $display("NONE UNIT Working");
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            $display("LUI");
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            $display("-->ALU UNIT working");
            $display("-->EX Operand 1 %d",$signed(operand1_integer_i));
            $display("-->EX Operand 2 %d",$signed(operand2_integer_i));
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `ALU_ADD : $display("ADD");
                `ALU_SUB: $display("SUB");
                `ALU_AND: $display("AND");                            
                `ALU_OR:  $display("OR");
                `ALU_XOR: $display("XOR");
                `ALU_SLL: $display("SLL");
                `ALU_SRL: $display("SRL");
                `ALU_SRA: $display("SRA");
                `ALU_SLT: $display("SLT");
                `ALU_SLTU: $display("SLTU");
                `ALU_SLLI: $display("SLLI");
                `ALU_SRLI: $display("SRLI");
                `ALU_SRAI: $display("SRAI");
                `ALU_ADDI: $display("ADDI");
                `ALU_ANDI: $display("ANDI");
                `ALU_ORI: $display("ORI");
                `ALU_XORI: $display("XORI");
                `ALU_SLTI: $display("SLTI");
                `ALU_SLTIU: $display("SLTIU");
            endcase
        end
        `INTEGER_MULTIPLICATION_UNIT: begin
            $display("INTEGER MULTIPLICATION UNIT working for instruction %d",i);
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `INT_MUL: $display("MUL");
                `INT_MULH: $display("MULH");
                `INT_MULHSU: $display("MULHSU");
                `INT_MULHU: $display("MULHU");
            endcase
        end
        `INTEGER_DIVISION_UNIT: begin
            $display("INTEGER DIVISION UNIT working for instruction %d",i);
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `INT_DIV: $display("DIV");
                `INT_DIVU: $display("DIVU");
                `INT_REM: $display("REM");
                `INT_REMU: $display("REMU");
            endcase
        end
        `FLOATING_POINT_UNIT:begin
            $display("Floating Point Unit working");
        end
        `BRANCH_RESOLVER_UNIT: begin
            $display("BRANCH RESOLVER UNIT working for instruction %d",i);
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Program Counter : %h",program_counter_i);
            $display("-->Immediate Value : %d",immediate_value_i);
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `BRANCH_JAL : $display("JAL");
                `BRANCH_JALR : $display("JALR");
                `BRANCH_BLT : $display("BLT");
                `BRANCH_BNE : $display("BNE");
                `BRANCH_BGE : $display("BGE");
                `BRANCH_BEQ : $display("BEQ");
            endcase
            if(instruction_type_i == `BRANCH_JAL) begin
                $display("Enable otherr");
            end
            else if(instruction_type_i == `BRANCH_JALR) begin
                $display("Enable otherr");      
            end
            
        end 
        `CONTROL_UNIT: begin
            $display("Control Unit working");
        end
        `CONTROL_STATUS_UNIT: begin
            $display("Control Status Unit working");
        end
        `ATOMIC_UNIT: begin
            $display("Atomic Unit working");
        end
        `BIT_MANIPULATION_UNIT: begin
            $display("Bit Manipulation Unit working");
        end
        `MEMORY_UNIT: begin
            $display("MEMORY UNIT WORKING");
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            $display("-->Memory address calculation is being done for instruction ",i);
            case(instruction_type_i[2:0])
                `MEM_SW: $display("SW");
                `MEM_LW : $display("LW");
            endcase
        end
    endcase
    execute1_finished = 1'b1;
    i=i+1;
end

always @(posedge execute1_finished) begin
    
    case(unit_type_i)
        `NOP_UNIT : begin
            $display("NOP UNIT");
         end
        `NONE_UNIT : begin
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            $display("ENABLE ALU");
            enable_alu_unit = 1'b1; 
        end
        `INTEGER_MULTIPLICATION_UNIT: begin
          enable_integer_multiplication_unit = 1'b1;
        end
        `INTEGER_DIVISION_UNIT: begin
           enable_integer_division_unit = 1'b1;
        end
        `FLOATING_POINT_UNIT:begin
            enable_floating_point_unit = 1'b1;
        end
        `BRANCH_RESOLVER_UNIT: begin
            enable_branch_resolver_unit = 1'b1;
            if(instruction_type_i == `BRANCH_JAL ||instruction_type_i ==  `BRANCH_JALR) begin
                other_resources = 1'b1;
            end
        end 
        `CONTROL_UNIT: begin
            enable_control_unit = 1'b1;
        end
        `CONTROL_STATUS_UNIT: begin
            enable_control_status_unit = 1'b1;
        end
        `ATOMIC_UNIT: begin
            enable_atomic_unit = 1'b1;
        end
        `BIT_MANIPULATION_UNIT: begin
           enable_bit_manipulation_unit = 1'b1;
        end
        `MEMORY_UNIT: begin
           other_resources = 1'b1;
           enable_memory_unit = 1'b1;
        end
    endcase
    execute1_finished = 1'b0;
end


always@(posedge clk_i) begin
    if(rst_i) begin
        enable_alu_unit = 1'b0; 
        enable_integer_multiplication_unit = 1'b0; 
        enable_integer_division_unit = 1'b0; 
        enable_floating_point_unit = 1'b0; 
        enable_branch_resolver_unit = 1'b0; 
        enable_control_unit = 1'b0; 
        enable_control_status_unit = 1'b0; 
        enable_atomic_unit = 1'b0;
        enable_bit_manipulation_unit = 1'b0; 
        enable_memory_unit = 1'b0;          
        register_selection_next = 2'b0;
        unit_type_next = 4'b0;
        calculated_result_next = 32'b0;
        rd_next = 5'b0;
        register_selection = 2'b0;
        calculated_result = 32'b0;
        rd = 5'b0;
        execute1_finished <= 1'b0;
        execute_working_info <= 1'b0;
        is_branch_address_calculated <=1'b0;
        other_resources <= 1'b0;
    end
    else begin
        if(execute_working_info_o == 1'b0) begin                                                   // if execute working info is 0, then update the registers coneying to writeback stage
            register_selection <= register_selection_next;                                         // update register selection
            rd <= rd_next;                                                                         // update target register 
            write_register_info <= (register_selection_next == `INTEGER_REGISTER) ? 3'b100 :       // update write register info
                               (register_selection_next == `FLOAT_REGISTER) ? 3'b010 : 
                               (register_selection_next == `CSR_REGISTER) ? 3'b001 : 
                               3'b000;
        end
        forwarded_rd <= rd_next;                                                                    // update forwarded rd for decode stage
    end
end

// at clock edge, assign calculated result to calculated result output and update the working info
always@(posedge clk_i) begin    
    case(unit_type_i)
        `NOP_UNIT : begin
            $display("Do Nothing");
        end
        `NONE_UNIT : begin
            calculated_result = immediate_value_i;
            $display("-->LUI LOADED RESULT %d",immediate_value_i);
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            enable_alu_unit = 1'b0; 
            arithmetic_logic_unit.is_finished = 1'b0;
            calculated_result = calculated_alu_result;
            $display("--->ALU RESULT %d ",$signed(calculated_result));
        end
        `INTEGER_MULTIPLICATION_UNIT: begin
            if(finished_integer_multiplication_unit) begin
               enable_integer_multiplication_unit = 1'b0;
               integer_multiplication_unit.is_finished = 1'b0;
               calculated_result = calculated_int_mul_result;
               $display("--> IM     RESULT %d ",calculated_result);
            end
            else
               $display("INTEGER MULTIPLICATION UNIT STILL WORKING");
        end
        `INTEGER_DIVISION_UNIT: begin
            if(finished_integer_division_unit) begin
               enable_integer_division_unit = 1'b0;
               integer_division_unit.is_finished = 1'b0;
               calculated_result = calculated_int_div_result;
               $display("--> ID RESULT %d ",calculated_result);
            end
            else
               $display("INTEGER DIVISION UNIT STILL WORKING");
        end
        `FLOATING_POINT_UNIT:begin
           enable_floating_point_unit = 1'b1;
        end
        `BRANCH_RESOLVER_UNIT: begin
            enable_branch_resolver_unit = 1'b0;
            other_resources = 1'b0;
            calculated_result = calculated_branch_result;
            $display("-->BR RESULT %h ",calculated_result);
            is_branch_address_calculated = 1'b1;
            branch_resolver_unit.is_finished = 1'b0;
        end 
        `CONTROL_UNIT: begin
            enable_control_unit = 1'b1;
        end
        `CONTROL_STATUS_UNIT: begin
            enable_control_status_unit = 1'b1;
        end
        `ATOMIC_UNIT: begin
            enable_atomic_unit = 1'b1;
        end
        `BIT_MANIPULATION_UNIT: begin
            enable_bit_manipulation_unit = 1'b0;
        end
        `MEMORY_UNIT: begin
            if(finished_memory_unit) begin
                enable_memory_unit = 1'b0;
                memory_unit.is_finished = 1'b0;
                calculated_result = calculated_memory_unit_result;
                other_resources = 1'b0;
                $display("--> MEM RESULT %h ",calculated_result);
            end
            else
                $display("MEMORY UNIT STILL WORKING");
        end
    endcase 
end


assign integer_multiplication_unit_working_info = (enable_integer_multiplication_unit & finished_integer_multiplication_unit == 1'b0);                     // assign integer multiplication unit working info
assign integer_division_unit_working_info = (enable_integer_division_unit & finished_integer_division_unit == 1'b0);                                       // assign integer division unit working info
assign memory_unit_working_info = (enable_memory_unit & finished_memory_unit == 1'b0);                                                                     // assign memory unit working info
//assign branch_resolver_working_info = (enable_branch_resolver_unit && finished_branch_resolver_unit == 1'b0);

assign calculated_result_o = calculated_result;       // Assign calculated result, goes to memory step                                                     // Assign calculated result, goes to writeback stage

assign execute_working_info_o =  integer_multiplication_unit_working_info ||                                                                               // Assign execute eorking info                                               
                                 integer_division_unit_working_info;
                                                                  
assign rd_o = rd;                                                                                                                                          // Assign target register goes to memory step
assign register_selection_o = register_selection;                                                                                                          // Assing register selection, goes to memory step
assign is_branch_address_calculated_o = is_branch_address_calculated;                                                                                      // Assign information of whether branch calculated or not
assign calculated_branch_address_o = calculated_branch_result; //calculated_branch_result;                                                                                             // Assign branch address, goes to fetch step
assign write_register_info_o = write_register_info;               
assign forwarded_data_o = calculated_result;                                                                                                               // Assign forwarded data, goes to decode stage
assign forwarded_rd_o = forwarded_rd;                                                                                                                      // Assign forwarded rd, goes to decode stage
 
endmodule 
*/