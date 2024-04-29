// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

include "definitions.vh";

module MemoryStep (
    input wire clk_i,                                            // Clock input
    input wire rst_i,                                            // Reset input
    input wire [31:0] data_i,                                    // comes from memory that will assign to calculated result 
    input wire [31:0] mem_address_i,                             // comes from execute calculated by ALU
    input wire [3:0] unit_type_i,                                // comes from execute step indicate memory operations
    input wire data_completed_i,                                 // data completed comes from helper memory
    input wire [2:0] memOp_i,                                    // Memory operation input
    input wire [31:0] calculated_result_i,                       // this comes from execute1 step
    input wire [4:0] rd_i,                                       // target register comes from execute step
    input wire [31:0] mem_stored_data_i,                         // comes from execute step, indicates rs2_value
    input wire [1:0] register_selection_i,                       // comes from execute step, goes to writeback step
    output wire [31:0] mem_data_o,                               // Memory data output goes to memory
    output wire [31:0] mem_address_o,                            // Memory address output goes to memory
    output wire [31:0] calculated_result_o,                      // calculated_result this will conveyed to writeback step
    output wire memory_working_info_o,                           // memory working info, goes to execute step
    output wire [4:0] rd_o,                                      // target register goes to writeback step
    output wire write_enable_o,                                  // goes to processor from there goes to helper memory
    output wire read_enable_o,                                   // read enable output goes to processor from there goes to memory
    output wire [2:0] write_register_info_o                      // goes to writeback step to write necessary info to register files
);

reg [2:0] write_register_info;
wire [31:0] mem_data_next;                                        // Memory data next
wire [31:0] mem_address_next;                                     // Memory address next    
reg [31:0] calculated_result_next;                                // Calculated result next
reg [4:0] rd_next;                                                // target register next
reg [1:0] register_selection_next;                                // register selection next
wire write_enable_next;                                           // write enable next
wire read_enable_next;                                            // read enable next


wire memory_working_info;                                          // Working info for memory step, goes to execute step
reg write_enable;                                                 // write info goes to memory
reg read_enable;                                                  // read info goes to memory
reg [31:0] mem_data;                                              // Memory data goes to memory
reg [31:0] mem_address;                                           // Memory address goes to memory
reg [31:0] calculated_result;                                     // Calculated result will conveyed to 
reg [4:0] rd;                                                     // target register goes to writeback step
integer i = -1;                                                   // For debugging the instruction number
reg [1:0] register_selection;                                     // register selection info, will be conveyed to writeback step

wire [31:0] calculated_result_mem;
wire [31:0] calculated_result_atom;
wire enable_memory_unit;
wire enable_atomic_unit;
wire finished_memory_unit;
wire finished_atomic_unit;

assign enable_memory_unit = (unit_type_i == `MEMORY_UNIT);
assign enable_atomic_unit = (unit_type_i == `ATOMIC_UNIT);

wire memory_unit_working_info;
wire atomic_unit_working_info;

assign memory_unit_working_info = (enable_memory_unit && ~finished_memory_unit);
assign atomic_unit_working_info = (enable_atomic_unit && ~finished_atomic_unit);

assign memory_working_info = memory_unit_working_info ||
                                atomic_unit_working_info;
// Memory Unit
/*MemoryUnit memory_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_memory_unit),
    .data_i(data_i),
    .data_completed_i(data_completed_i),
    .memOp_i(memOp_i),
    .mem_stored_data_i(mem_stored_data_i),
    .calculated_memory_address_i(mem_address_i),
    .mem_data_o(mem_data_next),
    .mem_address_o(mem_address_next),
    .write_enable_o(write_enable_next),
    .read_enable_o(read_enable_next),
    .mem_data_for_writeback_o(calculated_result_atom),
    .is_finished_o(finished_memory_unit)
);

AtomicUnit atomic_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_atomic_unit),
    .data_i(data_i),
    .data_completed_i(data_completed_i),
    .mem_stored_data_i(mem_stored_data_i),
    .mem_address_i(mem_address_i),
    .mem_address_o(mem_address_next),
     .write_enable_o(write_enable_next),
    .read_enable_o(read_enable_next),
    .mem_data_for_writeback_o(calculated_result_mem),
    .is_finished_o(finished_atomic_unit)
);

*/

