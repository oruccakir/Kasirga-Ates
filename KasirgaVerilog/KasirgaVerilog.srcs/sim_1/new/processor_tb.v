
module processor_tb();

localparam MEMORY_ADDRESS = 32'h8000_0000;
localparam ADDRESS_BIT = 32;
localparam DATA_BIT = 32;

reg clk_r;
reg rst_r;

wire [31:0] processor_MEMORY_ADDRESS;
wire [DATA_BIT-1:0] processor_memory_read_data;
wire [DATA_BIT-1:0] processor_memory_write_data;
wire processor_memory_write;


HelperMemory memory (
    .clk_i(clk_r),
    .address_i(processor_MEMORY_ADDRESS),
    .read_data_o(processor_memory_read_data),
    .write_data_i(processor_memory_write_data),
    .write_enable_i(processor_memory_write)
);

Processor processor (
    .clk_i(clk_r),
    .rst_i(rst_r),
    .instruction_i(processor_memory_read_data),
    .mem_address_o(processor_MEMORY_ADDRESS)
);

always begin
    clk_r = 1'b0;
    #5;
    clk_r = 1'b1;
    #5;
end

localparam MAX_CYCLES = 100;
integer stall_ctr;
initial begin
    stall_ctr = 0;
    //rst_r = 1'b1;
    // Race condition engellemek icin sistem 1 cevrim calistirilir
    @(posedge clk_r); // reset sinyali aktif oldugu icin degisiklik olusmaz
    // https://luplab.gitlab.io/rvcodecjs/ <- assembly binary donusumu icin kullanabiliriniz
    // BUYRUKLAR ,
    //memory_write('h8000_0000,32'h003100b3);   // add x1, x2, x3
    memory_write('h8000_0000, 32'h00500093); // addi x1, x0, 5
    //memory_write('h8000_0004, 32'h002081b3); // add  x3, x7, x8
    //memory_write('h8000_0004, 32'h003282b3); // add  x5, x5, x3

    // PROGRAM dataSI
    memory_write('h8000_0400, 32'hdeadbee0);
    memory_write('h8000_0404, 32'h55555555);

    // BUYRUKLAR - ALTERNATIF YONTEM (zaten 8000_0000'in 0. index oldugunu biliyoruz)
    // anamemory.memory[0] = 32'h00500093; 
    // anamemory.memory[1] = 32'h00a00113; 

    repeat (10) @(posedge clk_r); #2; // 10 cevrim reset
    rst_r = 1'b0;

end

task memory_write (
    input [ADDRESS_BIT-1:0] adres,
    input [DATA_BIT-1:0] data
);
begin
    memory.memory[address_row_idx(adres)] = data;
end
endtask

function [DATA_BIT-1:0] memory_read (
    input [ADDRESS_BIT-1:0] adres
);
begin
    memory_read = memory.memory[address_row_idx(adres)];
end
endfunction

// datalen adresi memory satir indisine donusturur.
function integer address_row_idx (
    input [ADDRESS_BIT-1:0] adres
);
begin
    address_row_idx = (adres - MEMORY_ADDRESS) >> $clog2(DATA_BIT / 8);
end
endfunction

endmodule