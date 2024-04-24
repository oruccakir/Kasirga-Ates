`timescale 1ns/1ps //////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 18:46:13
// Design Name: 
// Module Name: GsharePredictor
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
module GsharePredictor(
    input clk_i,
    input rst_i,
    
    input ongoru_genisletilmis_anlik_i,
    input tahmin_ps_gecerli_i,
    input [31:0] tahmin_ps_i,   

    output reg ongorulen_ps_gecerli_o,
    output reg [31:0] ongorulen_ps_o,

    input yurut_ps_gecerli_i,
    input [31:0] yurut_ps_i,  
    input yanlis_tahmin_i,
    input yurut_atladi_i,

    output reg dogru_ps_gecerli_o,//'b1 olduğunda getir psyi güncelleyecek.
    output reg [31:0]  dogru_ps_o

    );
    
    localparam GT = 2'd0;//güclü atlamaz
    localparam ZT = 2'd1;//zayıf atlamaz
    localparam ZA = 2'd2;//güclü atlar
    localparam GA = 2'd3;//zayıf atlar
    
    
    reg [1:0] cift_kutuplu_tablo [31:0];
    reg [1:0] cift_kutuplu_tablo_next [31:0];
    reg [4:0] genel_gecmis_yazmaci, genel_gecmis_yazmaci_next;
    reg [4:0] xor_sonucu, buyruk_adresi_xor;
    reg dallan;
    
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            cift_kutuplu_tablo[i] = GT;
        end
        genel_gecmis_yazmaci = 5'b00000;
    end
    
    always @* begin
        //reg outputları 0 yapmayı unutma
        for (i = 0; i < 32; i = i + 1) begin
            cift_kutuplu_tablo_next[i] = cift_kutuplu_tablo[i];
        end
        genel_gecmis_yazmaci_next = genel_gecmis_yazmaci;
        
        if (tahmin_ps_gecerli_i) begin
            buyruk_adresi_xor = tahmin_ps_i[5:1];
            xor_sonucu = buyruk_adresi_xor ^ genel_gecmis_yazmaci;
            if (cift_kutuplu_tablo[xor_sonucu] == GT || cift_kutuplu_tablo[xor_sonucu] == ZT) begin
                dallan = 1'b0;
            end
            else begin
                dallan = 1'b1;
            end  
        end
        
        else if (yurut_ps_gecerli_i) begin
            buyruk_adresi_xor = yurut_ps_i[5:1];
            xor_sonucu = buyruk_adresi_xor ^ genel_gecmis_yazmaci;
            if (!yurut_atladi_i && yanlis_tahmin_i) begin
                if(cift_kutuplu_tablo[xor_sonucu] != GA) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] + 1;
                end
            end
            if (yurut_atladi_i && yanlis_tahmin_i) begin
                if(cift_kutuplu_tablo[xor_sonucu] != GT) begin
                    cift_kutuplu_tablo_next[xor_sonucu] = cift_kutuplu_tablo[xor_sonucu] - 1;
                end
            end
            genel_gecmis_yazmaci_next[4:1] = genel_gecmis_yazmaci[3:0];
            genel_gecmis_yazmaci_next[0] = yurut_atladi_i;
        end
    end
    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < 32; i = i + 1) begin
                cift_kutuplu_tablo[i] <= GT;
            end
            genel_gecmis_yazmaci <= 5'b00000;
        end
        else begin
            genel_gecmis_yazmaci <= genel_gecmis_yazmaci_next;
            for (i = 0; i < 32; i = i + 1) begin
                cift_kutuplu_tablo[i] <= cift_kutuplu_tablo_next[i];
            end
            if (tahmin_ps_gecerli_i) begin
                ongorulen_ps_gecerli_o <= 'b1;
                ongorulen_ps_o <= (dallan) ? ongoru_genisletilmis_anlik_i : tahmin_ps_i + 4;
            end
            if (yurut_ps_gecerli_i) begin
                dogru_ps_gecerli_o <= 'b1;
                dogru_ps_o <= yurut_ps_i;
            end
        end
    end    
endmodule