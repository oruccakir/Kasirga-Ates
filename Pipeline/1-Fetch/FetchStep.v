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
    output wire [31:0] instruction_to_decode_o,
    output wire decode_activate_o,
    output wire fetch_working_info_o
);

reg fetch_working_info = 1'b0;
// decode
reg [31:0] instruction_to_decode = 32'b0;

reg decode_activate = 1'b0;


// FetchStep module implementation
reg [31:0] program_counter = 32'h8000_0000;
reg fetch_finished = 1'b0;
wire isWorking;

localparam FIRST_CYCLE = 3'b000;
localparam SECOND_CYCLE = 3'b001;
localparam STALL = 3'b010;

reg [2:0] STATE = FIRST_CYCLE;

integer i = 1;

assign isWorking = enable_step_i && fetch_finished != 1'b1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE : begin
                    decode_activate = 1'b0;
                    fetch_working_info = 1'b1;
                    if(decode_working_info_i) begin
                        $display("DECODE STILL WORKING FETCH WAITING");
                        STATE = STALL;
                    end
                    else begin
                        $display("FETCH STEP Fetching instruction from memory %h", program_counter, " for instruction %d",i); 
                        STATE <= SECOND_CYCLE;
                    end
                end
                SECOND_CYCLE : begin
                        $display("FETCH STEP Fetched Instruction %h", instruction_i," for instruction %d",i);
                        i = i+1;
                        instruction_to_decode <= instruction_i;
                        STATE <= FIRST_CYCLE;
                        program_counter <= program_counter + 4;
                        fetch_finished <= 1'b1;
                        decode_activate = 1'b1;
                        fetch_working_info = 1'b0;
                end
                STALL : begin
                    $display("STALL FOR FETCH");
                    STATE = FIRST_CYCLE;
                end
            endcase
        end
end

assign mem_address_o = program_counter;
assign fetch_finished_o = fetch_finished;
assign instruction_to_decode_o = instruction_to_decode;
assign decode_activate_o = decode_activate;
assign fetch_working_info_o = fetch_working_info;

endmodule