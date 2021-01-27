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

module PWM (
		PWM_CW,
		PWM_out,
		overflow,					         
		clk,
		enable
	); 
	parameter RESOLUTION = 10;
	
	input wire[RESOLUTION-1:0] PWM_CW;
	output reg PWM_out;				         
	input wire clk;
	input wire enable;
	
	wire [RESOLUTION-1:0] counter_out;
	output wire overflow;

	COUNTER #(.RESOLUTION(RESOLUTION)) counter(
		~0,
		counter_out,
		overflow,
		1'd1,
		clk,
		overflow|~enable
	);
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
