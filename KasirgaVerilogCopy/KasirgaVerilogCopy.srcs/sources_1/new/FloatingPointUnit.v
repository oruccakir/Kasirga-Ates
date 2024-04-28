`include "definitions.vh"
module FloatingPointUnit(
   input          wire                    clk_i,                              // Clock input
   input          wire                    rst_i,                              // Reset input
   input          wire                    enable_floating_point_unit_i,       // Enable input
   input          wire     [4:0]          float_operation_i,                  // Floating point operation input
   input          wire     [31:0]         operand1_i,                         // Operand 1 input
   input          wire     [31:0]         operand2_i,                         // Operand 2 input
   input          wire     [31:0]         operand3_i,                         // Operand 3 input
   input          wire     [31:0]         immediate_value_i,                  // immediate values
   input          wire     [2:0]               rm_i,
   output         reg      [31:0]         fpu_result_o,                       // Result output
   output         reg                     register_type_selection_o,          // is destination register floating or integer   
   output         reg                     finished_o   // is floating point unit finished or not     
);
endmodule
/*
module FloatingPointUnit(
   input          wire                    clk_i,                              // Clock input
   input          wire                    rst_i,                              // Reset input
   input          wire                    enable_floating_point_unit_i,       // Enable input
   input          wire     [4:0]          float_operation_i,                  // Floating point operation input
   input          wire     [31:0]         operand1_i,                         // Operand 1 input
   input          wire     [31:0]         operand2_i,                         // Operand 2 input
   input          wire     [31:0]         operand3_i,                         // Operand 3 input
   input          wire     [31:0]         immediate_value_i,                  // immediate values
   input          wire     [2:0]               rm_i,
   output         reg      [31:0]         fpu_result_o,                       // Result output
   output         reg                     register_type_selection_o,          // is destination register floating or integer   
   output         reg                     finished_o   // is floating point unit finished or not     
);



// Floting multiplication unit
reg            enable_floating_point_multiplication;
reg   [31:0]   multiplication_operand_1; 
reg   [31:0]   multiplication_operand_2;
wire  [31:0]   multiplication_result;
wire           is_multiplication_finished;
floating_point_multiplication flo_mul(
    .clk_i(clk_i),                                                                  // Clock input
    .rst_i(rst_i),                                                                  // Reset input
    .enable_floating_point_multiplication_i(enable_floating_point_multiplication),  // Enable input
    .multiplication_operand_1_i(multiplication_operand_1),                          // Operand 1 input
    .multiplication_operand_2_i(multiplication_operand_2),                          // Operand 2 input
    .result_o(multiplication_result),                                               // Result output
    .finished_o(is_multiplication_finished)                       // is multiplication finished
);

// Floating division unit
reg            enable_floating_point_division;
reg   [31:0]   division_operand_1; 
reg   [31:0]   division_operand_2;
wire  [31:0]   division_result;
wire           is_division_finished;
floating_division_unit flo_div(
    .clk_i(clk_i),                                                                  // Clock input
    .rst_i(rst_i),                                                                  // Reset input
    .enable_floating_point_division_i(enable_floating_point_division),              // Enable input
    .division_operand_1_i(division_operand_1),                                      // Operand 1 input
    .division_operand_2_i(division_operand_2),                                      // Operand 2 input
    .result_o(division_result),                                                     // Result output
    .finished_o(is_division_finished)                                   // is division finished
);

// Floating addition unit
reg             enable_floating_point_addition;
reg    [31:0]   addition_operand_1; 
reg    [31:0]   addition_operand_2;
wire   [31:0]   addition_result;
wire            is_addition_finished;
floating_addition_unit flo_add(
    .clk_i(clk_i),                                                      // Clock input
    .rst_i(rst_i),                                                      // Reset input
    .enable_floating_point_addition_i(enable_floating_point_addition),  // Enable input
    .addition_operand_1_i(addition_operand_1),                          // Operand 1 input
    .addition_operand_2_i(addition_operand_2),                          // Operand 2 input
    .result_o(addition_result),                                         // Result output
    .finished_o(is_addition_finished)                       // is addition finished
);
reg [1:0] state = 2'b00;  //YA BASLA YA BEKLE YA BITIR
localparam START=2'b00;
localparam WAIT_FOR_FIRST_STAGE=2'b01;
localparam WAIT_FOR_SECOND_STAGE=2'b10;

always@(*) begin
   if(enable_floating_point_unit_i) begin
      case(float_operation_i)
        `FLT_FMADD_S:begin   //rd=rs1*rs2+rs3
           case(state)
                START:begin
                    enable_floating_point_multiplication<=1'b1;
                    multiplication_operand_1<=operand1_i;
                    multiplication_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                    finished_o<=1'b0;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_multiplication_finished) begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<=multiplication_result;
                        addition_operand_2<=operand3_i;
                        state<=WAIT_FOR_SECOND_STAGE;
                        floating_point_multiplication.finished_o<=1'b0;
                        finished_o<=1'b0;
                    end
                    
                end
                WAIT_FOR_SECOND_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                end          
           endcase
        end
        `FLT_FMSUB_S:begin // f[rd] = f[rs1]?f[rs2]-f[rs3]
            case(state)
                START:begin
                    enable_floating_point_multiplication<=1'b1;
                    multiplication_operand_1<=operand1_i;
                    multiplication_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_multiplication_finished) begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<=multiplication_result;
                        addition_operand_2<={~operand3_i[31],operand3_i[30:0]};
                        state<=WAIT_FOR_SECOND_STAGE;
                        floating_point_multiplication.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_multiplication<=1'b1;
                        multiplication_operand_1<=operand1_i;
                        multiplication_operand_2<=operand2_i;
                    end
                end
                WAIT_FOR_SECOND_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                    else begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<=multiplication_result;
                        addition_operand_2<={~operand3_i[31],operand3_i[30:0]};
                    end
                end          
            endcase     
        end
        `FLT_FNMSUB_S:begin  //f[rd] = -f[rs1]?f[rs2]+f[rs3]
            case(state)
                START:begin
                    enable_floating_point_multiplication<=1'b1;
                    multiplication_operand_1<=operand1_i;
                    multiplication_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_multiplication_finished) begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<={~multiplication_result[31],multiplication_result[30:0]};
                        addition_operand_2<=operand3_i;
                        state<=WAIT_FOR_SECOND_STAGE;
                        floating_point_multiplication.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_multiplication<=1'b1;
                        multiplication_operand_1<=operand1_i;
                        multiplication_operand_2<=operand2_i;
                    end
                end
                WAIT_FOR_SECOND_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                    else begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<={~multiplication_result[31],multiplication_result[30:0]};
                        addition_operand_2<=operand3_i;
                    end
                end          
           endcase
        
        end
        `FLT_FNMADD_S: begin // f[rd] = -f[rs1]?f[rs2]-f[rs3]
            case(state)
                START:begin
                    enable_floating_point_multiplication<=1'b1;
                    multiplication_operand_1<=operand1_i;
                    multiplication_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_multiplication_finished) begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<={~multiplication_result[31],multiplication_result[30:0]};
                        addition_operand_2<={~operand3_i[31],operand3_i[30:0]};
                        state<=WAIT_FOR_SECOND_STAGE;
                        floating_point_multiplication.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_multiplication<=1'b1;
                        multiplication_operand_1<=operand1_i;
                        multiplication_operand_2<=operand2_i;
                    end
                end
                WAIT_FOR_SECOND_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                    else begin
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<={~multiplication_result[31],multiplication_result[30:0]};
                        addition_operand_2<={~operand3_i[31],operand3_i[30:0]};
                    end
                end          
           endcase     
        end
        `FLT_FADD_S:begin //f[rd] = f[rs1] + f[rs2]
            case(state)
                START:begin
                    enable_floating_point_addition<=1'b1;
                    addition_operand_1<=operand1_i;
                    addition_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<=operand1_i;
                        addition_operand_2<=operand2_i;
                    end
                end
            endcase       
        end
        `FLT_FSUB_S: begin  // f[rd] = f[rs1] - f[rs2]
            case(state)
                START:begin
                    enable_floating_point_addition<=1'b1;
                    addition_operand_1<=operand1_i;
                    addition_operand_2<={~operand2_i[31], operand2_i[30:0]};
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_addition_finished) begin
                        fpu_result_o<=addition_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_addition_unit.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_addition<=1'b1;
                        addition_operand_1<=operand1_i;
                        addition_operand_2<={~operand2_i[31], operand2_i[30:0]};
                    end
                end
            endcase              
        end
        `FLT_FMUL_S: begin  // f[rd] = f[rs1] * f[rs2]
            case(state)
                START:begin
                    enable_floating_point_multiplication<=1'b1;
                    multiplication_operand_1<=operand1_i;
                    multiplication_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_multiplication_finished) begin
                        fpu_result_o<=multiplication_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_point_multiplication.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_multiplication<=1'b1;
                        multiplication_operand_1<=operand1_i;
                        multiplication_operand_2<=operand2_i;
                    end
                end
            endcase        
        end
        `FLT_FDIV_S: begin    //f[rd] = f[rs1] / f[rs2]
            case(state)
                START:begin
                    enable_floating_point_division<=1'b1;
                    division_operand_1<=operand1_i;
                    division_operand_2<=operand2_i;
                    state<=WAIT_FOR_FIRST_STAGE;
                end
                WAIT_FOR_FIRST_STAGE:begin
                    if(is_division_finished) begin
                        fpu_result_o<=division_result;
                        finished_o<=1'b1;
                        state<=START;
                        floating_division_unit.finished_o<=1'b0;
                    end
                    else begin 
                        enable_floating_point_division<=1'b1;
                        division_operand_1<=operand1_i;
                        division_operand_2<=operand2_i;
                    end
                end
            endcase   
        end
        `FLT_FSQRT_S: begin
            
        
        end
        `FLT_FSGNJ_S: begin  //f[rd] = {f[rs2][31], f[rs1][30:0]}
            
        
        end
        `FLT_FSGNJN_S: begin
        
        end
        `FLT_FSGNJX_S: begin
        
        end
        `FLT_FMIN_S: begin
        
        end
        `FLT_FMAX_S: begin
        
        end
        `FLT_FCVT_W_S: begin
        
        end
        `FLT_FCVT_WU_S: begin
        
        end
        `FLT_FMV_X_W: begin
        
        end
        `FLT_FCLASS_S: begin
        
        end
        `FLT_FCVT_S_W: begin
        
        end
        `FLT_FCVT_S_WU: begin
        
        end
        `FLT_FMV_W_X: begin
        
        end 
      endcase
    end
