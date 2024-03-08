// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

module MemoryStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire mem_read_enable_i, // Memory read enable input
    input wire mem_write_enable_i, // Memory write enable input
    input wire [3:0] memOp_i, // Memory operation input
    output wire [31:0] mem_data_o, // Memory data output
    output wire [31:0] mem_address_o, // Memory address output
    output wire memory_finished_o // Flag for finishing memory step
);

// MemoryStep module implementation

reg [31:0] mem_data = 32'h0; // Memory data
reg [31:0] mem_address = 32'h0; // Memory address
wire isWorking; // Flag for working

reg memory_finished = 1'b0; // Flag for finishing memory step

localparam FIRST_CYCLE = 1'b0; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b1; // State for memory operation result

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && memory_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("MemoryStep: Performing memory operation");
                        STATE = SECOND_CYCLE;
                    end
                SECOND_CYCLE :
                    begin
                        $display("MemoryStep: Memory operation completed");
                        memory_finished <=1;
                        STATE = FIRST_CYCLE;
                    end
            endcase
        end
end

assign mem_data_o = mem_data;
assign mem_address_o = mem_address;
assign memory_finished_o = memory_finished;

endmodule