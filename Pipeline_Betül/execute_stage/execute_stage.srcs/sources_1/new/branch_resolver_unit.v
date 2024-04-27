module branch_resolver_unit(
   input                                                clk_i,
   input                                                rst_i,
   input                                                enable_branch_resolver_unit_i,
   input                  [3:0]                         branch_instruction_selection_i,
   input                  [31:0]                        program_counter_i,
   input                  [31:0]                        immediate_value_i,
   input                  [31:0]                        operand1_integer_i,
   input                  [31:0]                        operand2_integer_i,
   input                  [31:0]                        operand1_float_i,
   input                  [31:0]                        operand2_float_i,
   input                  [31:0]                        operand3_float_i,
   output                                               register_type_selection_o,
   output                 [31:0]                        branched_address_o,
   output                                               is_branched_o,
   output     reg                                       finished_o,
   output     reg                                       is_branched_address_valid_o
    );
endmodule
