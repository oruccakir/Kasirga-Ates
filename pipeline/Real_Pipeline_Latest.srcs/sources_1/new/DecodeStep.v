`timescale 1ns / 1ps

`include "definitions.vh"

module DecodeStep (
    input wire clk_i,                      // Clock input
    input wire rst_i,                      // Reset input
    input wire execute_working_info_i,     // is execute working
    
    //execute
    input wire [ 4:0] forwarded_rd_i,
    input wire [31:0] forwarded_data_i,

    //getir
    input wire [31:0] getir_buyruk_i,       // Instruction input 
    input wire [31:0] getir_ps_i,                // Program Counter input (?program sayac  uzunlugu)

    //writeback 
    input wire [31:0] writeback_result_i,  // Writeback input
    input wire [ 4:0] writeback_address_i, // writeback_address input

    //register file flags - 3 register file ??gerek olmayabilir
    input wire write_integer_file_i,    // write IntegerRegisterFile
    input wire write_float_file_i,      // write FloatRegisterFile
    input wire write_csr_file_i,        // write CsrRegisterFile

    //Y r t - CSR buyruklar  ile ilgili i lemleri sonraya b rak yorum
    output reg        yurut_FPU_en_o,
    output reg        yurut_ALU_en_o,
    output reg        yurut_IMU_en_o,
    output reg        yurut_IDU_en_o,
    output reg        yurut_BRU_en_o,
    output reg        yurut_CSU_en_o,
    output reg        yurut_AU_en_o,
    output reg        yurut_BMU_en_o,
    output reg        yurut_MU_en_o,
    output reg [ 4:0] yurut_islem_secimi_o,      // o birimde hangi buyru un islemi yap lacag 
    output reg [ 4:0] yurut_shamt_o,             // baz  buyruklarda bulunan shamt degeri
    output reg [ 2:0] yurut_rm_o,                // baz  buyruklarda bulunan rm degeri
    output reg        yurut_aq_o,                // baz  buyruklarda bulunan aq de eri
    output reg        yurut_rl_o,                // baz  buyruklarda bulunan rl degeri
    output reg [31:0] yurut_integer_deger1_o,    // yurut birimi integer girdileri
    output reg [31:0] yurut_integer_deger2_o,   
    output reg [31:0] yurut_float_deger1_o,      // yurut birimi float girdileri
    output reg [31:0] yurut_float_deger2_o,   
    output reg [31:0] yurut_float_deger3_o,
    output reg [31:0] yurut_mem_store_data_o,      // store buyruklar� icin rs2 degeri
    output reg [31:0] yurut_immidiate_o,         // immidiate value
    output reg [31:0] yurut_ps_yeni_o,           // Geriyaz'a kadar   kt lar
    output reg [ 4:0] yurut_rd_adres_o ,
    output reg [ 1:0] writeback_reg_file_sec_o,
    output wire       decode_working_info_o,
    output reg [31:0] mem_stored_data_o
            
);

reg [31:0]  mem_stored_sonraki_r;
reg [ 4:0]  rd_sonraki_r;
reg [ 1:0]  reg_file_sec_r;
reg [ 4:0]  islem_secimi_sonraki_r;
reg [ 4:0]  shamt_sonraki_r;
reg [ 2:0]  rm_sonraki_r;
reg [31:0]  first_operand;
reg [31:0]  second_operand;
reg [31:0]  immidiate_sonraki_r;     
reg [31:0]  ps_yeni_sonraki_r;       
reg [ 4:0]  rd_adres_sonraki_r;
reg         FPU_en_sonraki;
reg         ALU_en_sonraki;
reg         IMU_en_sonraki;
reg         IDU_en_sonraki;
reg         BRU_en_sonraki;
reg         CU_en_sonraki;
reg         CSU_en_sonraki;
reg         AU_en_sonraki;
reg         BMU_en_sonraki;
reg         MU_en_sonraki;
reg         aq_sonraki_r;
reg         rl_sonraki_r;
reg         enable_first_operand;
reg         enable_second_operand;
reg         change_reg_state_r;
reg [ 4:0]  rs1;
reg [ 4:0]  rs2;

wire [31:0] integer_deger1_sonraki_r;
wire [31:0] integer_deger2_sonraki_r;
wire [31:0] float_deger1_sonraki_r;  
wire [31:0] float_deger2_sonraki_r;  
wire [31:0] float_deger3_sonraki_r;
wire [31:0] mem_store_data_sonraki_r;
wire        rs1_state;
wire        rs2_state;
wire        data_forwarding_rs1;
wire        data_forwarding_rs2;
wire        decode_next_instruction;
wire        data_dependency_rs1;
wire        data_dependency_rs2;

assign data_forwarding_rs1 = ((forwarded_rd_i == rs1 ) && (forwarded_rd_i != 0));
assign data_forwarding_rs2 = ((forwarded_rd_i == rs2 ) && (forwarded_rd_i != 0));

assign data_dependency_rs1 = ((rs1_state == `WRITING_IN_PROGRESS) && rs1 != rd_sonraki_r);
assign data_dependency_rs2 = ((rs2_state == `WRITING_IN_PROGRESS) && rs2 != rd_sonraki_r);

