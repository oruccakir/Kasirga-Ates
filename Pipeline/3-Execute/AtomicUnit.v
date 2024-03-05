// Purpose: Atomic unit for the execute stage of the pipeline.
// Functionality: This module performs atomic operations.
// File: AtomicUnit.v


module AtomicUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [3:0] atomicOp_i, // Atomic operation input
);

endmodule