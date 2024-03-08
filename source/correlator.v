/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 *
 * Many thanks to an unknown genius that helped me on the indicization formula ... I never saw her... love
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
	parameter DELAY_SIZE=4;
	parameter TAIL_SIZE=1;
	parameter HEAD_SIZE=0;
	parameter NUM_BASELINES=8;
	parameter DELAY_LAG=1;
	parameter RESOLUTION=24;
	parameter WORD_WIDTH=1;
	parameter USE_SOFT_CLOCK=0;
	parameter MAX_ORDER=2;
	
	localparam SHANNON=(DELAY_SIZE == 4);
	localparam SINGLE=(DELAY_SIZE == 0);
	localparam SHANNON_OR_SINGLE=(SHANNON|SINGLE);
	localparam MAX_COUNTS=(((1<<RESOLUTION)-1)-((1<<WORD_WIDTH)-1));
	localparam FIFO_SIZE=(SHANNON_OR_SINGLE ? 4 : DELAY_SIZE);

	localparam DELAY_SIZE_LEN = SHANNON_OR_SINGLE ? 24 : (($clog2(DELAY_SIZE) & ~3) + 4);
	localparam NUM_INPUTS_LEN = (($clog2(NUM_INPUTS) & ~3) + 4);

	output reg signed [NUM_BASELINES*RESOLUTION*2-1:0] pulses;
	input wire enable;
	input wire reset;
	input wire clk;
	input wire [NUM_INPUTS_LEN:0] order;
	input wire [WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
	input wire [DELAY_SIZE_LEN*NUM_INPUTS-1:0] delay_arr;
	input wire [NUM_INPUTS-1:0] sampling_clk;
	input wire [NUM_INPUTS*8-1:0] led_lines;

	wire [WORD_WIDTH*NUM_INPUTS-1:0] tmp_data;
	reg [WORD_WIDTH*NUM_INPUTS-1:0] tmp_data_a;

	wire [WORD_WIDTH*FIFO_SIZE-1:0] delay_lines [0:NUM_INPUTS];
	wire [DELAY_SIZE_LEN-1:0] delay [0:NUM_INPUTS];

	wire [WORD_WIDTH-1:0] adc_data [0:NUM_INPUTS];
	wire[7:0] leds[0:NUM_INPUTS];
			
	generate 
		genvar line;
		genvar a;
		genvar _a;
		genvar c;
		genvar _c;
		for (line=0; line < NUM_INPUTS; line=line+1) begin
			reg tmp_clk;
			assign tmp_data[line*WORD_WIDTH+:WORD_WIDTH] = tmp_data_a[line*WORD_WIDTH+:WORD_WIDTH];
			always @(posedge clk) begin 
				if(tmp_clk != sampling_clk[line]) begin
					tmp_clk <= sampling_clk[line];
					tmp_data_a[line*WORD_WIDTH+:WORD_WIDTH] <= adc_data_a[line*WORD_WIDTH+:WORD_WIDTH]; 
				end 
			end
			fifo #(.USE_SOFT_CLOCK(USE_SOFT_CLOCK), .WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(FIFO_SIZE)) delay_line(clk, tmp_clk, tmp_data[line*WORD_WIDTH+:WORD_WIDTH], delay_lines[line]);
			assign leds[line]=led_lines[line*8+:8];
			assign delay[line]=delay_arr[line*DELAY_SIZE_LEN+:(SHANNON_OR_SINGLE ? DELAY_SIZE_LEN : (DELAY_SIZE_LEN >> 1))];
		end
		
		for (_a=0; _a < NUM_BASELINES; _a=_a+512) begin
			for (a=_a; a<_a+512 && a < NUM_BASELINES; a=a+1) begin
				always @(posedge clk) begin : correlator_block
					reg[MAX_ORDER-1:0] multiply;
					reg signed [WORD_WIDTH<<(MAX_ORDER<<2):0] tmp_i[0:MAX_ORDER];
					reg signed [WORD_WIDTH<<(MAX_ORDER<<2):0] tmp_q[0:MAX_ORDER];
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
								if(SHANNON) begin
									if(multiply[order]) begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[a % NUM_INPUTS][3*WORD_WIDTH+:WORD_WIDTH]};
									end else begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[a % NUM_INPUTS][3*WORD_WIDTH+:WORD_WIDTH]};
									end
								end else if(SINGLE) begin
									if(multiply[order]) begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, ~delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
									end else begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, ~delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[a % NUM_INPUTS][1*WORD_WIDTH+:WORD_WIDTH]};
									end
								end else begin
									if(multiply[order]) begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[a % NUM_INPUTS][(delay[a % NUM_INPUTS]>>1)*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[a % NUM_INPUTS][delay[a % NUM_INPUTS]*WORD_WIDTH+:WORD_WIDTH]};
									end else begin
										tmp_i[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[a % NUM_INPUTS][(delay[a % NUM_INPUTS]>>1)*WORD_WIDTH+:WORD_WIDTH]};
										tmp_q[d] <= {1'd0, delay_lines[a % NUM_INPUTS][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[a % NUM_INPUTS][delay[a % NUM_INPUTS]*WORD_WIDTH+:WORD_WIDTH]};
									end
								end
							end else begin
								if(SHANNON) begin
									if(multiply[order]) begin
										tmp_i[d] <= tmp_i[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][3*WORD_WIDTH+:WORD_WIDTH]});
									end else begin
										tmp_i[d] <= tmp_i[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][3*WORD_WIDTH+:WORD_WIDTH]});
									end
								end else if(SINGLE) begin
									if(multiply[order]) begin
										tmp_i[d] <= tmp_i[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, ~delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
									end else begin
										tmp_i[d] <= tmp_i[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, ~delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[(((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS))][1*WORD_WIDTH+:WORD_WIDTH]});
									end
								end else begin
									if(multiply[order]) begin
										tmp_i[d] <= tmp_i[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][((delay[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)])>>1)*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] * ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} * {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)])*WORD_WIDTH+:WORD_WIDTH]});
									end else begin
										tmp_i[d] <= tmp_i[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][((delay[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)])>>1)*WORD_WIDTH+:WORD_WIDTH]});
										tmp_q[d] <= tmp_q[d-1] - ({1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][0*WORD_WIDTH+:WORD_WIDTH]} - {1'd0, delay_lines[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)][(delay[((a + d * ((a / NUM_INPUTS) + 1)) % NUM_INPUTS)])*WORD_WIDTH+:WORD_WIDTH]});
									end
								end 
							end
						end 
					end
					if(reset|~enable) begin
						pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+:RESOLUTION] <= 0;
						pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= 0;
					end else begin
						if(pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+:RESOLUTION] < MAX_COUNTS && pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] < MAX_COUNTS) begin
							pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+:RESOLUTION] <= pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+:RESOLUTION] + tmp_i[(order < MAX_ORDER ? order : MAX_ORDER-1)];
							pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] <= pulses[(NUM_BASELINES-a-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION] + tmp_q[(order < MAX_ORDER ? order : MAX_ORDER-1)];
						end
					end
				end
			end
		end
	endgenerate
endmodule
