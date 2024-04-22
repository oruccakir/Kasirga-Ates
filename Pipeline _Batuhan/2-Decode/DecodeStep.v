// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v
`timescale 1ns / 1ps
`include "definitions.vh"

module DecodeStep (
    input wire clk_i,                      // Clock input
    input wire rst_i,                      // Reset input
    input wire execute_working_info_i,     // is execute working

    //getir
    input wire [31:0] getir_buyruk_i,       // Instruction input 
    input wire [31:0] getir_ps_i,                // Program Counter input (?program sayacı uzunlugu)

    //writeback 
    input wire [31:0] writeback_result_i,  // Writeback input
    input wire [ 4:0] writeback_address_i, // writeback_address input
    input wire        writeback_enable_i,  // writeback_result_i Rd'ye yazılacak mı

    //register file flags - 3 register file ??gerek olmayabilir
    input wire write_integer_file_i,    // write IntegerRegisterFile
    input wire write_float_file_i,      // write FloatRegisterFile
    input wire write_csr_file_i,        // write CsrRegisterFile

    //Yürüt - CSR buyrukları ile ilgili işlemleri sonraya bırakıyorum
    output reg [ 3:0] yurut_birim_secimi_o,      //hangi birimin seçileceği - 9 birim
    output reg [ 4:0] yurut_islem_secimi_o,      // o birimde hangi buyruğun islemi yapılacagı
    output reg [ 4:0] yurut_shamt_o,             // bazı buyruklarda bulunan shamt degeri
    output reg [ 2:0] yurut_rm_o,                // bazı buyruklarda bulunan rm degeri
    output reg        yurut_aq_o,                // bazı buyruklarda bulunan aq değeri
    output reg        yurut_rl_o,                // bazı buyruklarda bulunan rl degeri
    output reg [31:0] yurut_integer_deger1_o,    // yurut birimi integer girdileri
    output reg [31:0] yurut_integer_deger2_o,   
    output reg [31:0] yurut_float_deger1_o,      // yurut birimi float girdileri
    output reg [31:0] yurut_float_deger2_o,   
    output reg [31:0] yurut_float_deger3_o,   
    output reg [31:0] yurut_immidiate_o,         // immidiate value
    output reg [31:0] yurut_ps_yeni_o,           // Geriyaz'a kadar çıktılar
    output reg [ 4:0] yurut_rd_adres_o ,
    output reg        decode_working_info_o        
);


