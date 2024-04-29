// Purpose: Arithmetic Logic Unit (ALU) module for the RISC-V processor.
// Functionality: Performs arithmetic, logical, and comparison operations on two 32-bit operands.
// File: ArithmeticLogicUnit.v

// Include the definitions file

`include "definitions.vh"/*
module ArithmeticLogicUnit (
   input                                            clk_i,
   input                                            rst_i,
   input                                            enable_alu_unit_i,                       // Start signal for the ALU unit
   input                       [31:0]               operand1_i,                             // Operand 1                  
   input                       [31:0]               operand2_i,                             // Operand 2
   input                       [31:0]               immediate_value_i,                      // Immediate value
   input                       [31:0]               program_counter_i,                      // Program counter
   input                       [4:0]                aluOp_i,                                // ALU operation (20 instr.)               
   output                      [31:0]               calculated_memory_address_o,              // Calculated memory address
   output                      [31:0]               calculated_result_o,                    // Calculated result                  
   output                                           extension_mode_o,                       // Extension mode  0: zero extension, 1: sign extension
   output                      [2:0]                memory_operation_type_o,                // Memory operation type            
   output                                           register_type_selection_o,              // Register type selection
   output                      reg                  finished_o                              // Finished signal

);
reg [4:0] cycle, cycle_s;
reg finished_s;
    
    always@(*) begin
        cycle_s=cycle;
        if(enable_alu_unit_i)begin
            if(cycle_s<31) begin
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
*/
module ArithmeticLogicUnit (
    input wire [31:0] operand1_i, // First operand
    input wire [31:0] operand2_i, // Second operand
    input wire enable_i, // Enable input
    input wire [4:0] aluOp_i, // ALU operation
    input wire other_resources_i, // we can use arithmetic logic for memory address calculation
    output wire [31:0] result_o, // Result
    output wire is_finished_o
);

reg is_finished = 1'b1;
wire [31:0] result_addition;
reg [31:0] result = 32'b0;
wire cout;
/*RippleCarryAdder32 adder(
    .a(operand1_i),
    .b(operand2_i),
    .sum(result_addition),
    .cout(cout)
);*/
// Perform the operation based on the aluOp
always @(*) begin
    /*if(other_resources_i)
        $display("  ALU is working for other resources");*/
        $display(operand1_i);
        $display(operand2_i);
        $display(aluOp_i);
      case (aluOp_i)
        `ALU_SUB : result = operand1_i - operand2_i; // subtraction
        `ALU_ADD : result = operand1_i + operand2_i; // subtraction
        `ALU_AND: result = operand1_i & operand2_i; // Bitwise AND
        `ALU_OR: result = operand1_i | operand2_i; // Bitwise OR
        `ALU_XOR: result = operand1_i ^ operand2_i; // Bitwise XOR
        `ALU_SLT: result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than
        `ALU_SLTU: result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than unsigned
        `ALU_SLL: result = operand1_i << operand2_i; // Shift left logical
        `ALU_SRL: result = operand1_i >> operand2_i; // Shift right logical
        `ALU_SRA: result = operand1_i >>> operand2_i; // Shift right arithmetic
        `ALU_ADDI : result = operand1_i + operand2_i; // Addition
        `ALU_SLTI : result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than
        `ALU_SLTIU : result = (operand1_i < operand2_i) ? 32'b1 : 32'b0; // Set if less than unsigned
        `ALU_XORI : result = operand1_i ^ operand2_i; // Bitwise XOR
        `ALU_ORI : result = operand1_i | operand2_i; // Bitwise OR
        `ALU_ANDI : result = operand1_i & operand2_i; // Bitwise AND
        `ALU_SLLI : result = operand1_i << operand2_i; // Shift left logical
        `ALU_SRLI : result = operand1_i >> operand2_i; // Shift right logical
        `ALU_SRAI : result = operand1_i >>> operand2_i; // Shift right arithmetic
        default: result = 32'b0; // Default to 0
      endcase
      $display(result);
end
assign result_o = result;
//assign result_o = (aluOp_i == `ALU_ADD || other_resources_i) ? result_addition : result;
assign is_finished_o = is_finished;

endmodule