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
    input wire instruction_completed_i,
    output wire [31:0] mem_address_o, // Memory address output
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o, // instruction that will be conveyed to decode step 
    output wire fetch_working_info_o,  // for now this is unnecessary
    output wire get_instruction_o
);

reg get_instruction = 1'b0;
reg get_instruction_next = 1'b0;

reg [31:0] instruction_to_decode = 32'b0; // instruction that will be convetyed to decode step
reg [31:0] instruction_to_decode_next = 32'b0;

// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000;  // program counter to access memory, data and instructions
reg [31:0] program_counter_next = 32'h8000_0000;

reg fetch_finished = 1'b0;       // flag for fetch finished info
wire isWorking;                  // controling signal for working of this step

localparam FIRST_CYCLE = 3'b000;     // first state
localparam SECOND_CYCLE = 3'b001;    // secodn state
localparam STALL = 3'b010;           // stall state

reg [2:0] STATE = FIRST_CYCLE;      // set first state as first state
reg [2:0] STATE_NEXT = FIRST_CYCLE;

integer i = 1; // for debugging the which instruction is fetched and conveyed

assign isWorking = enable_step_i && fetch_finished != 1'b1;          // assign working info depending of enable and finish info

always @(*) begin
    
    get_instruction_next = get_instruction;
    instruction_to_decode_next = instruction_to_decode;
    program_counter_next = program_counter;
    STATE_NEXT = STATE;
    
    case(STATE_NEXT) // case for state
        FIRST_CYCLE : begin // first state
            //fetch_working_info= 1'b1; // working info for fetch step
            get_instruction_next = 1'b1;
            $display("FETCH STEP Fetching instruction from memory %h", program_counter_next, " for instruction %d",i); // debug info
            STATE_NEXT = SECOND_CYCLE; // change state to second state
        end
        SECOND_CYCLE : begin // second state
            if(decode_working_info_i) begin // if decode step is working then stall
                $display("DECODE STILL WORKING FETCH WAITING for ",i); // debug info
                STATE_NEXT = STALL; // change state to stall
            end
            else begin
                if(instruction_completed_i) begin
                    $display("FETCH STEP Fetched Instruction %h", instruction_i," for instruction %d",i); // debug info
                    i = i+1; // increment instruction number
                    instruction_to_decode_next = instruction_i; // convey instruction to decode step
                    STATE_NEXT = FIRST_CYCLE; // change state to first state
                    program_counter_next = program_counter + 4; // increment program counter
                    //fetch_finished = 1'b1; // set fetch finished info
                    //fetch_working_info = 1'b0; // set working info to 0
                    get_instruction_next = 1'b0;
                end
                else begin
                    STATE_NEXT = STALL;
                    $display("Instruction have not arrived yet");
                end
            end
        end  
        STALL : begin // stall state
            $display("STALL FOR FETCH"); // debug info
            STATE_NEXT = SECOND_CYCLE; // change state to second state
        end 
    endcase  // end of case
end // end of always block

always @(posedge clk_i) begin
    if(rst_i) begin
        get_instruction = 1'b0;
        instruction_to_decode = 32'b0;
        program_counter = 32'h8000_0000;
        STATE = FIRST_CYCLE;
    end
    else begin
        get_instruction <= get_instruction_next;
        instruction_to_decode <= instruction_to_decode_next;
        program_counter <= program_counter_next;
        STATE <= STATE_NEXT;
    end
end

assign mem_address_o = program_counter; // assign memory address to program counter
assign fetch_finished_o = fetch_finished; // assign fetch finished info to fetch finished
assign instruction_to_decode_o = instruction_to_decode; // assign instruction to decode
assign get_instruction_o = get_instruction;     // assign get instruction output

endmodule