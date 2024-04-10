// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

include "definitions.vh";

module MemoryStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire [31:0]data_i, // comes from memory
    input wire [3:0] unit_type_i,
    input wire enable_step_i, // Enable input
    input wire data_completed_i, // data completed comes from helper memory
    input wire mem_instruction_i,
    input wire mem_read_enable_i, // Memory read enable input
    input wire mem_write_enable_i, // Memory write enable input
    input wire [2:0] memOp_i, // Memory operation input
    input wire [31:0] calculated_result_i, // this comefrom execute1 step
    input wire writeback_working_info_i,
    input wire [4:0] rd_i, // come from execute step
    input wire [31:0] mem_data_i, // come from execute step goes to processor then memory
    output wire [31:0] mem_data_o, // Memory data output
    output wire [31:0] mem_address_o, // Memory address output
    output wire memory_finished_o, // Flag for finishing memory step
    output wire [31:0] calculated_result_o, // this will convey to writeback step
    output wire memory_working_info_o,
    output wire [4:0] rd_o, // goes to writeback step
    output wire write_enable_o, // goes to processor from there goes to helper memory
    output wire read_enable_o
);

reg memory_working_info = 1'b0; // Working info for memory step

reg write_enable = 1'b0;
reg read_enable = 1'b0;

// MemoryStep module implementation

reg [31:0] mem_data = 32'h0; // Memory data
reg [31:0] mem_address = 32'h0; // Memory address
wire isWorking; // Flag for working

reg [31:0] calculated_result = 32'b0; // Calculated result

reg [4:0] rd = 5'b0;

reg memory_finished = 1'b0; // Flag for finishing memory step // impoertant change

localparam FIRST_CYCLE = 3'b000; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b001; // State for memory operation result
localparam STALL = 3'b010;

reg [2:0] STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && memory_finished != 1'b1; // Assign isWorking

integer i = 1; // For debugging the instruction number

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE:begin
                if(writeback_working_info_i) begin
                    $display("WRITEBACK STILL WORKING");
                    STATE = STALL;
                end
                else begin
                    $display("MEMORY STEP for ",i);
                    memory_working_info = 1'b1;
                    calculated_result = calculated_result_i;
                    mem_address = calculated_result_i;
                    mem_data = mem_data_i;
                    $display("-->Performing memory operation for instruction num %d",i);
                    $display("--> INFO comes from execute step %d",calculated_result_i);
                    if(unit_type_i == `MEMORY_STEP) begin
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
                    STATE <= SECOND_CYCLE; // Go to the second cycle
                end
            end
            SECOND_CYCLE:begin
                if(unit_type_i == `MEMORY_STEP) begin
                    case(memOp_i)
                        `MEM_SW: begin
                            write_enable = 1'b0;
                            $display("NO WRITE !!!!");
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
                $display("-->Memory operation completed for instruction %d",i);
                i=i+1;
                memory_finished <=1; // Set memory_finished to 1
                STATE <= FIRST_CYCLE; // Go to the first cycle
                memory_working_info = 1'b0;
            end
            STALL: begin
                $display("STALL FOR MEMORY");
                STATE = FIRST_CYCLE;
            end
        endcase
    end
end

assign mem_data_o = mem_data; // Assign the memory data
assign mem_address_o = mem_address; // Assign the memory address
assign memory_finished_o = memory_finished;     // Assign the flag for finishing memory step
assign calculated_result_o = calculated_result; // Assign conveyed info
assign memory_working_info_o = memory_working_info; // assign memory working info
assign rd_o = rd;
assign write_enable_o = write_enable;
assign read_enable_o = read_enable;
endmodule