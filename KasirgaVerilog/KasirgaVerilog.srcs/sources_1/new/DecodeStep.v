// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input   
    output wire decode_finished_o
);

//Decode modul implementation
reg decode_finished = 1'b0;
wire isWorking;

localparam INS_DESIRE = 1'b0;
localparam INS_RESULT = 1'b1;

reg STATE = INS_DESIRE;

assign isWorking = enable_step_i && decode_finished != 1'b1;

always @(posedge clk_i) begin
    if(isWorking)
        begin
            case(STATE)
                INS_DESIRE :
                    begin
                        $display("DecodeStep: Decoding instruction %h", instruction_i);
                        STATE = INS_RESULT;
                    end
                INS_RESULT :
                    begin
                        $display("DecodeStep: Decoding completed");
                        decode_finished <= 1'b1;
                        STATE = INS_DESIRE;
                    end
            endcase
            
           
        end
end
   
assign decode_finished_o = decode_finished;

endmodule