
module processor_tb();

localparam MEMORY_ADDRESS = 32'h8000_0000;
localparam ADRES_BIT = 32;
localparam VERI_BIT = 32;

reg clk_r;
reg rst_r;

wire [ADRES_BIT-1:0] islemci_MEMORY_ADDRESS;
wire [VERI_BIT-1:0] islemci_bellek_oku_veri;
wire [VERI_BIT-1:0] islemci_bellek_yaz_veri;
wire islemci_bellek_yaz;


HelperMemory memory (
    .clk(clk_r),
    .adres(islemci_MEMORY_ADDRESS),
    .oku_veri(islemci_bellek_oku_veri),
    .yaz_veri(islemci_bellek_yaz_veri),
    .yaz_gecerli(islemci_bellek_yaz)
);

Processpr processor (
    .clk(clk_r),
    .rst(rst_r),
    .MEMORY_ADDRESS(islemci_MEMORY_ADDRESS),
    .bellek_oku_veri(islemci_bellek_oku_veri),
    .bellek_yaz_veri(islemci_bellek_yaz_veri),
    .bellek_yaz(islemci_bellek_yaz)
);

always begin
    clk_r = 1'b0;
    #5;
    clk_r = 1'b1;
    #5;
end

localparam MAX_CYCLES = 100;
integer stall_ctr;
initial begin
    stall_ctr = 0;
    rst_r = 1'b1;
    // Race condition engellemek icin sistem 1 cevrim calistirilir
    @(posedge clk_r); // reset sinyali aktif oldugu icin degisiklik olusmaz
    // https://luplab.gitlab.io/rvcodecjs/ <- assembly binary donusumu icin kullanabiliriniz
    // BUYRUKLAR 
    bellek_yaz('h8000_0000, 32'h00500093); // addi x1, x0, 5
    bellek_yaz('h8000_0004, 32'h00a00113); // addi x2, x0, 10
    bellek_yaz('h8000_0008, 32'h002081b3); // add  x3, x1, x2
    bellek_yaz('h8000_000c, 32'h80000237); // lui  x4, 0x80000
    bellek_yaz('h8000_0010, 32'h40022283); // lw   x5, 0x400(x4)
    bellek_yaz('h8000_0014, 32'h003282b3); // add  x5, x5, x3
    bellek_yaz('h8000_0018, 32'h40522223); // sw   x5, 0x404(x4)

    // PROGRAM VERISI
    bellek_yaz('h8000_0400, 32'hdeadbee0);
    bellek_yaz('h8000_0404, 32'h55555555);

    // BUYRUKLAR - ALTERNATIF YONTEM (zaten 8000_0000'in 0. index oldugunu biliyoruz)
    // anabellek.bellek[0] = 32'h00500093; 
    // anabellek.bellek[1] = 32'h00a00113; 

    repeat (10) @(posedge clk_r); #2; // 10 cevrim reset
    rst_r = 1'b0;

end

// Islemcide buyruk_sayisi kadar buyruk yurutulmesini izler ve asama sirasini kontrol eder.
task buyruk_kontrol (
    input [31:0] buyruk_sayisi
);
integer counter;
begin
    for (counter = 0; counter < buyruk_sayisi; counter = counter + 1) begin
        asama_kontrol(islemci.GETIR);
        @(posedge clk_r) #2;
        asama_kontrol(islemci.COZYAZMACOKU);
        @(posedge clk_r) #2;
        asama_kontrol(islemci.YURUTGERIYAZ);
        @(posedge clk_r) #2;
    end
end
endtask

task asama_kontrol (
    input integer beklenen
);
begin
    if (islemci.simdiki_asama_r !== beklenen) begin
        $display("[ERR] YANLIS ASAMA expected: %0x actual: %0x", beklenen, islemci.simdiki_asama_r);
    end
end
endtask

task bellek_yaz (
    input [ADRES_BIT-1:0] adres,
    input [VERI_BIT-1:0] veri
);
begin
    memory.bellek[adres_satir_idx(adres)] = veri;
end
endtask

function [VERI_BIT-1:0] bellek_oku (
    input [ADRES_BIT-1:0] adres
);
begin
    bellek_oku = memory.bellek[adres_satir_idx(adres)];
end
endfunction

function [VERI_BIT-1:0] yazmac_oku (
    input integer yazmac_idx
);
begin
    yazmac_oku = islemci.yazmac_obegi[yazmac_idx];
end
endfunction

// Verilen adresi bellek satir indisine donusturur.
function integer adres_satir_idx (
    input [ADRES_BIT-1:0] adres
);
begin
    adres_satir_idx = (adres - MEMORY_ADDRESS) >> $clog2(VERI_BIT / 8);
end
endfunction

endmodule