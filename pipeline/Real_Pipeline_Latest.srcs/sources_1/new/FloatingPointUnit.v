`include "definitions.vh"
module FloatingPointUnit(
   input          wire                    clk_i,                              // Clock input
   input          wire                    rst_i,                              // Reset input
   input          wire                    enable_floating_point_unit_i,       // Enable input
   input          wire     [4:0]          float_operation_i,                  // Floating point operation input
   input          wire     [31:0]         operand1_i,                         // Operand 1 input
   input          wire     [31:0]         operand2_i,                         // Operand 2 input
   input          wire     [31:0]         operand3_i,                         // Operand 3 input
   input          wire     [2:0]          rm_i,
   output         reg      [31:0]         fpu_result_o,                       // Result output   
   output         reg                     finished_o   // is floating point unit finished or not     
);

always@ (posedge clk_i) begin
    if(rst_i) begin
        fpu_result_o<=0;
        finished_o<=0;
    end


end

endmodule

