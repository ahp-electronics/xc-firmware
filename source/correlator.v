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

	localparam LAG_SIZE_AUTO = DELAY_SIZE+LAG_AUTO+1;
	localparam LAG_SIZE_CROSS = DELAY_SIZE+LAG_CROSS;
	localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

	localparam MAX_COUNT=(1<<RESOLUTION)-1;
	localparam TOTAL_NIBBLES=(PACKET_SIZE)/4;

	localparam QUADRANT_OR_SINGLE = (DELAY_SIZE < 5);
	localparam QUADRANT = (DELAY_SIZE == 4);

	wire [WORD_WIDTH*DELAY_SIZE:0] cross_delay_lines [0:NUM_INPUTS];
	output reg [PAYLOAD_SIZE-1:0] pulses;
	input wire reset;
	input wire pllclk;
	input wire [3:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [20*NUM_INPUTS-1:0] cross_a;
	input wire [19:0] cross[0:NUM_INPUTS];
	input wire [NUM_INPUTS-1:0] cross_smpclk;
	input wire [NUM_INPUTS*8-1:0] leds_a;

	reg signed [WORD_WIDTH-1:0] r[0:CORRELATIONS_SIZE];
	reg signed [WORD_WIDTH-1:0] i[0:CORRELATIONS_SIZE];

	wire [CORRELATIONS_SIZE*CORRELATIONS_HEAD_TAIL_SIZE-1:0] overflow;
	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];
	reg[7:0] a;
	reg[7:0] b;
	reg[15:0] idx;
	reg[4:0] c;
	reg[11:0] y;
	reg[11:0] z;

	wire[WORD_WIDTH-1:0] counts [CORRELATIONS_SIZE*2];

	generate
		genvar _idx;
		genvar x;
		genvar j;
		genvar line1;
		genvar line2;
		genvar channel;
		genvar _channels;
		for (_idx = 0; _idx < CORRELATIONS_HEAD_TAIL_SIZE; _idx = _idx+1) begin : iteration_block
			assign r[_idx*2] = pulses[_idx*RESOLUTION*2+:RESOLUTION];
			assign i[_idx*2+1] = pulses[_idx*RESOLUTION*2+RESOLUTION+:RESOLUTION];
			assign overflow[_idx] = (r[_idx] >= (((1<<RESOLUTION)-1)-(1<<WORD_WIDTH)) || r[_idx] >= -(((1<<RESOLUTION)-1)-(1<<WORD_WIDTH)) || i[_idx] >= (((1<<RESOLUTION)-1)-(1<<WORD_WIDTH)) || i[_idx] >= -(((1<<RESOLUTION)-1)-(1<<WORD_WIDTH)));
		end

		for (line1 = 0; line1 < NUM_INPUTS; line1 = line1+1) begin : correlator_outer_block
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_CROSS)) cross_delay_line(pllclk, cross_smpclk[line1], adc_data[line1], cross_delay_lines[line1]);
			for(x = 0; x < LAG_SIZE_CROSS; x=x+512) begin : correlator_iteration_block
				assign adc_data[line1] = adc_data_a[line1*WORD_WIDTH+:WORD_WIDTH];
				assign leds[line1] = leds_a[line1*8+:8];
				assign cross[line1] = cross_a[line1*20+:20];
			end
		end
	endgenerate

	always @(posedge pllclk) begin
		idx <= 0;
		for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
				if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
					for (a=0; a<NUM_INPUTS-order-1; a=a+1) begin : correlators_initial_block
						for (b=a+order+1; b<NUM_INPUTS-order; b=b+1) begin : correlators_block
							for (c=0; c<order+1; c=c+1) begin : order_block
								if(~reset) begin
									if(!overflow[idx]) begin
										if(leds[a][3]&leds[b+c][3]) begin
											if(~(leds[a][4]&leds[b+c][4])) begin
												r[idx] <= r[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b+c])+(y>LAG_CROSS?y-LAG_CROSS:0)][b+c*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
												i[idx] <= i[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] * cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b+c])+(y>LAG_CROSS?y-LAG_CROSS:0)][b+c+c*WORD_WIDTH+:WORD_WIDTH];
											end else begin
												r[idx] <= r[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[b+c])+(y>LAG_CROSS?y-LAG_CROSS:0)][b+c*WORD_WIDTH+:WORD_WIDTH]^(QUADRANT ? 0 : (~0));
												i[idx] <= i[idx] + cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 1 : 1) : cross[a])+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH] - cross_delay_lines[((QUADRANT_OR_SINGLE) ? (QUADRANT ? 2 : 1) : cross[b+c])+(y>LAG_CROSS?y-LAG_CROSS:0)][b+c*WORD_WIDTH+:WORD_WIDTH];
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