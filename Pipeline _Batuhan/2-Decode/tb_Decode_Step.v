`timescale 1ns / 1ps
`include "definitions.vh"


module tb_Decode_Step();
    reg clk_i;                
    reg rst_i;                
    reg execute_working_info_i;
    
    reg [31:0]getir_buyruk_i;
    reg [31:0] getir_ps_i;
    
    reg [31:0] writeback_result_i;
    reg [ 4:0] writeback_address_i;
    reg        writeback_enable_i;
    
    reg write_integer_file_i;
    reg write_float_file_i;
    reg write_csr_file_i;
    
    wire        yurut_FPU_en_o;
    wire        yurut_ALU_en_o;
    wire        yurut_IMU_en_o;
    wire        yurut_IDU_en_o;
    wire        yurut_BRU_en_o;
    wire        yurut_CU_en_o;
    wire        yurut_CSU_en_o;
    wire        yurut_AU_en_o;
    wire        yurut_BMU_en_o;
    wire        yurut_MU_en_o;
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
    wire        decode_working_info_o;
    
    DecodeStep ds(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .execute_working_info_i(execute_working_info_i),
        .getir_buyruk_i(getir_buyruk_i),
        .getir_ps_i(getir_ps_i),
        .writeback_result_i(writeback_result_i),
        .writeback_address_i(writeback_address_i),
        .writeback_enable_i(writeback_enable_i),
        .write_integer_file_i(write_integer_file_i),
        .write_csr_file_i(write_csr_file_i),
        .yurut_FPU_en_o(yurut_FPU_en_o),
        .yurut_ALU_en_o(yurut_ALU_en_o),
        .yurut_IMU_en_o(yurut_IMU_en_o),
        .yurut_IDU_en_o(yurut_IDU_en_o),
        .yurut_BRU_en_o(yurut_BRU_en_o),
        .yurut_CU_en_o(yurut_CU_en_o),
        .yurut_CSU_en_o(yurut_CSU_en_o),
        .yurut_AU_en_o(yurut_AU_en_o),
        .yurut_BMU_en_o(yurut_BMU_en_o),
        .yurut_MU_en_o(yurut_MU_en_o),
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
        .yurut_rd_adres_o(yurut_rd_adres_o),
        .decode_working_info_o(decode_working_info_o)
    ); 
    always begin
        clk_i =~clk_i;
        #5;
    end     
    
    initial begin
        rst_i = 1'b0;
        clk_i = 1'b0;
        execute_working_info_i = `EXECUTE_IS_NOT_WORKING;
        
        getir_buyruk_i =`ADD; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_ADD))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`SUB; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SUB))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`XOR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_XOR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`OR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_OR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AND; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_AND))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SRL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SRL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SRA; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SRA))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLT; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLT))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLTU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLTU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ADDI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_ADDI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLTI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLTI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLTIU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLTIU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`XORI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_XORI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ORI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_ORI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ANDI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_ANDI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SLLI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SLLI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SRLI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SRLI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SRAI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_SRAI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`SB; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_SB))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`SH; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_SH))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`SW; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_SW))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LB; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_LB))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LH; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_LH))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LW; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_LW))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LBU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_LBU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LHU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `ENABLE) && (yurut_islem_secimi_o == `MEM_LHU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BEQ; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BEQ))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BNE; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BNE))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BLT; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BLT))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BGE; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BGE))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BLTU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BLTU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`BGEU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_BGEU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`LUI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_LUI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`AUIPC; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `ENABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ALU_AUIPC))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`JAL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_JAL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end 

        getir_buyruk_i =`JALR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `ENABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BR_JALR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`MUL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `ENABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_MUL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`MULH; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `ENABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_MULH))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`MULHSU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `ENABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_MULHSU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`MULHU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `ENABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_MULHU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`DIV; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `ENABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_DIV))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`DIVU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `ENABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_DIVU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`REM; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `ENABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_REM))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`REMU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `ENABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `INT_REMU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`LR_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_LR_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SC_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_SC_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOSWAP_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOSWAP_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOADD_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOADD_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOXOR_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOXOR_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOAND_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOAND_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOOR_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOOR_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOMIN_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOMIN_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOMAX_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOMAX_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOMINU_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOMINU_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`AMOMAXU_W; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `ENABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `ATOM_AMOMAXU_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`FLW; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FLW))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSW; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSW))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMADD_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMADD_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMSUB_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMSUB_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FNMSUB_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FNMSUB_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FNMADD_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FNMADD_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FADD_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FADD_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSUB_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSUB_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMUL_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMUL_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FDIV_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FDIV_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSQRT_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSQRT_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSGNJ_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSGNJ_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSGNJN_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSGNJN_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FSGNJX_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FSGNJX_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMIN_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMIN_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMAX_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMAX_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FCVT_W_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FCVT_W_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FCVT_WU_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FCVT_WU_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMV_X_W; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMV_X_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FEQ_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FEQ_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FLT_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FLT_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FLE_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FLE_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FCLASS_S; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FCLASS_S))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FCVT_S_W; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FCVT_S_W))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FCVT_S_WU; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FCVT_S_WU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
                
        getir_buyruk_i =`FMV_W_X; 
        #10;
        if((yurut_FPU_en_o == `ENABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `DISABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `FLT_FMV_W_X))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end

        getir_buyruk_i =`ANDN; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ANDN))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CLMUL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CLMUL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CLMULH; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CLMULH))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CLMULR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CLMULR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CLZ; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CLZ))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CPOP; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CPOP))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`CTZ; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_CTZ))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`MAX; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_MAX))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`MAXU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_MAXU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`MIN; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_MIN))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`MINU; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_MINU))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ORC_B; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ORC_B))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ORN; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ORN))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`REV8; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_REV8))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ROL; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ROL))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ROR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ROR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`RORI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_RORI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BCLR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BCLR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BCLRI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BCLRI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BEXT; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BEXT))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BEXTI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BEXTI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BINV; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BINV))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BINVI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BINVI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BSET; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BSET))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`BSETI; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_BSETI))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SEXT_B; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_SEXT_B))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SEXT_H; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_SEXT_H))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SH1ADD; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_SH1ADD))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SH2ADD; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_SH2ADD))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`SH3ADD; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_SH3ADD))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`XNOR; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_XNOR))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        
        getir_buyruk_i =`ZEXT_H; 
        #10;
        if((yurut_FPU_en_o == `DISABLE) && (yurut_ALU_en_o == `DISABLE) && (yurut_IMU_en_o == `DISABLE) && (yurut_IDU_en_o == `DISABLE) && (yurut_BRU_en_o == `DISABLE) && (yurut_CSU_en_o == `DISABLE) && (yurut_AU_en_o == `DISABLE) && (yurut_BMU_en_o == `ENABLE) && (yurut_MU_en_o == `DISABLE) && (yurut_islem_secimi_o == `BT_ZEXT_H))begin
            $display("passed");
        end
        else begin
            $display("failed");
        end
        

        
        
       
    end
    
    
endmodule
