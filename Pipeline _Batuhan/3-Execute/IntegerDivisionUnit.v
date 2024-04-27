
`timescale 1ns / 1ps
`include "definitions.vh"
module division_unit(
    input               clk_i,       // Clock input
    input               rst_i,       // Reset input
    input               enable_i,    // Enable input
    input        [ 3:0] islem_i,     // 00-DIV, 01-DIVU, 10-REM, 11-REMU
    input        [31:0] bolunen_i,   // Operand 1 input Q
    input        [31:0] bolen_i,     // Operand 2 input M
    output wire   [31:0] sonuc_o,     // Result output
    output reg          bitti_o 
    );
    reg flag_r = 1'b1;
    reg flag_sonraki_r;
    
    reg [ 5:0] bit_sayisi_r;
    reg [ 5:0] bit_sayisi_sonraki_r = 6'd32;
    
    reg [32:0] kalan_r;
    reg [32:0] kalan_sonraki_r;
    
    reg [32:0] bolen_r;
    reg [32:0] bolen_sonraki_r;
    
    reg [32:0] bolunen_r;
    reg [32:0] bolunen_sonraki_r;
    
    reg [ 1:0] islem_r;
    reg [ 1:0] islem_sonraki_r;
    
    reg [31:0] sonuc_r;
    assign sonuc_o = sonuc_r;
    
    reg [ 1:0] isaret_secimi_r;//{bolunen_isareti, bolen_isareti}
    reg bitti_sonraki_r = 1'b0;

always@(*) begin
    if(enable_i && flag_r )begin
       isaret_secimi_r = {bolunen_i[31],bolen_i[31]};
       kalan_sonraki_r = 1'b0;
       islem_sonraki_r = islem_i;
       flag_sonraki_r  = 1'b0; 
       case (isaret_secimi_r)
       2'b00 : begin
            bolunen_sonraki_r = {1'b0,bolunen_i};
            bolen_sonraki_r   = {1'b0,bolen_i};
        end
        2'b01 : begin
            bolunen_sonraki_r = {1'b0,bolunen_i};
            bolen_sonraki_r   = {1'b0, ((~bolen_i)+1)};
        end
        2'b10 : begin
            bolunen_sonraki_r = {1'b0,((~bolunen_i)+1)};
            bolen_sonraki_r   = {1'b0,bolen_i};
        end 
        2'b11 : begin
            bolunen_sonraki_r = {1'b0,((~bolunen_i)+1)};
            bolen_sonraki_r   = {1'b0,((~bolen_i)+1)};
        end
       endcase
    end else  begin
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
            bit_sayisi_sonraki_r = 6'd32;
            bitti_sonraki_r = 1'b1;
            flag_sonraki_r = 1'b1;
            
            if(kalan_sonraki_r[32])begin
                kalan_sonraki_r = kalan_sonraki_r + bolen_r;
            end
            
            casez(islem_sonraki_r)
                `INT_DIVU  : begin
                    sonuc_r = bolunen_sonraki_r;
                end
                `INT_REMU  : begin
                    sonuc_r = kalan_sonraki_r;
                end
                `INT_DIV   : begin
                    if(isaret_secimi_r[1] ^ isaret_secimi_r[0])begin
                        sonuc_r = (~bolunen_sonraki_r) +1;
                    end else begin
                        sonuc_r = bolunen_sonraki_r;
                    end
                end
                `INT_REM   : begin
                    if(isaret_secimi_r[1] ==1'b1 && isaret_secimi_r[0] == 1'b0)begin
                        sonuc_r = bolen_i + ((~kalan_sonraki_r) +1);
                    end else if(isaret_secimi_r[1] ==1'b0 && isaret_secimi_r[0] == 1'b1) begin
                        sonuc_r = bolen_i - ((~kalan_sonraki_r) +1);
                    end else if(isaret_secimi_r[1] ==1'b0 && isaret_secimi_r[0] == 1'b0) begin
                        sonuc_r = kalan_sonraki_r;
                    end else begin
                        sonuc_r = ((~kalan_sonraki_r) +1);
                    end
                end
                default : begin
                   
                end
            endcase
        end else begin
            sonuc_r = 32'bx;
            bitti_o = 1'b0;
        end
    end
end

always@(posedge clk_i) begin
    if(rst_i) begin
        kalan_r   <= 0;
        bolen_r   <= 0;
        bolunen_r <= 0;
        islem_r   <= 0;
    end else begin
        flag_r         <= flag_sonraki_r;
        kalan_r        <= kalan_sonraki_r;
        bolen_r        <= bolen_sonraki_r;
        bolunen_r      <= bolunen_sonraki_r;
        islem_r        <= islem_sonraki_r;
        bit_sayisi_r   <= bit_sayisi_sonraki_r;
        bitti_o        <= bitti_sonraki_r;
    end

end

endmodule
