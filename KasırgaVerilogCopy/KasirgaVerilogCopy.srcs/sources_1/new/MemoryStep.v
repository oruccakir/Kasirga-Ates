// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

include "definitions.vh";

module MemoryStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire [31:0] data_i, // comes from memory that will assign to calculated result 
    input wire [3:0] unit_type_i, // comes from execute step indicate memory operations
    input wire enable_step_i, // Enable input
    input wire data_completed_i, // data completed comes from helper memory
    input wire mem_read_enable_i, // Memory read enable input
    input wire mem_write_enable_i, // Memory write enable input
    input wire [2:0] memOp_i, // Memory operation input
    input wire [31:0] calculated_result_i, // this comes from execute1 step
    input wire [4:0] rd_i, // target register comes from execute step
    input wire [31:0] mem_stored_data_i, // comes from execute step, indicates rs2_value
    input wire [1:0] register_selection_i, // comes from execute step, goes to writeback step
    output wire [31:0] mem_data_o, // Memory data output goes to memory
    output wire [31:0] mem_address_o, // Memory address output goes to memory
    output wire memory_finished_o, // Flag for finishing memory step
    output wire [31:0] calculated_result_o, // calculated_result this will conveyed to writeback step
    output wire memory_working_info_o,       // memory working info, goes to execute step
    output wire [4:0] rd_o,    // target register goes to writeback step
    output wire write_enable_o, // goes to processor from there goes to helper memory
    output wire read_enable_o,   // read enable output goes to processor from there goes to memory
    output wire [1:0] register_selection_o // register selection output goes to writeback step
);

reg memory_working_info = 1'b0; // Working info for memory step, goes to execute step
reg write_enable = 1'b0;        // write info goes to memory
reg read_enable = 1'b0;         // read info goes to memory
reg [31:0] mem_data = 32'h0;    // Memory data goes to memory
reg [31:0] mem_address = 32'h0; // Memory address goes to memory
wire isWorking;                 // Flag for working for this step
reg [31:0] calculated_result = 32'b0; // Calculated result will conveyed to 
reg [4:0] rd = 5'b0;                  // target register goes to writeback step
reg memory_finished = 1'b0;     // Flag for finishing memory step // impoertant change
integer i = 1;                  // For debugging the instruction number
reg [1:0] register_selection = 2'b0;  // register selection info, will be conveyed to writeback step

localparam FIRST_CYCLE = 3'b000; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b001; // State for memory operation result
localparam STALL = 3'b010;        // State for stalling later will be deleted because writeback step will implemented without cycle logic
reg [2:0] STATE = FIRST_CYCLE;    // State for stalling the module

assign isWorking = enable_step_i && memory_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE:begin
                $display("MEMORY STEP for ",i);
                memory_working_info = 1'b1;
                calculated_result = calculated_result_i;
                mem_address = calculated_result_i;
                mem_data = mem_stored_data_i;
                $display("-->Performing memory operation for instruction num %d",i);
                $display("--> INFO comes from execute step %d",calculated_result_i);
                if(unit_type_i == `MEMORY_UNIT) begin
                    case(memOp_i)
                        `MEM_SW: begin
                            write_enable = 1'b1;
                            $display("Memory SW Instruction writed address %h",mem_address);
                         end
                        `MEM_LW: begin
                            read_enable = 1'b1;
                            $display("Memory LW Instruction readed address %h",mem_address);
                         end
                        `MEM_LB: begin
                         end
                        `MEM_LH: begin
                         end
                        `MEM_LBU: begin
                         end
                        `MEM_LHU: begin
                         end
                        `MEM_SB: begin
                         end
                        `MEM_SH: begin
                         end
                    endcase
                end
               // rd = rd_i;
                STATE <= SECOND_CYCLE;
            end
            SECOND_CYCLE:begin
                if(unit_type_i == `MEMORY_UNIT) begin
                    case(memOp_i)
                        `MEM_SW: begin
                            write_enable = 1'b0;
                         end
                        `MEM_LW: begin
                            read_enable = 1'b0;
                            $display("data completed ",data_completed_i);
                            $display("From Memory readed %h",data_i);
                            calculated_result = data_i;
                         end
                        `MEM_LB: begin
                         end
                        `MEM_LH: begin
                         end
                        `MEM_LBU: begin
                         end
                        `MEM_LHU: begin
                         end
                        `MEM_SB: begin
                         end
                        `MEM_SH: begin
                         end
                    endcase
                end
                rd = rd_i;
                register_selection = register_selection_i;
                $display("-->Memory operation completed for instruction %d",i);
                i=i+1;
                memory_finished =1; 
                STATE = FIRST_CYCLE; 
                memory_working_info = 1'b0;
            end
            STALL: begin
                $display("STALL FOR MEMORY");
                STATE = FIRST_CYCLE;
            end
        endcase
    end
end

assign mem_data_o = mem_data;                       // Assign the memory data, goes to memory
assign mem_address_o = mem_address;                 // Assign the memory address, goes to memory
assign memory_finished_o = memory_finished;         // Assign the flag for finishing memory step
assign calculated_result_o = calculated_result;     // Assign result info, goes to writeback step
assign memory_working_info_o = memory_working_info; // Assign memory working info, goes to execute step
assign rd_o = rd;                                   // Assign target register, goes to writeback step
assign write_enable_o = write_enable;               // Assign write_enable, goes to memory
assign read_enable_o = read_enable;                 // Assign read_enable, goes to mempory
assign register_selection_o = register_selection;   // Assign register selection, goes to writeback step
endmodule