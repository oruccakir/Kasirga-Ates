// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

include "definitions.vh";

module FetchStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire decode_working_info_i, // very important info for stalling, comes from decode step
    input wire [31:0] instruction_i, // Instruction output, comes from memory via processor
    input wire instruction_completed_i, // this comes from memory, indicates memory completed process of giving instruction data
    output wire [31:0] mem_address_o, // Memory address output, goes to memory
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o, // instruction that will be conveyed to decode step 
    output wire get_instruction_o              // this is the fetching instruction desire from memory
);

reg fetch_working_info = 1'b0;  // working info for fetch step
reg get_instruction = 1'b0;     // desire for fetch, goes to memory
reg [31:0] instruction_to_decode = 32'b0; // instruction that will be convetyed to decode step
reg [31:0] program_counter = 32'h8000_0000;  // program counter to access memory, data and instructions
reg fetch_finished = 1'b0;       // flag for fetch finished info
wire isWorking;                  // controling signal for working of this step
integer i = 1; // for debugging the which instruction is fetched and conveyed

localparam FIRST_CYCLE = 3'b000;     // first state
localparam SECOND_CYCLE = 3'b001;    // secodn state
localparam STALL = 3'b010;           // stall state
reg [2:0] STATE = FIRST_CYCLE;      // set first state as first state

assign isWorking = enable_step_i && fetch_finished != 1'b1;          // assign working info depending of enable and finish info

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin 
                fetch_working_info= 1'b1; // working info for fetch step
                get_instruction = 1'b1;
                $display("FETCH STEP Fetching instruction from memory %h", program_counter, " for instruction %d",i); // debug info
                STATE = SECOND_CYCLE; // change state to second state
            end
            SECOND_CYCLE : begin // second state
                if(instruction_completed_i) begin
                    $display("FETCH STEP Fetched Instruction %h", instruction_i," for instruction %d",i); // debug info
                    if(decode_working_info_i == 0) begin
                        instruction_to_decode = instruction_i; // convey instruction to decode step
                        STATE = FIRST_CYCLE; // change state to first state 
                        program_counter = program_counter + 4; // increment program counter
                        fetch_finished = 1'b1; // set fetch finished info
                        fetch_working_info = 1'b0; // set working info to 0
                        get_instruction = 1'b0;
                        i = i+1; // increment instruction number
                    end
                    else begin
                        $display("Decode still working stall for fetch instruction ",i);
                        STATE = STALL;
                    end
                end
                else begin
                    STATE = STALL;
                     $display("Instruction have not arrived yet");
                end
            end  
            STALL : begin // stall state
                $display("STALL FOR FETCH"); // debug info
                STATE = SECOND_CYCLE; // change state to second state
            end 
        endcase 
    end  
end 

assign mem_address_o = program_counter; // assign memory address to program counter, goes to processor then memory
assign fetch_finished_o = fetch_finished; // assign fetch finished info to fetch finished
assign instruction_to_decode_o = instruction_to_decode; // assign instruction to decode, goes to decode step
assign get_instruction_o = get_instruction;            // flag for getting the instruction from memory, goes to memory

endmodule