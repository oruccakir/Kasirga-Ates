// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v

include "definitions.vh";

module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] calculated_result_i,// it comes from other steps
    output wire writeback_finished_o, // Flag for finishing writeback step
    output wire [31:0] writebacked_result_o, // final result after all calculations
    output wire reg_write_integer_o, // flag to write integer register
    output wire reg_write_float_o, // flag to write float register
    output wire reg_write_csr_o, //  flag to write csr register
    output wire fetch_activate_o
);

// to decode
reg reg_write_integer = 1'b0;
reg reg_write_float = 1'b0;
reg reg_write_csr = 1'b0;

reg fetch_activate = 1'b0;
// WriteBackStep module implementation
reg writeback_finished = 1'b0; // Flag for finishing writeback step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 1'b0; // State for desiring instruction
localparam SECOND_CYCLE = 1'b1; // State for instruction result

reg STATE = FIRST_CYCLE; // State for the module

reg [31:0] writebacked_result = 32'b0; // writed result

assign isWorking = enable_step_i && writeback_finished != 1'b1; // Assign isWorking

integer i = 1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                FIRST_CYCLE :
                    begin
                        $display(" WRITEBACK STEP Writing back to register file %d",calculated_result_i," for instruction %d",i);
                        writebacked_result <= calculated_result_i; 
                        reg_write_integer <= 1'b1;
                        STATE <= SECOND_CYCLE; // Go to the second cycle
                    end
                SECOND_CYCLE :
                    begin
                        $display("-->Writeback completed for instruction num %d",i);
                        $display("Writebacked result %d",writebacked_result_o);
                        writeback_finished <= 1'b1;
                        reg_write_integer <= 1'b0;
                        i=i+1;
                        STATE <= FIRST_CYCLE; // Go to the first cycle
                        fetch_activate = 1'b1;
                    end
            endcase
        end
end

assign writeback_finished_o = writeback_finished; // Assign writeback_finished
assign writebacked_result_o = writebacked_result; // Assign calculated result
assign reg_write_integer_o = reg_write_integer; // Assign write flag for integer register
assign reg_write_float_o = reg_write_float;     // Assign write flag for float register
assign reg_write_csr_o = reg_write_csr;         // Assign write flag for csr register
assign fetch_activate_o = fetch_activate;

endmodule