wire[`BIT_SAYISI_COZ-1:0] buyruk_w = {getir_buyruk_i[31:27], getir_buyruk_i[25], getir_buyruk_i[20], getir_buyruk_i[14:12], getir_buyruk_i[6:2]};
reg [ 1:0] reg_file_sec_r;

reg [ 3:0]  birim_secimi_sonraki_r;
reg [ 4:0]  islem_secimi_sonraki_r;
reg [ 4:0]  shamt_sonraki_r;
reg [ 2:0]  rm_sonraki_r;
reg         aq_sonraki_r;
reg         rl_sonraki_r;
wire [31:0] integer_deger1_sonraki_r;
wire [31:0] integer_deger2_sonraki_r;
wire [31:0] float_deger1_sonraki_r;  
wire [31:0] float_deger2_sonraki_r;  
wire [31:0] float_deger3_sonraki_r;  
reg  [31:0] immidiate_sonraki_r;     
reg  [31:0] ps_yeni_sonraki_r;       
reg  [ 4:0] rd_adres_sonraki_r;       


always@(*)begin
    casez (buyruk_w)
        `ADD_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_ADD;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SUB_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SUB;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
         end  
        `SLL_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLL;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SLT_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLT;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end     
        `SLTU_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLTU;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `XOR_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_XOR;                                
             reg_file_sec_r = `INTEGER_REGISTER; 
        end  
        `SRL_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SRL;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SRA_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SRA;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `OR_COZ        : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_OR;                                 
             reg_file_sec_r = `INTEGER_REGISTER; 
        end  
        `AND_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_AND;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ADDI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_ADDI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SLTI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLTI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SLTIU_COZ     : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLTIU;      
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `XORI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_XORI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ORI_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_ORI;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ANDI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;      
             islem_secimi_sonraki_r = `ALU_ANDI;       
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SLLI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SLLI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `SRLI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SRLI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `SRAI_COZ      : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_SRAI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `SB_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_SB;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SH_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_SH;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SW_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_SW;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LB_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_LB;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LH_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_LH;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LW_COZ        : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_LW;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER; 
        end  
        `LBU_COZ       : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_LBU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LHU_COZ       : begin
             birim_secimi_sonraki_r = `MEMORY_UNIT;                 
             islem_secimi_sonraki_r = `MEM_LHU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BEQ_COZ       : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BEQ;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BNE_COZ       : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BNE;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BLT_COZ       : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BLT;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BGE_COZ       : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BGE;         
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BLTU_COZ      : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BLTU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BGEU_COZ      : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_BGEU;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[7], getir_buyruk_i[30:25], getir_buyruk_i[11: 8], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LUI_COZ       : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_LUI;        
             immidiate_sonraki_r = {getir_buyruk_i[31:12], 12'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `AUIPC_COZ     : begin
             birim_secimi_sonraki_r = `ARITHMETIC_LOGIC_UNIT;       
             islem_secimi_sonraki_r = `ALU_AUIPC;      
             immidiate_sonraki_r = {getir_buyruk_i[31:12], 12'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `JAL_COZ       : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_JAL;         
             immidiate_sonraki_r = {{12{getir_buyruk_i[31]}}, getir_buyruk_i[19:12], getir_buyruk_i[20], getir_buyruk_i[30:21], 1'b0};  
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `JALR_COZ      : begin
             birim_secimi_sonraki_r = `BRANCH_RESOLVER_UNIT;        
             islem_secimi_sonraki_r = `BR_JALR;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:20]};  
             reg_file_sec_r = `INTEGER_REGISTER; 
        end  
        `MUL_COZ       : begin
             birim_secimi_sonraki_r = `INTEGER_MULTIPLICATION_UNIT; 
             islem_secimi_sonraki_r = `INT_MUL;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MULH_COZ      : begin
             birim_secimi_sonraki_r = `INTEGER_MULTIPLICATION_UNIT; 
             islem_secimi_sonraki_r = `INT_MULH;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MULHSU_COZ    : begin
             birim_secimi_sonraki_r = `INTEGER_MULTIPLICATION_UNIT; 
             islem_secimi_sonraki_r = `INT_MULHSU;                             
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MULHU_COZ     : begin
             birim_secimi_sonraki_r = `INTEGER_MULTIPLICATION_UNIT; 
             islem_secimi_sonraki_r = `INT_MULHU;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `DIV_COZ       : begin
             birim_secimi_sonraki_r = `INTEGER_DIVISION_UNIT;       
             islem_secimi_sonraki_r = `INT_DIV;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `DIVU_COZ      : begin
             birim_secimi_sonraki_r = `INTEGER_DIVISION_UNIT;      
             islem_secimi_sonraki_r = `INT_DIVU;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `REM_COZ       : begin
             birim_secimi_sonraki_r = `INTEGER_DIVISION_UNIT;       
             islem_secimi_sonraki_r = `INT_REM;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `REMU_COZ      : begin
             birim_secimi_sonraki_r = `INTEGER_DIVISION_UNIT;       
             islem_secimi_sonraki_r = `INT_REMU;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `LR_W_COZ      : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_LR_W;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26]; 
        end  
        `SC_W_COZ      : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                
             islem_secimi_sonraki_r = `ATOM_SC_W;                              
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOSWAP_W_COZ : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOSWAP_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOADD_W_COZ  : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOADD_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOXOR_W_COZ  : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOXOR_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOAND_W_COZ  : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOAND_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOOR_W_COZ   : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOOR_W;                           
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOMIN_W_COZ  : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOMIN_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOMAX_W_COZ  : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOMAX_W;                          
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOMINU_W_COZ : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOMINU_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `AMOMAXU_W_COZ : begin
             birim_secimi_sonraki_r = `ATOMIC_UNIT;                 
             islem_secimi_sonraki_r = `ATOM_AMOMAXU_W;                         
             reg_file_sec_r = `INTEGER_REGISTER;
             rl_sonraki_r = getir_buyruk_i[25];
             aq_sonraki_r = getir_buyruk_i[26];  
        end  
        `FLW_COZ       : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FLW;        
             immidiate_sonraki_r = getir_buyruk_i[31:20]; 
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FSW_COZ       : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSW;        
             immidiate_sonraki_r = {{20{getir_buyruk_i[31]}}, getir_buyruk_i[31:25], getir_buyruk_i[11:7]};  
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FMADD_S_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMADD_S;                            
             reg_file_sec_r = `FLOAT_REGISTER; 
             rm_sonraki_r = getir_buyruk_i[12];  
        end  
        `FMSUB_S_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMSUB_S;                            
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FNMSUB_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FNMSUB_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FNMADD_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FNMADD_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FADD_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FADD_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];   
         end  
        `FSUB_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSUB_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FMUL_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMUL_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FDIV_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FDIV_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FSQRT_S_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSQRT_S;                            
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FSGNJ_S_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSGNJ_S;                            
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FSGNJN_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSGNJN_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FSGNJX_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FSGNJX_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FMIN_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMIN_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FMAX_S_COZ    : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMAX_S;                             
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FCVT_W_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FCVT_W_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FCVT_WU_S_COZ : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FCVT_WU_S;                          
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FMV_X_W_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMV_X_W;                            
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FEQ_S_COZ     : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FEQ_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FLT_S_COZ     : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FLT_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FLE_S_COZ     : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FLE_S;                              
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FCLASS_S_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FCLASS_S;                           
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `FCVT_S_W_COZ  : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FCVT_S_W;                           
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FCVT_S_WU_COZ : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FCVT_S_WU;                          
             reg_file_sec_r = `FLOAT_REGISTER;
             rm_sonraki_r = getir_buyruk_i[12];    
        end  
        `FMV_W_X_COZ   : begin
             birim_secimi_sonraki_r = `FLOATING_POINT_UNIT;         
             islem_secimi_sonraki_r = `FLT_FMV_W_X;                            
             reg_file_sec_r = `FLOAT_REGISTER;    
        end  
        `ANDN_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ANDN;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CLMUL_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CLMUL;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CLMULH_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CLMULH;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CLMULR_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CLMULR;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CLZ_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CLZ;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CPOP_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CPOP;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `CTZ_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_CTZ;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MAX_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;      
             islem_secimi_sonraki_r = `BT_MAX;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MAXU_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_MAXU;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MIN_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_MIN;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `MINU_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_MINU;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ORC_B_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ORC_B;                               
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ORN_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ORN;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `REV8_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_REV8;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ROL_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ROL;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ROR_COZ       : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ROR;                                 
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `RORI_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_RORI;                                
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `BCLR_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BCLR;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BCLRI_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BCLRI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `BEXT_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BEXT;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BEXTI_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BEXTI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `BINV_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BINV;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BINVI_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BINVI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `BSET_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BSET;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `BSETI_COZ     : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_BSETI;                               
             reg_file_sec_r = `INTEGER_REGISTER;
             shamt_sonraki_r = getir_buyruk_i[24:20];  
        end  
        `SEXT_B_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_SEXT_B;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SEXT_H_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_SEXT_H;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SH1ADD_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_SH1ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SH2ADD_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_SH2ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `SH3ADD_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_SH3ADD;                              
             reg_file_sec_r = `INTEGER_REGISTER; 
        end  
        `XNOR_COZ      : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_XNOR;                                
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        `ZEXT_H_COZ    : begin
             birim_secimi_sonraki_r = `BIT_MANIPULATION_UNIT;       
             islem_secimi_sonraki_r = `BT_ZEXT_H;                              
             reg_file_sec_r = `INTEGER_REGISTER;  
        end  
        default        : begin
            birim_secimi_sonraki_r = `NO_UNIT;
        end 
    endcase
end

IntegerRegisterFile IRF (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .reg_write_i(writeback_enable_i),
    .rs1_i(getir_buyruk_i[19:15]),
    .rs2_i(getir_buyruk_i[24:20]),
    .rd_i(writeback_address_i),
    .write_data_i(writeback_result_i),
    .read_data1_o(integer_deger1_sonraki_r),
    .read_data2_o(integer_deger2_sonraki_r)
);

FloatRegisterFile FRF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .reg_write_i(writeback_enable_i),
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
        yurut_birim_secimi_o <= `NO_UNIT;
    end
    else if (execute_working_info_i == `EXECUTE_IS_NOT_WORKING)begin
        yurut_birim_secimi_o   <= birim_secimi_sonraki_r;
        yurut_islem_secimi_o   <= islem_secimi_sonraki_r;
        yurut_shamt_o          <= shamt_sonraki_r;
        yurut_rm_o             <= rm_sonraki_r;
        yurut_aq_o             <= aq_sonraki_r;
        yurut_rl_o             <= rl_sonraki_r;
        yurut_immidiate_o      <= immidiate_sonraki_r;
        yurut_ps_yeni_o        <= ps_yeni_sonraki_r;
        yurut_rd_adres_o       <= getir_buyruk_i[11:7];
        yurut_integer_deger1_o <= integer_deger1_sonraki_r;
        yurut_integer_deger2_o <= integer_deger2_sonraki_r;
        yurut_float_deger1_o   <= float_deger1_sonraki_r;
        yurut_float_deger2_o   <= float_deger2_sonraki_r;
        yurut_float_deger3_o   <= float_deger3_sonraki_r;
        decode_working_info_o  <= `DECODE_IS_NOT_WORKING;   
    end else begin
        decode_working_info_o  <= `DECODE_IS_WORKING;
    end

end
endmodule
