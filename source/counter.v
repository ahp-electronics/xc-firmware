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

module COUNTER (
		counter_max,
		counter_min,
		counter_out,
		overflow,
		signal,
		nsignal,
		cumulative,
		clk,
		reset
	);
	parameter RESOLUTION=64;
	parameter WORD_WIDTH=1;
	parameter HAS_CUMULATIVE_ONLY = 0;
	input wire signed [RESOLUTION-1:0] counter_max;
	input wire signed [RESOLUTION-1:0] counter_min;
	output reg signed [RESOLUTION-1:0] counter_out;
	output wire overflow;
	input wire [WORD_WIDTH-1:0] signal;
	input wire [WORD_WIDTH-1:0] nsignal;
	input wire reset;
	input wire clk;
	input wire cumulative;
	assign overflow = (counter_out == counter_max || counter_out == -counter_max);
	reg [WORD_WIDTH-1:0] tmp_signal;
	reg [WORD_WIDTH-1:0] tmp_nsignal;
	
	always @(posedge clk) begin
		if(~reset) begin
			if(counter_out + signal - nsignal <= counter_max && counter_out + signal - nsignal >= counter_min) begin
				if((cumulative | HAS_CUMULATIVE_ONLY) || (signal != tmp_signal) || (nsignal != tmp_nsignal)) begin
					tmp_signal <= signal;
					tmp_nsignal <= nsignal;
					counter_out <= counter_out + signal - nsignal;
				end
			end
		end else
			counter_out <= 0;
	end
		
endmodule
