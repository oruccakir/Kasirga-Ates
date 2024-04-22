`timescale 1ns / 1ps
// Purpose: FetchStep module for the Fetch stage of the pipeline.
// Functionality: Fetches the instruction from the instruction memory.
// File: FetchStep.v

module FetchStep (
    input clk_i, // Clock input
    input rst_i, // Reset input
    // buyruk önbelleği
    input bellek_gecerli_i,
    input [31:0] bellek_deger_i,
    output reg [31:0] bellek_adres_o, 

    // yurut asamasi
    input yurut_ps_gecerli_i,
    input [31:0] yurut_ps_i,
    input yurut_atladi_i

);

reg [31:0] instruction_o_next, instruction_o;
wire [31:0] memory_buyruk;

reg tahmin_et;
wire tahmin;
wire [31:0] tahmin_ps;

reg [31:0] ps = mem_adres_i;
reg [31:0] ps_next;

HelperMemory hm(
    .clk_i              (clk_i),
    .adres_i            (ps),
    .write_data_enable_i(1'b0),
    .read_data_o        (memory_buyruk)
    );

GsharePredictor gp(
	.clk_i              (clk_i),
    .rst_i              (rst_i),
    .getir_ps_i         (ps),
    .getir_ps_gecerli_i (tahmin_et),
    .buyruk_i           (memory_buyruk),
    .yurut_ps_i         (yurut_ps_i),
    .yurut_ps_gecerli_i (yurut_ps_gecerli_i),
    .yurut_atladi_i     (yurut_atladi_i),
    .sonuc_dallan_o     (tahmin),
    .sonuc_dallan_ps_o  (tahmin_ps)
    );

always @* begin
	tahmin_et = 1'b0;
	if (bellek_gecerli_i) begin
		instruction_o_next = memory_buyruk;
		if (mem_adres_i[6:5] == 2'b11) begin
			tahmin_et = 1'b1;
			ps_next = tahmin_ps;
		end
	end
	else if (yurut_ps_gecerli) begin
		if (yurut_atladi_i != tahmin) begin
			ps_next = yurut_ps_i;
		end
	end
end

always @(posedge clk_i) begin
	if (rst_i) begin
		instruction_o <= 0;
		ps <= 0;
	end
	else begin
		if (bellek_gecerli_i) begin
		    instruction_o <= instruction_o_next;    
		end
		ps <= ps_next;
    end
end

endmodule