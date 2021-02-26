/*
    AHP XC - a multiline spectrograph and cross-correlator
    Copyright (C) 2020  Ilia Platone

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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