// this always blocj is for debugging purposes
always @(*) begin
    $display("@@ MEMORY STAGE STARTED for instruction");
    $display("--> Calculated Memory address by ALU : %d ",mem_address_i);
end


always @(*) begin 
    register_selection_next = register_selection_i;
    rd_next = rd_i;
    calculated_result_next = calculated_result_i;
end

always @(posedge clk_i) begin
    if(rst_i) begin
        write_register_info <= 3'b0;
        calculated_result <= 32'b0;     calculated_result_next <= 32'b0;
        rd <= 5'b0;                     rd_next <= 5'b0;
        register_selection <= 2'b0;     register_selection_next <= 32'b0;
    end
    else begin
        write_enable <= write_enable_next;
        read_enable <= read_enable_next;
        mem_address <= mem_address_next;
        if(memory_working_info == 1'b0) begin
            calculated_result <= calculated_result_next;
            register_selection <= register_selection_next;
            mem_data <= mem_data_next;
            rd <= rd_next;
            write_register_info <= (register_selection_next == `INTEGER_REGISTER) ? 3'b100 :       // update write register info
                   (register_selection_next == `FLOAT_REGISTER) ? 3'b010 : 
                   (register_selection_next == `CSR_REGISTER) ? 3'b001 : 
                   3'b000;
        end
    end
end

assign mem_data_o = mem_data;                       // Assign the memory data, goes to memory
assign mem_address_o = mem_address;                 // Assign the memory address, goes to memory
assign calculated_result_o = calculated_result;     // Assign result info, goes to writeback step
assign memory_working_info_o = memory_working_info; // Assign memory working info, goes to execute step
assign rd_o = rd;                                   // Assign target register, goes to writeback step
assign write_enable_o = write_enable;               // Assign write_enable, goes to memory
assign read_enable_o = read_enable;                 // Assign read_enable, goes to mempory
assign write_register_info_o = write_register_info; //  Assign register write info
endmodule
/*
// Purpose: Memory step module for the pipeline.
// Functionality: This module performs the memory stage of the pipeline.
// File: MemoryStep.v

include "definitions.vh";

module MemoryStep (
    input wire clk_i,                                            // Clock input
    input wire rst_i,                                            // Reset input
    input wire [31:0] data_i,                                    // comes from memory that will assign to calculated result 
    input wire [31:0] mem_address_i,                             // comes from execute calculated by ALU
    input wire [3:0] unit_type_i,                                // comes from execute step indicate memory operations
    input wire data_completed_i,                                 // data completed comes from helper memory
    input wire [2:0] memOp_i,                                    // Memory operation input
    input wire [31:0] calculated_result_i,                       // this comes from execute1 step
    input wire [4:0] rd_i,                                       // target register comes from execute step
    input wire [31:0] mem_stored_data_i,                         // comes from execute step, indicates rs2_value
    input wire [1:0] register_selection_i,                       // comes from execute step, goes to writeback step
    output wire [31:0] mem_data_o,                               // Memory data output goes to memory
    output wire [31:0] mem_address_o,                            // Memory address output goes to memory
    output wire [31:0] calculated_result_o,                      // calculated_result this will conveyed to writeback step
    output wire memory_working_info_o,                           // memory working info, goes to execute step
    output wire [4:0] rd_o,                                      // target register goes to writeback step
    output wire write_enable_o,                                  // goes to processor from there goes to helper memory
    output wire read_enable_o,                                    // read enable output goes to processor from there goes to memory
    output wire [2:0] write_register_info_o                       // goes to writeback step to write necessary info to register files
);

reg [2:0] write_register_info;
reg [31:0] mem_data_next;                                        // Memory data next
reg [31:0] mem_address_next;                                     // Memory address next    
reg [31:0] calculated_result_next;                               // Calculated result next
reg [4:0] rd_next;                                               // target register next
reg [1:0] register_selection_next;                               // register selection next
reg write_enable_next;                                           // write enable next
reg read_enable_next;                                            // read enable next


reg memory_working_info;        // Working info for memory step, goes to execute step
reg write_enable;               // write info goes to memory
reg read_enable;                // read info goes to memory
reg [31:0] mem_data;            // Memory data goes to memory
reg [31:0] mem_address;         // Memory address goes to memory
reg [31:0] calculated_result;   // Calculated result will conveyed to 
reg [4:0] rd;                   // target register goes to writeback step
integer i = -1;                  // For debugging the instruction number
reg [1:0] register_selection;   // register selection info, will be conveyed to writeback step


// this always blocj is for debugging purposes
always @(*) begin
    $display("@@ MEMORY STAGE STARTED for instruction");
    $display("--> Calculated Memory address by ALU : %d ",mem_address_i);
    if(unit_type_i == `MEMORY_UNIT) begin
        case(memOp_i) 
            `MEM_SW: begin
                $display("Memory SW Instruction writed address %h",mem_address_i);
            end
            `MEM_LW: begin
                $display("Memory LW Instruction readed address %h",mem_address_i);
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
    end
end


always @(*) begin 
    mem_address_next <= mem_address_i;
    mem_data_next <= mem_stored_data_i;
    register_selection_next = register_selection_i;
    rd_next = rd_i;
    calculated_result_next = calculated_result_i;
    if(unit_type_i == `MEMORY_UNIT) begin
        case(memOp_i) 
            `MEM_SW: begin
                write_enable = 1'b1;
            end
            `MEM_LW: begin
                read_enable = 1'b1;
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
    end
end

always @(posedge clk_i) begin
    if(rst_i) begin
        write_register_info <= 3'b0;
        memory_working_info <= 1'b0;      
        write_enable <=1'b0;            read_enable_next <= 1'b0;
        read_enable <= 1'b0;            write_enable_next <= 1'b0;
        mem_data <= 32'b0;              mem_data_next <= 32'b0;
        mem_address <= 32'b0;           mem_address_next <= 32'b0;
        calculated_result <= 32'b0;     calculated_result_next <= 32'b0;
        rd <= 5'b0;                     rd_next <= 5'b0;
        register_selection <= 2'b0;     register_selection_next <= 32'b0;
    end
    else begin
        write_enable <= write_enable_next;
        read_enable <= read_enable_next;
        mem_address <= mem_address_next;
        if(memory_working_info == 1'b0) begin
            calculated_result <= calculated_result_next;
            register_selection <= register_selection_next;
            mem_data <= mem_data_next;
            rd <= rd_next;
            write_register_info <= (register_selection_next == `INTEGER_REGISTER) ? 3'b100 :       // update write register info
                   (register_selection_next == `FLOAT_REGISTER) ? 3'b010 : 
                   (register_selection_next == `CSR_REGISTER) ? 3'b001 : 
                   3'b000;
        end
    end
end

assign mem_data_o = mem_data;                       // Assign the memory data, goes to memory
assign mem_address_o = mem_address;                 // Assign the memory address, goes to memory
assign calculated_result_o = calculated_result;     // Assign result info, goes to writeback step
assign memory_working_info_o = memory_working_info; // Assign memory working info, goes to execute step
assign rd_o = rd;                                   // Assign target register, goes to writeback step
assign write_enable_o = write_enable;               // Assign write_enable, goes to memory
assign read_enable_o = read_enable;                 // Assign read_enable, goes to mempory
assign write_register_info_o = write_register_info; //  Assign register write info
endmodule
*/