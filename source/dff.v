/*
    AHP XC - a multiline spectrograph and cross-correlator
    Copyright (C) 2020  Ilia Platone

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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
