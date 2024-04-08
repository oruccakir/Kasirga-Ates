//33 çevrim - DIVU ve REMU destekliyor

`timescale 1ns / 1ps

module division_unit(
    input clk_i, // Clock input
    input rst_i, // Reset input
    input basla_i, // Enable input
    input [1:0] islem_i, // 00-DIV, 01-DIVU, 10-REM, 11-REMU
    input [31:0] bolunen_i, // Operand 1 input Q
    input [31:0] bolen_i, // Operand 2 input M
    output wire  [31:0] sonuc_o, // Result output
    output reg bitti_o = 0
    );

    reg flag_r = 1'b1;
    
    reg [5:0] bit_sayisi_r         ;
    reg [5:0] bit_sayisi_sonraki_r = 32;
    
    reg [32:0] kalan_r             = 0;
    reg [32:0] kalan_sonraki_r     = 0;
    
    reg [32:0] bolen_r             = 0;
    reg [32:0] bolen_sonraki_r     = 0;
    
    reg [32:0] bolunen_r           = 0;
    reg [32:0] bolunen_sonraki_r   = 0;
    
    reg [1:0] islem_r              = 0;
    reg [1:0] islem_sonraki_r      = 0;
    
    reg [31:0] sonuc_r             = 0;
    reg [31:0] sonuc_sonraki_r     = 0;
    
    reg bitti_r                    = 0;
    reg bitti_sonraki_r            = 0;
    
    always@(*) begin
        if(basla_i & flag_r)begin
           kalan_sonraki_r = 0;
           bolen_sonraki_r = bolen_i;
           bolunen_sonraki_r = bolunen_i;
           islem_sonraki_r   = islem_i;
           flag_r = 1'b0; 
        end else begin
            {kalan_sonraki_r , bolunen_sonraki_r} =  {kalan_r , bolunen_r} << 1;
            if(kalan_sonraki_r[32]) begin
                kalan_sonraki_r = kalan_sonraki_r + bolen_r;
            end else begin
                kalan_sonraki_r = kalan_sonraki_r - bolen_r;
            end
            
            if(kalan_sonraki_r[32]) begin
                bolunen_sonraki_r[0] = 1'b0;
            end else begin
                bolunen_sonraki_r[0] = 1'b1;
            end
            
            bit_sayisi_sonraki_r = bit_sayisi_r - 1;
            if(bit_sayisi_r == 0) begin
                bitti_o = 1'b1;
                if(kalan_sonraki_r[32])begin
                    kalan_sonraki_r = kalan_sonraki_r + bolen_r;
                end
            end
        end
    end
    
    always@(posedge clk_i) begin
        if(rst_i) begin
            kalan_r   <= 0;
            bolen_r   <= 0;
            bolunen_r <= 0;
            islem_r   <= 0;
            sonuc_r   <= 0;
            bitti_r   <= 0;
        end else begin
            kalan_r      <= kalan_sonraki_r;
            bolen_r      <= bolen_sonraki_r;
            bolunen_r    <= bolunen_sonraki_r;
            islem_r      <= islem_sonraki_r;
            sonuc_r      <= sonuc_sonraki_r;
            bitti_r      <= bitti_sonraki_r;
            bit_sayisi_r <= bit_sayisi_sonraki_r;
        end
    end
endmodule