assign decode_next_instruction = ((execute_working_info_i == 1'b0) && (data_dependency_rs1 == 1'b0) && (data_dependency_rs2 == 1'b0));
assign decode_working_info_o = ~decode_next_instruction;

wire[`BIT_SAYISI_COZ-1:0] buyruk_w = {getir_buyruk_i[31:27], getir_buyruk_i[25:20], getir_buyruk_i[14:12], getir_buyruk_i[6:2]};

IntegerRegisterFile IRF (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .change_int_reg_state_i(change_reg_state_r),
    .decode_rd_state_i(rd_sonraki_r),
    .reg_write_i(write_integer_file_i),
    .rs1_i(rs1),
    .rs2_i(rs2),
    .rd_i(writeback_address_i),
    .write_data_i(writeback_result_i),
    .read_reg1_state_o(rs1_state),
    .read_reg2_state_o(rs2_state),
    .read_data1_o(integer_deger1_sonraki_r),
    .read_data2_o(integer_deger2_sonraki_r)
);

FloatRegisterFile FRF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .reg_write_i(write_float_file_i),
    .rs1_i(getir_buyruk_i[19:15]),
    .rs2_i(getir_buyruk_i[24:20]),
    .rs3_i(getir_buyruk_i[31:27]),
    .rd_i(writeback_address_i),
    .write_data_i(writeback_result_i),
    .read_data1_o(float_deger1_sonraki_r),
    .read_data2_o(float_deger2_sonraki_r),
    .read_data3_o(float_deger3_sonraki_r)
);


always@(posedge clk_i)begin
    if(rst_i) begin
          yurut_FPU_en_o         <= `DISABLE;
          yurut_ALU_en_o         <= `DISABLE;
          yurut_IMU_en_o         <= `DISABLE;
          yurut_IDU_en_o         <= `DISABLE;
          yurut_BRU_en_o         <= `DISABLE;
          yurut_CSU_en_o         <= `DISABLE;
          yurut_AU_en_o          <= `DISABLE;
          yurut_BMU_en_o         <= `DISABLE;
          yurut_MU_en_o          <= `DISABLE;
          FPU_en_sonraki         <= `DISABLE;
          ALU_en_sonraki         <= `DISABLE;
          IMU_en_sonraki         <= `DISABLE;
          IDU_en_sonraki         <= `DISABLE;
          BRU_en_sonraki         <= `DISABLE;
          CSU_en_sonraki         <= `DISABLE;
          AU_en_sonraki          <= `DISABLE;
          BMU_en_sonraki         <= `DISABLE;
          MU_en_sonraki          <= `DISABLE;
          change_reg_state_r     <= 1'b0;
          islem_secimi_sonraki_r <= 5'b0;
          shamt_sonraki_r        <= 5'b0;
          rm_sonraki_r           <= 3'b0;
          aq_sonraki_r           <= 1'b0;
          rl_sonraki_r           <= 1'b0;
          yurut_islem_secimi_o   <= 5'b0;
          yurut_shamt_o          <= 5'b0;
          yurut_rm_o             <= 3'b0;
          yurut_aq_o             <= 1'b0;
          yurut_rl_o             <= 1'b0;
          rs1                    <= 5'b0;
          rs2                    <= 5'b0;
          writeback_reg_file_sec_o <= `NONE_REGISTER;
          yurut_rd_adres_o       <= 5'b0;
          yurut_ps_yeni_o        <= 32'b0;
          yurut_immidiate_o      <= 32'b0;
          yurut_mem_store_data_o <= 32'b0;
          reg_file_sec_r         <= `NONE_REGISTER;
          yurut_integer_deger1_o <= 32'b0;
          yurut_integer_deger2_o <= 32'b0;
          rd_sonraki_r           <= 5'b0;
          ps_yeni_sonraki_r      <= 32'b0;
          immidiate_sonraki_r    <= 32'b0;
          mem_stored_data_o      <= 32'b0;
          mem_stored_sonraki_r   <= 32'b0;
    end
    else if (decode_next_instruction)begin
        yurut_FPU_en_o           <= FPU_en_sonraki;
        yurut_ALU_en_o           <= ALU_en_sonraki;
        yurut_IMU_en_o           <= IMU_en_sonraki;
        yurut_IDU_en_o           <= IDU_en_sonraki;
        yurut_BRU_en_o           <= BRU_en_sonraki;
        yurut_CSU_en_o           <= CSU_en_sonraki;
        yurut_AU_en_o            <= AU_en_sonraki;
        yurut_BMU_en_o           <= BMU_en_sonraki;
        yurut_MU_en_o            <= MU_en_sonraki;
        yurut_islem_secimi_o     <= islem_secimi_sonraki_r;
        yurut_shamt_o            <= shamt_sonraki_r;
        yurut_rm_o               <= rm_sonraki_r;
        yurut_aq_o               <= aq_sonraki_r;
        yurut_rl_o               <= rl_sonraki_r;
        yurut_immidiate_o        <= immidiate_sonraki_r;
        yurut_ps_yeni_o          <= ps_yeni_sonraki_r;
        yurut_rd_adres_o         <= rd_sonraki_r; 
        yurut_integer_deger1_o   <= (enable_first_operand ) ? first_operand  : (data_forwarding_rs1) ? forwarded_data_i : integer_deger1_sonraki_r;
        yurut_integer_deger2_o   <= (enable_second_operand) ? second_operand : (data_forwarding_rs2) ? forwarded_data_i : integer_deger2_sonraki_r;
        yurut_float_deger1_o     <= float_deger1_sonraki_r;
        yurut_float_deger2_o     <= float_deger2_sonraki_r;
        yurut_float_deger3_o     <= float_deger3_sonraki_r;
        yurut_mem_store_data_o   <= integer_deger2_sonraki_r;
        writeback_reg_file_sec_o <= reg_file_sec_r;
        mem_stored_data_o        <= mem_stored_sonraki_r;
    end 
    

end


always@(*)begin
    mem_stored_sonraki_r = integer_deger2_sonraki_r;
    ps_yeni_sonraki_r = getir_ps_i;
    rd_sonraki_r = getir_buyruk_i[11:7];
    rs1 = getir_buyruk_i[19:15];
    rs2 = getir_buyruk_i[24:20];
    casez (buyruk_w)
        `NOP_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;
             islem_secimi_sonraki_r = `NOP;
             reg_file_sec_r = `NONE_REGISTER;
             rd_sonraki_r = 5'b0;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `DISABLE;
        end
        `ADD_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;
             islem_secimi_sonraki_r = `ALU_ADD;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;  
        end  
        `SUB_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;
             islem_secimi_sonraki_r = `ALU_SUB;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;  
         end  
        `SLL_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;
             islem_secimi_sonraki_r = `ALU_SLL;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `SLT_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SLT;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end     
        `SLTU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SLTU;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `XOR_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_XOR;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `SRL_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SRL;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SRA_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SRA;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `OR_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_OR;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `AND_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_AND;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `ADDI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_ADDI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SLTI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SLTI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SLTIU_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SLTIU;      
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `XORI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_XORI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `ORI_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_ORI;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `ANDI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;      
             islem_secimi_sonraki_r = `ALU_ANDI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `SLLI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SLLI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SRLI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SRLI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SRAI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_SRAI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SB_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_SB;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;
             second_operand = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};
             rd_sonraki_r = 5'b0;
             change_reg_state_r    = `DISABLE;
        end  
        `SH_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;
             islem_secimi_sonraki_r = `MEM_SH;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;
             second_operand = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};
             rd_sonraki_r = 5'b0;  
             change_reg_state_r    = `DISABLE;
        end  
        `SW_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_SW;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;  
             second_operand = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};
             rd_sonraki_r = 5'b0;
             change_reg_state_r    = `DISABLE;
        end  
        `LB_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_LB;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `LH_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_LH;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `LW_COZ        : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_LW;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `ENABLE;
        end  
        `LBU_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_LBU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `LHU_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `ENABLE;                 
             islem_secimi_sonraki_r = `MEM_LHU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `BEQ_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;        
             islem_secimi_sonraki_r = `BR_BEQ;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             rd_sonraki_r = 5'b0;  
             change_reg_state_r    = `DISABLE;
        end  
        `BNE_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `BR_BNE;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `DISABLE;
        end  
        `BLT_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `BR_BLT;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `DISABLE;
        end  
        `BGE_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;        
             islem_secimi_sonraki_r = `BR_BGE;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             rd_sonraki_r = 5'b0;  
             change_reg_state_r    = `DISABLE;
        end  
        `BLTU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `BR_BLTU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             rd_sonraki_r = 5'b0;
             change_reg_state_r    = `DISABLE;
        end  
        `BGEU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `BR_BGEU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             rd_sonraki_r = 5'b0; 
             change_reg_state_r    = `DISABLE;
        end  
        `LUI_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_LUI;        
             immidiate_sonraki_r = {getir_buyruk_i[31:12], 12'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;
             second_operand = {getir_buyruk_i[31:12], 12'b0};
             change_reg_state_r    = `ENABLE;
        end  
        `AUIPC_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `ENABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `ALU_AUIPC;      
             immidiate_sonraki_r = {getir_buyruk_i[31:12], 12'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `ENABLE;
             enable_second_operand = `ENABLE;
             first_operand  = getir_ps_i;
             second_operand = {getir_buyruk_i[31:12], 12'b0};
             change_reg_state_r    = `ENABLE;  
        end  
        `JAL_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;        
             islem_secimi_sonraki_r = `BR_JAL;         
             immidiate_sonraki_r = {{12{getir_buyruk_i[31]}}, getir_buyruk_i[19:12], getir_buyruk_i[20], getir_buyruk_i[30:21], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `ENABLE;
             enable_second_operand = `ENABLE;  
             first_operand  = getir_ps_i;
             second_operand = 'd4;
             change_reg_state_r    = `ENABLE;
        end  
        `JALR_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `ENABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;        
             islem_secimi_sonraki_r = `BR_JALR;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `ENABLE;
             enable_second_operand = `ENABLE;  
             first_operand  = getir_ps_i;
             second_operand = 'd4; 
             change_reg_state_r    = `ENABLE;
        end  
        `MUL_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `ENABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE; 
             islem_secimi_sonraki_r = `INT_MUL;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MULH_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `ENABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE; 
             islem_secimi_sonraki_r = `INT_MULH;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MULHSU_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `ENABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE; 
             islem_secimi_sonraki_r = `INT_MULHSU;                             
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MULHU_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `ENABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE; 
             islem_secimi_sonraki_r = `INT_MULHU;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `DIV_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `ENABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `INT_DIV;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `DIVU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `ENABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;      
             islem_secimi_sonraki_r = `INT_DIVU;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `REM_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `ENABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `INT_REM;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `REMU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `ENABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `INT_REMU;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `LR_W_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_LR_W;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `SC_W_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                
             islem_secimi_sonraki_r = `ATOM_SC_W;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOSWAP_W_COZ : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOSWAP_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOADD_W_COZ  : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOADD_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOXOR_W_COZ  : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOXOR_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOAND_W_COZ  : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOAND_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOOR_W_COZ   : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOOR_W;                           
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOMIN_W_COZ  : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOMIN_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOMAX_W_COZ  : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOMAX_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `AMOMINU_W_COZ : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOMINU_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26]; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `AMOMAXU_W_COZ : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `ENABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;                 
             islem_secimi_sonraki_r = `ATOM_AMOMAXU_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `FLW_COZ       : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FLW;        
             immidiate_sonraki_r = getir_buyruk_i[31:20]; 
             reg_file_sec_r = `FLOAT_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FSW_COZ       : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSW;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `NONE_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `ENABLE;
             second_operand = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};
        end  
        `FMADD_S_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMADD_S;                            
             reg_file_sec_r = `FLOAT_REGISTER; 
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
        end  
        `FMSUB_S_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMSUB_S;                            
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12]; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FNMSUB_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FNMSUB_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FNMADD_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FNMADD_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FADD_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FADD_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
         end  
        `FSUB_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSUB_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FMUL_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMUL_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12]; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FDIV_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FDIV_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FSQRT_S_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSQRT_S;                            
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FSGNJ_S_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSGNJ_S;                            
             reg_file_sec_r = `FLOAT_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FSGNJN_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSGNJN_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FSGNJX_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FSGNJX_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FMIN_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMIN_S;                             
             reg_file_sec_r = `FLOAT_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FMAX_S_COZ    : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMAX_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FCVT_W_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FCVT_W_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FCVT_WU_S_COZ : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FCVT_WU_S;                          
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FMV_X_W_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMV_X_W;                            
             reg_file_sec_r = `FLOAT_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FEQ_S_COZ     : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FEQ_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FLT_S_COZ     : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FLT_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;   
        end  
        `FLE_S_COZ     : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FLE_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FCLASS_S_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FCLASS_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FCVT_S_W_COZ  : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FCVT_S_W;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FCVT_S_WU_COZ : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FCVT_S_WU;                          
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `FMV_W_X_COZ   : begin
             FPU_en_sonraki = `ENABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `DISABLE;
             MU_en_sonraki  = `DISABLE;         
             islem_secimi_sonraki_r = `FLT_FMV_W_X;                            
             reg_file_sec_r = `FLOAT_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;    
        end  
        `ANDN_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_ANDN;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `CLMUL_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CLMUL;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE; 
        end  
        `CLMULH_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CLMULH;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `CLMULR_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CLMULR;                              
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `CLZ_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CLZ;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `CPOP_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CPOP;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `CTZ_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_CTZ;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MAX_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;      
             islem_secimi_sonraki_r = `BT_MAX;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MAXU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_MAXU;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MIN_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_MIN;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `MINU_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_MINU;                                
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `ORC_B_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_ORC_B;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `ORN_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_ORN;                                 
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `REV8_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_REV8;                                
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `ROL_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;      
             islem_secimi_sonraki_r = `BT_ROL;                                 
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `ROR_COZ       : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_ROR;                                 
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `RORI_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_RORI;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `ENABLE;
        end  
        `BCLR_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BCLR;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `ENABLE;
        end  
        `BCLRI_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BCLRI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `BEXT_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BEXT;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `ENABLE;
        end  
        `BEXTI_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BEXTI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `BINV_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BINV;                                
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE; 
             change_reg_state_r    = `ENABLE;
        end  
        `BINVI_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BINVI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `BSET_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BSET;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `BSETI_COZ     : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_BSETI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SEXT_B_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_SEXT_B;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SEXT_H_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_SEXT_H;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SH1ADD_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_SH1ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SH2ADD_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_SH2ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `SH3ADD_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_SH3ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER; 
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;
             change_reg_state_r    = `ENABLE;
        end  
        `XNOR_COZ      : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_XNOR;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        `ZEXT_H_COZ    : begin
             FPU_en_sonraki = `DISABLE;
             ALU_en_sonraki = `DISABLE;
             IMU_en_sonraki = `DISABLE;
             IDU_en_sonraki = `DISABLE;
             BRU_en_sonraki = `DISABLE;
             CU_en_sonraki  = `DISABLE;
             CSU_en_sonraki = `DISABLE;
             AU_en_sonraki  = `DISABLE;
             BMU_en_sonraki = `ENABLE;
             MU_en_sonraki  = `DISABLE;       
             islem_secimi_sonraki_r = `BT_ZEXT_H;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             enable_first_operand  = `DISABLE;
             enable_second_operand = `DISABLE;  
             change_reg_state_r    = `ENABLE;
        end  
        default        : begin
          yurut_FPU_en_o         <= `DISABLE;
          yurut_ALU_en_o         <= `DISABLE;
          yurut_IMU_en_o         <= `DISABLE;
          yurut_IDU_en_o         <= `DISABLE;
          yurut_BRU_en_o         <= `DISABLE;
          yurut_CSU_en_o         <= `DISABLE;
          yurut_AU_en_o          <= `DISABLE;
          yurut_BMU_en_o         <= `DISABLE;
          yurut_MU_en_o          <= `DISABLE;
          change_reg_state_r    = 1'b0;
        end 
        
    endcase
    
end


endmodule

/*
// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v
`include "definitions.vh";

module DecodeStep (
    input wire clk_i,                                  // Clock input
    input wire rst_i,                                  // Reset input
    input wire [31:0] instruction_i,                   // Instruction input, comes from fetch step
    input wire [31:0] writebacked_result_i,            // writebacked result to suitable register, comes from writeback step
    input wire reg_write_integer_i,                    // Write data flag for integer register file, comes from writeback step
    input wire reg_write_float_i,                      // Write data flag for float register file,  comes from writeback step
    input wire reg_write_csr_i,                        // Write data flag for csr register file, comes from writeback step
    input wire [4:0] target_register_i,                // this is crucial for writig info to correct register file index, comes from writeback step 
    input wire execute_working_info_i,                 // execute working info, comes from execute step, crucial for stalling
    output wire [31:0] program_counter_i,              // this comes from fetch step and will be conveyed to decode step as first operand
    input wire [31:0] forwarded_data_i,                // this comes from execute step and necessary for data forwarding, indicates forwarded data
    input wire [4:0] forwarded_rd_i,                   // this comes from execute step and necessary for data forwarding, indicates forwarded register target index
    input wire branch_info_i,                          // this comes from execute step and necessary for not running next stages for branch instructions
    input wire [31:0] branch_predictor_address_i,      // this info comes from fecth step and goes to execute step as input
    output wire [4:0] rd_o,                            // Destination register output, goes to execute step, Note : this value later comes as target_register_i as input from writeback step
    output wire [31:0] integer_operand1_o,             // Operand 1 output, goes to execute step
    output wire [31:0] integer_operand2_o,             // Operand 2 output, goes to execute step
    output wire [31:0] float_operand1_o,               // operand 1 for float, goes to execute step
    output wire [31:0] float_operand2_o,               // operand 2 for float, goes to execute step
    output wire [31:0] float_operand3_o,               // operand 3 for float, goes to execute step
    output wire [3:0] unit_type_o,                     // select corrrect unit depends on instruction, goes to execute step
    output wire [4:0] instruction_type_o,              // hold information of  which instruction, goes to execute step
    output wire decode_working_info_o,                 // output for decoding working info, goes to fetch step
    output wire [31:0] rs2_value_o,                    // output for rs2 value, this is important for memory operations, goes to execute
    output wire [1:0] register_selection_o,            // output for register selection, important for writeback step, goes to execute step
    output wire [31:0] program_counter_o,              // output for program counter, necessary for brach instructions, goes to execute step
    output wire [31:0] immediate_value_o,              // output for immeadiate value, necessart for branch instructions, goes to execute stage
    output wire [31:0] branch_predictor_address_o      // output for branch predictor address comes as input goes as output to execute step
);

reg [6:0] opcode;                                     // Opcode
reg [4:0] rs1;                                        // Source register 1
reg [4:0] rs2;                                        // Source register 2 
reg [4:0] rs3;                                        // Source register 3
reg [4:0] rd;                                         // Destination register, important for writeback step
wire [31:0] operand1_integer;                         // Operand 1 integer
wire [31:0] operand2_integer;                         // Operand 2 integer
wire [31:0] operand1_float;                           // Operand 1 for float
wire [31:0] operand2_float;                           // Operand 2 for float
wire [31:0] operand3_float;                           // Operand 3 float
reg [3:0] unit_type;                                  // default zero will be changed later, will conveyed to execute step
reg  [4:0] instruction_type;                          // instruction type will be conveyed to execute step
reg  [1:0] register_selection;                        // register selection for register file, this later should be conveyed to writeback step for writing the data correct register file
reg [31:0] first_operand;                             // for some instructions operand1_ineteger are not nesessary, this reg is assigned necessary info
reg [31:0] second_operand;                            // for some instructions operand2_ineteger are not nesessary, this reg is assigned necessary info
reg enable_first;                                     // this flag is necessary for assigning integer_operand1
reg enable_generate;                                  // this is necessary for immediate generator and assigning operand 2 value
reg [31:0] program_counter;                           // necessary for branch instructions, goes to execute step
reg [31:0] imm_generated_operand2;                    // imm generated operand2
reg [31:0] branch_predictor_address;                  // branch predictor address, goes to execute step

reg [31:0] rs2_value;
reg [3:0] unit_type_next;
reg [4:0] instruction_type_next;
reg [1:0] register_selection_next;
reg [4:0] rd_next;
reg [31:0] program_counter_next;
reg [31:0] imm_generated_operand2_next;
reg [31:0] branch_predictor_address_next;

reg [31:0] integer_operand1;
reg [31:0] integer_operand2;
reg [31:0] operand1_integer_next;
reg [31:0] operand2_integer_next;
reg [31:0] operand1_float_next; 
reg [31:0] operand2_float_next;
reg [31:0] operand3_float_next;

wire data_forwarding_info_rs1;
wire data_forwarding_info_rs2;

wire data_dependency_info_rs1;
wire data_dependency_info_rs2;
wire rs1_state;
wire rs2_state;

wire decode_next_instruction;
wire decode_working_info;
reg change_integer_register_state;

// Integer Register File module
IntegerRegisterFile integerRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1   
    .rs2_i(rs2), // Source register 2
    .rd_i(target_register_i), // Destination register
    .write_data_i(writebacked_result_i), // Writebacked result
    .rd_state_i(rd_next),
    .change_integer_register_state_i(change_integer_register_state),
    .reg_write_i(reg_write_integer_i), // Write data flag
    .read_data1_o(operand1_integer),    // Operand 1
    .read_data2_o(operand2_integer),   // Operand 2
    .read_rs1_state_o(rs1_state),
    .read_rs2_state_o(rs2_state)
);

// Float Register File module
FloatRegisterFile floatRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1
    .rs2_i(rs2), // Source register 2
    .rs3_i(rs3), // Source register 3
    .rd_i(target_register_i), // Destination register
    .write_data_i(writebacked_result_i),    // Writebacked result
    .reg_write_i(reg_write_float_i), // Write data flag
    .read_data1_o(operand1_float), // Operand 1
    .read_data2_o(operand2_float), // Operand 2
    .read_data3_o(operand3_float) // Operand 3
);


integer i = -2; // debugging for which instruction decoded


assign data_forwarding_info_rs1 = (forwarded_rd_i == rs1 && forwarded_rd_i != 1'b0);
assign data_forwarding_info_rs2 = (forwarded_rd_i == rs2 && forwarded_rd_i != 1'b0);

assign data_dependency_info_rs1 =  rs1_state == `WRITING_IN_PROGRESS && rs1 != rd_next;
assign data_dependency_info_rs2 =  rs2_state == `WRITING_IN_PROGRESS && rs2 != rd_next;


assign decode_next_instruction = (execute_working_info_i == 1'b0 && data_dependency_info_rs1 == 1'b0 && data_dependency_info_rs2 == 1'b0 && branch_info_i != `BRANCH_TAKEN);
assign decode_working_info = ~decode_next_instruction;

always@(*) begin
    operand1_integer_next = operand1_integer; 
    operand2_integer_next = operand2_integer;
end


always@(*) begin                 
    $display("@@DECODE STAGE Decoded instruction  %h ",instruction_i);
    $display("-->IMM %d ",imm_generated_operand2_next);
    $display("-->Opcode: %b ", opcode); // Display opcode
    $display("-->rs1 : %d ", rs1," Value : %d ",operand1_integer);       // Display source register 1
    $display("-->rs2 : %d ", rs2," Value : %d ",operand2_integer);       // Display source register 2
    $display("-->rd  : %d ", rd_next);         // Display destination register);
    case(register_selection_next) 
        `INTEGER_REGISTER: $display("--->Which file : INTEGER_REGISTER");
        `FLOAT_REGISTER:  $display("--->Which file :  FLOAT_REGISTER");
        `CSR_REGISTER:  $display("--->Which file : CSR_REGISTER");
        `NONE_REGISTER: $display("--->Which file : NONE_REGISTER");
    endcase
end

always @(*) begin
    branch_predictor_address_next = branch_predictor_address_i;
    program_counter_next = program_counter_i;
    enable_generate = 1'b0; 
    enable_first = 1'b0;
    opcode = instruction_i[6:0]; // Extract opcode not that not use <= here 
    case(opcode) // Extract the opcode
        7'b0000000: begin
            $display("FETCH SEND NOPE INSTRUCTION");
            imm_generated_operand2_next = 32'b0;
            change_integer_register_state = 1'b0;
            register_selection_next = `NONE_REGISTER;
            unit_type_next = `NOP_UNIT;
            instruction_type_next = `NOP;
            enable_first = 1'b0;
            enable_generate = 1'b0;
            rd_next = 5'b0;
            operand1_integer_next = 32'b0;
            operand2_integer_next = 32'b0;
            rs1 = 5'b0;
            rs2 = 5'b0; 
        end
        7'b1101111: begin
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER;
            unit_type_next = `BRANCH_RESOLVER_UNIT;
            instruction_type_next = `BRANCH_JAL;
            enable_first = 1'b1;
            enable_generate = 1'b1;
            first_operand = program_counter_i;
            second_operand = 32'd4;
            rd_next = instruction_i[11:7];
            imm_generated_operand2_next[20] = instruction_i[31];
            imm_generated_operand2_next[19:12] = instruction_i[19:12];
            imm_generated_operand2_next[11] = instruction_i[20];
            imm_generated_operand2_next[10:1] = instruction_i[30:21];
            imm_generated_operand2_next[0] = 0; // not sure but it works okey
            if(instruction_i[31] == 1'b0)
                imm_generated_operand2_next[31:21] = 11'b0;
            else
                imm_generated_operand2_next[31:21] = 11'b1;
        end
        7'b1100111: begin
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER;
            unit_type_next = `BRANCH_RESOLVER_UNIT;
            instruction_type_next = `BRANCH_JALR;
            enable_generate = 1'b1;
            second_operand = 32'd4;
            rd_next = instruction_i[11:7];
            rs1 = instruction_i[19:15];         
            imm_generated_operand2_next[11:0] = instruction_i[31:20];
            if(imm_generated_operand2_next[11] == 0)
                imm_generated_operand2_next[31:12] = 20'b0000000000000000000;
            else
                imm_generated_operand2_next[31:12] = 20'b11111111111111111111;                          
        end
        7'b1100011: begin
            change_integer_register_state = 1'b0;
            register_selection_next = `NONE_REGISTER;      
            rs1 = instruction_i[19:15];
            rs2 = instruction_i[24:20];
            rd_next= 5'b0;
            enable_first = 1'b0;
            enable_generate = 1'b0;
            unit_type_next = `BRANCH_RESOLVER_UNIT;
            imm_generated_operand2_next[4:1] = instruction_i[11:8];
            imm_generated_operand2_next[11] = instruction_i[7];
            imm_generated_operand2_next[10:5] = instruction_i[30:25];
            imm_generated_operand2_next[12] = instruction_i[31];
            case(instruction_i[14:12])
                3'b000: begin
                    instruction_type_next = `BRANCH_BEQ;
                end
                3'b001: begin
                    instruction_type_next = `BRANCH_BNE;
                end
                3'b100: begin
                    instruction_type_next = `BRANCH_BLT;
                end
                3'b101: begin 
                    instruction_type_next = `BRANCH_BGE;
                end
                3'b110: begin 
                    instruction_type_next = `BRANCH_BLTU;
                end
                3'b111: begin
                     instruction_type_next = `BRANCH_BGEU;
                end
            endcase
        end
        7'b0110111: begin
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER;
            rd_next = instruction_i[11:7];
            enable_generate = 1'b1;
            imm_generated_operand2_next[31:12] = instruction_i[31:12];
            imm_generated_operand2_next[11:0] = 12'b0;
            second_operand = imm_generated_operand2_next;
            instruction_type_next = `NONE_LUI;
            unit_type_next = `NONE_UNIT;
            
            
        end
        7'b0010111: begin
            $display("AUPIC INSTRUCTON");
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER;
            rd_next = instruction_i[11:7];
            enable_generate = 1'b1;
            enable_first = 1'b1;
            first_operand = program_counter_i;
            imm_generated_operand2_next[31:12] = instruction_i[31:12];
            imm_generated_operand2_next[11:0] = 12'b0;
            second_operand = imm_generated_operand2_next;
            instruction_type_next = `ALU_ADD;
            unit_type_next = `ARITHMETIC_LOGIC_UNIT;
            
            
        end
        7'b0000011: begin
            change_integer_register_state = 1'b1;
            enable_generate = 1'b1;    // enable generate       
            unit_type_next = `MEMORY_UNIT;
            register_selection_next = `INTEGER_REGISTER; // Set the register selection
            rs1 = instruction_i[19:15]; // Extract source register 1
            rd_next = instruction_i[11:7];   // Extract destination register
            generate_operand2(instruction_i);
            second_operand = imm_generated_operand2_next;
            case(instruction_i[14:12])
                3'b000 : instruction_type_next[2:0] = `MEM_LB;
                3'b001 : instruction_type_next[2:0] = `MEM_LH;
                3'b010 : instruction_type_next[2:0] = `MEM_LW;
                3'b100 : instruction_type_next[2:0] = `MEM_LBU;
                3'b101 : instruction_type_next[2:0] = `MEM_LHU;
            endcase
            
            
        end
        7'b0100011: begin
            change_integer_register_state = 1'b0;
            enable_generate = 1'b1;    // enable generate       
            unit_type_next = `MEMORY_UNIT;
            register_selection_next = `NONE_REGISTER; // Set the register selection
            rs1 = instruction_i[19:15]; // Extract source register 1
            rs2 = instruction_i[24:20]; // Extract source register 2
            rd_next = 5'b0;   // Extract destination register
            imm_generated_operand2_next [4:0] = instruction_i[11:7]; // Extract immediate
            imm_generated_operand2_next [11:5] = instruction_i[31:25]; // Extract immediate
            if(instruction_i[31] == 1'b0)
                imm_generated_operand2_next[31:12] = 20'b0;
            else
                imm_generated_operand2_next[31:12] = 20'b1;
            second_operand = imm_generated_operand2_next;
            case(instruction_i[14:12])
                3'b000 : instruction_type_next[2:0] = `MEM_SB;
                3'b001 : instruction_type_next[2:0] = `MEM_SH;
                3'b010 : instruction_type_next[2:0] = `MEM_SW;
            endcase
            
            
        end
        7'b0010011: begin
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER; // Set the register selection
            rs1 = instruction_i[19:15]; // Extract source register 1
            rd_next = instruction_i[11:7];   // Extract destination register
            unit_type_next = `ARITHMETIC_LOGIC_UNIT; // Set the unit type
            enable_generate = 1'b1;    // enable generate      
                                       
            case(instruction_i[14:12]) // Extract the instruction type
                3'b000 : begin
                     generate_operand2(instruction_i); // Generate operand 2
                     instruction_type_next = `ALU_ADDI; // Set the instruction type
                end
                3'b010 : begin 
                    generate_operand2(instruction_i); // Generate operand 2
                    instruction_type_next = `ALU_SLTI; // Set the instruction type
                end
                3'b011 : begin 
                     generate_operand2(instruction_i); // Generate operand 2
                    instruction_type_next = `ALU_SLTIU; // Set the instruction type
                end
                3'b100 : begin 
                    generate_operand2(instruction_i); // Generate operand 2
                    instruction_type = `ALU_XORI; // Set the instruction type
                end
                3'b110 : begin 
                    generate_operand2(instruction_i); // Generate operand 2
                    instruction_type_next = `ALU_ORI; // Set the instruction type
                end
                3'b111 : begin
                    generate_operand2(instruction_i);  // Generate operand 2
                    instruction_type_next = `ALU_ANDI; // Set the instruction type
                end
                3'b001 : instruction_type = `ALU_SLLI; // Set the instruction type
                3'b101 : begin 
                    if(instruction_i[31:25] == 6'b000000) // Extract the instruction type
                        instruction_type_next = `ALU_SRLI; // Set the instruction type
                    else
                        instruction_type_next = `ALU_SRAI; // Set the instruction type
                end
            endcase
            second_operand = imm_generated_operand2_next;


        end
        7'b0110011: begin
            change_integer_register_state = 1'b1;
            register_selection_next = `INTEGER_REGISTER; // Set the register selection
            enable_generate =1'b0; // disable generate
            rs1 = instruction_i[19:15]; // Extract source register 1
            rs2 = instruction_i[24:20]; // Extract source register 2
            rd_next = instruction_i[11:7];   // Extract destination register
            unit_type_next = `ARITHMETIC_LOGIC_UNIT; // Set the unit type                
            case(instruction_i[14:12]) // Extract the instruction type
                3'b000 : begin
                    if(instruction_i[25] == 1'b1) // Extract the instruction type
                    begin
                        unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                        instruction_type_next = `INT_MUL; // Set the instruction type
                    end
                    else if(instruction_i[30] == 1'b0)
                        instruction_type_next = `ALU_ADD; // Set the instruction type
                    else
                        instruction_type_next = `ALU_SUB; // Set the instruction type
                end
                3'b001 : begin
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                        instruction_type_next = `INT_MULH; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_SLL; // Set the instruction type
                end
                3'b010 : begin
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                        instruction_type_next = `INT_MULHSU; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_SLT; // Set the instruction type
                end
                3'b011 : begin
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                        instruction_type_next = `INT_MULHU; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_SLTU; // Set the instruction type
                end
                3'b100 : begin instruction_type_next = `ALU_XOR; // Set the instruction type
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                        instruction_type_next = `INT_DIV; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_XOR; // Set the instruction type
                end
                3'b101 : begin
                    if(instruction_i[25] == 1'b1)
                       begin
                        unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                        instruction_type_next = `INT_DIVU; // Set the instruction type
                       end
                    else if(instruction_i[30] == 1'b1)
                        instruction_type_next = `ALU_SRA; // Set the instruction type
                    else
                        instruction_type_next = `ALU_SRL; // Set the instruction type
                end
                3'b110 : begin
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                        instruction_type_next = `INT_REM; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_OR; // Set the instruction type
                end
                3'b111 : begin
                    if(instruction_i[25] == 1'b1)
                    begin
                        unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                        instruction_type_next = `INT_REMU; // Set the instruction type
                    end
                    else
                        instruction_type_next = `ALU_AND; // Set the instruction type
                end
            endcase
        end
      7'b0101111: begin
           change_integer_register_state = 1'b1;
           register_selection_next = `INTEGER_REGISTER; // set register selection
           rs1 = instruction_i[19:15]; // Extract source register 1
           rs2 = instruction_i[24:20]; // Extract source register 2
           rd_next = instruction_i[11:7];   // Extract destination register
           unit_type_next = `ATOMIC_UNIT;   // set unit type as atomic unit
           case(instruction_i[31:27])
                5'b00010: instruction_type_next = `ATOM_LOAD; // set instruction type
                5'b00011: instruction_type_next = `ATOM_STORE; // set instruction type
                5'b00001: instruction_type_next = `ATOM_SWAP;   // set instruction type
                5'b00000: instruction_type_next = `ATOM_ADD;   // set instruction type
                5'b00100: instruction_type_next = `ATOM_XOR;  // set instruction type
                5'b01100: instruction_type_next = `ATOM_AND; // set instruction type
                5'b01000: instruction_type_next = `ATOM_OR; // set instruction type
                5'b10000: instruction_type_next = `ATOM_MIN; // set instruction type
                5'b10100: instruction_type_next = `ATOM_MAX; // set instruction type
                5'b11000: instruction_type_next = `ATOM_MINU; // set instruction type
                5'b11100: instruction_type_next = `ATOM_MAXU; // set instruction type
          endcase
    end
    7'b0000111: begin
        change_integer_register_state = 1'b0;
        register_selection_next = `FLOAT_REGISTER;
        rs1 = instruction_i[19:15]; // Extract source register 1
        rs2 = instruction_i[24:20]; // Extract source register 2
        rs3 = instruction_i[31:27]; // Extract source register 3
        rd_next = instruction_i[11:7];   // Extract destination register
        instruction_type_next = `FLT_LOAD; // set instruction type
        unit_type_next = `FLOATING_POINT_UNIT; // set unit type
        generate_operand2(instruction_i); // generate operand 2
        enable_generate = 1'b1; // enable generate
    end
    7'b0100111: begin
        register_selection_next = `FLOAT_REGISTER;
        rs1 = instruction_i[19:15]; // Extract source register 1
        rs2 = instruction_i[24:20]; // Extract source register 2
        rs3 = instruction_i[31:27]; // Extract source register 3
        rd_next = instruction_i[11:7];   // Extract destination register
        instruction_type_next = `FLT_STORE; // set instruction type
        unit_type_next = `FLOATING_POINT_UNIT; // set unit type
        imm_generated_operand2_next[4:0] = instruction_i[11:7]; // set value
        imm_generated_operand2_next[11:5] = instruction_i[31:25]; // set value
        if(instruction_i[31] == 1'b0) 
            imm_generated_operand2_next[31:12] = 20'b0; // extend with zero
        else
            imm_generated_operand2_next[31:12] = 20'b1; // extend with one                               
    end
    7'b1000011: begin
       register_selection_next = `FLOAT_REGISTER;
       rs1 = instruction_i[19:15]; // Extract source register 1
       rs2 = instruction_i[24:20]; // Extract source register 2
       rs3 = instruction_i[31:27]; // Extract source register 3
       rd_next = instruction_i[11:7];   // Extract destination register
       instruction_type_next = `FLT_FMADD; // set instruction type
       unit_type_next = `FLOATING_POINT_UNIT;    // set unit type
   end 
   7'b1000111: begin
       register_selection_next = `FLOAT_REGISTER;
       rs1 = instruction_i[19:15]; // Extract source register 1
       rs2 = instruction_i[24:20]; // Extract source register 2
       rs3 = instruction_i[31:27]; // Extract source register 3
       rd_next = instruction_i[11:7];   // Extract destination register
       instruction_type_next = `FLT_FMSUB;  // set instruction type
       unit_type_next = `FLOATING_POINT_UNIT;  // set unit type
   end
   7'b1001011: begin
       register_selection_next = `FLOAT_REGISTER;
       rs1 = instruction_i[19:15]; // Extract source register 1
       rs2 = instruction_i[24:20]; // Extract source register 2
       rs3 = instruction_i[31:27]; // Extract source register 3
       rd_next = instruction_i[11:7];   // Extract destination register
       instruction_type_next = `FLT_FNMSUB;  // set instruction type
       unit_type_next = `FLOATING_POINT_UNIT; // set unit type                                
    end
    7'b1001111: begin
       register_selection_next = `FLOAT_REGISTER;
       rs1 = instruction_i[19:15]; // Extract source register 1
       rs2 = instruction_i[24:20]; // Extract source register 2
       rs3 = instruction_i[31:27]; // Extract source register 3
       rd_next = instruction_i[11:7];   // Extract destination register
       instruction_type_next = `FLT_FNMADD; // set instruction type
       unit_type_next = `FLOATING_POINT_UNIT; // set unit type                               
    end
    7'b1010011: begin
       register_selection_next = `FLOAT_REGISTER;
       rs1 = instruction_i[19:15]; // Extract source register 1
       rs2 = instruction_i[24:20]; // Extract source register 2
       rs3 = instruction_i[31:27]; // Extract source register 3
       rd_next = instruction_i[11:7];   // Extract destination register                           
       unit_type_next = `FLOATING_POINT_UNIT; // set unit type
       case(instruction_i[31:25])
            7'b0000000: instruction_type_next = `FLT_FADD; // set instruction type
            7'b0000100: instruction_type_next = `FLT_FSUB; // set instruction type
            7'b0001000: instruction_type_next = `FLT_FMUL; // set instruction type
            7'b0001100: instruction_type_next = `FLT_FDIV; // set instruction type
            7'b0101100: instruction_type_next = `FLT_FSQRT; // set instruction type
            7'b0010000:
                begin
                    if(instruction_i[14:12] == 3'b000)
                        instruction_type_next = `FLT_FSGNJ; // set instruction type
                    else if(instruction_i[14:12] == 3'b001)
                        instruction_type_next = `FLT_FSGNJN;    // set instruction type
                    else  
                        instruction_type_next = `FLT_FSGNJX; // set instruction type
                end
           7'b0010100:
                begin
                    if(instruction_i[14:12] == 3'b000)
                        instruction_type_next = `FLT_FMIN; // set instruction type
                    else
                        instruction_type_next = `FLT_FMAX; // set instruction type
                end
          7'b1100000:
                begin
                    if(instruction_i[24:20] == 5'b00000)
                        instruction_type_next = `FLT_FCVTW; // set instruction type
                    else
                        instruction_type_next = `FLT_FCVTWU; // set instruction type                                          
                end
          7'b1110000:
                begin
                    if(instruction_i[14:12] == 3'b000)
                        instruction_type_next = `FLT_FMVXW; // set instruction type
                    else
                        instruction_type_next = `FLT_FCLASS;    // set instruction type
                end
          7'b1010000:
                begin
                    if(instruction_i[14:12] == 3'b010)
                        instruction_type_next = `FLT_FEQ; // set instruction type
                    else if(instruction_i[14:12] == 3'b001)
                        instruction_type_next = `FLT_FLT; // set instruction type
                    else 
                        instruction_type_next = `FLT_FLE;       // set instruction type               
                end
          7'b1101000:
                begin
                    if(instruction_i[20] == 1'b0)
                        instruction_type_next = `FLT_FCVTSW; // set instruction type
                    else 
                        instruction_type_next = `FLT_FCVTSWU; // set instruction type
                end
           7'b1111000: instruction_type_next = `FLT_FMVWX; // set instruction type
       endcase                     
      end
    endcase             
end

always@(posedge branch_info_i) begin
    $display("BRANCH INSTRUCTION WRONG STEP");
    rd_next = 5'b0;
    unit_type_next = `NOP_UNIT;
    register_selection_next = `NONE_REGISTER;
    instruction_type_next = `NOP;
    imm_generated_operand2_next = 32'b0;
    operand2_integer_next = 32'b0;
    change_integer_register_state = 1'b0;
end

always@(posedge clk_i) begin
    if(rst_i) begin 
        enable_first = 1'b0;    enable_generate <= 1'b0;
        opcode <= 7'b0;    rs1 <= 5'b0;   rs2 <= 5'b0;    rs3 <= 5'b0;
        rd <= 5'b0;                         rd_next <= 5'b0;
        unit_type <= `NONE_UNIT;            unit_type_next <= `NONE_UNIT;
        program_counter <= 32'b0;           program_counter_next <= 32'b0;
        register_selection <= `NONE_REGISTER;         register_selection_next = `NONE_REGISTER;
        instruction_type <= 5'b0;           instruction_type_next <= 5'b0;
        imm_generated_operand2 <= 32'b0;    imm_generated_operand2_next <= 32'b0;
        operand1_integer_next <= 32'b0;     branch_predictor_address <= 32'b0;
        operand2_integer_next  <= 32'b0;    branch_predictor_address_next <= 32'b0;
        operand1_float_next <= 32'b0;
        operand2_float_next <= 32'b0;
        rs2_value <= 32'b0;
        integer_operand1 <= 32'b0;
        integer_operand2 <= 32'b0;
    end
    else begin   

        if(data_dependency_info_rs1)
            $display("Data Dependency for rs1 for %h",program_counter_i);          
        if(data_dependency_info_rs2)
            $display("Data Dependency for rs2 for %h",program_counter_i);
        if(data_forwarding_info_rs1)
            $display("Data is being forwarding for rs1 %d ",forwarded_data_i," for %h ",program_counter_i);
        if(data_forwarding_info_rs2)
            $display("Data is being forwarding for rs2 %d ",forwarded_data_i," for %h ",program_counter_i);
        
        if(decode_next_instruction) begin
           rd <= rd_next;
           unit_type <= unit_type_next;
           program_counter <= program_counter_next;
           register_selection <= register_selection_next;
           instruction_type <= instruction_type_next;
           imm_generated_operand2 <= imm_generated_operand2_next;
           rs2_value <= operand2_integer_next;
           branch_predictor_address <= branch_predictor_address_next;
           integer_operand1 <=    (enable_first) ? first_operand  : (data_forwarding_info_rs1) ? forwarded_data_i : operand1_integer_next;
           integer_operand2 <= (enable_generate) ? second_operand : (data_forwarding_info_rs2) ? forwarded_data_i : operand2_integer_next;          
        end
    end
end


assign rd_o = rd;                                                                // Assign destination register is important for keeping the target register info for writeback, // this info comes later again to this step, goes to execute step
assign integer_operand1_o = integer_operand1;                                    // assign operand1 output, goes to execute step
assign integer_operand2_o = integer_operand2;                                    // Assign operand 2 depending on the instruction and condition, goes to execute
assign rs2_value_o = rs2_value;                                                  // assign operand2_integer to rs2_value for memory operations, goes to execute step
assign float_operand1_o = operand1_float;                                        // Assign float operand 1, goes to execute step
assign float_operand2_o = operand2_float;                                        // Assign float operand 2, goes to execute step
assign float_operand3_o = operand3_float;                                        // Assign float operand 3, goes to execute step
assign unit_type_o = unit_type;                                                  // Assign unit type, goes to execute step, important for which sub module should work       
assign instruction_type_o = instruction_type;                                    // Assign instruction type, again important for which instruction should work in which sub module
assign decode_working_info_o = decode_working_info;                              // Assign decode working info, will be conveyed to fetch step for stalling operation
assign register_selection_o = register_selection;                                // Assign register selection info, will be conveyed to execute step
assign program_counter_o = program_counter;                                      // Assign program counter, goes to execute step
assign immediate_value_o = imm_generated_operand2;                               // Assign immediate value, goes to execute step;
assign branch_predictor_address_o = branch_predictor_address;                    // Assign branch predictor addres goes to execute step

task generate_operand2(
    input [31:0] instruction_i
);
    begin
        imm_generated_operand2_next[11:0] = instruction_i[31:20]; // set value
        if(instruction_i[31] == 1'b0)
            imm_generated_operand2_next[31:12] = 20'b0; // extend with zero
        else
            imm_generated_operand2_next[31:12] = 20'b1; // extend with one
    end
endtask


endmodule
*/
