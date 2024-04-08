module HelperMemory #(
    parameter INITIAL_ADDRES = 32'h8000_0000,
    parameter ADDRES_BIT       = 32,
    parameter DATA_BIT        = 32,
    parameter MEMORY_INDEX    = 2048,
    parameter DEBUG           = "TRUE"
)(
    input wire                       clk_i,
    input wire   [ADDRES_BIT-1:0]    address_i,
    input wire   [DATA_BIT-1:0]      write_data_i,
    input wire                       write_enable_i,
    input wire                       get_instruction_i,
    input wire                       get_data_i,
    output wire  [DATA_BIT-1:0]      read_data_o,
    output wire                      data_completed_o,
    output wire                      instruction_completed_o   
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

reg data_completed = 1'b0;
reg instruction_completed = 1'b0;

reg [DATA_BIT-1:0] memory [0:MEMORY_INDEX-1];
reg [DATA_BIT-1:0] read_data_cmb;

wire mem_access_valid = (address_i >= INITIAL_ADDRES) && (address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire [ADDRES_BIT-1:0] MEM_INDEX = (address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);

integer i;
initial begin
    for (i = 0; i < MEMORY_INDEX; i = i + 1) begin
        memory[i] <= 0;
    end
end

integer instruction_latency = 0;
integer data_latency = 20;
integer instruction_counter = 0;
integer data_counter = 0;

always @(*)begin
    read_data_cmb = UNDEFINED;
        if(get_instruction_i) begin
            if(instruction_counter == instruction_latency) begin
                if(mem_access_valid)
                    read_data_cmb = memory[MEM_INDEX];
                instruction_counter = 0;
                instruction_completed = 1'b1;
            end
            else begin
                instruction_counter = instruction_counter + 1;
            end
        end
        else
            instruction_completed = 1'b0;
            
        if(get_data_i) begin
            if(data_counter == data_latency) begin
                if(mem_access_valid)
                    read_data_cmb = memory[MEM_INDEX];
                data_counter = 0;
                data_completed = 1'b1;
            end
            else begin
                data_counter = data_counter + 1;
            end
        end
        else
            data_completed = 1'b0;
end

always @(posedge clk_i) begin
    if (mem_access_valid && write_enable_i) begin
        $display("Memory WRITE writed data ",write_data_i);
        memory[MEM_INDEX] <= write_data_i;
    end
end

assign read_data_o = read_data_cmb;
assign data_completed_o = data_completed;
assign instruction_completed_o = instruction_completed;

endmodule