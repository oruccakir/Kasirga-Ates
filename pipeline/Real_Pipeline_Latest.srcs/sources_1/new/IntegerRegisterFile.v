// File: IntegerRegisterFile.v
// Purpose: Define a module for the integer register file

`timescale 1ns / 1ps

`include "definitions.vh"

module IntegerRegisterFile #(stack_address = 32'h0000_0000) (  
  input wire         clk_i,          // clock signal
  input wire         rst_i,          // reset signal
  input wire         reg_write_i,    // write enable

  input wire         change_int_reg_state_i,
  input wire [4:0]   decode_rd_state_i,
  input wire [4:0]   rs1_i,          // read register 1
  input wire [4:0]   rs2_i,          // read register 2
  input wire [4:0]   rd_i,           // write register
  input wire [31:0]  write_data_i,   // data to write

  output wire        read_reg1_state_o,
  output wire        read_reg2_state_o,
  
  output wire [31:0] read_data1_o,   // data from read register 1
  output wire [31:0] read_data2_o    // data from read register 2
);

reg [31:0] register_file [31:0];
reg [31:0] register_states; 

assign read_reg1_state_o = register_states[rs1_i];
assign read_reg2_state_o = register_states[rs2_i];

assign read_data1_o = register_file[rs1_i];
assign read_data2_o = register_file[rs2_i];

integer i = 0;

always@(posedge clk_i) begin
  if(rst_i)begin
    for(i=0; i<32; i=i+1)begin
      register_states   <= `WRITING_COMPLETED;
    end
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
    register_states[rd_i] <= `WRITING_COMPLETED;
    $display("Integer writed result",write_data_i); // writed result stored here
    $display("Target register ",rd_i);              // writed result stored 
  end 
  if (change_int_reg_state_i) begin
    register_states[decode_rd_state_i] <= `WRITING_IN_PROGRESS; 
  end
end
endmodule

/*
// File: IntegerRegisterFile.v
// Purpose: Define a module for the integer register file

include "definitions.vh";

module IntegerRegisterFile (  
  input wire clk_i, // clock signal
  input wire rst_i, // reset signal
  input wire [4:0] rs1_i, // read register 1
  input wire [4:0] rs2_i, // read register 2
  input wire [4:0] rd_i,  // write register
  input wire [31:0] write_data_i, // data to write
  input wire reg_write_i, // write enable
  input wire [4:0] rd_state_i, // for changing register state
  input wire change_integer_register_state_i, // for changing register state
  output wire [31:0] read_data1_o, // data from read register 1
  output wire [31:0] read_data2_o, // data from read register 2
  output wire read_rs1_state_o,
  output wire read_rs2_state_o
);

reg [31:0] registers [31:0];
reg [31:0] registers_state;
  
integer i = 0;
initial begin


    
  registers[0] = 0; registers[1] = 0; registers[2] = 0; registers[3] = 0; 
  registers[4] = 0; registers[5] = 0; registers[6] = 0; registers[7] = 0;
  registers[8] = 0; registers[9] = 0; registers[10] = 0; registers[11] = 5; 
  registers[12] = 0; registers[13] = 0; registers[14] = 0; registers[15] = 32'd60;
  registers[16] = 0; registers[17] = 48; registers[18] = 0; registers[19] = 0; 
  registers[20] = 0; registers[21] = 0; registers[22] = 0; registers[23] = 0;
  registers[24] = 0; registers[25] = 0; registers[26] = 0; registers[27] = 0; 
  registers[28] = 0; registers[29] = 0; registers[30] = 0; registers[31] = 0;
  registers[0] = 40;
  registers[5] = 88;
  registers[3] = 22;
  registers[2] = 13;
  registers[6] = 14;
  registers[7] = 55;
  registers[8] = 15;
  registers[9] = 23;
  registers[31] = 32'h8000_0000;
end

assign read_data1_o = registers[rs1_i]; // read data from register 1
assign read_data2_o = registers[rs2_i]; // read data from register 2
assign read_rs1_state_o = registers_state[rs1_i];  // read state info for rs1
assign read_rs2_state_o = registers_state[rs2_i];  // read state info for rs2

always@(change_integer_register_state_i) begin
    $display("Writing in Progess to %d ",rd_state_i);
    registers_state[rd_state_i] = `WRITING_IN_PROGRESS;
end

always@(posedge clk_i) begin
    if(rst_i) begin
        for(i=0; i<32; i=i+1)  begin
            registers_state[i] = `WRITING_COMPLETED;
            //registers[i] = 32'b0; 
        end
    end
    if(rd_i != 0 && reg_write_i) begin
        registers[rd_i] = write_data_i; // write data to register;
        $display("-->INTEGER REGISTER FILE Writed result %d ",registers[rd_i]," Target Register %d ", rd_i);
        registers_state[rd_i] = `WRITING_COMPLETED;
    end
    if(change_integer_register_state_i) begin
        $display("Writing in Progess to %d ",rd_state_i);
        registers_state[rd_state_i] = `WRITING_IN_PROGRESS;
    end
end

endmodule
*/