module arithmetic_logic_unit(
   input                                            clk_i,
   input                                            rst_i,
   input                                            enable_alu_unit_i,                       // Start signal for the ALU unit
   input                       [31:0]               operand1_i,                             // Operand 1                  
   input                       [31:0]               operand2_i,                             // Operand 2
   input                       [31:0]               immediate_value_i,                      // Immediate value
   input                       [31:0]               program_counter_i,                      // Program counter
   input                       [4:0]                aluOp_i,                                // ALU operation (20 instr.)               
   output                      [31:0]               calculated_memory_address_o,              // Calculated memory address
   output                      [31:0]               calculated_result_o,                    // Calculated result                  
   output                                           extension_mode_o,                       // Extension mode  0: zero extension, 1: sign extension
   output                      [2:0]                memory_operation_type_o,                // Memory operation type            
   output                                           register_type_selection_o,              // Register type selection
   output                      reg                  finished_o                              // Finished signal
);





endmodule