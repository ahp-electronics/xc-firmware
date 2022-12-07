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
	parameter HAS_CUMULATIVE_ONLY = 0;
	parameter USE_SOFT_CLOCK = 0;

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
		reset,
		enable
	);

	parameter PLL_FREQUENCY = 400000000;
	parameter CLK_FREQUENCY = 10000000;
	parameter CLK_DIVISOR = 2;
	parameter SIN_FREQUENCY = 50;
	parameter MUX_LINES = 1;
	parameter NUM_LINES = 8;
	parameter DELAY_SIZE = 0;
	parameter LAG_CROSS = 1;
	parameter LAG_AUTO = 1;
	parameter RESOLUTION = 24;
	parameter HAS_LEDS = 1;
	parameter HAS_PSU = 0;
	parameter HAS_CUMULATIVE_ONLY = 0;
	parameter BAUD_RATE = 57600;
	parameter WORD_WIDTH = 1;
	parameter USE_UART = 1;
	parameter BINARY = 0;
	parameter USE_SOFT_CLOCK = 0;
	parameter MAX_ORDER = 2;

	localparam SIGNED_WIDTH = RESOLUTION + 1;
	localparam SHIFT = 1;
	localparam SECOND = 1000000000;
	localparam TICK_CYCLES = CLK_DIVISOR*MUX_LINES;
	localparam TICK_FREQUENCY = PLL_FREQUENCY/TICK_CYCLES;
	localparam NUM_INPUTS = NUM_LINES*MUX_LINES;
	localparam[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
	localparam NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
	localparam SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
	localparam CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
	localparam MAX_LAG = (LAG_AUTO > CORRELATIONS_HEAD_TAIL_SIZE) ? LAG_AUTO : CORRELATIONS_HEAD_TAIL_SIZE;
	localparam CORRELATIONS_SIZE = (NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
	localparam PAYLOAD_SIZE = ((CORRELATIONS_SIZE+SPECTRA_SIZE)*2+NUM_INPUTS)*RESOLUTION;
	localparam HEADER_SIZE = 64;
	localparam FOOTER_SIZE = 64;
	localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE+FOOTER_SIZE;
	localparam MAX_COUNTS = (((1<<RESOLUTION)-1)-((1<<WORD_WIDTH)-1));

	localparam LAG_SIZE_AUTO = DELAY_SIZE+LAG_AUTO+1;
	localparam LAG_SIZE_CROSS = DELAY_SIZE+LAG_CROSS+1;
	localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

	localparam MAX_COUNT=(1<<RESOLUTION)-1;
	localparam TOTAL_NIBBLES=(PACKET_SIZE)/4;

	localparam QUADRANT_OR_SINGLE = (DELAY_SIZE < 5);
	localparam QUADRANT = (DELAY_SIZE == 4);
	localparam SINGLE = (DELAY_SIZE == 0);

	output reg signed [NUM_INPUTS*RESOLUTION-1:0] pulses;
	input wire enable;
	input wire reset;
	input wire clk;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [NUM_INPUTS*8-1:0] leds_a;

	always @(posedge clk) begin : counter_sum_block
		reg [7:0] a;
		for (a=0; a<NUM_INPUTS; a=a+1) begin
			if(enable) begin
				if(reset|~enable) begin
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
