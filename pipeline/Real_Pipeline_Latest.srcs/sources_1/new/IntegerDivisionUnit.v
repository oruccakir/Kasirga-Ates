// Purpose: Integer division unit for the execute stage of the pipeline.
// Functionality: This module performs integer division.
// File: IntegerDivisionUnit.v    
module IntegerDivisionUnit(
   input                                                                    clk_i,
   input                                                                    rst_i,
   input                                                                    enable_integer_division_unit_i,
   input                                      [1:0]                         divOp_i,
   input                                      [31:0]                        operand1_i,
   input                                      [31:0]                        operand2_i,
   output                                     [31:0]                        result_o,
   output              reg                                                  finished_o

    );


always@ (posedge clk_i) begin
    if(rst_i)begin
        finished_o<=0;
    end
end

endmodule

/*
module IntegerDivisionUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input [4:0]divOp_i,  // operation code for integer division unit
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output wire [31:0] result_o, // Result output
    output wire is_finished_o
);

reg is_finished = 1'b0;
reg [31:0] result = 32'b0;

localparam CYCLE1 = 3'b000;
localparam CYCLE2 = 3'b001;
localparam CYCLE3 = 3'b010;
localparam CYCLE4 = 3'b100;
localparam CYCLE5 = 3'b101;

reg [2:0] STATE = CYCLE1;
wire isWorking;

assign isWorking = enable_i && is_finished != 1'b1; // Assign isWorking

always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            result <= 32'b0; // Reset the result
        end
        else if(isWorking) begin
            case(STATE)
                CYCLE1: begin
                    case(divOp_i)
                        `INT_DIV: result <= operand1_i / operand2_i; // Perform the division
                        `INT_DIVU : result <= operand1_i / operand2_i; // Perform the division
                        `INT_REMU : result <= operand1_i % operand2_i; // Perform remainder division
                        `INT_REM : result <= operand1_i % operand2_i; // Perform remainder division
                    endcase
                    STATE = CYCLE2;
                end
                CYCLE2: begin
                    STATE = CYCLE3;
                end
                CYCLE3: begin
                    STATE = CYCLE4;
                end
                CYCLE4: begin
                    STATE = CYCLE5;
                end
                CYCLE5: begin
                    is_finished <= 1'b1; 
                    STATE = CYCLE1;
                end
            endcase
       end
end
    
assign result_o = result;
assign is_finished_o = is_finished;
endmodule*/