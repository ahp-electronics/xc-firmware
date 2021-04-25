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
