/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module indicators (
	pwm_out,
	clk,
	enable
	);
parameter CLK_FREQUENCY = 14000000;
parameter CYCLE_MS = 10000;
parameter CHANNELS = 8;
parameter RESOLUTION = 8;

parameter MAX_VALUE = (1<<RESOLUTION)-1;
parameter DIVIDER = CLK_FREQUENCY/2000000;
parameter CYCLE = (CYCLE_MS<<9)>>RESOLUTION;
parameter OFFSET = 1<<(RESOLUTION-2);

input wire clk;
output wire[CHANNELS-1:0] pwm_out;
input wire enable;
reg pwm_clk;
reg[RESOLUTION:0] pwm_idx = OFFSET;
reg[31:0] index1;
reg[31:0] index2;
wire[RESOLUTION-1:0] pwm_value[0:CHANNELS];
wire[RESOLUTION:0] idx_value[0:CHANNELS];

always@(posedge clk) begin
	index1 <= index1+1;
	if(index1 >= DIVIDER) begin
		pwm_clk <= ~pwm_clk;
		index1 <= 0;
	end
end

always@(posedge pwm_clk) begin
	if(enable)
		index2 <= index2+1;
	if(index2 >= CYCLE) begin
		pwm_idx <= pwm_idx-1;
		index2 <= 0;
	end
end

generate
	genvar i;
	for(i = 0; i < CHANNELS; i=i+1) begin
		assign idx_value[i] = (pwm_idx+OFFSET*i)%((MAX_VALUE<<1)-2);
		assign pwm_value[i] = (idx_value[i] > MAX_VALUE) ? ((MAX_VALUE<<1)-2)-idx_value[i] : idx_value[i];
		PWM #(.RESOLUTION(RESOLUTION)) pwm(
			pwm_value[i],
			pwm_out[i],
			pwm_clk,
			1'b1
		);
	end
endgenerate

endmodule
