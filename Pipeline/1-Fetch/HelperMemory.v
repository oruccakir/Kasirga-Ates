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
    output wire  [DATA_BIT-1:0]      read_data_o
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

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

always @* begin
    read_data_cmb = UNDEFINED;
    if (mem_access_valid) begin
        read_data_cmb = memory[MEMORY_INDEX];
    end
end

always @(posedge clk_i) begin
    if (mem_access_valid && write_enable_i) begin
        memory[MEM_INDEX] <= write_data_i;
    end
end

assign read_data_o = read_data_cmb;

endmodule