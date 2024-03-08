// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction output
    output wire [31:0] mem_address_o, // Memory address output
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o // Instruction to decode will convey to the next stage
);

// Instruction to decode needs to be conveyed to the next stage
reg [31:0] instruction_to_decode = 32'b0;


// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000; // Program counter
reg fetch_finished = 1'b0; // Flag for finishing fetch step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for first cycle
localparam SECOND_CYCLE = 1'b1; // State for second cycle

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && fetch_finished != 1'b1; // Assign isWorking

// FetchStep module implementation
always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE : begin
                    $display("FetchStep: Fetching instruction from memory %h", program_counter);
                    STATE <= SECOND_CYCLE;
                end
                SECOND_CYCLE : begin
                    $display("Instruction %h", instruction_i); 
                    instruction_to_decode <= instruction_i; // Convey the instruction to the next stage
                    STATE <= FIRST_CYCLE; // Go back to the first cycle
                    program_counter <= program_counter + 4; // Increment the program counter
                    fetch_finished <= 1'b1; // Set the flag for finishing fetch step
                end
            endcase
        end
end

assign mem_address_o = program_counter; // Assign the program counter to the memory address
assign fetch_finished_o = fetch_finished; // Assign the flag for finishing fetch step
assign instruction_to_decode_o = instruction_to_decode; // Assign the instruction to decode

endmodule