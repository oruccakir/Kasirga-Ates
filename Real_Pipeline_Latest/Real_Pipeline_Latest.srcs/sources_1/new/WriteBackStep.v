// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v
include "definitions.vh";
module WriteBackStep (
    input wire clk_i,                                            // Clock input
    input wire rst_i,                                            // Reset input
    input wire [31:0] calculated_result_i,                       // Calculated result, comes from execute step
    input wire [4:0] rd_i,                                       // Target register, comes from decode step via execute step
    input wire [1:0] register_selection_i,                       // Register selection, comes from decode step  via execute step
    input wire [2:0] write_register_info_i,                      // Write register info, comes from decode step via execute step
    output wire [31:0] writebacked_result_o,                     // Writebacked result, goes to decode step
    output wire reg_write_integer_o,                             // Write integer register, goes to decode step
    output wire reg_write_float_o,                               // Write float register, goes to decode step
    output wire reg_write_csr_o,                                 // Write csr register, goes to decode step
    output wire [4:0] rd_o                                       // Target register, goes to decode step
);


integer i=-1;                                                    // for debugging the which instruction is fetched and conveyed
// Debugging purpose
always@(*) begin
    $display("@@ WRITEBACK STAGE writebacked result %d ", calculated_result_i ,"for instruction %d ",i);
    i=i+1;                                                       // increment counter when new instruction comes
end


assign writebacked_result_o = calculated_result_i;               // Assign calculated result, goes to decode step
assign reg_write_integer_o = write_register_info_i[2];           // Assign register write info, goes to decode step
assign reg_write_float_o = write_register_info_i[1];             // Assign register write info, goes to decode step
assign reg_write_csr_o = write_register_info_i[0];               // Assign register write info, goes to decode step
assign rd_o = rd_i;                                              // Assign target register , goes to decode step 


endmodule

