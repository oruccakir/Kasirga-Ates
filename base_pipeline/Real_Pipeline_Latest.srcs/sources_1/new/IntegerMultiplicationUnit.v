// Purpose: 32-bit integer multiplication unit for the execute stage of the pipeline.
// Functionality: This module performs 32-bit integer multiplication.
// File: IntegerMultiplicationUnit.v

module IntegerMultiplicationUnit(
   input wire clk_i,
   input wire rst_i,
   input wire enable_integer_multiplication_unit_i,
   input wire [ 4:0] mulOp_i,
   input wire [31:0] operand1_i,
   input wire[31:0] operand2_i,
   input wire reset_finish,
   output wire[31:0] result_o,
   output wire finished_o,
   output wire state_o   
);

reg is_finished;
reg [31:0] result;
integer counter = 0;
integer c =0;
wire state;
assign state = enable_integer_multiplication_unit_i && ~is_finished;

always@(posedge clk_i) begin
    if(rst_i) begin
        is_finished <= 1'b0;
        result <= 32'b0;
    end
    else begin
        if(state == `IN_PROGRESS) begin
            if(counter != 10) begin
                result =  operand1_i * operand2_i;
                counter = counter + 1;    
            end
            else begin
                is_finished = 1'b1;
                counter = 0;
            end
        end
        else if(is_finished) begin
            if(c == 1) begin
                is_finished = 1'b0;
                c = 0;
            end
            else begin
                c = c + 1;
                
            end
        end
    end
end

assign finished_o = is_finished;
assign result_o = result;
assign state_o = state;
endmodule

