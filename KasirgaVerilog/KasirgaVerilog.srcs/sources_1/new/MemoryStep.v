// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

include "definitions.vh";

module MemoryStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire mem_read_enable_i, // Memory read enable input
    input wire mem_write_enable_i, // Memory write enable input
    input wire [3:0] memOp_i, // Memory operation input
    input wire [31:0] calculated_result_i, // this comefrom execute1 step
    output wire [31:0] mem_data_o, // Memory data output
    output wire [31:0] mem_address_o, // Memory address output
    output wire memory_finished_o, // Flag for finishing memory step
    output wire [31:0] calculated_result_o, // this will convey to writeback step
    output writeback_activate_o
);


reg writeback_activate = 1'b0;
// MemoryStep module implementation

reg [31:0] mem_data = 32'h0; // Memory data
reg [31:0] mem_address = 32'h0; // Memory address
wire isWorking; // Flag for working

reg [31:0] calculated_result = 32'b0;

reg memory_finished = 1'b0; // Flag for finishing memory step

localparam FIRST_CYCLE = 1'b0; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b1; // State for memory operation result

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && memory_finished != 1'b1; // Assign isWorking

integer i = 1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            $display("MEMORY STEP");
            case(STATE)
                FIRST_CYCLE :
                    begin
                        calculated_result <= calculated_result_i;
                        $display("-->Performing memory operation for instruction num %d",i);
                        $display("--> INFO comes from execute step %d",calculated_result_i);
                        STATE <= SECOND_CYCLE; // Go to the second cycle
                    end
                SECOND_CYCLE :
                    begin
                        $display("-->Memory operation completed for instruction %d",i);
                        i=i+1;
                        memory_finished <=1; // Set memory_finished to 1
                        STATE <= FIRST_CYCLE; // Go to the first cycle
                        writeback_activate = 1'b1;
                    end
            endcase
        end
end

assign mem_data_o = mem_data; // Assign the memory data
assign mem_address_o = mem_address; // Assign the memory address
assign memory_finished_o = memory_finished;     // Assign the flag for finishing memory step
assign calculated_result_o = calculated_result; // Assign conveyed info
assign writeback_activate_o = writeback_activate;

endmodule