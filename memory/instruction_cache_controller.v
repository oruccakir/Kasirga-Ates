`timescale 1ns / 1ps

`include "memory_definitions.vh"

`define satir_indexi 11:4
`define etiket 31:12
`define veri_secimi 3:2 // istenilen buyrugu 16 bayt icinden 4 bayt olarak secicem

module instruction_cache_controller(
    input                                   clk_i,
    input                                   rst_i,
    
    // FetchStep <> instruction_cache_controller
    input       [`BUYRUK_ADRES_BIT-1:0]                     getir_okuma_istek_adres_i, // getir asamasindan program counterdaki deger gelicek bu adresteki buyrugu okuyayim diye
    input                                                   getir_okuma_istek_gecerli_i, // getir asamasindan okuma istegi gelip gelmedigini haber veriyor gelirse okuma yapicam
    output      [`BUYRUK_VERI_BIT-1:0]                      getir_okuma_istek_buyruk_o, // getir asamasina gonderilecek istenilen adresten okunmus buyruk
    output                                                  getir_okuma_istek_hazir_o, // getir asamasina okudugum buyrugun gecerli oldugunu ve kullanilabilir oldugunu haber veriyorum
    
    // BRAM_instruction_cache <> instruction_cache_controller
    output                                                  b_onbellek_istek_gecerli_o, // buyruk onbellegine calis komutu veriyorum, yazma ya da okuma, BRAM kurallarindan
    
        // buyruk onbellegi nden veri okuma
    output      [`BUYRUK_ONBELLEGI_SATIR_SECIM_BIT-1:0]     b_onbellek_okuma_istek_adres_o, // buyruk onbellegine sorgu yapacagim blogun satir indexi
    input       [`BUYRUK_ETIKET_BIT+`BUYRUK_BLOK_BIT-1:0]   b_onbellek_okuma_istek_etiket_blok_i, // buyruk onbelleginin istenen adresten okudugu veri blok u ve verinin tagi onbellekten geliyor, tag sayesinde gelen verinin aradigim veri olup olmadigina bakicam; veri blok olarak geliyor ayristirmayi ben yapicam yani olu veriler de gelicek
        
        // buyruk onbellegi ne veri yazma, misslemisim yani bu yuzden anabellekten veri getiriyorum
    output      [`BUYRUK_ONBELLEGI_SATIR_SECIM_BIT-1:0]     b_onbellek_yazma_istek_adres_o, // buyruk onbellegine yazacagim veri blogunun satir indexi, bu veri anabellekten geliyor
    output                                                  b_onbellek_yazma_istek_gecerli_o, // buyruk onbellegine yaz diyorum
    output      [`BUYRUK_ETIKET_BIT+`BUYRUK_BLOK_BIT-1:0]   b_onbellek_yazma_veri_blok_o, // buyruk onbellegine yazilacak blok halindeki veri
    
    // main_memory_controller <> instruction_cache_controller
    output      [`BUYRUK_ADRES_BIT-1:0]                     anabellek_denetleyici_okuma_istek_adres_o, // anabellekten okumak istedigim adresi denetleyiciye veriyorum
    output                                                  anabellek_denetleyici_okuma_istek_gecerli_o, // anabellekten okuma yapmak istedigimi denetleyiciye bildiriyorum 
    input       [`BUYRUK_BLOK_BIT-1:0]                      anabellek_denetleyici_okuma_veri_blok_i, // anabellekten okumak istedigim veri blogunu anabellek denetleyicisinden aliyorum
    input                                                   anabellek_denetleyici_okuma_istek_hazir_i // anabellekten okunan verinin anabellek denetleyicisi uzerinden geldigini haber veriyorum
    
    );
    
    // DURUM MAKINESI
    localparam BOSTA = 'd0; // getirden istek almaya hazir durumda
    localparam ONBELLEK_OKU = 'd1; // getirden alinan istek sonucu onbellek e gidilip veri okunuyor, tag karsilastirmasi yapiliyor veri istedigim gibiyse veri getire donuluyor degilse anabellege giden asamaya geciliyor 
    localparam ANABELLEK_OKU_ONBELLEK_YAZ = 'd2; // verilen adresteki veri anabellekten okunuyor getirilen blok halindeki veri cache yaziliyor ve cache okuma asamasina gecilip istenen veri cache den okunup(istenilen verinin olmasi garanti) getire yonlendiriliyor 
    localparam ONBELLEK_OKU_TEKRAR = 'd3; // anabellekten gelen veri onbellege yazilirken, okuma da yapilmaya calisiliyor bu kismi sorgula 
    
    reg [1:0] simdiki_durum;
    reg [1:0] sonraki_durum;
    
    // DEPOLADIGIM BILGILER
    reg [`BUYRUK_ADRES_BIT-1:0] adres_r; // getirden gelen istek adresi tutuyor, hemen arkadan digir buyruk adresi gelebilir ve durum karisabilir oldugundan benim islemekte oldugum buyruk adresini geldigi gibi depoluyorum
    reg [`BUYRUK_ADRES_BIT-1:0] adres_ns;
    
    reg [`BUYRUK_ADRES_BIT-1:0] veri;
    
    reg getir_okuma_istek_hazir;
    reg [`BUYRUK_ADRES_BIT-1:0] getir_okuma_istek_buyruk;
    
    always @(posedge clk_i) begin
        if(rst_i) begin
            simdiki_durum <= BOSTA;
            adres_r <= 0; 
            getir_okuma_istek_hazir <= 0;
        end
        else begin
            simdiki_durum <= sonraki_durum;
            adres_r <= adres_ns;
        end
        //$display("simdiki durum: %d", simdiki_durum);
    end
    
    always @(*) begin
        adres_ns = adres_r;
        
        case(simdiki_durum)
            BOSTA: begin // getirden istek almaya hazir durumdayim demek
            $display("simdiki durum: %d", simdiki_durum);
            getir_okuma_istek_hazir = 0;
                if (getir_okuma_istek_gecerli_i) begin // getirden istek aldim, once cache den okuma yapicam
                    adres_ns = getir_okuma_istek_adres_i; // getirden gelen istegin adresini depoluyorum, cache ve gerekirse anabellege gondericem
                    sonraki_durum = ONBELLEK_OKU; // getirden istek aldim cache den veri okuyup kontrol edicem  
                end 
            end
            ONBELLEK_OKU: begin
            $display("simdiki durum: %d", simdiki_durum);
                if(b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_ETIKET_BIT+`BUYRUK_BLOK_BIT-1:`BUYRUK_BLOK_BIT] == adres_r[`BUYRUK_VERI_BIT-1:`BUYRUK_VERI_BIT-`BUYRUK_ETIKET_BIT]) begin // onbellekten gelen verinin tag ile benim elimdeki adresin tag ini karsilatiriyorum
                    $display("hitledim");
                    getir_okuma_istek_hazir = 1;
                    getir_okuma_istek_buyruk = veri;
                    sonraki_durum = BOSTA;
                end
                else begin
                    $display("missledim");
                    getir_okuma_istek_hazir = 0;
                    sonraki_durum = ANABELLEK_OKU_ONBELLEK_YAZ; 
                end    
            end
            ANABELLEK_OKU_ONBELLEK_YAZ: begin
            $display("simdiki durum: %d", simdiki_durum);
            getir_okuma_istek_hazir = 0;
                if(anabellek_denetleyici_okuma_istek_hazir_i) begin
                    sonraki_durum = ONBELLEK_OKU_TEKRAR;
                end
            end
            ONBELLEK_OKU_TEKRAR: begin // yazildiktan sonra bir cevrim de okumaya sure veriyorum
            $display("simdiki durum: %d", simdiki_durum);
            getir_okuma_istek_hazir = 0;
                sonraki_durum = ONBELLEK_OKU;
            end
        endcase 
    end
    
    always@(*) begin
        case(adres_r[`veri_secimi])
            2'b00: begin
                veri = b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_VERI_BIT+(0*`BUYRUK_VERI_BIT)-1:0*`BUYRUK_VERI_BIT];
            end
            2'b01: begin
                veri = b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_VERI_BIT+(1*`BUYRUK_VERI_BIT)-1:1*`BUYRUK_VERI_BIT];
            end
            2'b10: begin
                veri = b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_VERI_BIT+(2*`BUYRUK_VERI_BIT)-1:2*`BUYRUK_VERI_BIT];
            end
            2'b11: begin
                veri = b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_VERI_BIT+(3*`BUYRUK_VERI_BIT)-1:3*`BUYRUK_VERI_BIT];
            end
        endcase
    end
    
    // OUTPUTS
    //assign getir_okuma_istek_hazir_o = ( b_onbellek_okuma_istek_etiket_blok_i[`BUYRUK_ETIKET_BIT+`BUYRUK_BLOK_BIT-1:`BUYRUK_BLOK_BIT] == adres_r[`BUYRUK_VERI_BIT-1:`BUYRUK_VERI_BIT-`BUYRUK_ETIKET_BIT] ); // eger tag onunde sonunda istenilen adresle uyusuyorsa bu getire devam et buyruk hazir diyor
    assign getir_okuma_istek_hazir_o = getir_okuma_istek_hazir;
    
    //assign getir_okuma_istek_buyruk_o = veri;
    assign getir_okuma_istek_buyruk_o = getir_okuma_istek_buyruk;
    
    assign b_onbellek_istek_gecerli_o = (sonraki_durum == ONBELLEK_OKU) || anabellek_denetleyici_okuma_istek_hazir_i || (sonraki_durum == ONBELLEK_OKU_TEKRAR);
    
    assign b_onbellek_okuma_istek_adres_o = adres_ns[`satir_indexi]; // BRAM sadece satir indexini istiyor
    
    assign b_onbellek_yazma_istek_gecerli_o = anabellek_denetleyici_okuma_istek_hazir_i;
    assign b_onbellek_yazma_veri_blok_o = {adres_r[`etiket], anabellek_denetleyici_okuma_veri_blok_i};
    assign b_onbellek_yazma_istek_adres_o = adres_r[`etiket];
    
    assign anabellek_denetleyici_okuma_istek_gecerli_o = simdiki_durum == ANABELLEK_OKU_ONBELLEK_YAZ && !anabellek_denetleyici_okuma_istek_hazir_i;
    assign anabellek_denetleyici_okuma_istek_adres_o = adres_r;
    
    endmodule
