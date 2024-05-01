`timescale 1ns / 1ps

`include "memory_definitions.vh"

module main_memory_controller(
    input                                   clk_i,
    input                                   rst_i,
    
    // main_memory_controller <> instruction_cache_controller
    input       [`BUYRUK_ADRES_BIT-1:0]                     denetleyici_okuma_istek_adres_i, // anabellekten okumak istedigim adresi denetleyiciye veriyorum
    input                                                   denetleyici_okuma_istek_gecerli_i, // anabellekten okuma yapmak istedigimi denetleyiciye bildiriyorum 
    output      [`BUYRUK_BLOK_BIT-1:0]                      denetleyici_okuma_veri_blok_o, // anabellekten okumak istedigim veri blogunu anabellek denetleyicisinden aliyorum
    output                                                  denetleyici_okuma_istek_hazir_o // anabellekten okunan verinin anabellek denetleyicisi uzerinden geldigini haber veriyorum
    );
    
    reg [`BUYRUK_BLOK_BIT-1:0] BELLEK [3:0];
    
    initial begin
        //BELLEK[0] = {32'd4, 32'd3, 32'd2, 32'd1};
        //BELLEK[1] = {32'd8, 32'd7, 32'd6, 32'd5};
        //BELLEK[2] = {32'd12, 32'd11, 32'd10, 32'd9};
        //BELLEK[3] = {32'd16, 32'd15, 32'd14, 32'd13};
        
        BELLEK[0] = {32'h15ef0e93, 32'h40360f33, 32'h008381b3, 32'h00940633};
        BELLEK[1] = {32'h0235cb33, 32'h03158ab3, 32'h003589b3, 32'h40c288b3};
        BELLEK[2] = {32'h016586b3, 32'h06cfa223, 32'h025185b3, 32'h02897cb3};
        BELLEK[3] = {32'h00001f37, 32'h073fa423, 32'h016586b3, 32'h000fae03};
    end
    
    //DURUM MAKINESI
    localparam BOSTA = 'd0;
    localparam YANIT_VER = 'd1;
    
    reg simdiki_durum = BOSTA;
    reg sonraki_durum;
    
    reg [`BUYRUK_BLOK_BIT-1:0] veri;
    
    always @(posedge clk_i) begin
        if(rst_i) begin
           simdiki_durum <= BOSTA; 
        end
        else begin
           simdiki_durum <= sonraki_durum;
        end
    end
    
    always @(*) begin 
        case(simdiki_durum)
            BOSTA: begin
                if(denetleyici_okuma_istek_gecerli_i) begin
                    sonraki_durum = YANIT_VER;
                end
                else begin
                    sonraki_durum = BOSTA;
                end
            end
            YANIT_VER: begin
               veri = BELLEK[denetleyici_okuma_istek_adres_i[31:4]];
               sonraki_durum = BOSTA;
            end
        endcase
    end
    
    assign denetleyici_okuma_veri_blok_o = veri;
    assign denetleyici_okuma_istek_hazir_o = (simdiki_durum == YANIT_VER);
    
endmodule
