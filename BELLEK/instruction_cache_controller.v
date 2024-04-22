`timescale 1ns / 1ps

// buyruk onbellek kapasitesi: 4KB = 4096 bayt, 1 blokta 128 bit = 16 bayt veri var satir sayisi da 4096/16 = 256 satir
// adres yapisi: [31:10](22 bit) ETIKET - [9:2](8 bit) SATIR SECIMI - [1:0](2 bit) BAYT SECIMI
// buyruk onbellegi donulen veri yapisi: [53:0](54 bit) TOPLAM = [53:32](22 bit) ETIKET - [31:0](32 bit) VERI 

`include "memory_definitions.vh"

module instruction_cache_controller(
    input                                   clk_i,
    input                                   rst_i,
    
    // FetchStep <> instruction_cache_controller
    input       [`ADRES_BIT-1:0]            getir_okuma_istek_adres_i, // getir asamasindan program counterdaki deger gelicek bu adresteki buyrugu okuyayim diye
    input                                   getir_okuma_istek_gecerli_i, // getir asamasindan okuma istegi gelip gelmedigini haber veriyor gelirse okuma yapicam
    output      [`VERI_BIT-1:0]             getir_okuma_istek_buyruk_o, // getir asamasina gonderilecek istenilen adresten okunmus buyruk
    output                                  getir_okuma_istek_hazir_o, // getir asamasina okudugum buyrugun gecerli oldugunu ve kullanilabilir oldugunu haber veriyorum
    
    // instruction_cache <> instruction_cache_controller
        // buyruk onbellegi nden veri okuma
    output      [`ADRES_BIT-1:0]            b_onbellek_okuma_istek_adres_o, // buyruk onbellegine sorgu yapacagim adres
    output                                  b_onbellek_okuma_istek_gecerli_o, // buyruk onbellegine verdigim adresten sorgu yapmasini soyluyorum
    input       [`ETIKET_BIT+`VERI_BIT-1:0] b_onbellek_okuma_istek_etiket_veri_i, // buyruk onbelleginin istenen adresten okudugu veri ve verinin tagi onbellekten geliyor, tag sayesinde gelen verinin aradigim veri olup olmadigina bakicam
        
        // buyruk onbellegi ne veri yazma, misslemisim yani bu yuzden anabellekten veri getiriyorum
    output      [`ADRES_BIT-1:0]            b_onbellek_yazma_istek_adres_o, // buyruk onbellegine yazacagim veri blogunun adresi, bu veri anabellekten geliyor
    output                                  b_onbellek_yazma_istek_gecerli_o, // buyruk onbellegine yaz diyorum
    output      [`BLOK_BIT-1:0]             b_onbellek_yazma_veri_blok_o, // buyruk onbellegine yazilacak blok halindekii veri
    
    // main_memory_controller <> instruction_cache_controller
    output      [`ADRES_BIT-1:0]            anabellek_denetleyici_okuma_istek_adres_o, // anabellekten okumak istedigim adresi denetleyiciye veriyorum
    output                                  anabellek_denetleyici_okuma_istek_gecerli_o, // anabellekten okuma yapmak istedigimi denetleyiciye bildiriyorum 
    input       [`BLOK_BIT-1:0]             anabellek_denetleyici_okuma_veri_blok_i, // anabellekten okumak istedigim veri blogunu anabellek denetleyicisinden aliyorum
    input                                   anabellek_denetleyici_okuma_istek_hazir_i // anabellekten okunan verinin anabellek denetleyicisi uzerinden geldigini haber veriyorum
    
    );
    
    // DURUM MAKINESI
    localparam BOSTA = 2'b00; // getirden istek almaya hazir durumda
    localparam ONBELLEK_OKU = 2'b01; // getirden alinan istek sonucu onbellek e gidilip veri okunuyor, tag karsilastirmasi yapiliyor veri istedigim gibiyse veri getire donuluyor degilse anabellege giden asamaya geciliyor 
    localparam ANABELLEK_OKU_ONBELLEK_YAZ = 2'b10; // verilen adresteki veri anabellekten okunuyor getirilen blok halindeki veri cache yaziliyor ve cache okuma asamasina gecilip istenen veri cache den okunup(istenilen verinin olmasi garanti) getire yonlendiriliyor 
    
    reg [1:0] simdiki_durum;
    reg [1:0] sonraki_durum;
    
    // DEPOLADIGIM BILGILER
    reg [`ADRES_BIT-1:0] adres; // getirden gelen istek adresi tutuyor
    
    
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
            BOSTA: begin // getirden istek almaya hazir durumdayim demek
                if (getir_okuma_istek_gecerli_i) begin // getirden istek aldim, once cache den okuma yapicam
                    adres = getir_okuma_istek_adres_i; // getirden gelen istegin adresini depoluyorum, cache ve gerekirse anabellege gondericem
                    sonraki_durum = ONBELLEK_OKU; // getirden istek aldim cache den veri okuyup kontrol edicem  
                end 
            end
            ONBELLEK_OKU: begin
                if(b_onbellek_okuma_istek_etiket_veri_i[`ETIKET_BIT+`VERI_BIT-1:`VERI_BIT] == adres[`VERI_BIT-1:`VERI_BIT-`ETIKET_BIT]) begin // onbellekten gelen verinin tag ile benim elimdeki adresin tag ini karsilatiriyorum
                    sonraki_durum = BOSTA;
                end
                else begin
                    sonraki_durum = ANABELLEK_OKU_ONBELLEK_YAZ; 
                end    
            end
            ANABELLEK_OKU_ONBELLEK_YAZ: begin
                if(anabellek_denetleyici_okuma_istek_hazir_i) begin
                    sonraki_durum = ONBELLEK_OKU;
                end
            end
        endcase
    end
    
    // OUTPUTS
    assign getir_okuma_istek_hazir_o = b_onbellek_okuma_istek_etiket_veri_i[53:32] == adres[31:10]; // eger tag onunde sonunda istenilen adresle uyusuyorsa bu getire devam et buyruk hazir diyor
    assign getir_okuma_istek_buyruk_o = b_onbellek_okuma_istek_etiket_veri_i[31:0];
   
    assign b_onbellek_okuma_istek_adres_o = adres;
    
    assign b_onbellek_yazma_istek_gecerli_o = anabellek_denetleyici_okuma_istek_hazir_i;
    assign b_onbellek_yazma_veri_blok_o = anabellek_denetleyici_okuma_veri_blok_i;
    assign b_onbellek_yazma_istek_adres_o = adres;
    
    assign anabellek_denetleyici_okuma_istek_adres_o = adres;
    
    
endmodule
