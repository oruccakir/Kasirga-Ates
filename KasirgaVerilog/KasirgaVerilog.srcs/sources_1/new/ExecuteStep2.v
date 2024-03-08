// Purpose: Execute Step 2 of the pipeline.
// Functionality: This module performs the second part of the execute stage of the pipeline.
// File: ExecuteStep2.v

module ExecuteStep2 (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    output wire execute2_finished_o
);

// ExecuteStep2 module implementation
reg execute2_finished = 1'b0; // Flag for finishing execute step 2
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for desiring instruction
localparam SECOND_CYCLE = 1'b1; // State for instruction result

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && execute2_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("ExecuteStep2: Executing instruction");
                        STATE = SECOND_CYCLE;
                    end
                SECOND_CYCLE :
                    begin
                        $display("ExecuteStep2: Execution completed");
                        execute2_finished <= 1'b1;
                        STATE = FIRST_CYCLE;
                    end
            endcase
        end
end

assign execute2_finished_o = execute2_finished;
endmodule
