// Purpose: Atomic unit for the execute stage of the pipeline.
// Functionality: This module performs atomic operations.
// File: AtomicUnit.v

module AtomicUnit(
   input                                            clk_i,                              // Clock signal            
   input                                            rst_i,                              // Reset signal                                  
   input                                            enable_atomic_unit_i,                // Start signal for the atomic unit                        
   input                         [31:0]             operand1_i,                         // Operand 1                                    
   input                         [31:0]             operand2_i,                         // Operand 2
   input                         [2:0]              atomicOp_i,                         // Atomic operation (11 instr.) 
   input                                            aq_i,
   input                                            rl_i,                             
   output                        [31:0]             calculated_memory_address_o,        // Calculated memory address                        
   output                        [31:0]             calculated_result_o,                // Calculated result
   output                                           extension_mode_o,                   // Extension mode  0: zero extension, 1: sign extension                        
   output                        [2:0]              au_memory_operation_type_o,         // Memory operation type                    
   output                                           register_type_selection_o,          // Register type selection                                
   output            reg                            finished_o                          // Finished signal                                  
    );

/*
module AtomicUnit(
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_i, // Enable input
    input wire [4:0] atomicOp_i, // Atomic operation input
    output wire is_finished_o,  // finished output
    output wire [31:0] result_o // result output
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

assign isWorking = (enable_i && is_finished != 1'b1);

always@(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            CYCLE1: begin
            
            end
            CYCLE2: begin
            
            end
            CYCLE3: begin
            
            end
            CYCLE4: begin
            
            end
            CYCLE5: begin
                STATE = CYCLE1;
                is_finished = 1'b1;
            end
        endcase
    end
end

assign is_finished_o = is_finished;
assign result_o = result;
*/
endmodule
