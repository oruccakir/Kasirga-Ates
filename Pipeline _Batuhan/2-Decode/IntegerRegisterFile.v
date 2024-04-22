// File: IntegerRegisterFile.v
// Purpose: Define a module for the integer register file

`timescale 1ns / 1ps

`include "definitions.vh"

module IntegerRegisterFile #(stack_address = 32'h0000_0000) (  
  input wire         clk_i,          // clock signal
  input wire         rst_i,          // reset signal
  input wire         reg_write_i,    // write enable

  input wire [4:0]   rs1_i,          // read register 1
  input wire [4:0]   rs2_i,          // read register 2
  input wire [4:0]   rd_i,           // write register
  input wire [31:0]  write_data_i,   // data to write

  output wire [31:0] read_data1_o,   // data from read register 1
  output wire [31:0] read_data2_o    // data from read register 2
);

reg [31:0] register_file [31:0]; 

assign read_data1_o = register_file[rs1_i];
assign read_data2_o = register_file[rs2_i];

always@(posedge clk_i) begin
  if(rst_i)begin
   register_file[0] <= 0;
   register_file[2] <= stack_address;
end
  else if(reg_write_i && (rd_i !=0))begin
    register_file[rd_i] <= write_data_i;
    $display("Integer writed result",write_data_i); // writed result stored here
    $display("Target register ",rd_i);              // writed result stored 
  end
end
endmodule
