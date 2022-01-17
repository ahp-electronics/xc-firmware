/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module ADC (
		signal,
		data_out,
		done,
		overflow,
		clk,
		enable
	);
	parameter WORD_WIDTH=1;
	parameter MAX_VALUE=(1<<WORD_WIDTH);
	
	output wire overflow;
	output reg[WORD_WIDTH-1:0] data_out;
	reg[WORD_WIDTH-1:0] data_tmp;
	output reg done;
	input wire signal;
	input wire clk;
	input wire enable;
	reg[WORD_WIDTH:0] counter;
	
	assign overflow = (counter == MAX_VALUE);
	
	always @(posedge (clk))
	begin
		if(enable) begin
			if (counter < MAX_VALUE) begin
				if(signal && data_tmp == 0)
					data_tmp <= counter;
				counter <= counter + 1;
				done <= 0;
			end else begin
				done <= 1;
				data_out <= data_tmp;
				counter <= 0;
			end
			if (counter == 0) begin
				done <= 0;
				data_tmp <= 0;
				counter <= counter + 1;
			end
		end else begin
			done <= 0;
			counter <= 0;
		end
	end
		
endmodule
