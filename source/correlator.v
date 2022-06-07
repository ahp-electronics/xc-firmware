/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CORRELATOR (
		pulses,
		pllclk,
		cross_a,
		adc_data_a,
		cross_smpclk,
		leds_a,
		order,
		reset
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
	parameter USE_SOFT_CLOCK = 1;
	parameter MAX_ORDER = 2;

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
	localparam MAX_ALLOWED_ORDER = ((NUM_INPUTS < MAX_ORDER) ? NUM_INPUTS : MAX_ORDER);
	localparam MAX_COUNTS = (((1<<RESOLUTION)-1)-((1<<WORD_WIDTH)-1));

	localparam LAG_SIZE_AUTO = DELAY_SIZE+LAG_AUTO+1;
	localparam LAG_SIZE_CROSS = DELAY_SIZE+LAG_CROSS+1;
	localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

	localparam MAX_COUNT=(1<<RESOLUTION)-1;
	localparam TOTAL_NIBBLES=(PACKET_SIZE)/4;

	localparam QUADRANT_OR_SINGLE = (DELAY_SIZE < 5);
	localparam QUADRANT = (DELAY_SIZE == 4);
	localparam SINGLE = (DELAY_SIZE == 0);

	output wire [PAYLOAD_SIZE-1:0] pulses;
	input wire reset;
	input wire pllclk;
	input wire [7:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [20*NUM_INPUTS-1:0] cross_a;
	input wire [NUM_INPUTS-1:0] cross_smpclk;
	input wire [NUM_INPUTS*8-1:0] leds_a;

	wire [WORD_WIDTH*LAG_SIZE_CROSS-1:0] cross_delay_lines [0:NUM_INPUTS];
	wire [19:0] cross [0:NUM_INPUTS];
	wire [19:0] delays_r [0:NUM_INPUTS];
	wire [19:0] delays_i [0:NUM_INPUTS];
	reg [WORD_WIDTH*LAG_CROSS-1:0] old_delayed_lines_r [0:NUM_INPUTS];
	reg [WORD_WIDTH*LAG_CROSS-1:0] old_delayed_lines_i [0:NUM_INPUTS];
	wire [WORD_WIDTH*LAG_CROSS-1:0] cross_delayed_lines_r [0:NUM_INPUTS];
	wire [WORD_WIDTH*LAG_CROSS-1:0] cross_delayed_lines_i [0:NUM_INPUTS];
	reg signed [WORD_WIDTH-1:0] r[0:CORRELATIONS_SIZE];
	reg signed [WORD_WIDTH-1:0] i[0:CORRELATIONS_SIZE];

	wire [7:0] m_order;
	wire [CORRELATIONS_SIZE-1:0] overflow;
	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];

	generate
		genvar a;
		genvar b;
		genvar c;
		genvar idx;
		genvar line;

		for (idx = 0; idx < CORRELATIONS_SIZE; idx = idx+1) begin : iteration_block
			assign pulses[idx*RESOLUTION*2+:RESOLUTION] = r[CORRELATIONS_SIZE-idx-1];
			assign pulses[idx*RESOLUTION*2+RESOLUTION+:RESOLUTION] = i[CORRELATIONS_SIZE-idx-1];
			assign overflow[idx] = ~(r[idx] < MAX_COUNTS && r[idx] > -MAX_COUNTS && i[idx] < MAX_COUNTS && i[idx] > -MAX_COUNTS);
		end

		for (line = 0; line < NUM_INPUTS; line = line+1) begin : correlator_outer_block
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_CROSS)) cross_delay_line(pllclk, cross_smpclk[line], adc_data[line], cross_delay_lines[line]);
			assign adc_data[line] = adc_data_a[line*WORD_WIDTH+:WORD_WIDTH];
			assign leds[line] = leds_a[line*8+:8];
			assign cross[line] = cross_a[line*20+:20];
			assign delays_r[line] = (QUADRANT ? 1 : (SINGLE ? 1 : cross[line]));
			assign delays_i[line] = (QUADRANT ? 2 : (SINGLE ? 1 : cross[line]));
			assign cross_delayed_lines_r[line] = cross_delay_lines[line][(QUADRANT_OR_SINGLE ? 1 : cross[line])*WORD_WIDTH+:WORD_WIDTH*LAG_CROSS];
			assign cross_delayed_lines_i[line] = cross_delay_lines[line][(QUADRANT ? 2 : (SINGLE ? 1 : cross[line]))*WORD_WIDTH+:WORD_WIDTH*LAG_CROSS];
			assign m_order = (order < MAX_ALLOWED_ORDER ? order+2 : MAX_ALLOWED_ORDER);
		end
	
		for (a=0; a<NUM_INPUTS-1; a=a+1) begin
			for (b=a+1; b<NUM_INPUTS; b=b+1) begin
				for (c=-LAG_CROSS+1; c<LAG_CROSS; c=c+1) begin
					always @(posedge pllclk) begin : crosscorrelator_block
						reg [12:0] d;
						reg signed [WORD_WIDTH-1:0] old_r;
						reg signed [WORD_WIDTH-1:0] old_i;
						for (d=0; d<MAX_ALLOWED_ORDER; d=d+1) begin
							if(d < m_order && b < NUM_INPUTS - m_order + 1) begin
								if(~overflow[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))]) begin
									if(d == 0) begin
										old_r <= cross_delayed_lines_r[a][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH];
										old_i <= cross_delayed_lines_i[a][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH];
									end else begin
										if(~(leds[a][4]&leds[b+d-1][4])) begin
											old_r <= old_r * cross_delayed_lines_r[b+d-1][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH];
											old_i <= old_i * cross_delayed_lines_i[b+d-1][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?((1<<WORD_WIDTH)-1):0);
										end else begin
											old_r <= old_r - cross_delayed_lines_r[b+d-1][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH];
											old_i <= old_i - cross_delayed_lines_i[b+d-1][(c < 0 ? -c : c)*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?((1<<WORD_WIDTH)-1):0);
										end
									end
								end
							end
						end
						if(~reset) begin
							r[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] <= r[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] + old_r;
							i[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] <= i[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] + old_i;
						end else begin
							r[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] <= 0;
							i[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*CORRELATIONS_HEAD_TAIL_SIZE+(c+LAG_CROSS-1))] <= 0;
						end
					end
				end
			end
		end
	endgenerate
endmodule
