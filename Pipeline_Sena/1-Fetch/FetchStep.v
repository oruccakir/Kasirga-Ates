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
    output bellek_istek_o,
    output [31:0] bellek_ps_o,
    

    // getir <> coz
    output reg [31:0] coz_buyruk_o,
    output reg coz_buyruk_gecerli_o,
    output reg [31:0] coz_ps_o,

    //dallanma birimi (yurut) <> getir
    input [31:0] yurut_ps_i,
    input yurut_ps_gecerli_i,
    input yurut_atladi_i
);

reg [31:0] ps;
reg [31:0] ps_next;


// dallanma öngörücüsü için gerekli input ve outputlar
reg dallanma_tahmini_gecerli;
reg buyruk_jal_j_type;
reg buyruk_jalr_i_type;
reg buyruk_branch_b_type;
reg [31:0] ongoru_genisletilmis_anlik;

wire [31:0] ongorulen_ps;
wire ongorulen_ps_gecerli;

reg yanlis_tahmin;

wire dogru_ps_gecerli;//'b1 olduğunda getir psyi güncelleyecek.
wire [31:0] dogru_ps;

always @(*) begin
    dallanma_tahmini_gecerli = 'b0;
    buyruk_jal_j_type = 'b0;//bunlar hiçbir yerde işe yaramıyor?
    buyruk_jalr_i_type = 'b0;
    buyruk_branch_b_type = 'b0;

    if (bellek_gecerli_i) begin
        dallanma_tahmini_gecerli = (bellek_deger_i[1:0] == 'b11);
        if (dallanma_tahmini_gecerli) begin
            case (bellek_deger_i[3:2])
                'b11: begin
                    buyruk_jal_j_type = 'b1;
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {12'b1111_1111_1111, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]} : {12'b0000_0000_0000, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]};//son bit 0 mı olacak?
                end
                'b01: begin
                    buyruk_jalr_i_type = 'b1;//hedef adresi bulmak için rs1 yazmacının değerine eklenmesi lazım????
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31:20]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31:20]};
                end
                'b00: begin
                    buyruk_branch_b_type = 'b1;
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]};//son bit 0 mı olacak?
                end
                default: begin
                    dallanma_tahmini_gecerli = 'b0;
                end
            endcase
        end
    end
end

always @(*) begin
    if (yurut_ps_gecerli_i) begin
        yanlis_tahmin = (ps != yurut_ps_i) ? 'b1 : 'b0;
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
    .yurut_atladi_i                     (yurut_atladi_i),

    .dogru_ps_gecerli_o                 (dogru_ps_gecerli),
    .dogru_ps_o                         (dogru_ps));

always @(*) begin
    ps_next = ps + 4;
    if (ongorulen_ps_gecerli) begin
        ps_next = ongorulen_ps;
    end
    if (dogru_ps_gecerli) begin
        ps_next = dogru_ps;
    end
end

always @(posedge clk_i) begin
    if (rst_i) begin
        ps <= 32'b0;
    end
    else begin
        ps <= ps_next;
        if (bellek_gecerli_i) begin
            coz_buyruk_gecerli_o <= 'b1;
            coz_buyruk_o <= bellek_deger_i;
            coz_ps_o <= ps;
        end
    end
end

assign bellek_istek_o = (coz_buyruk_gecerli_o) ? 'b1 : 'b0;
assign bellek_ps_o = ps;

endmodule