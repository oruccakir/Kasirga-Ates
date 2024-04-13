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
    input wire is_branch_address_calculated_i, // this comes from execute step, indicating that whether branch address calculation is completed or not
    input wire [31:0] calculated_branch_address_i, // this comes from execute step, gives correct branch address
    input wire branch_info_i, // this info comes from execute step, indicates whether branch is taken or not
    output wire [31:0] mem_address_o, // Memory address output, goes to memory
    output wire fetch_finished_o, // flag for finishing fetch step
    output wire [31:0] instruction_to_decode_o, // instruction that will be conveyed to decode step 
    output wire get_instruction_o,              // this is the fetching instruction desire from memory
    output wire [31:0] program_counter_o, // this is for increasig program counter for some instructions, goes to decode step
    output wire is_branch_instruction_o   // this is for branch instruction information, indicating current instruction is branch, informing processor
);

reg get_instruction = 1'b0;     // desire for fetch, goes to memory
reg [31:0] instruction_to_decode = 32'b0; // instruction that will be convetyed to decode step
reg [31:0] program_counter = 32'h8000_0000;  // program counter to access memory, data and instructions
reg fetch_finished = 1'b0;       // flag for fetch finished info
wire isWorking;                  // controling signal for working of this step
integer i = 1; // for debugging the which instruction is fetched and conveyed
reg [31:0] program_counter_to_decode = 32'b0; // this goes to decode step, from there goes to execute step
reg is_branch_instruction = 1'b0;         // if this is true, then infrom processor to not make work other pipeline step by the time execute calculate correct program counter

localparam FIRST_CYCLE = 3'b000;     // first state
localparam SECOND_CYCLE = 3'b001;    // secodn state
localparam STALL = 3'b010;           // stall state
reg [2:0] STATE = FIRST_CYCLE;      // set first state as first state

assign isWorking = enable_step_i && fetch_finished != 1'b1;          // assign working info depending of enable and finish info

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin 
                get_instruction = 1'b1;
                $display("FETCH STEP Fetching instruction from memory %h", program_counter, " for instruction %d",i); // debug info
                STATE = SECOND_CYCLE; // change state to second state
            end
            SECOND_CYCLE : begin // second state
                if(instruction_completed_i) begin
                    $display("FETCH STEP Fetched Instruction %h", instruction_i," for instruction %d",i); // debug info
                    if(instruction_i[6:0] == 7'b1100011 || instruction_i[6:0] == 7'b1101111 || instruction_i[6:0] == 7'b1100111) begin
                        $display("BRANCH INSTRUCTION");
                        is_branch_instruction = 1'b1;
                    end
                    else
                        is_branch_instruction = 1'b0;
                    if(decode_working_info_i == 0) begin
                        instruction_to_decode = instruction_i; // convey instruction to decode step
                        STATE = FIRST_CYCLE; // change state to first state 
                        program_counter_to_decode = program_counter;
                        program_counter = program_counter + 4; // increment program counter
                        fetch_finished = 1'b1; // set fetch finished info
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

/*
    This always block is for branch instruction, if the branch instruction is calculated then
    the program counter is set to the calculated branch address
*/
always@(posedge is_branch_address_calculated_i) begin // if branch address is calculated run this always block
    if(branch_info_i == `BRANCH_TAKEN) begin
        $display("Calculated branch address ",calculated_branch_address_i, " as hexadeciamal %h",calculated_branch_address_i); // for debugging display calculated branch address
        is_branch_instruction = 1'b0;                                       // this is crucial because for next instructions pipeline should work as usual, important for processor module
        program_counter = calculated_branch_address_i;                      // set program counter as newly calculated branch address
    end
end


assign mem_address_o = program_counter; // assign memory address to program counter, goes to processor then memory
assign fetch_finished_o = fetch_finished; // assign fetch finished info to fetch finished
assign instruction_to_decode_o = instruction_to_decode; // assign instruction to decode, goes to decode step
assign get_instruction_o = get_instruction;            // flag for getting the instruction from memory, goes to memory
assign program_counter_o = program_counter_to_decode;     // Assing program counter output, goes to decode step
assign is_branch_instruction_o = is_branch_instruction;  // Assing is_branch_instruction_o for stopping the pipeline 

endmodule