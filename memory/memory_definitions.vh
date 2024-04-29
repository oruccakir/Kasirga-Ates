// BELLEK TANIMLAMALARI

//---------------------BUYRUK KISMI---------------------//
// buyruk onbellek kapasitesi: 4KB = 4096 bayt, 1 blokta 128 bit = 16 bayt veri var satir sayisi da 4096/16 = 256 satir
// adres yapisi: [31:12](20 bit) ETIKET - [11:4](8 bit) SATIR SECIMI - [3:0](4 bit) BAYT SECIMI
// buyruk onbelleginden gelen veri yapisi: (148 bit) TOPLAM  = [147:128](20 bit) ETIKET - [127:0](128 bit) BLOK // olu bitler de geliyor ben blok icinden istedigimi secicem, bu isi denetleyicide hallediyorum

`define BUYRUK_ADRES_BIT 32 // adresler 32 bitlik
`define BUYRUK_VERI_BIT 32 // veriler 32 bit yani 4 bayt halinde
`define BUYRUK_BLOK_BIT 128 // onbellegin bir satiri yani 1 blogu 128 bit yani 16 bayt veri tutuyor bu da 4 tane veri demek
`define BUYRUK_ETIKET_BIT 20 // etiket adresin [31:12] bitleri
`define BUYRUK_ONBELLEGI_KAPASITE_BAYT 4096 // 4KB = 4096 bayt
`define BUYRUK_ONBELLEGI_SATIR_SAYISI 256// blogun(satir) bitini bayta cevirip kapasiteye boldum: (BUYRUK_ONBELLEGI_KAPASITE_BAYT/(BLOK_BIT/8)) 
`define BUYRUK_ONBELLEGI_SATIR_SECIM_BIT 8 // log(satir sayisi) = log256 = 8


