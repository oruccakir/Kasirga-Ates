// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

include "definitions.vh";

module FetchStep (
    input wire clk_i,                                        // Clock input
    input wire rst_i,                                        // Reset input
    input wire decode_working_info_i,                        // very important info for stalling, comes from decode step
    input wire [31:0] instruction_i,                         // Instruction output, comes from memory via processor
    input wire instruction_completed_i,                      // this comes from memory, indicates memory completed process of giving instruction data
    input wire is_branch_address_calculated_i,               // this comes from execute step, indicating that whether branch address calculation is completed or not
    input wire [31:0] calculated_branch_address_i,           // this comes from execute step, gives correct branch address
    input wire branch_info_i,                                // this info comes from execute step, indicates whether branch is taken or not
    output reg [31:0] mem_address_o,                         // Memory address output, goes to memory
    output reg [31:0] instruction_to_decode_o,               // instruction that will be conveyed to decode step 
    output wire fetch_next_instruction_o,                    // this is the fetching instruction desire from memory
    output reg [31:0] program_counter_o,                      // this is for increasig program counter for some instructions, goes to decode step
    output wire reset_branch_info_o                          // this is goes to directly execute step to reset branch working info
);

reg [31:0] program_counter_next;                             // next register for program_counter
reg [31:0] instruction_to_decode_next;                       // next register for instruction that will be conveyed to decode step

wire fetch_next_instruction;                                 // this is flag for getting instruction from memory or cache, crucial for stalling operations
reg [31:0] instruction_to_decode;                            // instruction that will be convetyed to decode step
reg [31:0] program_counter;                                  // program counter to access memory, data and instructions
reg reset_branch_info;
integer i = -1;                                              // for debugging the which instruction is fetched and conveyed

//assign reset_branch_info = (branch_info_i == `BRANCH_TAKEN) ? 1'b1 : 1'b0;

always@(*) begin
    $display("@@FETCH STAGE Fetched Instruction %h  ", instruction_i," instruction count %d ",i);     // debugging purpose
    i=i+1;                                                                                            // increment counter when new instruction comes
end                                


always@(*) begin
    instruction_to_decode_next = instruction_i;              // assign new instruction to instruction_to_decode_next
    program_counter_next = program_counter + 4;              // assign new program counter to program_counter_next
end

always@(posedge clk_i) begin
    if(rst_i) begin
        program_counter <= 32'h8000_0000;
        instruction_to_decode <= 32'b0;
        program_counter_next <= 32'h8000_0000;
        instruction_to_decode_next <= 32'b0;
    end
    else begin     
        if(branch_info_i == `BRANCH_TAKEN) begin
            program_counter_o <= program_counter;
            program_counter <= calculated_branch_address_i;
            mem_address_o <=calculated_branch_address_i;
            instruction_to_decode_o <= 32'b0;
            reset_branch_info <= 1'b1;
            $display("Branch Address  Calculated Branch Taken %h",calculated_branch_address_i );
        end
        else if(fetch_next_instruction) begin                    // if fetch_next_instruction is true, then send necessary outputs to decode stage and fetch new instruction
            program_counter_o <= program_counter;
            program_counter <= program_counter_next;
            mem_address_o <=program_counter_next;
            instruction_to_decode_o <= instruction_to_decode_next;
            reset_branch_info <= 1'b0;
        end

    end
end




assign fetch_next_instruction_o = fetch_next_instruction;            // flag for getting the instruction from memory, goes to memory1
assign fetch_next_instruction = ~decode_working_info_i;              // When decode stage is running, then do not fetch new instruction and do not update signals that will go to decode stage
assign reset_branch_info_o = reset_branch_info;

endmodule