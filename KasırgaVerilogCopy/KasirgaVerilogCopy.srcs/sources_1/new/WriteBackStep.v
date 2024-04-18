// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v
include "definitions.vh";
module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire [31:0] calculated_result_i,// it comes from other steps,
    input wire [4:0] rd_i, // writeback target register
    input wire [1:0] register_selection_i, // comes from mempory, depending on this input reg_write signals will be updated
    input wire [2:0] write_register_info_i,
    input instruction_count_i,
    output wire [31:0] writebacked_result_o, // final result after all calculations
    output wire reg_write_integer_o, // flag to write integer register
    output wire reg_write_float_o, // flag to write float register
    output wire reg_write_csr_o, //  flag to write csr register
    output wire [4:0] rd_o,           // target register 
    output instruction_count_o
);

integer i=-1;
always@(*) begin
    $display("@@ WRITEBACK STAGE writebacked result %d ", calculated_result_i ,"for instruction %d ",i);
    /*
        case(register_selection_i) 
        `INTEGER_REGISTER: $display("--->Writing to : INTEGER_REGISTER");
        `FLOAT_REGISTER:  $display("--->Writing to :  FLOAT_REGISTER");
        `CSR_REGISTER:  $display("--->Writing to : CSR_REGISTER");
        `NONE_REGISTER: $display("--->Not Writing : NONE_REGISTER");
    endcase
    */
    i=i+1;
end

assign instruction_count_o = instruction_count_i;
assign writebacked_result_o = calculated_result_i; // Assign calculated result, goes to decode step
assign reg_write_integer_o = write_register_info_i[2];
assign reg_write_float_o = write_register_info_i[1];
assign reg_write_csr_o = write_register_info_i[0];
assign rd_o = rd_i;                               // Assign target register , goes to decode step


endmodule

