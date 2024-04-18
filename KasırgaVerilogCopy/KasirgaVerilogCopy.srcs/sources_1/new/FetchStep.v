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
    output reg [31:0] mem_address_o, // Memory address output, goes to memory
    output wire fetch_finished_o, // flag for finishing fetch step
    output reg [31:0] instruction_to_decode_o, // instruction that will be conveyed to decode step 
    output wire get_instruction_o,              // this is the fetching instruction desire from memory
    output reg [31:0] program_counter_o, // this is for increasig program counter for some instructions, goes to decode step
    output wire is_branch_instruction_o   // this is for branch instruction information, indicating current instruction is branch, informing processor
);

reg [31:0] program_counter_next;
reg [31:0] instruction_to_decode_next;
reg [31:0] program_counter_to_decode_next;
reg get_instruction_next;


reg get_instruction = 1'b1;     // desire for fetch, goes to memory
reg [31:0] instruction_to_decode; // instruction that will be convetyed to decode step
reg [31:0] program_counter;  // program counter to access memory, data and instructions
reg fetch_finished = 1'b0;       // flag for fetch finished info
wire isWorking;                  // controling signal for working of this step
integer i = -1; // for debugging the which instruction is fetched and conveyed
reg [31:0] program_counter_to_decode = 32'b0; // this goes to decode step, from there goes to execute step
reg is_branch_instruction = 1'b0;         // if this is true, then infrom processor to not make work other pipeline step by the time execute calculate correct program counter

localparam FIRST_CYCLE = 3'b000;     // first state
localparam SECOND_CYCLE = 3'b001;    // secodn state
localparam STALL = 3'b010;           // stall state
reg [2:0] STATE = FIRST_CYCLE;      // set first state as first state

assign isWorking = enable_step_i && fetch_finished != 1'b1;          // assign working info depending of enable and finish info


always@(*) begin
    $display("@@FETCH STAGE Fetched Instruction %h  ", instruction_i," instruction count %d ",i);
    i=i+1;
end


always@(*) begin
    instruction_to_decode_next = instruction_i;
    program_counter_next = program_counter + 4;
end

always@(decode_working_info_i) begin
    get_instruction = ~decode_working_info_i;
    if(decode_working_info_i)
        $display("Decode Working stall for fetch");
    
end

always@(posedge clk_i) begin
    if(rst_i) begin
        program_counter <= 32'h8000_0000;
        instruction_to_decode <= 32'b0;
        program_counter_next <= 32'h8000_0000;
        instruction_to_decode_next <= 32'b0;
        program_counter_to_decode <= 32'h8000_0000;
        program_counter_to_decode_next = 32'h8000_0000;
    end
    else begin
    
        if(get_instruction) begin
            program_counter_o <= program_counter;
            program_counter <= program_counter_next;
            mem_address_o <= program_counter_next;
            instruction_to_decode_o <= instruction_to_decode_next;
        end
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
        //i=i+1;
    end
end


//assign mem_address_o = program_counter; // assign memory address to program counter, goes to processor then memory
assign fetch_finished_o = fetch_finished; // assign fetch finished info to fetch finished
//assign instruction_to_decode_o = instruction_to_decode; // assign instruction to decode, goes to decode step
assign get_instruction_o = get_instruction;            // flag for getting the instruction from memory, goes to memory
//assign program_counter_o = program_counter_to_decode;     // Assing program counter output, goes to decode step
assign is_branch_instruction_o = is_branch_instruction;  // Assing is_branch_instruction_o for stopping the pipeline 

endmodule