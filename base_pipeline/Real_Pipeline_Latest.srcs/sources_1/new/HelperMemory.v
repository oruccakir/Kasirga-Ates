/*
module HelperMemory #(
    parameter INITIAL_ADDRES = 32'h8000_0000,
    parameter ADDRES_BIT       = 32,
    parameter DATA_BIT        = 32,
    parameter MEMORY_INDEX    = 2048,
    parameter DEBUG           = "TRUE"
)(
    input wire                       clk_i,
    input wire                       rst_i,
    input wire   [ADDRES_BIT-1:0]    ins_address_i,
    input wire   [31:0]              data_address_i,
    input wire   [DATA_BIT-1:0]      write_data_i,
    input wire                       write_enable_i,
    input wire                       get_instruction_i,
    input wire                       read_enable_i,
    output wire  [DATA_BIT-1:0]      read_data_o,
    output wire  [31:0]              read_ins_o,
    output wire                      data_completed_o,
    output wire                      instruction_completed_o   
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

reg data_completed = 1'b0;
reg instruction_completed;

reg [DATA_BIT-1:0] memory [0:MEMORY_INDEX-1];
reg [DATA_BIT-1:0] read_data_cmb;
reg [31:0]  read_ins_cmb;


wire mem_access_valid_ins = (ins_address_i >= INITIAL_ADDRES) && (ins_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire mem_access_valid_data = (data_address_i >= INITIAL_ADDRES) && (data_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire [ADDRES_BIT-1:0] MEM_INDEX_INS = (ins_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);
wire [ADDRES_BIT-1:0] MEM_INDEX_DATA = (data_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);

integer i;

initial begin

end


integer instruction_latency = 0;
integer data_latency = 0;
integer instruction_counter = 0;
integer data_counter = 0;

always @(*)begin
   // read_ins_cmb = UNDEFINED;
   
    if(mem_access_valid_ins && get_instruction_i) begin
        read_ins_cmb = memory[MEM_INDEX_INS];
        instruction_completed = 1'b1;
     end
                    
        if(read_enable_i) begin
            if(data_counter == data_latency) begin
                if(mem_access_valid_data) begin
                    read_data_cmb = memory[MEM_INDEX_DATA];
                    $display("Reading from this address %h",data_address_i);
                    $display("Data is being reading %h ",read_data_cmb);
                end
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
    if (mem_access_valid_data && write_enable_i) begin
        $display("Memory WRITE writed data ",write_data_i);
        $display("Memory WRITE writed address %h ",data_address_i);
        memory[MEM_INDEX_DATA] <= write_data_i;
    end
end

always@(posedge rst_i) begin
        read_ins_cmb <= 32'b0;
        instruction_completed <= 1'b0;
        for (i = 0; i < MEMORY_INDEX; i = i + 1) begin
            memory[i] <= 0;
    end
end

assign read_data_o = read_data_cmb;
assign data_completed_o = data_completed;
assign instruction_completed_o = instruction_completed;
assign read_ins_o = read_ins_cmb;

endmodule


/*
module HelperMemory #(
    parameter INITIAL_ADDRES = 32'h8000_0000,
    parameter ADDRES_BIT       = 32,
    parameter DATA_BIT        = 32,
    parameter MEMORY_INDEX    = 2048,
    parameter DEBUG           = "TRUE"
)(
    input wire                       clk_i,
    input wire                       rst_i,
    input wire   [ADDRES_BIT-1:0]    ins_address_i,
    input wire   [31:0]              data_address_i,
    input wire   [DATA_BIT-1:0]      write_data_i,
    input wire                       write_enable_i,
    input wire                       get_instruction_i,
    input wire                       read_enable_i,
    output wire  [DATA_BIT-1:0]      read_data_o,
    output wire  [31:0]              read_ins_o,
    output wire                      data_completed_o,
    output wire                      instruction_completed_o   
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

reg data_completed;
reg instruction_completed;
reg instruction_completed_next;
reg [31:0] instruction;

reg [DATA_BIT-1:0] memory [0:MEMORY_INDEX-1];
reg [DATA_BIT-1:0] read_data_cmb;
reg [31:0]  read_ins_cmb;


wire mem_access_valid_ins = (ins_address_i >= INITIAL_ADDRES) && (ins_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire mem_access_valid_data = (data_address_i >= INITIAL_ADDRES) && (data_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire [ADDRES_BIT-1:0] MEM_INDEX_INS = (ins_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);
wire [ADDRES_BIT-1:0] MEM_INDEX_DATA = (data_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);

integer i;
/*
initial begin

end
*/
/*
integer instruction_latency = 0;
integer data_latency = 0;
integer instruction_counter = 0;
integer data_counter = 0;

always @(*)begin
   // read_ins_cmb = UNDEFINED;
   
    if(mem_access_valid_ins && get_instruction_i)
        read_ins_cmb = memory[MEM_INDEX_INS];
                    
        if(read_enable_i) begin
            if(data_counter == data_latency) begin
                if(mem_access_valid_data) begin
                    read_data_cmb = memory[MEM_INDEX_DATA];
                    $display("Reading from this address %h",data_address_i);
                    $display("Data is being reading %h ",read_data_cmb);
                end
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
    if(rst_i) begin
        instruction_completed <= 1'b0;
        data_completed <= 1'b0;
        instruction_completed_next <= 1'b0;
        read_ins_cmb <= 32'b0;
        instruction <= 32'b0;
        for (i = 0; i < MEMORY_INDEX; i = i + 1)
            memory[i] <= 0;
    end
    else begin
        if (mem_access_valid_data && write_enable_i) begin
            $display("Memory WRITE writed data ",write_data_i);
            $display("Memory WRITE writed address %h ",data_address_i);
            memory[MEM_INDEX_DATA] <= write_data_i;
        end
        if(get_instruction_i)
            instruction <= read_ins_cmb;
    end
end



assign read_data_o = read_data_cmb;
assign data_completed_o = data_completed;
assign instruction_completed_o = instruction_completed;
assign read_ins_o = instruction;

endmodule
*/



