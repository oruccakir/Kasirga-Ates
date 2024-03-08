// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v

module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    output wire writeback_finished_o
);

// WriteBackStep module implementation
reg writeback_finished = 1'b0; // Flag for finishing writeback step
wire isWorking; // Flag for working

localparam INS_DESIRE = 1'b0; // State for desiring instruction
localparam INS_RESULT = 1'b1; // State for instruction result

reg STATE = INS_DESIRE; // State for the module

assign isWorking = enable_step_i && writeback_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                INS_DESIRE :
                    begin
                        $display("WriteBackStep: Writing back to register file");
                        STATE = INS_RESULT;
                    end
                INS_RESULT :
                    begin
                        $display("WriteBackStep: Writeback completed");
                        writeback_finished <= 1'b1;
                        STATE = INS_DESIRE;
                    end
            endcase
        end
end

assign writeback_finished_o = writeback_finished;

endmodule