end



endmodule


/*

// Purpose: Floating point unit for the execute stage of the pipeline.
// Functionality: This module performs floating point operations.
// File: FloatingPointUnit.v

module FloatingPointUnit (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [4:0] floatOp_i, // Floating point operation input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input
    input wire [31:0] operand3_i, // Operand 3 input
    output wire [31:0] result_o // Result output
);

reg enable_float_multiplication = 1'b0; // Enable float multiplication
reg enable_float_division = 1'b0; // Enable float division

wire [31:0] mul_result; // Multiplication result
wire [31:0] div_result; // Division result
// Floting multiplication unit
FloatingMultiplicationUnit fmulUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_multiplication), // Enable input
    .operand1_i(operand1_i), // Operand 1 input
    .operand2_i(operand2_i), // Operand 2 input
    .result_o(mul_result) // Result output
);

// Floating division unit
FloatingDivisionUnit fdivUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_division), // Enable input
    .operand1_i(operand1_i), // Operand 1 input
    .operand2_i(operand2_i), // Operand 2 input
    .result_o(div_result) // Result output
);

/*
always@(*) begin
   if(enable_i == 1'b1) begin
       case(floatOp_i)
           `FLT_FMUL: begin
               enable_float_multiplication = 1'b1;
           end
           `FLT_FDIV: begin
               enable_float_division = 1'b1;
           end
           default: begin
               enable_float_multiplication = 1'b0;
               enable_float_division = 1'b0;
           end
       endcase
   end
   else begin
       enable_float_multiplication = 1'b0;
       enable_float_division = 1'b0;
   end
end

assign result_o = (floatOp_i == `FLT_FMUL) ? mul_result : div_result;

endmodule
*/

