// Purpose: 32-bit float multiplication unit for the execute stage of the pipeline.
// Functionality: This module performs 32-bit integer multiplication.
// File: FloatMultiplicationUnit.v

module FloatingMultiplicationUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input 
    output wire [31:0] result_o // Result output
    output wire exception_o, // exception_o output
    output wire overflow_o, // Overflow output
    output wire underflow_o // underflow_o output
);
    
wire sign,product_round,normalised,zero;
wire [8:0] exponent,sum_exponent;
wire [22:0] product_mantissa;
wire [23:0] operand_a,operand_b;
wire [47:0] product,product_normalised; //48 Bits


assign sign = a_operand[31] ^ b_operand[31];

//exception_o flag sets 1 if either one of the exponent is 255.
assign exception_o = (&a_operand[30:23]) | (&b_operand[30:23]);

//Assigining significand values according to Hidden Bit.
//If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1

assign operand_a = (|a_operand[30:23]) ? {1'b1,a_operand[22:0]} : {1'b0,a_operand[22:0]};

assign operand_b = (|b_operand[30:23]) ? {1'b1,b_operand[22:0]} : {1'b0,b_operand[22:0]};

assign product = operand_a * operand_b;			//Calculating Product

assign product_round = |product_normalised[22:0];  //Ending 22 bits are OR'ed for rounding operation.

assign normalised = product[47] ? 1'b1 : 1'b0;	

assign product_normalised = normalised ? product : product << 1;	//Assigning Normalised value based on 48th bit

//Final Manitssa.
assign product_mantissa = product_normalised[46:24] + {21'b0,(product_normalised[23] & product_round)};

assign zero = exception_o ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;

assign sum_exponent = a_operand[30:23] + b_operand[30:23];

assign exponent = sum_exponent - 8'd127 + normalised;

assign overflow_o = ((exponent[8] & !exponent[7]) & !zero) ; //If overall exponent is greater than 255 then Overflow condition.
//exception_o Case when exponent reaches its maximu value that is 384.

//If sum of both exponents is less than 127 then underflow_o condition.
assign underflow_o = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; 

assign result = exception_o ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : underflow_o ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};

endmodule