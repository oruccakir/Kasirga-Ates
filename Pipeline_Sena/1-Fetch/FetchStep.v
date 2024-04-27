`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input         clk_i, // Clock input
    input         rst_i, // Reset input

    // buyruk önbelleği <> getir
    input              bellek_gecerli_i, //bellekten gelen buyruk geçerli 
    input      [31:0]  bellek_deger_i,   //bellekten gelen bıyruk
    output reg         bellek_istek_o,   //bellekten sonraki buyruk için istek
    output reg [31:0]  bellek_ps_o,      //sonraki buyruğun program sayacı
    

    // getir <> coz
    input              coz_bos_i,        //çöz aşamasında buyruk yok
    output reg [31:0]  coz_buyruk_o,     //çöz aşamasına verilecek olan buyruk
    output reg         coz_buyruk_gecerli_o,//çöz aşamasına buyruk verildi
    output reg [31:0]  coz_ps_o,         //çöz aşamasına verilecek olan buyruğun program sayacı

    //dallanma birimi (yurut) <> getir
    input      [31:0]  yurut_ps_i,       //yürüt aşamasından gelen dallanma buyruğunun adresi
    input              yurut_ps_gecerli_i,//yürüt aşamasından doğru program sayacı geldi
    input              yurut_atladi_i    //dallanma öngörüsüne verilecek düzeltme sinyali
);

reg [31:0] ps=32'h8000_0000;
reg [31:0] ps_next;


// dallanma öngörücüsü için gerekli input ve outputlar
reg dallanma_tahmini_gecerli;
reg [31:0] ongoru_genisletilmis_anlik;

wire [31:0] ongorulen_ps;
wire ongorulen_ps_gecerli;

reg yanlis_tahmin;
reg yeni_baslamadi=0;

always @(*) begin
    ps_next = ps;
    yanlis_tahmin = 0;
    dallanma_tahmini_gecerli = 'b0;

    if (bellek_gecerli_i) begin
        yeni_baslamadi = 1;
        dallanma_tahmini_gecerli = (bellek_deger_i[1:0] == 'b11);
        if (dallanma_tahmini_gecerli) begin
            case (bellek_deger_i[3:2])
                'b11: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {12'b1111_1111_1111, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]} : {12'b0000_0000_0000, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]};//son bit 0 mı olacak?
                end
                'b01: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31:20]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31:20]};
                end
                'b00: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]};//son bit 0 mı olacak?
                end
                default: begin
                    dallanma_tahmini_gecerli = 'b0;
                end
            endcase
        end
    end
    if (yurut_ps_gecerli_i) begin
        yanlis_tahmin = (yurut_ps_i != ps_next) ? 'b1 : 'b0; 
    end
    if (ongorulen_ps_gecerli) begin
        ps_next = ongorulen_ps;
    end
    else if (yanlis_tahmin && yurut_ps_gecerli_i) begin
        ps_next = yurut_ps_i;
    end
    else if (bellek_gecerli_i) begin
        ps_next = ps + 4;
    end
end

GsharePredictor ongoru(
    .clk_i                              (clk_i),
    .rst_i                              (rst_i),
    
    .ongoru_genisletilmis_anlik_i       (ongoru_genisletilmis_anlik),
    .tahmin_ps_gecerli_i                (dallanma_tahmini_gecerli),
    .tahmin_ps_i                        (ps),

    .ongorulen_ps_gecerli_o             (ongorulen_ps_gecerli),
    .ongorulen_ps_o                     (ongorulen_ps),

    .yurut_ps_gecerli_i                 (yurut_ps_gecerli_i),	
    .yurut_ps_i                         (yurut_ps_i),
    .yanlis_tahmin_i                    (yanlis_tahmin),
    .yurut_atladi_i                     (yurut_atladi_i));



integer i = 0;
always @(*) begin
    $display("Gelen instruction %h",bellek_deger_i," Num %d ",i);
    i = i +1;
end

always @(posedge clk_i) begin
    if (rst_i) begin
        yeni_baslamadi <= 0;
        bellek_istek_o <= 1'b1;
        bellek_ps_o <= 0;
        ps <= 32'h8000_0000;
    end
    else begin
        
        if (bellek_gecerli_i && coz_bos_i) begin //&&coz_bos_i gereksiz mi
            coz_buyruk_gecerli_o = 1'b1;//<= olursa bi şey değişir mi?
            coz_ps_o = ps;
            coz_buyruk_o = bellek_deger_i;
        end
        else begin
            coz_buyruk_gecerli_o = 1'b0;
        end

        ps = ps_next;

        if (!yeni_baslamadi) begin
            bellek_ps_o = ps_next;
            bellek_istek_o = 1'b1;         
        end
        else begin
            if ((coz_bos_i && bellek_gecerli_i) || yanlis_tahmin) begin//bellekten bilgi geldiyse???aşama boş kalabilir mi? ve çöz boş veya yanlış dallanma tahminiyse belleğe istek atılır.
                bellek_ps_o = ps_next;
                bellek_istek_o = 1'b1;         
            end
            else begin
                bellek_istek_o = 1'b0;
            end
        end
        
    end
end


endmodule