module floating_addition_unit(
   input                         clk_i,
   input                         rst_i,
   input    wire                 enable_floating_point_addition_i,
   input    wire       [31:0]    addition_operand_1_i,
   input    wire       [31:0]    addition_operand_2_i,
   input    wire                 add_or_sub_i,
   output   reg        [31:0]    result_o,
   output   reg                  finished_o
);

/* yanlýþ iþlemler sadece yürütü denemek icindi

always@(*) begin   
    if(enable_floating_point_addition_i)begin
        result_o=addition_operand_1_i+addition_operand_2_i;
        finished_o=1'b1;
    end
end
*/
endmodule

