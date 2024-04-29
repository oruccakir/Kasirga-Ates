// Purpose: Bit manipulation unit for the execute stage of the pipeline.
// Functionality: This module performs bit manipulation.
// File: BitManipulationUnit.v

// Include the necessary files
`include "definitions.vh"
module BitManipulationUnit (
   input                                                clk_i,                                                  // Clock signal 
   input                                                rst_i,                                                  // Reset signal     
   input                                                enable_bit_manipulation_unit_i,                            // Start signal for the bit manipulation unit
   input                   [31:0]                       operand1_i,                                             // Operand 1                                                  
   input                   [31:0]                       operand2_i,                                             // Operand 2
   input                   [4:0]                        shamt_i,                                                // Shift amount (5 bit)
   input                   [4:0]                        bmuOp_i,                                                // Bit manipulation operation (32 instr.)                               
   output                  [31:0]                       result_o,                                               // Result            
   output      reg                                      finished_o                                              // Finished signal
    );  
    
    
    
    
always@ (posedge clk_i) begin
    if(rst_i) begin
        finished_o<=0;
    end
end


endmodule





/*
module BitManipulationUnit (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [4:0] bitOp_i, // Bit operation input
    input wire [31:0] operand1_i, // Operand 1 input
    input wire [31:0] operand2_i, // Operand 2 input
    output reg [31:0] result_o // Result output
);



 // Always block for the bit manipulation unit
 always @(posedge clk_i or posedge rst_i)
     begin
     // If the reset input is high, reset the result
         if(rst_i)
         begin
            result_o <= 0; // Reset the result
         end
            // If the enable input is high, perform the bit operation
         else if(enable_i)
         begin
         end
     end    


endmodule*/