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

module TX_WORD(
	TX,
	tx_data,
	clk,
	stb,
	tx_done,
	enable
	);

parameter SHIFT=4;
parameter RESOLUTION=32;
parameter TOTAL_NIBBLES=RESOLUTION/4;

output wire TX;
input wire [RESOLUTION-1:0] tx_data;
input wire enable;
input wire stb;
output wire tx_done;
input wire clk;

reg done;
assign tx_done = done;
reg signed [31:0] tidx;
wire TXIF;
reg [7:0] TXREG;

uart_tx #(.SHIFT(SHIFT)) tx_block(
	TX,
	TXREG,
	TXIF,
	enable,
	clk
);
	
always@(posedge TXIF or negedge enable) begin
	if(!enable) begin
		TXREG <= 8'h0d;
		tidx <= TOTAL_NIBBLES-1;
		done <= 0;
	end else if(tidx>=0) begin
		if(tx_data[tidx*4+:4] > 4'h9)
			TXREG <= 8'h3f + tx_data[tidx*4+:3];
		else
			TXREG <= 8'h30 + tx_data[tidx*4+:4];
		tidx <= tidx-1;
		done <= 0;
	end else begin
		TXREG <= 8'h0d;
		tidx <= TOTAL_NIBBLES-1;
		done <= 1;
	end
end
endmodule
