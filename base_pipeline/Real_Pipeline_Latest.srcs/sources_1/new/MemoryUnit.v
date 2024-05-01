/*
include "definitions.vh";

module MemoryUnit(
    input wire clk_i,        // clk_i input comes from processor
    input wire rst_i,        // rst_i input comes from processor
    input wire enable_i,     // enable_i input comes from excecute step, when a memory instruction encountered
    input wire [31:0] data_i, // comes from memory that will assign to calculated result 
    input wire data_completed_i, // data completed comes from helper memory
    input wire [2:0] memOp_i, // Memory operation input
    input wire [31:0] mem_stored_data_i, // comes from execute step, indicates rs2_value
    input wire [31:0] calculated_memory_address_i, // comes from arithmetic logic unit
    output wire [31:0] mem_data_o, // Memory data output goes to memory
    output wire [31:0] mem_data_for_writeback_o, // Mem data output goes to writeback
    output wire [31:0] mem_address_o, // Memory address output goes to memory
    output wire write_enable_o, // goes to processor from there goes to helper memory
    output wire read_enable_o,   // read enable output goes to processor from there goes to memory
    output wire is_finished_o     // finish info for memory unit
);

reg [31:0] mem_address_next = 32'b0; // next reg for mem_address
reg [31:0] mem_data_next = 32'b0;    // next reg for mem_data


reg write_enable = 1'b0;        // write info goes to memory
reg read_enable = 1'b0;         // read info goes to memory
reg [31:0] mem_data = 32'h0;    // Memory data goes to memory
reg [31:0] mem_address = 32'h0; // Memory address goes to memory
wire isWorking;                 // Flag for working for this step
reg [31:0] calculated_result = 32'b0; // Calculated result will conveyed to 
reg [4:0] rd = 5'b0;                  // target register goes to writeback step
reg is_finished = 1'b0;     // Flag for finishing memory step // impoertant change

localparam FIRST_CYCLE = 3'b000; // State for desiring memory operation
localparam SECOND_CYCLE = 1'b001; // State for memory operation result
localparam STALL = 3'b010;        // State for stalling later will be deleted because writeback step will implemented without cycle logic
reg [2:0] STATE = FIRST_CYCLE;    // State for stalling the module


always @(*) begin
    mem_address_next = calculated_memory_address_i; // when trigerred assign next mem_address
    mem_data_next = mem_stored_data_i;              // when trigerred assign next mem_stored_data
end

always @(posedge clk_i) begin
    mem_address = mem_address_next;             // assign mem_address with clock   
    mem_data = mem_data_next;                   // assign mem_data with clock
end

assign isWorking = enable_i && is_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE:begin


                //mem_address = calculated_memory_address_i;
                //mem_data = mem_stored_data_i;
                $display("-->Performing memory operation for instruction num ");

                case(memOp_i)
                    `MEM_SW: begin
                        write_enable = 1'b1;
                        $display("Memory SW Instruction writed address %h",mem_address_next);
                     end
                    `MEM_LW: begin
                        read_enable = 1'b1;
                        $display("Memory LW Instruction readed address %h",mem_address_next);
                     end
                    `MEM_LB: begin
                     end
                    `MEM_LH: begin
                     end
                    `MEM_LBU: begin
                     end
                    `MEM_LHU: begin
                     end
                    `MEM_SB: begin
                     end
                    `MEM_SH: begin
                     end
                endcase
               // rd = rd_i;
                STATE <= SECOND_CYCLE;
            end
            SECOND_CYCLE:begin
                case(memOp_i)
                    `MEM_SW: begin
                        write_enable = 1'b0;
                     end
                    `MEM_LW: begin
                        read_enable = 1'b0;
                        $display("data completed ",data_completed_i);
                        $display("From Memory readed %h",data_i);
                        calculated_result = data_i;
                     end
                    `MEM_LB: begin
                     end
                    `MEM_LH: begin
                     end
                    `MEM_LBU: begin
                     end
                    `MEM_LHU: begin
                     end
                    `MEM_SB: begin
                     end
                    `MEM_SH: begin
                     end
                endcase


                $display("-->Memory operation completed for instruction");
                is_finished =1'b1; 
                STATE = FIRST_CYCLE; 
            end
            STALL: begin
                $display("STALL FOR MEMORY");
                STATE = FIRST_CYCLE;
            end
        endcase
    end
end

assign mem_data_o = mem_data;                        // Assign the memory data, goes to memory
assign mem_address_o = mem_address;                  // Assign the memory address, goes to memory
assign is_finished_o = is_finished;                  // Assign the flag for finishing memory step


assign write_enable_o = write_enable;                // Assign write_enable, goes to memory
assign read_enable_o = read_enable;                  // Assign read_enable, goes to mempory
assign mem_data_for_writeback_o = calculated_result; // Assign result for writeback step
endmodule
*/