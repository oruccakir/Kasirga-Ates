// Purpose: WriteBackStep module for the WriteBack stage of the pipeline.
// Functionality: This module performs the write back stage of the pipeline.
// File: WriteBackStep.v

include "definitions.vh";

module WriteBackStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    //input wire enable_step_i, // Enable input
    input wire [31:0] calculated_result_i,// it comes from other steps,
    input wire fetch_working_info_i,
    //output wire writeback_finished_o, // Flag for finishing writeback step
    output wire [31:0] writebacked_result_o, // final result after all calculations
    output wire reg_write_integer_o, // flag to write integer register
    output wire reg_write_float_o, // flag to write float register
    output wire reg_write_csr_o, //  flag to write csr register
    output writeback_working_info_o // working info for writeback step
);

reg writeback_working_info; // working info for writeback step
reg writeback_working_info_next; // next working info for writeback step
// to decode
reg reg_write_integer = 1'b0; // flag to write integer register
reg reg_write_integer_next = 1'b0; // next flag to write integer register
reg reg_write_float = 1'b0; // flag to write float register
reg reg_write_float_next = 1'b0; // next flag to write float register
reg reg_write_csr = 1'b0; // flag to write csr register
reg reg_write_csr_next = 1'b0; // next flag to write csr register

// WriteBackStep module implementation
reg writeback_finished = 1'b0; // Flag for finishing writeback step   // important change
reg writeback_finished_next = 1'b0; // Next flag for finishing writeback step
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 3'b000; // State for desiring instruction
localparam SECOND_CYCLE = 3'b001; // State for instruction result
localparam STALL = 3'b010;
reg [2:0] STATE = FIRST_CYCLE; // State for the module
reg [2:0] STATE_NEXT = FIRST_CYCLE; // Next state for the module

reg [31:0] writebacked_result = 32'b0; // writed result
reg [31:0] writebacked_result_next = 32'b0; // next writed result

//assign isWorking = enable_step_i && writeback_finished != 1'b1; // Assign isWorking

integer i = 1; // For debugging the instruction number

always @(*) begin

    writeback_working_info_next = writeback_working_info;
    writebacked_result_next = writebacked_result;
    reg_write_integer_next = reg_write_integer;
    reg_write_float_next = reg_write_float;
    reg_write_csr_next = reg_write_csr;
    STATE_NEXT = STATE;
    case(STATE)
        FIRST_CYCLE : begin
            writeback_working_info_next = 1'b1;
            $display(" WRITEBACK STEP Writing back to register file %d",calculated_result_i," for instruction %d",i);
            writebacked_result_next = calculated_result_i; 
            reg_write_integer_next = 1'b1;
            STATE_NEXT = SECOND_CYCLE; // Go to the second cycle
        end
        SECOND_CYCLE : begin
            $display("-->Writeback completed for instruction num %d",i);
            $display("Writebacked result %d",writebacked_result_o);
            reg_write_integer_next = 1'b0;
            i=i+1;
            STATE_NEXT = FIRST_CYCLE; // Go to the first cycle
            writeback_working_info_next = 1'b0;
        end
        STALL : begin
            STATE_NEXT = SECOND_CYCLE;
        end
    endcase
end

always@(posedge clk_i) begin
    if(rst_i) begin
        writeback_finished <= 1'b0;
        writeback_working_info <= 1'b0;
        writebacked_result <= 32'b0;
        reg_write_integer <= 1'b0;
        reg_write_float <= 1'b0;
        reg_write_csr <= 1'b0;
        STATE <= FIRST_CYCLE;
    end
    else begin
        writeback_finished <= writeback_finished_next;
        writeback_working_info <= writeback_working_info_next;
        writebacked_result <= writebacked_result_next;
        reg_write_integer <= reg_write_integer_next;
        reg_write_float <= reg_write_float_next;
        reg_write_csr <= reg_write_csr_next;
        STATE <= STATE_NEXT;
    end
end

//assign writeback_finished_o = writeback_finished; // Assign writeback_finished
assign writebacked_result_o = writebacked_result; // Assign calculated result
assign reg_write_integer_o = reg_write_integer; // Assign write flag for integer register
assign reg_write_float_o = reg_write_float;     // Assign write flag for float register
assign reg_write_csr_o = reg_write_csr;         // Assign write flag for csr register
assign writeback_working_info_o = writeback_working_info; // Assign working info for writeback step
endmodule

