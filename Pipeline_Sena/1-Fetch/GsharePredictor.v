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
    input getir_gecerli,
    input yurut_gecerli,
    input clk,
    input rst,
    input [31:0] getir_ps,
    input [31:0] getir_buyruk,
    input [31:0] yurut_ps,
    input [31:0] yurut_buyruk,
    input yurut_dallan,
    input [31:0] yurut_dallan_ps,
    output reg sonuc_dallan,
    output reg [31:0] sonuc_dallan_ps
    );
    localparam GT = 2'd0;//güclü atlamaz
    localparam ZT = 2'd1;//zayıf atlamaz
    localparam ZA = 2'd2;//güclü atlar
    localparam GA = 2'd3;//zayıf atlar
    reg [1:0] cift_kutuplu_tablo [15:0];
    reg [1:0] cift_kutuplu_tablo_next [15:0];
    reg [3:0] genel_gecmis_yazmaci, genel_gecmis_yazmaci_next;
    reg [3:0] xor_sonucu, buyruk_adresi_xor;
    reg [31:0] dallan_ps;//gerek yok sanırım.
    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            cift_kutuplu_tablo[i] = GT;
        end
        genel_gecmis_yazmaci = 4'b0000;
    end
    always @* begin
        for (i = 0; i < 16; i = i + 1) begin
            cift_kutuplu_tablo_next[i] = cift_kutuplu_tablo[i];
        end
        genel_gecmis_yazmaci_next = genel_gecmis_yazmaci;
        if (getir_gecerli) begin
            buyruk_adresi_xor = getir_ps[3:0];
            if (cift_kutuplu_tablo[xor_sonucu] == GT || cift_kutuplu_tablo[xor_sonucu] == ZT) begin
                sonuc_dallan = 1'b0;
            end
            else begin
                sonuc_dallan = 1'b1;
                if (getir_buyruk[31] == 1'b1)
                    dallan_ps = {19'b1111_1111_1111_1111_111, getir_buyruk[31], getir_buyruk[7], getir_buyruk[30:25], getir_buyruk[11:8], 1'b0} + getir_ps;
                else
                    dallan_ps = {19'b0000_0000_0000_0000_000, getir_buyruk[31], getir_buyruk[7], getir_buyruk[30:25], getir_buyruk[11:8], 1'b0} + getir_ps;
                sonuc_dallan_ps = dallan_ps;
            end  
        end
        else if (yurut_gecerli) begin
            if (yurut_dallan) begin
                if(cift_kutuplu_tablo[xor_sonucu] != GA) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] + 1;
                end
            end
            else begin
                if(cift_kutuplu_tablo[xor_sonucu] != GT) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] - 1;
                end
            end
            genel_gecmis_yazmaci_next[3:1] = genel_gecmis_yazmaci[2:0];
            genel_gecmis_yazmaci_next[0] = yurut_dallan;
        end
    end
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) begin
                cift_kutuplu_tablo[i] <= GT;
            end
            dallan_ps <= 0;
            genel_gecmis_yazmaci <= 4'b0000;
        end
        else begin
            genel_gecmis_yazmaci <= genel_gecmis_yazmaci_next;
            for (i = 0; i < 16; i = i + 1) begin
                cift_kutuplu_tablo[i] <= cift_kutuplu_tablo_next[i];
            end
        end
    end    
endmodule
