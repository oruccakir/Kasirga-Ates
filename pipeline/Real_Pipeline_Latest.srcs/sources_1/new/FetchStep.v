`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input         clk_i, // Clock input
    input         rst_i, // Reset input

    // buyruk  onbellegi <> getir
    input              bellek_gecerli_i, //bellekten gelen buyruk gecerli 
    input      [31:0]  bellek_deger_i,   //bellekten gelen buyruk
    output reg         bellek_istek_o,   //bellekten sonraki buyruk icin istek
    output reg [31:0]  bellek_ps_o,      //sonraki buyrugun program sayac
    

    // getir <> coz
    
    input              coz_bos_i,        //coz asamasinda buyruk yok
    output reg [31:0]  coz_buyruk_o,     //coz asamasina verilecek olan buyruk
    output reg         coz_buyruk_gecerli_o,//coz asamasina buyruk verildi
    output reg [31:0]  coz_ps_o,         //coz asamasina verilecek olan buyrugun program sayaci
    output wire        ongoru_atladi_o,  //yurutun yanlis tahmin bilgisi vermesi icin cozun yurute direkt verecegi atladi bilgisi

    //dallanma birimi (yurut) <> getir
    input      [31:0]  yurut_ps_i,       //yurut asamasindan gelen dallanma buyrugunun adresi
    input              yurut_ps_gecerli_i,//yurut asamasindan dogru program sayaci geldi
    input              yurut_atladi_i,    //dallanma ongorusune verilecek duzeltme sinyali
    input              yurut_yanlis_tahmin_i//psyi ve ongorucuyu duzeltmek icin gonderilen dallanma yanlis tahmin bilgisi
);

reg [31:0] ps='h8000_0000;
reg [31:0] ps_next;
reg [31:0] buyruk_next;
reg buyruk_gecerli;
// dallanma ongorusu icin gerekli input ve outputlar
reg dallanma_tahmini_gecerli;
reg [31:0] ongoru_genisletilmis_anlik;

wire [31:0] ongorulen_ps;
wire ongorulen_ps_gecerli;


always @(*) begin
    ps_next = ps;
    dallanma_tahmini_gecerli = 'b0;

    if (bellek_gecerli_i) begin
        buyruk_next = bellek_deger_i;
        buyruk_gecerli = 1;
        dallanma_tahmini_gecerli = (bellek_deger_i[6:5] == 'b11);
        if (dallanma_tahmini_gecerli) begin
            case (bellek_deger_i[3:2])
                'b11: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {12'b1111_1111_1111, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]} : {12'b0000_0000_0000, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]};//son bit 0 m  olacak?
                end
                'b01: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31:20]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31:20]};
                end
                'b00: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]};//son bit 0 m  olacak?
                end
                default: begin
                    dallanma_tahmini_gecerli = 'b0;
                end
            endcase
        end
    end

    if (ongorulen_ps_gecerli) begin
        ps_next = ongorulen_ps;
    end
    else if (yurut_atladi_i && yurut_ps_gecerli_i && yurut_yanlis_tahmin_i) begin
        ps_next = yurut_ps_i;
    end
    else if (buyruk_gecerli&& coz_bos_i)begin
        ps_next = ps + 4;
    end
end

GsharePredictor ongoru(
    .clk_i                              (clk_i),
    .rst_i                              (rst_i),
  
    .ongoru_genisletilmis_anlik_i       (ongoru_genisletilmis_anlik),
    .tahmin_ps_gecerli_i                (dallanma_tahmini_gecerli),
    .tahmin_ps_i                        (ps),

    .ongorulen_atladi_o                 (ongoru_atladi_o),
    .ongorulen_ps_gecerli_o             (ongorulen_ps_gecerli),
    .ongorulen_ps_o                     (ongorulen_ps),

    .yurut_ps_gecerli_i                 (yurut_ps_gecerli_i),	
    .yurut_ps_i                         (yurut_ps_i),
    .yanlis_tahmin_i                    (yurut_yanlis_tahmin_i),
    .yurut_atladi_i                     (yurut_atladi_i));



integer i = 0;
always @(*) begin
    $display("Gelen instruction %h",bellek_deger_i," Num %d ",i);
    i = i +1;
end

always @(posedge clk_i) begin
    if (rst_i) begin
        bellek_ps_o <= 'h8000_0000;
        ps <= 'h8000_0000;
        dallanma_tahmini_gecerli <= 0;
        bellek_istek_o <= 1;
        coz_buyruk_o <= 32'b0;
        coz_buyruk_gecerli_o <= 1'b0;
        coz_ps_o <= 32'b0;
    end
    else begin
        if (buyruk_gecerli && coz_bos_i) begin
            coz_ps_o <= ps;
            coz_buyruk_o <= buyruk_next;
            coz_buyruk_gecerli_o <= 1'b1; 
            bellek_ps_o <= ps_next;
            bellek_istek_o <= 1'b1;
            buyruk_gecerli <= 0;   
        end
        else begin
            coz_buyruk_gecerli_o <= 0;
            bellek_istek_o <= 1'b0;
        end
        ps = ps_next;
    end
       
end


endmodule