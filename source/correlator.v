/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CORRELATOR (
		pulses,
		overflow,
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
	parameter HAS_CROSSCORRELATOR = 1;
	parameter HAS_PSU = 0;
	parameter HAS_CUMULATIVE_ONLY = 0;
	parameter BAUD_RATE = 57600;
	parameter WORD_WIDTH = 1;
	parameter USE_UART = 1;
	parameter BINARY = 0;
	parameter USE_SOFT_CLOCK = 1;

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
	localparam CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
	localparam PAYLOAD_SIZE = ((CORRELATIONS_SIZE+SPECTRA_SIZE)*2+NUM_INPUTS)*RESOLUTION;
	localparam HEADER_SIZE = 64;
	localparam FOOTER_SIZE = 64;
	localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE+FOOTER_SIZE;

	localparam LAG_SIZE_AUTO = DELAY_SIZE+LAG_AUTO+1;
	localparam LAG_SIZE_CROSS = DELAY_SIZE+LAG_CROSS;
	localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

	localparam MAX_COUNT=(1<<RESOLUTION)-1;
	localparam TOTAL_NIBBLES=(PACKET_SIZE)/4;

	localparam QUADRANT_OR_SINGLE = (DELAY_SIZE < 5);
	localparam QUADRANT = (DELAY_SIZE == 4);

	wire [NUM_INPUTS-1:0] cross_delay_lines[WORD_WIDTH*LAG_SIZE_CROSS-1:0];
	wire[LAG_SIZE_CROSS*NUM_INPUTS*WORD_WIDTH-1:0] cross_delays;
	output reg [PAYLOAD_SIZE-1:0] pulses;
	output wire overflow[CORRELATIONS_SIZE-1:0];
	input wire reset;
	input wire pllclk;
	input wire [3:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [WORD_WIDTH*LAG_SIZE_CROSS*NUM_INPUTS-1:0] cross_delays;
	input wire cross_a[20*NUM_INPUTS-1:0];
	input wire [19:0] cross[NUM_INPUTS];
	input wire cross_smpclk[NUM_INPUTS-1:0];
	input wire leds_a[NUM_INPUTS*8-1:0];

	reg[WORD_WIDTH-1:0] r[CORRELATIONS_SIZE];
	reg[WORD_WIDTH-1:0] i[CORRELATIONS_SIZE];

	wire [WORD_WIDTH-1:0] adc_data [NUM_INPUTS];
	wire[7:0] leds[NUM_INPUTS];
	reg[7:0] a;
	reg[7:0] b;
	reg[15:0] idx;
	reg[3:0] c;
	reg[11:0] y;
	reg[11:0] z;

	wire[WORD_WIDTH-1:0] counts [CORRELATIONS_SIZE*2];

	generate
		genvar x;
		genvar j;
		genvar line1;
		genvar line2;
		genvar channel;
		genvar _channels;
		for (line1 = 0; line1 < NUM_INPUTS; line1 = line1+1) begin : correlator_outer_block
			for(x = 0; x < LAG_SIZE_CROSS; x=x+512) begin : correlator_iteration_block
				for(j = x; j < x + 512 && j < LAG_SIZE_CROSS; j=j+1) begin : cross_delays_block
					assign cross_delay_lines[j][line1*WORD_WIDTH+:WORD_WIDTH] = cross_delays[line1*WORD_WIDTH+j*WORD_WIDTH+:WORD_WIDTH];
				end
				assign adc_data[line1] = adc_data_a[line1*WORD_WIDTH+:WORD_WIDTH];
				assign leds[line1] = leds_a[line1*8+:8];
				assign cross[line1] = cross_a[line1*20+:20];
				fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_CROSS)) cross_delay_line(pllclk, cross_smpclk[line1], adc_data[line1], cross_delays[line1]);
				for (line2 = line1+1; line2 < NUM_INPUTS; line2 <= line2+1) begin : correlator_block
					/*for(_channels=0; _channels < MAX_LAG*2; _channels=_channels+512) begin : jitter_block
						for(channel=_channels; channel < _channels+512 && channel < MAX_LAG*2; channel=channel+1) begin : jitter_inner_block
							if(channel!=LAG_CROSS&&channel<CORRELATIONS_HEAD_TAIL_SIZE) begin : channel_inner_block
								assign r[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*2] = pulses[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*RESOLUTION*2+:RESOLUTION];
								assign i[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*2+1] = pulses[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION];
								assign overflow[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*2] = (r[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)] == ((1<<(RESOLUTION-1))|1) || r[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)] == ~(1<<(RESOLUTION-1)));
								assign overflow[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)*2+1] = (i[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)] == ((1<<(RESOLUTION-1))|1) || i[((CORRELATIONS_SIZE-((line1*(NUM_INPUTS+NUM_INPUTS-line1-1))>>1)-line2+line1+1)*CORRELATIONS_HEAD_TAIL_SIZE-(channel>LAG_CROSS?channel-1:channel)-1)] == ~(1<<(RESOLUTION-1)));
							end
						end
					end*/
				end
			end
		end
	endgenerate

	always @(posedge pllclk) begin
		for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
			for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
				for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
					if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
						for (b=a+order+1; b<NUM_INPUTS; b=b+order+1) begin : correlators_block
							for (c=0; c<order; c=c+1) begin : order_block
								if(~reset) begin
									if(!overflow[idx]) begin
										if(leds[a][3]&leds[b][3]) begin
											if(c == 0) begin
												if(~(leds[a][4]&leds[b][4])) begin
													r[idx] <= r[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
													i[idx] <= i[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b+c*WORD_WIDTH+:WORD_WIDTH];
												end else begin
													r[idx] <= r[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
													i[idx] <= i[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH];
												end
											end else begin
												if(~(leds[a][4]&leds[b][4])) begin
													r[idx] <= r[idx] + r[idx] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
													i[idx] <= i[idx] + i[idx] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH];
												end else begin
													r[idx] <= r[idx] + r[idx] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
													i[idx] <= i[idx] + i[idx] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b])+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH];
												end
											end
										end
									end
								end else begin
									r[idx] <= 0;
									i[idx] <= 0;
								end
							end
							idx <= idx+1;
						end
					end
				end
			end
		end
	end
		
endmodule
