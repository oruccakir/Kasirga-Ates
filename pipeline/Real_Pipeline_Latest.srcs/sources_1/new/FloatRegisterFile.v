// File: FloatRegisterFile.v
// Purpose: Define a module for the floating-point register file

include "definitions.vh";

module FloatRegisterFile(  
  input wire clk_i, // clock signal
  input wire rst_i, // reset signal
  input wire [4:0] rs1_i, // read register 1
  input wire [4:0] rs2_i, // read register 2
  input wire [4:0] rs3_i, // read register 3
  input wire [4:0] rd_i,  // write register
  input wire [31:0] write_data_i, // data to write
  input wire reg_write_i, // write enable
  output wire [31:0] read_data1_o, // data from read register 1
  output wire [31:0] read_data2_o, // data from read register 2
  output wire [31:0] read_data3_o // data from read register 3
);

  reg [31:0] registers [31:0]; // 32 registers for float data
  
  initial begin
    registers[0] = 0; registers[1] = 0; registers[2] = 0; registers[3] = 0; 
      registers[4] = 0; registers[5] = 0; registers[6] = 0; registers[7] = 0;
      registers[8] = 0; registers[9] = 0; registers[10] = 0; registers[11] = 0; 
      registers[12] = 0; registers[13] = 0; registers[14] = 0; registers[15] = 0;
      registers[16] = 0; registers[17] = 0; registers[18] = 0; registers[19] = 0; 
      registers[20] = 0; registers[21] = 0; registers[22] = 0; registers[23] = 0;
      registers[24] = 0; registers[25] = 0; registers[26] = 0; registers[27] = 0; 
      registers[28] = 0; registers[29] = 0; registers[30] = 0; registers[31] = 0;
  end
  
  assign read_data1_o = registers[rs1_i]; // read data from register 1
  assign read_data2_o = registers[rs2_i]; // read data from register 2
  assign read_data3_o = registers[rs3_i]; // read data from register 2

  always @(posedge clk_i or posedge rst_i) begin // synchronous reset
    if (rst_i) begin 
      // reset all registers
      registers[0] <= 0; registers[1] <= 0; registers[2] <= 0; registers[3] <= 0; 
      registers[4] <= 0; registers[5] <= 0; registers[6] <= 0; registers[7] <= 0;
      registers[8] <= 0; registers[9] <= 0; registers[10] <= 0; registers[11] <= 0; 
      registers[12] <= 0; registers[13] <= 0; registers[14] <= 0; registers[15] <= 0;
      registers[16] <= 0; registers[17] <= 0; registers[18] <= 0; registers[19] <= 0; 
      registers[20] <= 0; registers[21] <= 0; registers[22] <= 0; registers[23] <= 0;
      registers[24] <= 0; registers[25] <= 0; registers[26] <= 0; registers[27] <= 0; 
      registers[28] <= 0; registers[29] <= 0; registers[30] <= 0; registers[31] <= 0;
      
      
    end 
    else if (reg_write_i && rd_i != 0) begin // write to register 0 is not allowed
      registers[rd_i] <= write_data_i; // write data to register
    end
  end

 

endmodule

