// Purpose: Control Status Unit for the Execute stage of the pipeline.
// Functionality: This module performs the control status of the pipeline.
// File: ControlStatusUnit.v
module ControlStatusUnit (
   input                                                        clk_i,
   input                                                        rst_i,
   input                                                        enable_control_status_unit_i,
   output                      reg                              finished_o
    );



always@ (posedge clk_i) begin
    if(rst_i) begin
        finished_o<=0;
    end
end
endmodule