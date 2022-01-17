/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module PWM (
		PWM_CW,
		PWM_out,				         
		clk,
		enable
	); 
	parameter RESOLUTION = 10;
	
	parameter MAX_CW = (1<<RESOLUTION)-1;
	input wire[RESOLUTION-1:0] PWM_CW;
	output reg PWM_out;				         
	input wire clk;
	input wire enable;
	
	reg [RESOLUTION-1:0] counter_out;

	always @ (posedge clk)
	begin
		counter_out <= counter_out+1;
	end
	
	always @ (*)
	begin
		if(enable) begin
			if(counter_out >= PWM_CW) begin
				PWM_out <= 0;
			end else begin
				PWM_out <= 1;
			end
		end
	end
endmodule
