`timescale 1ns/1ps //////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 18:46:13
// Design Name: 
// Module Name: ongorucu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//gshare predictor
module GsharePredictor(
    input clk_i,
    input rst_i,
    
    input [31:0] getir_ps_i,
    input getir_ps_gecerli,
    input [31:0] buyruk_i,
    
    input [31:0] yurut_ps_i,
    input yurut_ps_gecerli,
    input yurut_yanlis_tahmin,
    input [31:0] yurut_dogru_adres_i,
    input yurut_atladi_i,
    
    output reg sonuc_dallan_o,
    output reg [31:0] sonuc_dallan_ps_o
    );
    
    localparam GT = 2'd0;//güclü atlamaz
    localparam ZT = 2'd1;//zayıf atlamaz
    localparam ZA = 2'd2;//güclü atlar
    localparam GA = 2'd3;//zayıf atlar
    
    
    reg [1:0] cift_kutuplu_tablo [31:0];
    reg [1:0] cift_kutuplu_tablo_next [31:0];
    reg [4:0] genel_gecmis_yazmaci, genel_gecmis_yazmaci_next;
    reg [4:0] xor_sonucu, buyruk_adresi_xor;
    reg [31:0] dallan_ps;//gerek yok sanırım.
    
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            cift_kutuplu_tablo[i] = GT;
        end
        genel_gecmis_yazmaci = 5'b00000;
    end
    
    always @* begin
        for (i = 0; i < 32; i = i + 1) begin
            cift_kutuplu_tablo_next[i] = cift_kutuplu_tablo[i];
        end
        genel_gecmis_yazmaci_next = genel_gecmis_yazmaci;
        
        if (getir_ps_gecerli) begin
            buyruk_adresi_xor = getir_ps_i[5:1];
            if (cift_kutuplu_tablo[xor_sonucu] == GT || cift_kutuplu_tablo[xor_sonucu] == ZT) 		begin
                sonuc_dallan_o = 1'b0;
            end
            else begin
                sonuc_dallan_o = 1'b1;
                if (buyruk_i[31] == 1'b1)
                    dallan_ps = {19'b1111_1111_1111_1111_111, buyruk_i[31], buyruk_i[7], buyruk_i[30:25], buyruk_i[11:8], 1'b0} + getir_ps_i;
                else
                    dallan_ps = {19'b0000_0000_0000_0000_000, buyruk_i[31], buyruk_i[7], buyruk_i[30:25], buyruk_i[11:8], 1'b0} + getir_ps_i;
                sonuc_dallan_ps_o = dallan_ps;
            end  
        end
        else if (yurut_ps_gecerli) begin
            if (yurut_atladi_i) begin
                if(cift_kutuplu_tablo[xor_sonucu] != GA) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] + 1;
                end
            end
            else begin
                if(cift_kutuplu_tablo[xor_sonucu] != GT) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] - 1;
                end
            end
            genel_gecmis_yazmaci_next[4:1] = genel_gecmis_yazmaci[3:0];
            genel_gecmis_yazmaci_next[0] = yurut_dallan;
        end
    end
    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < 32; i = i + 1) begin
                cift_kutuplu_tablo[i] <= GT;
            end
            dallan_ps <= 0;
            genel_gecmis_yazmaci <= 5'b00000;
        end
        else begin
            genel_gecmis_yazmaci <= genel_gecmis_yazmaci_next;
            for (i = 0; i < 32; i = i + 1) begin
                cift_kutuplu_tablo[i] <= cift_kutuplu_tablo_next[i];
            end
        end
    end    
endmodule