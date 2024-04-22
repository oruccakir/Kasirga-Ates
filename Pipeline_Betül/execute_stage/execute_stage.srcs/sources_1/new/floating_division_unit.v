module floating_division_unit(
   input                         clk_i,
   input                         rst_i,
   input    wire                 enable_floating_point_division_i,
   input    wire       [31:0]    division_operand_1_i,
   input    wire       [31:0]    division_operand_2_i,
   output   reg        [31:0]    result_o,
   output   reg                  finished_o
);

endmodule