module HelperMemory #(
    parameter INITIAL_ADDRES = 32'h8000_0000,
    parameter ADDRES_BIT       = 32,
    parameter DATA_BIT        = 32,
    parameter MEMORY_INDEX    = 2048,
    parameter DEBUG           = "TRUE"
)(
    input wire                       clk_i,
    input wire                       rst_i,
    input wire   [ADDRES_BIT-1:0]    ins_address_i,
    input wire   [31:0]              data_address_i,
    input wire   [DATA_BIT-1:0]      write_data_i,
    input wire                       write_enable_i,
    input wire                       get_instruction_i,
    input wire                       read_enable_i,
    output wire  [DATA_BIT-1:0]      read_data_o,
    output wire  [31:0]              read_ins_o,
    output wire                      data_completed_o,
    output wire                      instruction_completed_o   
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

reg data_completed = 1'b0;
reg instruction_completed;
reg instruction_completed_next;

reg [DATA_BIT-1:0] memory [0:MEMORY_INDEX-1];
reg [DATA_BIT-1:0] read_data_cmb;
reg [31:0]  read_ins_cmb;
reg [31:0] read_ins;

wire mem_access_valid_ins = (ins_address_i >= INITIAL_ADDRES) && (ins_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire mem_access_valid_data = (data_address_i >= INITIAL_ADDRES) && (data_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire [ADDRES_BIT-1:0] MEM_INDEX_INS = (ins_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);
wire [ADDRES_BIT-1:0] MEM_INDEX_DATA = (data_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);

integer i;




integer instruction_latency = 0;
integer data_latency = 0;
integer instruction_counter = 0;
integer data_counter = 0;

always @(*)begin
   // read_ins_cmb = UNDEFINED;d
    $display("Getting instruction address %h",ins_address_i );
    if(mem_access_valid_ins) begin
        read_ins_cmb = memory[MEM_INDEX_INS];
     end
                    
        if(read_enable_i) begin
            if(data_counter == data_latency) begin
                if(mem_access_valid_data) begin
                    read_data_cmb = memory[MEM_INDEX_DATA];
                    $display("Reading from this address %h",data_address_i);
                    $display("Data is being reading %h ",read_data_cmb);
                end
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
     if(rst_i)begin
        read_ins <= 32'b0;
        instruction_completed_next <= 1'b0;
        read_ins_cmb <= 32'b0;
        instruction_completed <= 1'b0;
    end
    else begin
        if(instruction_counter == 2) begin
            instruction_completed_next = 1'b1;
            instruction_counter = 0;
        end
        else begin
            instruction_counter = instruction_counter + 1;
            instruction_completed_next = 1'b0;
            instruction_completed = instruction_completed_next;
        end
        if(instruction_completed_next) begin
            read_ins <= read_ins_cmb;
            instruction_completed <= instruction_completed_next;
        end
        if (mem_access_valid_data && write_enable_i) begin
            $display("Memory WRITE writed data ",write_data_i);
            $display("Memory WRITE writed address %h ",data_address_i);
            memory[MEM_INDEX_DATA] <= write_data_i;
        end
    end
end


assign read_data_o = read_data_cmb;
assign data_completed_o = data_completed;
assign instruction_completed_o = instruction_completed;
assign read_ins_o = read_ins;

endmodule


/*
module HelperMemory #(
    parameter INITIAL_ADDRES = 32'h8000_0000,
    parameter ADDRES_BIT       = 32,
    parameter DATA_BIT        = 32,
    parameter MEMORY_INDEX    = 2048,
    parameter DEBUG           = "TRUE"
)(
    input wire                       clk_i,
    input wire                       rst_i,
    input wire   [ADDRES_BIT-1:0]    ins_address_i,
    input wire   [31:0]              data_address_i,
    input wire   [DATA_BIT-1:0]      write_data_i,
    input wire                       write_enable_i,
    input wire                       get_instruction_i,
    input wire                       read_enable_i,
    output wire  [DATA_BIT-1:0]      read_data_o,
    output wire  [31:0]              read_ins_o,
    output wire                      data_completed_o,
    output wire                      instruction_completed_o   
);

localparam UNDEFINED = DEBUG == "TRUE" ? {DATA_BIT{1'bZ}} : {DATA_BIT{1'b0}};

reg data_completed;
reg instruction_completed;
reg instruction_completed_next;
reg [31:0] instruction;

reg [DATA_BIT-1:0] memory [0:MEMORY_INDEX-1];
reg [DATA_BIT-1:0] read_data_cmb;
reg [31:0]  read_ins_cmb;


wire mem_access_valid_ins = (ins_address_i >= INITIAL_ADDRES) && (ins_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire mem_access_valid_data = (data_address_i >= INITIAL_ADDRES) && (data_address_i < (INITIAL_ADDRES + MEMORY_INDEX));
wire [ADDRES_BIT-1:0] MEM_INDEX_INS = (ins_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);
wire [ADDRES_BIT-1:0] MEM_INDEX_DATA = (data_address_i - INITIAL_ADDRES) >> $clog2(DATA_BIT / 8);

integer i;
/*
initial begin

end
*/
/*
integer instruction_latency = 0;
integer data_latency = 0;
integer instruction_counter = 0;
integer data_counter = 0;

always @(*)begin
   // read_ins_cmb = UNDEFINED;
   
    if(mem_access_valid_ins && get_instruction_i)
        read_ins_cmb = memory[MEM_INDEX_INS];
                    
        if(read_enable_i) begin
            if(data_counter == data_latency) begin
                if(mem_access_valid_data) begin
                    read_data_cmb = memory[MEM_INDEX_DATA];
                    $display("Reading from this address %h",data_address_i);
                    $display("Data is being reading %h ",read_data_cmb);
                end
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
    if(rst_i) begin
        instruction_completed <= 1'b0;
        data_completed <= 1'b0;
        instruction_completed_next <= 1'b0;
        read_ins_cmb <= 32'b0;
        instruction <= 32'b0;
        for (i = 0; i < MEMORY_INDEX; i = i + 1)
            memory[i] <= 0;
    end
    else begin
        if (mem_access_valid_data && write_enable_i) begin
            $display("Memory WRITE writed data ",write_data_i);
            $display("Memory WRITE writed address %h ",data_address_i);
            memory[MEM_INDEX_DATA] <= write_data_i;
        end
        if(get_instruction_i)
            instruction <= read_ins_cmb;
    end
end



assign read_data_o = read_data_cmb;
assign data_completed_o = data_completed;
assign instruction_completed_o = instruction_completed;
assign read_ins_o = instruction;

endmodule
*/
