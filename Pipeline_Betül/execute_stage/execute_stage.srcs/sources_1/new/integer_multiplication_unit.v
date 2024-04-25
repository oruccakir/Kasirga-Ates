module integer_multiplication_unit(
   input                                                                   clk_i,
   input                                                                   rst_i,
   input                                                                   enable_integer_multiplication_unit_i,
   input                         [1:0]                                     mulOp_i,
   input                         [31:0]                                    operand1_i,
   input                         [31:0]                                    operand2_i,
   output                        [31:0]                                    result_o,
   output                                                                  register_type_selection_o,
   output         reg                                                      finished_o   
    );
    
    
    reg [4:0] cycle=0, cycle_s=0;
    reg finished_s=0;
    
    always@(*) begin
        cycle_s=cycle;
        if(enable_integer_multiplication_unit_i)begin
            if(cycle_s<31) begin
                cycle_s=cycle_s+1;
                finished_s=0;
            end else begin
                finished_s=1;           
            end
        
        end
    
    
    end
    
    always@(posedge clk_i)begin
        cycle<=cycle_s;
        finished_o<=finished_s;
    
    
    end
    
    
    
    
    
endmodule
