`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input clk_i, // Clock input
    input rst_i, // Reset input

    // buyruk önbelleği <> getir
    input bellek_gecerli_i,
    input [31:0] bellek_deger_i,
    output reg bellek_istek_o,
    output reg [31:0] bellek_ps_o,
    

    // getir <> coz
    input coz_bos_i,
    output reg [31:0] coz_buyruk_o,
    output reg coz_buyruk_gecerli_o,
    output reg [31:0] coz_ps_o,

    //dallanma birimi (yurut) <> getir
    input [31:0] yurut_ps_i,
    input yurut_ps_gecerli_i,
    input yurut_atladi_i
);

reg [31:0] ps = 0;
reg [31:0] ps_next;


// dallanma öngörücüsü için gerekli input ve outputlar
reg dallanma_tahmini_gecerli;
reg [31:0] ongoru_genisletilmis_anlik;

wire [31:0] ongorulen_ps;
wire ongorulen_ps_gecerli;

reg yanlis_tahmin;

always @(*) begin
    ps_next = ps;
    yanlis_tahmin = 0;
    dallanma_tahmini_gecerli = 'b0;

    if (bellek_gecerli_i) begin
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
    else begin
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


always @(posedge clk_i) begin
    if (rst_i) begin
        ps <= 32'b0;
    end
    else begin
        bellek_ps_o <= ps_next;
        if (bellek_gecerli_i) begin
            coz_buyruk_gecerli_o = 1'b1;
            coz_ps_o = ps;
            coz_buyruk_o = bellek_deger_i;
        end
        else begin
            coz_buyruk_gecerli_o = 1'b0;
        end
        if (coz_bos_i || yanlis_tahmin) begin
            bellek_istek_o = 1'b1;
            ps = ps_next;
        end
        else begin
            bellek_istek_o = 1'b0;
        end
    end
end


endmodule