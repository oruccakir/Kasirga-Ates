// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

include "definitions.vh";

module FetchStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction output
    output wire [31:0] mem_address_o, // Memory address output
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o
);

// decode
reg [31:0] instruction_to_decode = 32'b0;


// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000;
reg fetch_finished = 1'b0;
wire isWorking;

localparam FIRST_CYCLE = 1'b0;
localparam SECOND_CYCLE = 1'b1;

reg STATE = FIRST_CYCLE;

integer i = 1;

assign isWorking = enable_step_i && fetch_finished != 1'b1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            $display();
            case(STATE)
                FIRST_CYCLE : begin
                    $display("FETCH STEP Fetching instruction from memory %h", program_counter);
                    $display("Instruction num : %d",i);
                    STATE <= SECOND_CYCLE;
                end
                SECOND_CYCLE : begin
                    $display("FETCH STEP Fetched Instruction %h", instruction_i); 
                    i = i+1;
                    instruction_to_decode <= instruction_i;
                    STATE <= FIRST_CYCLE;
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