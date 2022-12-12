/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CROSSCORRELATOR (
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

	output reg signed [CORRELATIONS_SIZE*RESOLUTION*2-1:0] pulses;
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

	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];

	reg[2:0] _log;
	reg[2:0] log;
	
	generate
		genvar line;
		for (line = 0; line < NUM_INPUTS; line = line+1) begin : correlator_outer_block
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_CROSS)) cross_delay_line(clk, cross_smpclk[line], adc_data_a[line*WORD_WIDTH+:WORD_WIDTH], cross_delay_lines[line]);
			assign leds[line] = leds_a[line*8+:8];
			assign cross[line] = (QUADRANT_OR_SINGLE ? cross_a[line*20+:20] : cross_a[line*20+:12]);
		end 
	endgenerate

	always @(posedge clk) begin : crosscorrelator_block
		reg [15:0] _a;
		reg [15:0] a;
		for (_log=1; _log!=7; _log=_log+1) begin
			if(NUM_INPUTS[_log])
				log <= _log;
		end
		for (_a=0; _a<NUM_BASELINES; _a=_a+512) begin
			for (a=_a; a<_a+512 && a < NUM_BASELINES; a=a+1) begin : crosscorrelator_sum_block
				reg [12:0] _c;
				reg [12:0] c;
				reg [8:0] d;
				reg multiply;
				for (d=0; d<MAX_ORDER; d=d+1) begin
					if(d < (order+2))
						multiply = multiply | ~leds[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][4];
				end
				for (_c=0; _c<CORRELATIONS_HEAD_TAIL_SIZE; _c=_c+512) begin
					for (c=_c; c<_c+512 && c < CORRELATIONS_HEAD_TAIL_SIZE; c=c+1) begin : crosscorrelator_generation_block
						reg signed [RESOLUTION:0] tmp_r;
						reg signed [RESOLUTION:0] tmp_i;
						for (d=0; d<MAX_ORDER; d=d+1) begin
							if(d == 0) begin
								tmp_r = cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 1 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH];
								tmp_i = cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 3 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
							end else if(d < (order+2)) begin
								if(multiply) begin
									tmp_r = tmp_r * cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 1 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH];
									tmp_i = tmp_i * cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 3 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
								end else begin
									tmp_r = tmp_r - {1'd0, cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 1 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH]};
									tmp_i = tmp_i - {1'd0, cross_delay_lines[((a + d * ((a >> log) + 1)) % NUM_INPUTS)][(QUADRANT ? 3 : (SINGLE ? 1 : cross[((a + d * ((a >> log) + 1)) % NUM_INPUTS)]+(c < LAG_CROSS ? LAG_CROSS-c : c+LAG_CROSS-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0)};
								end
							end
						end
						if(reset|~enable) begin
							pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] = 0;
							pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] = 0;
						end else begin
							if(pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-1)*RESOLUTION*2+:RESOLUTION] < MAX_COUNTS && pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
								pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] = pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] + tmp_r;
								pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] = pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] + tmp_i;
							end
						end
					end
				end
			end
		end
	end

endmodule
