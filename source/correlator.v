/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CORRELATOR (
		pulses,
		clk,
		delay_arr,
		adc_data_a,
		sampling_clk,
		led_lines,
		order,
		reset,
		enable
	);
	
	parameter NUM_INPUTS=8;
	parameter DELAY_SIZE=0;
	parameter NUM_BASELINES=8;
	parameter TAIL_SIZE=1;
	parameter HEAD_SIZE=0;
	parameter RESOLUTION=20;
	parameter WORD_WIDTH=1;
	parameter USE_SOFT_CLOCK=0;
	parameter MAX_ORDER=2;
	
	localparam DELAYS_SIZE=DELAY_SIZE < 4 ? 4 : DELAY_SIZE;
	localparam NEGATIVE_MASK=(1<<WORD_WIDTH)-1;
	localparam CORRELATIONS_HEAD_TAIL_SIZE=(HEAD_SIZE+TAIL_SIZE-1);
	localparam MAX_LAG=(HEAD_SIZE > CORRELATIONS_HEAD_TAIL_SIZE) ? HEAD_SIZE : CORRELATIONS_HEAD_TAIL_SIZE;
	localparam CORRELATIONS_SIZE=(NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
	localparam MAX_COUNTS=(((1<<RESOLUTION)-1)-((1<<WORD_WIDTH)-1));

	localparam QUADRANT_OR_SINGLE=(DELAY_SIZE < 5);
	localparam QUADRANT=(DELAY_SIZE == 4);
	localparam SINGLE=(DELAY_SIZE == 0);

	output reg signed [CORRELATIONS_SIZE*RESOLUTION*2-1:0] pulses;
	input wire enable; 
	input wire reset;
	input wire clk;
	input wire [7:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [24*NUM_INPUTS-1:0] delay_arr;
	input wire [NUM_INPUTS-1:0] sampling_clk;
	input wire [NUM_INPUTS*8-1:0] led_lines;

	wire [WORD_WIDTH*(DELAYS_SIZE+TAIL_SIZE+1)-1:0] delay_lines [0:NUM_INPUTS];
	wire [19:0] delay [0:NUM_INPUTS];

	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];
			
	generate
		genvar line;
		genvar a;
		genvar _a;
		genvar c;
		genvar _c;
		for (line=0; line < NUM_INPUTS; line=line+1) begin
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAYS_SIZE+TAIL_SIZE+1)) delay_line(clk, sampling_clk[line], adc_data_a[line*WORD_WIDTH+:WORD_WIDTH], delay_lines[line]);
			assign leds[line]=led_lines[line*8+:8];
			assign delay[line]=(QUADRANT_OR_SINGLE ? delay_arr[line*20+:20] : delay_arr[line*20+:12]);
		end
		
		for (_a=0; _a < NUM_BASELINES; _a=_a+512) begin
			for (a=_a; a<_a+512 && a < NUM_BASELINES; a=a+1) begin
				for (_c=-TAIL_SIZE; _c<HEAD_SIZE-1; _c=_c+512) begin
					for (c=_c; c<_c+512 && c < HEAD_SIZE-1; c=c+1) begin
						always @(posedge clk) begin : correlator_block
							reg[MAX_ORDER:0] multiply;
							reg signed [RESOLUTION-1:0] tmp_r[0:MAX_ORDER];
							reg signed [RESOLUTION-1:0] tmp_i[0:MAX_ORDER];
							integer d;
							integer e;
							for (e=0; e<MAX_ORDER; e=e+1) begin : correlator_multiplier_block
								if(e == 0)
									multiply[e] <= ~leds[a % NUM_INPUTS][4];
								else
									multiply[e] <= multiply[e-1] | ~leds[((a + e * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][4];
							end
							for (d=0; d<MAX_ORDER; d=d+1) begin : correlator_order_block
								if(d<=order) begin
									if(d == 0) begin
										if(SINGLE) begin
											if(multiply[order]) begin
												tmp_r[d] <= delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, ~delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end else if(QUADRANT) begin
											if(multiply[order]) begin
												tmp_r[d] <= (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1) * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(3+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1) * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(4+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(3+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(4+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end else begin
											if(multiply[order]) begin
												tmp_r[d] <= (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1) * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(((delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]*3)>>2)+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1) * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(((delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]*3)>>2)+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= {1'd0, (MAX_ORDER == 1 ? delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0+:WORD_WIDTH] : 1)} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end
									end else begin
										if(SINGLE) begin
											if(multiply[order]) begin
												tmp_r[d] <= tmp_r[d-1] * {1'd0, ~delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= tmp_r[d-1] - {1'd0, ~delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(1+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end else if(QUADRANT) begin
											if(multiply[order]) begin
												tmp_r[d] <= tmp_r[d-1] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(3+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(4+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= tmp_r[d-1] - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(3+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(4+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end else begin
											if(multiply[order]) begin
												tmp_r[d] <= tmp_r[d-1] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(((delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]*3)>>2)+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end else begin
												tmp_r[d] <= tmp_r[d-1] - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(((delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]*3)>>2)+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
												tmp_i[d] <= tmp_i[d-1] - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[(a + d * ((a / NUM_INPUTS) + 1) % NUM_INPUTS)]+(c < 0 ? -c : 0))*WORD_WIDTH+:WORD_WIDTH]};
											end
										end
									end
								end 
							end
							if(reset|~enable) begin
								pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] <= 0;
								pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= 0;
							end else begin
								if(pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] < MAX_COUNTS && pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
									pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] <= pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+:RESOLUTION] + tmp_r[(order<MAX_ORDER ?order:MAX_ORDER-1)];
									pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= pulses[((NUM_BASELINES-a)*CORRELATIONS_HEAD_TAIL_SIZE-TAIL_SIZE-c-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] + tmp_i[(order<MAX_ORDER ?order:MAX_ORDER-1)];
								end
							end
						end
					end
				end
			end
		end
	endgenerate

endmodule
