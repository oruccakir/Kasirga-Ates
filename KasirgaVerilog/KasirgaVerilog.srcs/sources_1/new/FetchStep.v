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
    output wire [31:0] instruction_to_decode_o
);

// Output signals to decode stage
reg [31:0] instruction_to_decode = 32'b0;


// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000;
reg fetch_finished = 1'b0;
wire isWorking;

localparam INS_DESIRE = 1'b0;
localparam INS_RESULT = 1'b1;

reg STATE = INS_DESIRE;

assign isWorking = enable_step_i && fetch_finished != 1'b1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                INS_DESIRE : begin
                    $display("FetchStep: Fetching instruction from memory %h", program_counter);
                    STATE = INS_RESULT;
                end
                INS_RESULT : begin
                    $display("Instruction %h", instruction_i); 
                    instruction_to_decode = instruction_i;
                    STATE = INS_DESIRE;
                    program_counter <= program_counter + 4;
                    fetch_finished <= 1'b1;
                end
            endcase
        end
end

assign mem_address_o = program_counter;
assign fetch_finished_o = fetch_finished;
assign instruction_to_decode_o = instruction_to_decode;

endmodule