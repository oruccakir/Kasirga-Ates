// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v
/*
include "definitions.vh";

module FetchStep (
    input wire clk_i,                                        // Clock input
    input wire rst_i,                                        // Reset input
    input wire decode_working_info_i,                        // very important info for stalling, comes from decode step
    input wire [31:0] instruction_i,                         // Instruction output, comes from memory via processor
    input wire instruction_completed_i,                      // this comes from memory, indicates memory completed process of giving instruction data
    input wire is_branch_address_calculated_i,               // this comes from execute step, indicating that whether branch address calculation is completed or not
    input wire [31:0] calculated_branch_address_i,           // this comes from execute step, gives correct branch address
    input wire branch_info_i,                                // this info comes from execute step, indicates whether branch is taken or not
    output reg [31:0] mem_address_o,                         // Memory address output, goes to memory
    output reg [31:0] instruction_to_decode_o,               // instruction that will be conveyed to decode step 
    output wire fetch_next_instruction_o,                    // this is the fetching instruction desire from memory
    output reg [31:0] program_counter_o,                      // this is for increasig program counter for some instructions, goes to decode step
    output wire reset_branch_info_o,                          // this is goes to directly execute step to reset branch working info
    output wire [31:0] branch_predictor_address_o                    // this is goes to execute step via decode to understand the predictor result
);

reg [31:0] branch_predictor_address;                         // branch_precitor address output
reg [31:0] program_counter_next;                             // next register for program_counter
reg [31:0] instruction_to_decode_next;                       // next register for instruction that will be conveyed to decode step
wire fetch_next_instruction;                                 // this is flag for getting instruction from memory or cache, crucial for stalling operations
reg [31:0] instruction_to_decode;                            // instruction that will be convetyed to decode step
reg [31:0] program_counter;                                  // program counter to access memory, data and instructions
reg reset_branch_info;                                       // this is for resetting branch info in execute stage
integer i = -1;                                              // for debugging the which instruction is fetched and conveyed


always@(*) begin
    $display("@@FETCH STAGE Fetched Instruction %h  ", instruction_i," instruction count %d ",i);     // debugging purpose
    i=i+1;                                                                                            // increment counter when new instruction comes
end                                


always@(*) begin
    instruction_to_decode_next = instruction_i;              // assign new instruction to instruction_to_decode_next
    program_counter_next = program_counter + 4;              // assign new program counter to program_counter_next
end

always@(posedge clk_i) begin
    if(rst_i) begin
        branch_predictor_address <= 32'b0;
        program_counter <= 32'h8000_0000;
        instruction_to_decode <= 32'b0;
        program_counter_next <= 32'h8000_0000;
        instruction_to_decode_next <= 32'b0;
    end
    else begin     
        if(branch_info_i == `BRANCH_TAKEN) begin                  // if branch taken, send NOP instruction to decode step and update program counter and memory adddress with calculated branch address
            program_counter_o <= program_counter;                 
            program_counter <= calculated_branch_address_i;
            mem_address_o <=calculated_branch_address_i;
            instruction_to_decode_o <= 32'b0;
            reset_branch_info <= 1'b1;
            $display("Branch Address  Calculated Branch Taken %h",calculated_branch_address_i );
        end
        else if(fetch_next_instruction) begin                    // if fetch_next_instruction is true, then send necessary outputs to decode stage and fetch new instruction
            program_counter_o <= program_counter;
            program_counter <= program_counter_next;
            mem_address_o <=program_counter_next;
            instruction_to_decode_o <= instruction_to_decode_next;
            reset_branch_info <= 1'b0;
        end

    end
end



assign fetch_next_instruction = ~decode_working_info_i;              // When decode stage is running, then do not fetch new instruction and do not update signals that will go to decode stage
assign fetch_next_instruction_o = fetch_next_instruction;            // flag for getting the instruction from memory, goes to memory1
assign reset_branch_info_o = reset_branch_info;                      // We should reset the branch info output in execute stage for branch resolver unit, so we should convey this signal to execute stage

endmodule
*/

`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input         clk_i, // Clock input
    input         rst_i, // Reset input

    // buyruk önbelleði <> getir
    input              bellek_gecerli_i, //bellekten gelen buyruk geçerli 
    input      [31:0]  bellek_deger_i,   //bellekten gelen býyruk
    output reg         bellek_istek_o,   //bellekten sonraki buyruk için istek
    output reg [31:0]  bellek_ps_o,      //sonraki buyruðun program sayacý
    

    // getir <> coz
    input              coz_bos_i,        //çöz aþamasýnda buyruk yok
    output reg [31:0]  coz_buyruk_o,     //çöz aþamasýna verilecek olan buyruk
    output reg         coz_buyruk_gecerli_o,//çöz aþamasýna buyruk verildi
    output reg [31:0]  coz_ps_o,         //çöz aþamasýna verilecek olan buyruðun program sayacý

    //dallanma birimi (yurut) <> getir
    input      [31:0]  yurut_ps_i,       //yürüt aþamasýndan gelen dallanma buyruðunun adresi
    input              yurut_ps_gecerli_i,//yürüt aþamasýndan doðru program sayacý geldi
    input              yurut_atladi_i    //dallanma öngörüsüne verilecek düzeltme sinyali
);

reg [31:0] ps=32'h8000_0000;
reg [31:0] ps_next;
reg [31:0] buyruk_next;
reg buyruk_gecerli;
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
        buyruk_next = bellek_deger_i;
        buyruk_gecerli = 1;
        dallanma_tahmini_gecerli = (bellek_deger_i[6:5] == 'b11);
        if (dallanma_tahmini_gecerli) begin
            case (bellek_deger_i[3:2])
                'b11: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {12'b1111_1111_1111, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]} : {12'b0000_0000_0000, bellek_deger_i[31], bellek_deger_i[19:12], bellek_deger_i[20], bellek_deger_i[30:21]};//son bit 0 mý olacak?
                end
                'b01: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31:20]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31:20]};
                end
                'b00: begin
                    ongoru_genisletilmis_anlik = bellek_deger_i[31] ? {20'b1111_1111_1111_1111_1111, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]} : {20'b0000_0000_0000_0000_0000, bellek_deger_i[31], bellek_deger_i[7], bellek_deger_i[30:25], bellek_deger_i[11:8]};//son bit 0 mý olacak?
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
    else if (buyruk_gecerli && coz_bos_i)begin
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
        bellek_ps_o <= 32'h8000_0000;
        ps <= 32'h8000_0000;
        dallanma_tahmini_gecerli = 0;
    end
    else begin
        if (buyruk_gecerli && coz_bos_i) begin
            coz_ps_o = ps;
            coz_buyruk_o = buyruk_next;     //ç
            coz_buyruk_gecerli_o = 1'b1;     
        end
        else begin
            coz_buyruk_gecerli_o = 0;
        end
        ps = ps_next;
         
        if ((coz_bos_i && buyruk_gecerli) || yanlis_tahmin) begin//bellekten bilgi geldiyse???aþama boþ kalabilir mi? ve çöz boþ veya yanlýþ dallanma tahminiyse belleðe istek atýlýr.
                bellek_ps_o = ps;
                bellek_istek_o = 1'b1;
                buyruk_gecerli = 0;
            end
            else begin
                bellek_istek_o = 1'b0;
            end
        end
        
    end


endmodule