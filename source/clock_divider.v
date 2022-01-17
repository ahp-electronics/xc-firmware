/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CLK_GEN 
	(
		div,
		clk_out,
		clk,
		overflow,
		enable
	);
	parameter RESOLUTION = 32;
	
	input wire [RESOLUTION-1:0] div;
	output reg clk_out;
	input wire clk;
	input wire enable;
	
	output wire overflow;

	reg [RESOLUTION-1:0] cycles;
	assign overflow = cycles == (div>>1);
	always @(posedge clk)
	begin
		if(enable) begin
			if(cycles < (div>>1))
				cycles <= cycles+1;
			else begin
				clk_out <= ~clk_out;
				cycles <= 0;
			end
		end else begin
			clk_out <= 0;
		end
	end
endmodule
