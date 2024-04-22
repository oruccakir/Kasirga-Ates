module bit_manipulation_unit(
   input                                                clk_i,                                                  // Clock signal 
   input                                                rst_i,                                                  // Reset signal     
   input                                                enable_bit_manipulation_unit,                            // Start signal for the bit manipulation unit
   input                   [31:0]                       operand1_i,                                             // Operand 1                                                  
   input                   [31:0]                       operand2_i,                                             // Operand 2
   input                   [31:0]                       immediate_value_i,                                      // Immediate value            
   input                   [4:0]                        shamt_i,                                                // Shift amount (5 bit)
   input                   [4:0]                        bmuOp_i,                                                // Bit manipulation operation (32 instr.)                               
   output                  [31:0]                       result_o,                                               // Result            
   output                                               register_type_selection_o,                              // Register type selection              
   output      reg                                      finished_o                                              // Finished signal
    );  
endmodule
