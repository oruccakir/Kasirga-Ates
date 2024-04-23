// buyruk onbellek kapasitesi: 4KB = 4096 bayt, 1 blokta 128 bit = 16 bayt veri var satir sayisi da 4096/16 = 256 satir
// adres yapisi: [31:10](22 bit) ETIKET - [9:2](8 bit) SATIR SECIMI - [1:0](2 bit) BAYT SECIMI
// buyruk onbellegi donulen veri yapisi: [53:0](54 bit) TOPLAM = [53:32](22 bit) ETIKET - [31:0](32 bit) VERI 

// BELLEK TANIMLAMALARI
`define ADRES_BIT 32 // adresler 32 bitlik
`define VERI_BIT 32 // veriler 32 bit yani 4 bayt halinde
`define BLOK_BIT 128 // onbellegin bir satiri yani 1 blogu 128 bit yani 16 bayt veri tutuyor bu da 4 tane veri demek
`define ETIKET_BIT 22 // etiket adresin [31:10] bitleri
