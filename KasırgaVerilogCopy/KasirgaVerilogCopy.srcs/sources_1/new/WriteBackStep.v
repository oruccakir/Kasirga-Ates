// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v
include "definitions.vh";
module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] calculated_result_i,// it comes from other steps,
    input wire [4:0] rd_i, // writeback target register
    output wire writeback_finished_o, // Flag for finishing writeback step
    output wire [31:0] writebacked_result_o, // final result after all calculations
    output wire reg_write_integer_o, // flag to write integer register
    output wire reg_write_float_o, // flag to write float register
    output wire reg_write_csr_o, //  flag to write csr register
    output writeback_working_info_o, // working info for writeback step
    output wire [4:0] rd_o           // target register 
);

reg writeback_working_info; // working info for writeback step will conveyed to memory step for stalling operation
reg reg_write_integer = 1'b0; // flag to write integer register will conveyed to decode
reg reg_write_float = 1'b0; // flag to write float register will conveyed to decode
reg reg_write_csr = 1'b0; // flag to write csr register will conveyed to decode
reg writeback_finished = 1'b0; // Flag for finishing writeback step
wire isWorking; // Flag for working for this step 
reg [31:0] writebacked_result = 32'b0; // writeback result that will be conveyed to decode step
localparam FIRST_CYCLE = 3'b000;  // State for first cycle
localparam SECOND_CYCLE = 3'b001; // State for second cycle
localparam STALL = 3'b010;        // State for stalling operation. However there will not be stall here 
reg [2:0] STATE = FIRST_CYCLE;    // State for the module
integer i = 1; // For debugging the instruction number

assign isWorking = enable_step_i && writeback_finished != 1'b1; // Assign isWorking for this step

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin
                writeback_working_info = 1'b1;
                $display(" WRITEBACK STEP Writing back to register file %d",calculated_result_i," for instruction %d",i);
                writebacked_result = calculated_result_i; 
                reg_write_integer = 1'b1;
                STATE = SECOND_CYCLE;
            end
            SECOND_CYCLE : begin
                $display("-->Writeback completed for instruction num %d",i);
                $display("Writebacked result %d",writebacked_result);
                writeback_finished = 1'b1;
                reg_write_integer = 1'b0;
                i=i+1;
                STATE = FIRST_CYCLE;
                writeback_working_info = 1'b0;
            end
        endcase
    end
end

assign writeback_finished_o = writeback_finished; // Assign writeback_finished
assign writebacked_result_o = writebacked_result; // Assign calculated result, goes to decode step
assign reg_write_integer_o = reg_write_integer; // Assign write flag for integer register, goes to decode step
assign reg_write_float_o = reg_write_float;     // Assign write flag for float register, goes to decode step
assign reg_write_csr_o = reg_write_csr;         // Assign write flag for csr register, goes to decode step
assign writeback_working_info_o = writeback_working_info; // Assign working info for writeback step, goes to memory step
assign rd_o = rd_i;                               // Assign target register , goes to decode step

endmodule

