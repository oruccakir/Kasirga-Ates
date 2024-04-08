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


localparam FLW=5'd0;
localparam FSW=5'd1;
localparam FMADD_S=5'd2;
localparam FMSUB_S=5'd3;
localparam FNMSUB_S=5'd4;
localparam FNMADD_S=5'd5;
localparam FADD_S=5'd6;
localparam FSUB_S=5'd7;
localparam FMUL_S=5'd8;
localparam FDIV_S=5'd9;
localparam FSQRT_S=5'd10;
localparam FSGNJ_S=5'd11;
localparam FSGNJN_S=5'd12;
localparam FSGNJX_S=5'd13;
localparam FMIN_S=5'd14;
localparam FMAX_S=5'd15;
localparam FCVT_W_S=5'd16;
localparam FCVT_WU_S=5'd17;
localparam FMV_X_W=5'd18;
localparam FEQ_S=5'd19;
localparam FLT_S=5'd20;
localparam FLE_S=5'd21;
localparam FCLASS_S=5'd22;
localparam FCVT_S_W=5'd23;
localparam FCVT_S_WU=5'd24;
localparam FMV_W_X=5'd25;


reg enable_float_multiplication = 1'b0; // Enable float multiplication
reg enable_float_division = 1'b0; // Enable float division
reg enable_add_sub_division= 1'b0; // Enable float addition and subtruction
reg result_fmul_unit;
reg result_fdiv_unit;
reg result_fadd_unit;
reg [31:0] operand1_mul, operand2_mul;
reg [31:0] operand1_div, operand2_div;
reg [31:0] operand1_add_or_sub, operand2_add_or_sub;




// Floting multiplication unit
FloatMultiplicationUnit fmulUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_multiplication), // Enable input
    .operand1_i(operand1_mul), // Operand 1 input
    .operand2_i(operand2_mul), // Operand 2 input
    .result_o(result_fmul_unit) // Result output
);

// Floating division unit
FloatingDivisionUnit fdivUnit (
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_float_division), // Enable input
    .operand1_i(operand1_div), // Operand 1 input
    .operand2_i(operand2_div), // Operand 2 input
    .result_o(result_fdiv_unit) // Result output
);


floating_add_and_sub_unit fAddSubUnit(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .enable_i(enable_add_sub_division), // Enable input
    .operand1_i(operand1_add_or_sub), // Operand 1 input
    .operand2_i(operand2_add_or_sub), // Operand 2 input
    .result_o(result_fadd_unit) // Result output
);




always@* begin
    case(floatOp_i)
        FLW: begin
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=operand1_i;
            operand2_add_or_sub=operand2_i;
        end
        FSW:begin
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=operand1_i;
            operand2_add_or_sub=operand2_i;
        end
        FMADD_S:begin   //rd=rs1*rs2+rs3
            enable_float_multiplication=1'b1;
            operand1_mul=operand1_i;
            operand2_mul=operand2_i;
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=result_fmul_unit;
            operand2_add_or_sub=operand3_i;
        end
        FMSUB_S:begin
            enable_float_multiplication=1'b1;
            operand1_mul=operand1_i;
            operand2_mul=operand2_i;
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=result_fmul_unit;
            operand2_add_or_sub=operand3_i;
        end
        FNMSUB_S:begin
            enable_float_multiplication=1'b1;
            operand1_mul=operand1_i;
            operand2_mul=operand2_i;
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=result_fmul_unit;
            operand2_add_or_sub=operand3_i;
        
        end
        FNMADD_S: begin
            enable_float_multiplication=1'b1;
            operand1_mul=operand1_i;
            operand2_mul=operand2_i;
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=result_fmul_unit;
            operand2_add_or_sub=operand3_i;
        
        end
        FADD_S:begin
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=operand1_i;
            operand2_add_or_sub=operand2_i;
        
        end
        FSUB_S: begin
            enable_add_sub_division=1'b1;
            operand1_add_or_sub=operand1_i;
            operand2_add_or_sub=operand2_i;
        
        end
        FMUL_S: begin
            enable_float_multiplication=1'b1;
            operand1_mul=operand1_i;
            operand2_mul=operand2_i;
        
        end
        FDIV_S: begin
            enable_float_division=1'b1;
            operand1_div=operand1_i;
            operand2_div=operand2_i;
        
        end
        FSQRT_S: begin
        
        end
        FSGNJ_S: begin  //f[rd] = {f[rs2][31], f[rs1][30:0]}
        
        end
        FSGNJN_S: begin
        
        end
        FSGNJX_S: begin
        
        end
        FMIN_S: begin
        
        end
        FMAX_S: begin
        
        end
        FCVT_W_S: begin
        
        end
        FCVT_WU_S: begin
        
        end
        FMV_X_W: begin
        
        end
        FEQ_S: begin
        
        end
        FLT_S: begin
        
        end
        FLE_S: begin
        
        end
        FCLASS_S: begin
        
        end
        FCVT_S_W: begin
        
        end
        FCVT_S_WU: begin
        
        end
        FMV_W_X: begin
        
        end 
    endcase
end


always@(posedge clk_i) begin

end

endmodule