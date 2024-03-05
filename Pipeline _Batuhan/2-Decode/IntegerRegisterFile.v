// File: IntegerRegisterFile.v
// Purpose: Define a module for the integer register file

module IntegerRegisterFile (  
  input wire clk_i, // clock signal
  input wire rst_i, // reset signal
  input wire [4:0] rs1_i, // read register 1
  input wire [4:0] rs2_i, // read register 2
  input wire [4:0] rd_i,  // write register
  input wire [31:0] write_data_i, // data to write
  input wire reg_write_i, // write enable
  output wire [31:0] read_data1_o, // data from read register 1
  output wire [31:0] read_data2_o // data from read register 2
);

  reg [31:0] registers [31:0]; // 32 registers for integer data

  assign read_data1_o = registers[rs1]; // read data from register 1
  assign read_data2_o = registers[rs2]; // read data from register 2

  always @(posedge clk_i or posedge rst_i) begin // synchronous reset
    if (rst_i) begin 
      registers <= 0; // reset all registers
    end else if (reg_write && rd_i != 0) begin // write to register 0 is not allowed
      registers[rd] <= write_data_i; // write data to register
    end
  end

endmodule
