/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CORRELATOR (
		pulses,
		clk,
		cross_a,
		adc_data_a,
		cross_smpclk,
		leds_a,
		order,
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

	output reg signed [PAYLOAD_SIZE-1:0] pulses;
	input wire enable;
	input wire reset;
	input wire clk;
	input wire [7:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [20*NUM_INPUTS-1:0] cross_a;
	input wire [NUM_INPUTS-1:0] cross_smpclk;
	input wire [NUM_INPUTS*8-1:0] leds_a;

	wire [WORD_WIDTH*LAG_SIZE_CROSS-1:0] cross_delay_lines [0:NUM_INPUTS];
	wire [19:0] cross [0:NUM_INPUTS];


	wire [7:0] m_order;
	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];
	reg [WORD_WIDTH*NUM_INPUTS-1:0] old_signal;

	generate
		genvar a;
		for (a = 0; a < NUM_INPUTS; a = a+1) begin : correlator_outer_block
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_CROSS)) cross_delay_line(clk, cross_smpclk[a], adc_data[a], cross_delay_lines[a]);
			assign adc_data[a] = adc_data_a[a*WORD_WIDTH+:WORD_WIDTH];
			assign leds[a] = leds_a[a*8+:8];
			assign cross[a] = cross_a[a*20+:20];
		end
	endgenerate

	always @(posedge clk) begin : crosscorrelator_block
		reg [7:0] a;
		reg [7:0] b;
		reg signed [12:0] _c;
		reg signed [12:0] c;
		reg signed [8:0] d;
		reg signed [RESOLUTION:0] tmp_r;
		reg signed [RESOLUTION:0] tmp_i;
		if(enable) begin
			for (a=0; a<NUM_INPUTS; a=a+1) begin
				for (b=0; b<NUM_INPUTS; b=b+1) begin
					if(b > a && a < (NUM_INPUTS - order - 1)) begin
						for (_c=-LAG_CROSS+1; _c<LAG_CROSS; _c=_c+512) begin
							for (c=_c; c<_c+512 && c < LAG_CROSS; c=c+1) begin
								for (d=-1; d<MAX_ORDER; d=d+1) begin
									if(d < 0) begin
										if (HAS_CUMULATIVE_ONLY || leds[a][3] || old_signal[a*WORD_WIDTH+:WORD_WIDTH] != cross_delay_lines[a][0+:WORD_WIDTH]) begin
											old_signal[a*WORD_WIDTH+:WORD_WIDTH] <= cross_delay_lines[a][0+:WORD_WIDTH];
											tmp_r <= cross_delay_lines[a][(QUADRANT ? 2 : (SINGLE ? 1 : cross[a+c+LAG_CROSS-1]))*WORD_WIDTH+:WORD_WIDTH];
											tmp_i <= cross_delay_lines[a][(QUADRANT ? 2 : (SINGLE ? 1 : cross[a+c+LAG_CROSS-1]))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
										end
									end else if(d < (order+1)) begin
										if (HAS_CUMULATIVE_ONLY || leds[b+d][3] || old_signal[(b+d)*WORD_WIDTH+:WORD_WIDTH] != cross_delay_lines[b+d][0+:WORD_WIDTH]) begin
											old_signal[(b+d)*WORD_WIDTH+:WORD_WIDTH] <= cross_delay_lines[b+d][0+:WORD_WIDTH];
											if(leds[b+d][4]) begin
												tmp_r <= tmp_r * cross_delay_lines[b+d][(QUADRANT ? 2 : (SINGLE ? 1 : cross[(b+d+c+LAG_CROSS-1)]))*WORD_WIDTH+:WORD_WIDTH];
												tmp_i <= tmp_i * cross_delay_lines[b+d][(QUADRANT ? 2 : (SINGLE ? 1 : cross[(b+d+c+LAG_CROSS-1)]))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
											end else begin
												tmp_r <= tmp_r - cross_delay_lines[b+d][(QUADRANT ? 2 : (SINGLE ? 1 : cross[(b+d+c+LAG_CROSS-1)]))*WORD_WIDTH+:WORD_WIDTH];
												tmp_i <= tmp_i - cross_delay_lines[b+d][(QUADRANT ? 2 : (SINGLE ? 1 : cross[(b+d+c+LAG_CROSS-1)]))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
											end
										end
									end
								end
								if(~reset) begin
									if(pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+:RESOLUTION] < MAX_COUNTS && pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
										pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+:RESOLUTION] <= pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+:RESOLUTION] + tmp_r;
										pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] + tmp_i;
									end
								end else begin
									pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+:RESOLUTION] <= 0;
									pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(c+LAG_CROSS-1)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= 0;
								end
							end
						end
					end
				end
			end
		end
	end
endmodule
