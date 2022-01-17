/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module dff (
	clk,
	d,
	q
);
parameter WORD_WIDTH=1;
input wire clk;
input wire[WORD_WIDTH-1:0] d;
output reg[WORD_WIDTH-1:0] q;

always @ ( posedge clk)
	begin
		q <= d;
	end
endmodule

module fifo (
	clk,
	d,
	q
	);
	parameter DELAY_SIZE = 1;
	parameter WORD_WIDTH=1;
	
	input wire clk;
	input wire[WORD_WIDTH-1:0] d;
	output wire[DELAY_SIZE*WORD_WIDTH-1:0] q;
	 
	assign q[0+:WORD_WIDTH] = d;
	generate 
		genvar a;
		genvar b;
		for(a=1; a<DELAY_SIZE; a=a+512) begin : delay_iteration_block
			for(b=a; b < a+512 && b < DELAY_SIZE; b=b+1) begin : delay_iteration_inner_block
				dff #(.WORD_WIDTH(WORD_WIDTH)) delay(clk, q[(b-1)*WORD_WIDTH+:WORD_WIDTH], q[b*WORD_WIDTH+:WORD_WIDTH]);
			end
		end
	endgenerate
endmodule
