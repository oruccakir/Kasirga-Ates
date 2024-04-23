`include "definitions.vh"

module floating_point_unit(
   input          wire                    clk_i,                              // Clock input
   input          wire                    rst_i,                              // Reset input
   input          wire                    enable_floating_point_unit_i,       // Enable input
   input          wire     [4:0]          float_operation_i,                  // Floating point operation input
   input          wire     [31:0]         operand1_i,                         // Operand 1 input
   input          wire     [31:0]         operand2_i,                         // Operand 2 input
   input          wire     [31:0]         operand3_i,                         // Operand 3 input
   input          wire     [31:0]         immediate_value_i,                  // immediate values
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

always@(posedge clk_i) begin
    enable_floating_point_addition<=1'b0;
    enable_floating_point_division<=1'b0;
    enable_floating_point_multiplication<=1'b0;
   if(enable_floating_point_unit_i) begin
      case(float_operation_i)
        `FLT_FMADD:begin   //rd=rs1*rs2+rs3
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
                        addition_operand_1<=multiplication_result;
                        addition_operand_2<=operand3_i;
                    end
                end          
           endcase
        end
        `FLT_FMSUB:begin // f[rd] = f[rs1]?f[rs2]-f[rs3]
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
        `FLT_FNMSUB:begin  //f[rd] = -f[rs1]?f[rs2]+f[rs3]
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
        `FLT_FNMADD: begin // f[rd] = -f[rs1]?f[rs2]-f[rs3]
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
        `FLT_FADD:begin //f[rd] = f[rs1] + f[rs2]
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
        `FLT_FSUB: begin  // f[rd] = f[rs1] - f[rs2]
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
        `FLT_FMUL: begin  // f[rd] = f[rs1] * f[rs2]
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
        `FLT_FDIV: begin    //f[rd] = f[rs1] / f[rs2]
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
        `FLT_FSQRT: begin
            
        
        end
        `FLT_FSGNJ: begin  //f[rd] = {f[rs2][31], f[rs1][30:0]}
            
        
        end
        `FLT_FSGNJN: begin
        
        end
        `FLT_FSGNJX: begin
        
        end
        `FLT_FMIN: begin
        
        end
        `FLT_FMAX: begin
        
        end
        `FLT_FCVTW: begin
        
        end
        `FLT_FCVTWU: begin
        
        end
        `FLT_FMVXW: begin
        
        end
        `FLT_FCLASS: begin
        
        end
        `FLT_FCVTSW: begin
        
        end
        `FLT_FCVTSWU: begin
        
        end
        `FLT_FMVWX: begin
        
        end 
      endcase
    end
end



endmodule
