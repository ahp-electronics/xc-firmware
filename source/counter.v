/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module DIFF_COUNTER (
		counter_out,
		overflow,
		in_p,
		in_n,
		multiply,
		clk,
		reset
	);
	parameter RESOLUTION=64;
	parameter WORD_WIDTH=1;

	output reg signed [RESOLUTION-1:0] counter_out;
	output wire overflow;
	input wire reset;
	input wire [WORD_WIDTH-1:0] in_p;
	input wire [WORD_WIDTH-1:0] in_n;
	input wire clk;
	input wire multiply;
	assign overflow = (counter_out >= ((1<<(RESOLUTION-1))-1)) || (counter_out <= -((1<<(RESOLUTION-1))-1));
	reg signed [WORD_WIDTH:0] tmp_signal[0:2];
	wire signed [WORD_WIDTH:0] signal[0:2];
	assign signal[0] = { 1'd0, in_p };
	assign signal[1] = { 1'd0, in_n };

	always @(posedge clk) begin
		if(~reset) begin
			if(!overflow) begin
				if(multiply) begin
					counter_out <= counter_out + signal[0] * signal[1];
				end else begin
					counter_out <= counter_out + signal[0] - signal[1];
				end
			end
		end else
			counter_out <= 0;
	end
endmodule

module COUNTER (
		pulses,
		clk,
		adc_data_a,
		leds_a,
		overflow,
		reset,
		enable
	);

	parameter NUM_INPUTS=8;
	parameter RESOLUTION = 24;
	parameter WORD_WIDTH = 1;

	localparam MAX_COUNTS = (((1<<RESOLUTION)-1)-((1<<WORD_WIDTH)-1));

	output reg signed [NUM_INPUTS*RESOLUTION-1:0] pulses;
	input wire enable;
	input wire reset;
	input wire clk;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [NUM_INPUTS*8-1:0] leds_a;
	output wire[NUM_INPUTS-1:0] overflow;
	
	generate
		genvar i;
		for(i = 0; i < NUM_INPUTS; i = i+1) begin
			assign overflow[i] = pulses[(NUM_INPUTS-i-1)*RESOLUTION+:RESOLUTION] == MAX_COUNTS;
		end
	endgenerate
	
	always @(posedge clk) begin : counter_sum_block
		integer a;
		for (a=0; a<NUM_INPUTS; a=a+1) begin
			if(enable) begin
				if(reset) begin
					pulses[(NUM_INPUTS-a-1)*RESOLUTION+:RESOLUTION] = 0;
				end else begin
					if(pulses[(NUM_INPUTS-a-1)*RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
						pulses[(NUM_INPUTS-a-1)*RESOLUTION+:RESOLUTION] = pulses[(NUM_INPUTS-a-1)*RESOLUTION+:RESOLUTION] + adc_data_a[a*WORD_WIDTH+:WORD_WIDTH];
					end
				end
			end
		end
	end

endmodule
