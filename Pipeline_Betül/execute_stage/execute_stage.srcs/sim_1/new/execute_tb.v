module execute_tb();
    
    reg                                  clk_i;                                     // clock signal
    reg                                  rst_i;                                      // reset signal

    //-------------------------------from memory_stage----------------------------------------------
    reg                                  is_memory_stage_finished_i;                        // memory stage finished signal for Stall

    
    //-------------------------------from decode_stage----------------------------------------------
    
    //olmali mi
    //input wire [31:0] rs2_value_i,        // rs2 register value comes from decode integer register file



    reg             [31:0]              operand1_integer_i;                         // Operand 1 input comes from decode integer register file
    reg             [31:0]              operand2_integer_i;                         // Operand 2 input comes from decode integer register file or from another calculation logic
    
    reg             [31:0]              operand1_float_i;                           // Operand 1 input comes from decode float register file
    reg             [31:0]              operand2_float_i;                           // Operand 2 input comes from decode float register file
    reg             [31:0]              operand3_float_i;                           // Operand 3 input comes from decode float register file
    
    reg             [31:0]              immediate_value_i;                          // generated immediate value from decode stage
    
    reg             [31:0]              program_counter_i;                          // because of address calculate for branch instructions

    reg             [4:0]               which_operation_alu_i;                      // which operation should be executed in ALU 31
    reg             [1:0]               which_operation_mul_i;                      // which operation should be executed in integer multiplication unit 4
    reg             [1:0]               which_operation_div_i;                      // which operation should be executed in integer division unit 4
    reg             [2:0]               which_operation_atomic_i;                   // which operation should be executed in atomic unit 11
    reg             [4:0]               which_operation_floating_point_i;           // which operation should be executed in floating point unit 23
    reg             [4:0]               which_operation_bit_manipulation_i;         // which operation should be executed in bit manipulation unit 32
    reg             [3:0]               which_branch_operation_i;                   // which branch operation should be executed in branch resolver unit 11

    reg                                 enable_alu_unit_i;                          // enable signal for ALU unit
    reg                                 enable_integer_multiplication_unit_i;       // enable signal for integer multiplication unit
    reg                                 enable_integer_division_unit_i;             // enable signal for integer division unit
    reg                                 enable_atomic_unit_i;                       // enable signal for atomic unit
    reg                                 enable_floating_point_unit_i;               // enable signal for floating point unit
    reg                                 enable_bit_manipulation_unit;               // enable signal for bit manipulation unit
    reg                                 enable_branch_resolver_unit_i;              // enable signal for branch resolver unit
    reg                                 enable_control_status_unit_i;               // enable signal for control status unit

    reg                                           aq_i;                                       // acquire signal              
    reg                                           rl_i;                                       // release signal   
    reg                        [4:0]              shamt_i;                                    // shift amount for bit manipulation unit

 /*   reg             [3:0]               unit_selection_i,                           // which unit should be executed
    reg             [4:0]               process_selection_i,                        // in the unit, which instruction should be executed    
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
    wire            [2:0]               memory_operation_type_o;
    wire            [31:0]              memory_write_data_o;                        // data to be written to memory
    wire            [31:0]              calculated_memory_address;                  // memory address to be read or written
    wire                                extension_mode_o;                           // 0 : zero extension, 1 : sign extension for halfword and byte operations

    wire            [31:0]              calculated_result_o;                        // calculated result output, goes to memory step)
    wire            [4:0]               rd_io;                                      // Destination register input from decode step, goes to memory step for write back
    wire            [1:0]               register_type_selection;                    // 0: integer register file, 1: float register file 2:csr register file ?????

    
    //--------------------------to fetch stage--------------------------------------------------------------
    wire                                 is_branched_o;                             // branched or not
    wire            [31:0]               branched_address_o;                        // branched address to be fetched right instruction
    
    // to decode stage for sta
    wire                                 is_execute_finished_o;                       // finish signal


    
    execute_stage ex_tb(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .is_memory_stage_finished_i(is_memory_stage_finished_i),
        .operand1_integer_i(operand1_integer_i),
        .operand2_integer_i(operand2_integer_i),
        .operand1_float_i(operand1_float_i),
        .operand2_float_i(operand2_float_i),
        .operand3_float_i(operand3_float_i),
        .immediate_value_i(immediate_value_i),
        .program_counter_i(program_counter_i),
        .which_operation_alu_i(which_operation_alu_i),
        .which_operation_mul_i(which_operation_mul_i),
        .which_operation_div_i(which_operation_div_i),
        .which_operation_atomic_i(which_operation_atomic_i),
        .which_operation_floating_point_i(which_operation_floating_point_i),
        .which_operation_bit_manipulation_i(which_operation_bit_manipulation_i),
        .which_branch_operation_i(which_branch_operation_i),
        .enable_alu_unit_i(enable_alu_unit_i),
        .enable_integer_multiplication_unit_i(enable_integer_multiplication_unit_i),
        .enable_integer_division_unit_i(enable_integer_division_unit_i),
        .enable_atomic_unit_i(enable_atomic_unit_i),
        .enable_floating_point_unit_i(enable_floating_point_unit_i),
        .enable_bit_manipulation_unit(enable_bit_manipulation_unit),
        .enable_branch_resolver_unit_i(enable_branch_resolver_unit_i),
        .enable_control_status_unit_i(enable_control_status_unit_i),
        .aq_i(aq_i),
        .rl_i(rl_i),
        .shamt_i(shamt_i),
        .memory_operation_type_o(memory_operation_type_o),
        .memory_write_data_o(memory_write_data_o),
        .calculated_memory_address_o(calculated_memory_address),
        .extension_mode_o(extension_mode_o),
        .calculated_result_o(calculated_result_o),
        .rd_io(rd_io),
        .register_type_selection_o(register_type_selection),
        .is_branched_o(is_branched_o),
        .branched_address_o(branched_address_o),
        .is_execute_finished_o(is_execute_finished_o)
    );

    
    always begin
        clk_i = ~clk_i; 
        #0.5;
    end

    initial begin
        clk_i = 0;
        rst_i = 1;
        #1;
        rst_i = 0;

        #1;
        is_memory_stage_finished_i = 1;
        operand1_integer_i = 32'h00000000;
        operand2_integer_i = 32'h00000000;
        operand1_float_i = 32'h00000000;
        operand2_float_i = 32'h00000000;
        operand3_float_i = 32'h00000000;
        immediate_value_i = 32'h00000000;
        program_counter_i = 32'h00000000;
        which_operation_alu_i = 5'b00000;
        which_operation_mul_i = 2'b00;
        which_operation_div_i = 2'b00;
        which_operation_atomic_i = 3'b000;
        which_operation_floating_point_i = 5'h2;
        which_operation_bit_manipulation_i = 5'b00000;
        which_branch_operation_i = 3'b000;
        enable_alu_unit_i = 0;
        enable_integer_multiplication_unit_i = 0;
        enable_integer_division_unit_i = 0;
        enable_atomic_unit_i = 0;
        enable_floating_point_unit_i = 1;
        enable_bit_manipulation_unit = 0;
        enable_branch_resolver_unit_i = 0;
        enable_control_status_unit_i = 0;
        aq_i = 0;
        rl_i = 0;
        shamt_i = 5'b00000;      
    end
    
endmodule
