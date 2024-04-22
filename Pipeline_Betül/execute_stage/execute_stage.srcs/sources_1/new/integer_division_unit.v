module integer_division_unit(
   input                                                                    clk_i,
   input                                                                    rst_i,
   input                                                                    enable_integer_division_unit_i,
   input                                      [1:0]                         divOp_i,
   input                                      [31:0]                        operand1_i,
   input                                      [31:0]                        operand2_i,
   output                                     [31:0]                        result_o,
   output                                                                   register_type_selection_o,
   output              reg                                                  finished_o

    );
endmodule
