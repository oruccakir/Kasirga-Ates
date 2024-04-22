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
   register_file[0]  <= 32'd0;
   register_file[1]  <= 32'd1;
   register_file[2]  <= 32'd2;
   register_file[3]  <= 32'd3;
   register_file[4]  <= 32'd4;
   register_file[5]  <= 32'd5;
   register_file[6]  <= 32'd6;
   register_file[7]  <= 32'd7;
   register_file[8]  <= 32'd8;
   register_file[9]  <= 32'd9;
   register_file[10] <= 32'd10;
   register_file[11] <= 32'd11;
   register_file[12] <= 32'd12;
   register_file[13] <= 32'd13;
   register_file[14] <= 32'd14;
   register_file[15] <= 32'd15;
   register_file[16] <= 32'd16;
   register_file[17] <= 32'd17;
   register_file[18] <= 32'd18;
   register_file[19] <= 32'd19;
   register_file[20] <= 32'd20;
   register_file[21] <= 32'd21;
   register_file[22] <= 32'd22;
   register_file[23] <= 32'd23;
   register_file[24] <= 32'd24;
   register_file[25] <= 32'd25;
   register_file[26] <= 32'd26;
   register_file[27] <= 32'd27;
   register_file[28] <= 32'd28;
   register_file[29] <= 32'd29;
   register_file[30] <= 32'd30;
   register_file[31] <= 32'd31;
end
  else if(reg_write_i && (rd_i !=0))begin
    register_file[rd_i] <= write_data_i;
    $display("Integer writed result",write_data_i); // writed result stored here
    $display("Target register ",rd_i);              // writed result stored 
  end
end
endmodule
