// Purpose: 32-bit integer multiplication unit for the execute stage of the pipeline.
// Functionality: This module performs 32-bit integer multiplication.
// File: IntegerMultiplicationUnit.v

module IntegerMultiplicationUnit(
   input                                                                   clk_i,
   input                                                                   rst_i,
   input                                                                   enable_integer_multiplication_unit_i,
   input                         [ 4:0]                                     mulOp_i,
   input                         [31:0]                                    operand1_i,
   input                         [31:0]                                    operand2_i,
   output                        [31:0]                                    result_o,
   output         reg                                                      finished_o   
    );
    reg [4:0] cycle, cycle_s;
    reg finished_s;
    
    always@(*) begin
        cycle_s=cycle;
        if(enable_integer_multiplication_unit_i)begin
            if(cycle_s<2) begin
                cycle_s=cycle+1;
                finished_s=0;
            end else begin
                finished_s=1;        
                cycle_s=0;   
            end
        
        end
    
    
    end
    
    always@(posedge clk_i)begin
        if(rst_i)begin
            cycle<=0;
            cycle_s<=0;
            finished_o<=0;
            finished_s<=0;
        end else begin
            cycle<=cycle_s;
            finished_o<=finished_s;
        end
        
    end

endmodule

/*
module IntegerMultiplicationUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire mulOp_i, // operation code for mul operations
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output wire [31:0] result_o, // Result output
    output wire is_finished_o // finish signal
);
    
reg [31:0] result = 32'b0;
reg is_finished = 1'b0;

wire isWorking;

localparam CYCLE1 = 3'b000;
localparam CYCLE2 = 3'b001;
localparam CYCLE3 = 3'b010;
localparam CYCLE4 = 3'b100;
localparam CYCLE5 = 3'b101;

reg [2:0] STATE = CYCLE1;

assign isWorking = enable_i && is_finished != 1'b1; // Assign isWorking

always @(posedge clk_i or posedge rst_i) begin
        if(rst_i)begin
            result <= 32'b0; // Reset the result
        end
        else if(isWorking)begin
            case(STATE)
                CYCLE1: begin
                    case(mulOp_i)
                        `INT_MUL: result = operand1_i * operand2_i;
                        `INT_MULH: result = operand1_i * operand2_i;
                        `INT_MULHSU: result = operand1_i * operand2_i;
                        `INT_MULHU: result = operand1_i * operand2_i;
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
                    STATE = CYCLE1;
                    is_finished = 1'b1;
                end
            endcase
        end
    end   

assign result_o = result;
assign is_finished_o = is_finished;

endmodule*/