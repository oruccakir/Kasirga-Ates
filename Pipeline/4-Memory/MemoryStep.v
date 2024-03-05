// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

// Include the definitions file
`include "Pipeline\definitions.vh"

module MemoryStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire [3:0] memOp_i; // Memory operation input
);

endmodule