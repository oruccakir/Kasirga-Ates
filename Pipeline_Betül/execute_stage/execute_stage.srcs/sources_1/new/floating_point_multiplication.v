`timescale 1ns / 1ps
module floating_point_multiplication(
   input                         clk_i,
   input                         rst_i,
   input                         enable_floating_point_multiplication_i,
   input               [31:0]    multiplication_operand_1_i,
   input               [31:0]    multiplication_operand_2_i,
   output    reg       [31:0]    result_o,
   output    reg                 finished_o
);






/* yanlýþ iþlemler sadece yürütü denemek icindi
reg [31:0] result;
reg cycle=0, cycle_s;
reg is_floating_point_multiplication_finished=0;
always@(*) begin
   result=result_o;
   cycle_s=cycle;
   is_floating_point_multiplication_finished=finished_o;
   if(enable_floating_point_multiplication_i)begin
      case(cycle_s)
         1'b0: begin
            result[31:16]=multiplication_operand_1_i[31:16]*multiplication_operand_2_i[31:16];
            cycle_s=1'b1;
         end
         1'b1: begin 
            result[15:0]=multiplication_operand_1_i[15:0]*multiplication_operand_2_i[15:0];
            cycle_s=0;
            is_floating_point_multiplication_finished=1'b1;
         end
      endcase
   end
end


always@(posedge clk_i) begin
      if(enable_floating_point_multiplication_i)begin
           result_o<=result;
           cycle<=cycle_s;
           finished_o<=is_floating_point_multiplication_finished;
      end
      else begin
           finished_o<=1'b0;
      end
end*/
endmodule
