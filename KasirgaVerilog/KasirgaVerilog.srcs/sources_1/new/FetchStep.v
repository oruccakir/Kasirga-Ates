// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] mem_address_i, // Memory address input
    output wire [31:0] instruction_o // Instruction output
);

// FetchStep module implementation
always @(posedge clk_i) begin
    if(enable_step_i)
        begin
            $display("FetchStep: Fetching instruction from memory %d", instruction_i);
        end
end

endmodule