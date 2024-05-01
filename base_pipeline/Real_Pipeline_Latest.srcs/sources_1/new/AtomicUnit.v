
// Purpose: Atomic unit for the execute stage of the pipeline.
// Functionality: This module performs atomic operations.
// File: AtomicUnit.v
include "definitions.vh";
module AtomicUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire data_completed_i,
    input wire [31:0] mem_address_i,
    input wire [31:0] data_i,
    input wire [31:0] mem_stored_data_i,
    input wire [4:0] atomicOp_i, // Atomic operation input
    output wire [31:0] mem_address_o,
    output wire [31:0] mem_data_o,
    output wire [31:0] mem_data_for_writeback_o,
    output wire is_finished_o,  // finished output
    output wire write_enable_o, // goes to processor from there goes to helper memory
    output wire read_enable_o   // read enable output goes to processor from there goes to memory
);

reg [31:0] result = 32'b0;
reg is_finished = 1'b0;
wire isWorking;

localparam CYCLE1 = 3'b000;
localparam CYCLE2 = 3'b001;
localparam CYCLE3 = 3'b010;
localparam CYCLE4 = 3'b100;
localparam CYCLE5 = 3'b101;

reg [2:0] STATE = CYCLE1;

assign isWorking = (enable_i && is_finished != 1'b1);

always@(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            CYCLE1: begin
            
            end
            CYCLE2: begin
            
            end
            CYCLE3: begin
            
            end
            CYCLE4: begin
            
            end
            CYCLE5: begin
                STATE = CYCLE1;
                is_finished = 1'b1;
            end
        endcase
    end
end

assign is_finished_o = is_finished;

endmodule
