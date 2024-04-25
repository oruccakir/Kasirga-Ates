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


// yanlýþ iþlemler sadece yürütü denemek icindi
    reg [4:0] cycle=0, cycle_s=0;
    reg finished_s=0;
    
    always@(*) begin
        cycle_s=cycle;
        if(enable_floating_point_multiplication_i)begin
            if(cycle_s<31) begin
                cycle_s=cycle_s+1;
                finished_s=0;
            end else begin
                finished_s=1;           
            end
        
        end
    
    
    end
    
    always@(posedge clk_i)begin
        cycle<=cycle_s;
        finished_o<=finished_s;
    
    
    end
endmodule
