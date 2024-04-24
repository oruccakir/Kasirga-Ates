`timescale 1ns / 1ps

module BRAM_instruction_cache #(
	parameter DATA_WIDTH = 148, // bir satirda tutulan veri biti miktari, ben (20 bit) ETIKET + (128 bit) BLOK = (148 bit) TOPLAM tutuyorum simdilik
	parameter BRAM_DEPTH = 256, // onbellek satir sayisi 
	

	localparam ADDR_WIDTH = $clog2(BRAM_DEPTH) // adres, hangi satiri istedigimi belirtiyor 
)(
	input 						clk_i,
	
	input	[DATA_WIDTH-1:0]	data_i,
	input	[ADDR_WIDTH-1:0]	addr_i,
	input						wr_en_i,
	input						cmd_en_i,
	output	[DATA_WIDTH-1:0]	data_o
);


reg [DATA_WIDTH-1:0] mem_r [0:BRAM_DEPTH-1];
reg [DATA_WIDTH-1:0] data_r;


always @(posedge clk_i) begin
	if (cmd_en_i) begin
		if (wr_en_i) begin
			mem_r[addr_i] <= data_i;
		end
		else begin
			data_r <= mem_r[addr_i];
		end
	end
end

assign data_o = data_r;

endmodule
