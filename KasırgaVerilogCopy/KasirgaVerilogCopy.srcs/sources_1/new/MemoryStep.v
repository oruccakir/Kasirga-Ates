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
    input wire writeback_working_info_i,
    output wire [31:0] mem_data_o, // Memory data output
    output wire [31:0] mem_address_o, // Memory address output
    output wire memory_finished_o, // Flag for finishing memory step
    output wire [31:0] calculated_result_o, // this will convey to writeback step
    output wire memory_working_info_o
);

reg memory_working_info = 1'b0; // Working info for memory step
reg memory_working_info_next = 1'b0; // Next working info for memory step

// MemoryStep module implementation

reg [31:0] mem_data = 32'h0; // Memory data
reg [31:0] mem_data_next = 32'h0; // Next memory data
reg [31:0] mem_address = 32'h0; // Memory address
reg [31:0] mem_address_next = 32'h0; // Next memory address
wire isWorking; // Flag for working

reg [31:0] calculated_result = 32'b0; // Calculated result
reg [31:0] calculated_result_next = 32'b0; // Next calculated result

reg memory_finished = 1'b0; // Flag for finishing memory step // impoertant change
reg memory_finished_next = 1'b0; // Next flag for finishing memory step

localparam FIRST_CYCLE = 3'b000; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b001; // State for memory operation result
localparam STALL = 3'b010;

reg [2:0] STATE = FIRST_CYCLE; // State for the module
reg [2:0] STATE_NEXT = FIRST_CYCLE; // Next state for the module

assign isWorking = enable_step_i && memory_finished != 1'b1; // Assign isWorking

integer i = 1; // For debugging the instruction number

always @(*) begin
    if(isWorking) begin
        $display("MEMORY STEP");
        case(STATE)
            FIRST_CYCLE:begin
            
                mem_data_next = mem_data;
                mem_address_next = mem_address;
                calculated_result_next = calculated_result;
                memory_finished_next = memory_finished;
                memory_working_info_next = memory_working_info;
                STATE_NEXT = STATE;
            
                memory_working_info_next = 1'b1;
                calculated_result_next = calculated_result_i;
                $display("-->Performing memory operation for instruction num %d",i);
                $display("--> INFO comes from execute step %d",calculated_result_i);
                STATE_NEXT = SECOND_CYCLE; // Go to the second cycle
            end
            SECOND_CYCLE:begin
                if(writeback_working_info_i) begin
                    $display("WRITEBACK STILL WORKING");
                    STATE_NEXT = STALL;
                end
                $display("-->Memory operation completed for instruction %d",i);
                i=i+1;
                memory_finished_next =1; // Set memory_finished to 1
                STATE_NEXT = FIRST_CYCLE; // Go to the first cycle
                memory_working_info_next = 1'b0;
            end
            STALL: begin
                $display("STALL FOR MEMORY");
                STATE_NEXT = SECOND_CYCLE;
            end
        endcase
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        mem_data <= 32'h0;
        mem_address <= 32'h0;
        calculated_result <= 32'h0;
        memory_finished <= 1'b0;
        memory_working_info <= 1'b0;
        STATE <= FIRST_CYCLE;
    end
    else begin
        if(isWorking) begin
            mem_data <= mem_data_next;
            mem_address <= mem_address_next;
            calculated_result <= calculated_result_next;
            memory_finished <= memory_finished_next;
            memory_working_info <= memory_working_info_next;
            STATE <= STATE_NEXT;
        end
    end
end

assign mem_data_o = mem_data; // Assign the memory data
assign mem_address_o = mem_address; // Assign the memory address
assign memory_finished_o = memory_finished;     // Assign the flag for finishing memory step
assign calculated_result_o = calculated_result; // Assign conveyed info
assign memory_working_info_o = memory_working_info; // assign memory working info

endmodule