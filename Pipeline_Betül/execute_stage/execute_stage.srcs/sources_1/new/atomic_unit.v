

module atomic_unit(
   input                                            clk_i,                              // Clock signal            
   input                                            rst_i,                              // Reset signal                                  
   input                                            enable_atomic_unit_i,                // Start signal for the atomic unit                        
   input                         [31:0]             operand1_i,                         // Operand 1                                    
   input                         [31:0]             operand2_i,                         // Operand 2
   input                         [2:0]              atomicOp_i,                         // Atomic operation (11 instr.) 
   input                                            aq_i,
   input                                            rl_i,                             
   output                        [31:0]             calculated_memory_address_o,        // Calculated memory address                        
   output                        [31:0]             calculated_result_o,                // Calculated result
   output                                           extension_mode_o,                   // Extension mode  0: zero extension, 1: sign extension                        
   output                        [2:0]              au_memory_operation_type_o,         // Memory operation type                    
   output                                           register_type_selection_o,          // Register type selection                                
   output            reg                            finished_o                          // Finished signal                                  
    );
endmodule
