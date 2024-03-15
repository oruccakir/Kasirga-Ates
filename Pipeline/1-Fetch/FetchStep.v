// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

include "definitions.vh";

module FetchStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire decode_working_info_i, // very important info for stalling
    input wire [31:0] instruction_i, // Instruction output
    output wire [31:0] mem_address_o, // Memory address output
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o, // instruction that will be conveyed to decode step 
    output wire fetch_working_info_o  // for now this is unnecessary
);

reg fetch_working_info = 1'b0;  // working info for fetch step

reg [31:0] instruction_to_decode = 32'b0; // instruction that will be convetyed to decode step

// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000;  // program counter to access memory, data and instructions
reg fetch_finished = 1'b0;       // flag for fetch finished info
wire isWorking;                  // controling signal for working of this step

localparam FIRST_CYCLE = 3'b000;     // first state
localparam SECOND_CYCLE = 3'b001;    // secodn state
localparam STALL = 3'b010;           // stall state

reg [2:0] STATE = FIRST_CYCLE;      // set first state as first state

integer i = 1; // for debugging the which instruction is fetched and conveyed

assign isWorking = enable_step_i && fetch_finished != 1'b1;          // assign working info depending of enable and finish info

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin
                fetch_working_info = 1'b1;
                $display("FETCH STEP Fetching instruction from memory %h", program_counter, " for instruction %d",i); 
                STATE <= SECOND_CYCLE;
            end
            SECOND_CYCLE : begin
                if(decode_working_info_i) begin
                    $display("DECODE STILL WORKING FETCH WAITING");
                    STATE = STALL;
                end
                else begin
                    $display("FETCH STEP Fetched Instruction %h", instruction_i," for instruction %d",i);
                    i = i+1;
                    instruction_to_decode <= instruction_i;
                    STATE <= FIRST_CYCLE;
                    program_counter <= program_counter + 4;
                    fetch_finished <= 1'b1;
                    fetch_working_info = 1'b0;
                end 
            end  
            STALL : begin
                $display("STALL FOR FETCH");
                STATE = SECOND_CYCLE;
            end 
        endcase  
    end  
end 

assign mem_address_o = program_counter;
assign fetch_finished_o = fetch_finished;
assign instruction_to_decode_o = instruction_to_decode;
assign fetch_working_info_o = fetch_working_info;

endmodule