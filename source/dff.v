/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module dff (
	clk,
	refclk,
	d,
	q
	);
	parameter WORD_WIDTH=1;
	parameter USE_SOFT_CLOCK=0;
	input wire clk;
	input wire refclk;
	reg _refclk = 0;
	input wire[WORD_WIDTH-1:0] d;
	output reg[WORD_WIDTH-1:0] q;

	wire clock;
	assign clock = (USE_SOFT_CLOCK ? clk : refclk);

	always @ ( posedge clock) begin
		if(USE_SOFT_CLOCK) begin
			if(refclk != _refclk) begin
				_refclk <= refclk;
				if(refclk) begin
					q <= d;
				end
			end
		end else begin
			q <= d;
		end
	end
endmodule

module fifo (
	clk,
	refclk,
	d,
	q
	);
	parameter DELAY_SIZE = 1;
	parameter WORD_WIDTH=1;
	parameter USE_SOFT_CLOCK=0;
	
	input wire clk;
	input wire refclk;
	input wire[WORD_WIDTH-1:0] d;
	output wire[DELAY_SIZE*WORD_WIDTH-1:0] q;
	 
	assign q[0+:WORD_WIDTH] = d;
	generate  
		genvar a;
		genvar b;
		for(a=1; a<=DELAY_SIZE; a=a+512) begin : delay_iteration_block
			for(b=a; b < a+512 && b < DELAY_SIZE; b=b+1) begin : delay_iteration_inner_block
				dff #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH)) delay(clk, refclk, q[(b-1)*WORD_WIDTH+:WORD_WIDTH], q[b*WORD_WIDTH+:WORD_WIDTH]);
			end
		end
	endgenerate
endmodule
