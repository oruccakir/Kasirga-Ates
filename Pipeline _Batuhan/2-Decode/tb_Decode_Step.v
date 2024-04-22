`timescale 1ns / 1ps
`include "definitions.vh"


module tb_Decode_Step();
    reg clk_i;                
    reg rst_i;                
    reg enable_step_i;
    reg stall_i;
    
    reg [31:0]getir_buyruk_i;
    reg [31:0] getir_ps_i;
    
    reg [31:0] writeback_result_i;
    reg [ 4:0] writeback_address_i;
    reg        writeback_enable_i;
    
    reg write_integer_file_i;
    reg write_float_file_i;
    reg write_csr_file_i;
    
    wire [ 3:0] yurut_birim_secimi_o;
    wire [ 4:0] yurut_islem_secimi_o;
    wire [ 4:0] yurut_shamt_o;
    wire [ 2:0] yurut_rm_o;
    wire        yurut_aq_o;
    wire        yurut_rl_o;
    wire [31:0] yurut_integer_deger1_o;
    wire [31:0] yurut_integer_deger2_o;
    wire [31:0] yurut_float_deger1_o;
    wire [31:0] yurut_float_deger2_o;
    wire [31:0] yurut_float_deger3_o;
    wire [31:0] yurut_immidiate_o;
    wire [31:0] yurut_ps_yeni_o;
    wire [ 4:0] yurut_rd_adres_o;
    
    DecodeStep ds(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .enable_step_i(enable_step_i),
        .stall_i(stall_i),
        .getir_buyruk_i(getir_buyruk_i),
        .getir_ps_i(getir_ps_i),
        .writeback_result_i(writeback_result_i),
        .writeback_address_i(writeback_address_i),
        .writeback_enable_i(writeback_enable_i),
        .write_integer_file_i(write_integer_file_i),
        .write_csr_file_i(write_csr_file_i),
        .yurut_birim_secimi_o(yurut_birim_secimi_o),
        .yurut_islem_secimi_o(yurut_islem_secimi_o),
        .yurut_shamt_o(yurut_shamt_o),
        .yurut_rm_o(yurut_rm_o),
        .yurut_aq_o(yurut_aq_o),
        .yurut_rl_o(yurut_rl_o),
        .yurut_integer_deger1_o(yurut_integer_deger1_o),
        .yurut_integer_deger2_o(yurut_integer_deger2_o),
        .yurut_float_deger1_o(yurut_float_deger1_o),
        .yurut_float_deger2_o(yurut_float_deger2_o),
        .yurut_float_deger3_o(yurut_float_deger3_o),
        .yurut_immidiate_o(yurut_immidiate_o),
        .yurut_ps_yeni_o(yurut_ps_yeni_o),
        .yurut_rd_adres_o(yurut_rd_adres_o)
    ); 
    always begin
        clk_i =~clk_i;
        #5;
    end     
    
    initial begin
        rst_i = 1'b0;
        clk_i = 1'b0;
         
        
        getir_buyruk_i = 32'b010101010101_00000_000_00000_0010011; 
        #10;
        if((yurut_birim_secimi_o == `ARITHMETIC_LOGIC_UNIT) && (yurut_islem_secimi_o == `ALU_ADDI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
    end
    
    
endmodule