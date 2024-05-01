module processor_tb();

localparam MEMORY_ADDRESS = 32'h8000_0000;
localparam ADDRESS_BIT = 32;
localparam DATA_BIT = 32;

reg clk_r;
reg rst_r;

wire [31:0] processor_MEMORY_ADDRESS_INS;
wire [31:0] processor_MEMORY_ADDRESS_DATA;
wire [DATA_BIT-1:0] processor_memory_read_data;
wire [DATA_BIT-1:0] processor_memory_read_ins;
wire [DATA_BIT-1:0] processor_memory_write_data;
wire processor_memory_write;
wire processor_memory_read;
wire get_instruction;
wire data_completed;
wire instruction_completed;

HelperMemory memory (
    .clk_i(clk_r),
    .rst_i(rst_r),
    .ins_address_i(processor_MEMORY_ADDRESS_INS),
    .data_address_i(processor_MEMORY_ADDRESS_DATA),
    .read_data_o(processor_memory_read_data),
    .read_ins_o(processor_memory_read_ins),
    .read_enable_i(processor_memory_read),
    .get_instruction_i(get_instruction),
    .write_data_i(processor_memory_write_data),
    .write_enable_i(processor_memory_write),
    .data_completed_o(data_completed),
    .instruction_completed_o(instruction_completed)
);

Processor processor (
    .clk_i(clk_r),
    .rst_i(rst_r),
    .instruction_i(processor_memory_read_ins),
    .data_i(processor_memory_read_data),
    .data_completed_i(data_completed),
    .instruction_completed_i(instruction_completed),
    .mem_address_o(processor_MEMORY_ADDRESS_INS),
    .read_enable_o(processor_memory_read),
    .get_instruction_o(get_instruction),
    .write_data_o(processor_memory_write_data),
    .write_enable_o(processor_memory_write),
    .data_address_o(processor_MEMORY_ADDRESS_DATA)
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
    rst_r = 1'b1;

    
    // Race condition engellemek icin sistem 1 cevrim calistirilir
    @(posedge clk_r); // reset sinyali aktif oldugu icin degisiklik olusmaz
    // https://luplab.gitlab.io/rvcodecjs/ <- assembly binary donusumu icin kullanabiliriniz
    // BUYRUKLAR ,
    /*
    memory_write('h8000_0000, 32'h064a8593);  // 3   addi x11, x21, 100
    memory_write('h8000_0004, 32'h03158ab3);  //  7   mul x21, x11, x17
    */
    
    /*
    memory_write('h8000_0000, 32'h03158ab3); //  7   mul x21, x11, x17
    memory_write('h8000_0004, 32'h008381b3); //  2   add  x3, x7, x8,
    memory_write('h8000_0008, 32'h064a8593);  // 3   addi x11, x21, 100
    */
    
      //memory_write('h8000_0000, 32'h40c288b3); //  5   sub x17, x5, x12
     // memory_write('h8000_0004, 32'h003589b3); //  6   add x19, x11, x3
   /*
    memory_write('h8000_0000, 32'h00940633);  // 1   add x12, x8, x9
    memory_write('h8000_0004, 32'h40c288b3); //  5   sub x17, x5, x12
    memory_write('h8000_0008, 32'h03158ab3); //  7   mul x21, x11, x17
    */
    
    
    /*
    memory_write('h8000_0000, 32'h00940633); // 1   add x12, x8, x9
    memory_write('h8000_0004, 32'h008381b3); //  2   add  x3, x7, x8
    memory_write('h8000_0008, 32'h00364863); // 3    blt x12,x3,16
    memory_write('h8000_000c, 32'h40c457b3); //  4   sra x15, x8, x12
    memory_write('h8000_0010, 32'h40c288b3); //  5   sub x17, x5, x12
    memory_write('h8000_0014, 32'h064a8593); // 3   addi x11, x21, 100
    memory_write('h8000_0018, 32'h003589b3); //  6   add x19, x11, x3
    memory_write('h8000_001c, 32'h40c288b3); //  5   sub x17, x5, x12
    memory_write('h8000_0020, 32'h0235cb33); //  8   div x22, x11, x3
    */
  
    memory_write('h8000_0000, 32'h00940633); // 1    add x12, x8, x9
    memory_write('h8000_0004, 32'h008381b3); //  2   add  x3, x7, x8
    memory_write('h8000_0008, 32'h40360f33);  // 3   sub x30, x12, x3
    memory_write('h8000_000c, 32'h15ef0e93); //  4   addi x29 x30 350
    memory_write('h8000_0010, 32'h40c288b3); //  5   sub x17, x5, x12
    memory_write('h8000_0014, 32'h003589b3); //  6   add x19, x11, x3
    memory_write('h8000_0018, 32'h03158ab3); //  7   mul x21, x11, x17
    memory_write('h8000_001c, 32'h025185b3);  // 10  mul x11, x3, x5
    memory_write('h8000_0020, 32'h00fa8e33); //  8   add x28, x21, x15
   // memory_write('h8000_0020,32'h016586b3);   // 12  add x13, x11, x22
    /*
    memory_write('h8000_001c, 32'h03158ab3);
    //memory_write('h8000_001c, 32'h0235cb33); //  8   div x22, x11, x3  ...bu buyrukta çöz ve execute flaglarý x gelmeye baþlýyor? onun dýþýnda her þey tamam.
    memory_write('h8000_0020, 32'h02897cb3);  // 9   remu x25, x18, x8
    memory_write('h8000_0024, 32'h025185b3);  // 10  mul x11, x3, x5
    memory_write('h8000_0028,32'h06cfa223);   // 11  sw x12, 100(x31)
    memory_write('h8000_002c,32'h016586b3);   // 12  add x13, x11, x22
    memory_write('h8000_0030,32'h000fae03);   // 13  lw x28, 0(x31)
    memory_write('h8000_0034,32'h016586b3);   // 14 add x13, x11, x22
    memory_write('h8000_0038,32'h073fa423);   // 15 sw x19, 104(x31)
    memory_write('h8000_003c,32'h00001f37);   // 16 lui x30, 1
    memory_write('h8000_0040,32'h016586b3);   // 17 add x13, x11, x22
    memory_write('h8000_0044,32'h016586b3);   // 18 add x13, x11, x22
    memory_write('h8000_0044,32'h00001f37);   // 16 lui x30, 1
    memory_write('h8000_0048,32'h01efa223);   // 19 sw x30, 4(x31)
    memory_write('h8000_004c,32'h00001717);   // 20 auipc x14, 1
    memory_write('h8000_0050,32'h00d5c663);   // 21 blt x11, x13, 12
    memory_write('h8000_005c,32'h01000eef);   // 22 jal x29, 16
    memory_write('h8000_006c,32'h078f8e67);   // 23 jalr x28, 120(x31)
*/
    /*
    memory_write('h8000_0000,32'h00d5c663);   // 21 blt x11, x13, 12
    memory_write('h8000_0004,32'h01000eef);   // 22 jal x29, 16
    memory_write('h8000_0008,32'h078f8e67);   // 23 jalr x28, 120(x31)
    
    */
    
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