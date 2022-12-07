/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module AUTOCORRELATOR (
		pulses,
		clk,
		auto_a,
		adc_data_a,
		auto_smpclk,
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

	output reg signed [SPECTRA_SIZE*RESOLUTION*2-1:0] pulses;
	input wire enable;
	input wire reset;
	input wire clk;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [20*NUM_INPUTS-1:0] auto_a;
	input wire [NUM_INPUTS-1:0] auto_smpclk;
	input wire [NUM_INPUTS*8-1:0] leds_a;

	wire [WORD_WIDTH*LAG_SIZE_AUTO-1:0] auto_delay_lines [0:NUM_INPUTS];
	wire [19:0] auto [0:NUM_INPUTS];

	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];

	generate
		genvar line;
		for (line = 0; line < NUM_INPUTS; line = line+1) begin : autocorrelator_outer_block
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(LAG_SIZE_AUTO)) auto_delay_line(clk, auto_smpclk[line], adc_data_a[line*WORD_WIDTH+:WORD_WIDTH], auto_delay_lines[line]);
			assign leds[line] = leds_a[line*8+:8];
			assign auto[line] = (QUADRANT_OR_SINGLE ? auto_a[line*20+:20] : auto_a[line*20+:12]);
		end 
	endgenerate

	always @(posedge clk) begin : autocorrelator_block
		reg [7:0] a;
		for (a=0; a<NUM_INPUTS; a=a+1) begin : autocorrelator_sum_block
			reg signed [RESOLUTION:0] tmp_r;
			reg signed [RESOLUTION:0] tmp_i;
			reg [12:0] _c;
			reg [12:0] c;
			reg d;
			if(enable) begin
				for (_c=0; _c<LAG_AUTO; _c=_c+512) begin
					for (c=_c; c<_c+512 && c < LAG_AUTO; c=c+1) begin
						for (d=0; d<1; d=d+1) begin
							if(d == 0) begin
								tmp_r = auto_delay_lines[a][(QUADRANT ? 1 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH];
								tmp_i = auto_delay_lines[a][(QUADRANT ? 3 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
							end else begin
								if(~leds[a][4]) begin
									tmp_r = tmp_r * auto_delay_lines[a][(QUADRANT ? 1 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH];
									tmp_i = tmp_i * auto_delay_lines[a][(QUADRANT ? 3 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0);
								end else begin
									tmp_r = tmp_r - {1'd0, auto_delay_lines[a][(QUADRANT ? 1 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH]};
									tmp_i = tmp_i - {1'd0, auto_delay_lines[a][(QUADRANT ? 3 : (SINGLE ? 1 : auto[a]+(c < LAG_AUTO ? LAG_AUTO-c : c+LAG_AUTO-1)))*WORD_WIDTH+:WORD_WIDTH]^(SINGLE?~0:0)};
								end
							end
						end
						if(reset|~enable) begin
							pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+:RESOLUTION] = 0;
							pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] = 0;
						end else begin
							if(pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+:RESOLUTION] < MAX_COUNTS && pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
								pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+:RESOLUTION] = pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+:RESOLUTION] + tmp_r;
								pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] = pulses[(NUM_INPUTS-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] + tmp_i;
							end
						end
					end
				end
			end
		end
	end

endmodule
