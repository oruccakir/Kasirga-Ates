// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v

include "definitions.vh";

module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    output wire writeback_finished_o // Flag for finishing writeback step
);

// WriteBackStep module implementation
reg writeback_finished = 1'b0; // Flag for finishing writeback step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for desiring instruction
localparam SECOND_CYCLE = 1'b1; // State for instruction result

reg STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && writeback_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking)
        begin
            $display("WRITEBACK STEP");
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display("-->Writing back to register file");
                        STATE <= SECOND_CYCLE; // Go to the second cycle
                    end
                SECOND_CYCLE :
                    begin
                        $display("-->Writeback completed");
                        writeback_finished <= 1'b1;
                        STATE <= FIRST_CYCLE; // Go to the first cycle
                    end
            endcase
        end
end

assign writeback_finished_o = writeback_finished; // Assign writeback_finished

endmodule

