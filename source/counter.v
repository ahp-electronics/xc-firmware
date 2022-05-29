/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module COUNTER (
		counter_out,
		overflow,
		in_p,
		in_n,
		cumulative,
		multiply,
		clk,
		refclk,
		reset
	);
	parameter RESOLUTION=64;
	parameter WORD_WIDTH=1;
	parameter HAS_CUMULATIVE_ONLY = 0;
	parameter USE_SOFT_CLOCK = 0;

	output reg signed [RESOLUTION-1:0] counter_out;
	output wire overflow;
	input wire signed [WORD_WIDTH:0] signal;
	input wire signed [WORD_WIDTH:0] nsignal;
	input wire reset;
	input wire [WORD_WIDTH-1:0] in_p;
	input wire [WORD_WIDTH-1:0] in_n;
	input wire clk;
	input wire refclk;
	input wire cumulative;
	input wire multiply;
	assign overflow = (counter_out == ((1<<(RESOLUTION-1))|1) || counter_out == ~(1<<(RESOLUTION-1)));
	wire signed [WORD_WIDTH:0] signal;
	wire signed [WORD_WIDTH:0] nsignal;
	reg signed [WORD_WIDTH:0] tmp_signal;
	reg signed [WORD_WIDTH:0] tmp_nsignal;
	assign signal = { 0, in_p };
	assign nsignal = { 0, in_n };
	reg _refclk;
	wire clock;
	assign clock = (USE_SOFT_CLOCK ? clk : refclk);

	always @(posedge clock) begin
		if(refclk != _refclk || !USE_SOFT_CLOCK) begin
			_refclk <= refclk;
			if(refclk || !USE_SOFT_CLOCK) begin
				if(~reset) begin
					if(!overflow) begin
						if((cumulative | HAS_CUMULATIVE_ONLY) || (signal != tmp_signal) || (nsignal != tmp_nsignal)) begin
							tmp_signal <= signal;
							tmp_nsignal <= nsignal;
							if(multiply) begin
								counter_out <= counter_out + signal * nsignal;
							end else begin
								counter_out <= counter_out + signal - nsignal;
							end
						end
					end
				end else
					counter_out <= 0;
			end
		end
	end
		
endmodule
