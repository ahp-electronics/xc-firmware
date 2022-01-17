/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module COUNTER (
		counter_out,
		overflow,
		signal,
		nsignal,
		cumulative,
		multiply,
		clk,
		reset
	);
	parameter RESOLUTION=64;
	parameter WORD_WIDTH=1;
	parameter HAS_CUMULATIVE_ONLY = 0;
	output reg signed [RESOLUTION-1:0] counter_out;
	output wire overflow;
	input wire signed [WORD_WIDTH:0] signal;
	input wire signed [WORD_WIDTH:0] nsignal;
	input wire reset;
	input wire clk;
	input wire cumulative;
	input wire multiply;
	assign overflow = (counter_out == ((1<<(RESOLUTION-1))|1) || counter_out == ~(1<<(RESOLUTION-1)));
	reg signed [WORD_WIDTH:0] tmp_signal;
	reg signed [WORD_WIDTH:0] tmp_nsignal;
	
	always @(posedge clk) begin
		if(~reset) begin
			if(!overflow) begin
				if((cumulative | HAS_CUMULATIVE_ONLY) || (signal != tmp_signal) || (nsignal != tmp_nsignal)) begin
					tmp_signal <= signal;
					tmp_nsignal <= nsignal;
					if(multiply)
						counter_out <= counter_out + signal * nsignal;
					else
						counter_out <= counter_out + signal - nsignal;
				end
			end
		end else
			counter_out <= 0;
	end
		
endmodule
