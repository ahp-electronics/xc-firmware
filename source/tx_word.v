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
	TXREG,
	TXIF,
	tx_data,
	tx_done,
	enable
	);
parameter BINARY = 0;
parameter RESOLUTION=32;

localparam WORD_WIDTH=4+4*BINARY;
localparam TOTAL_NIBBLES=RESOLUTION/WORD_WIDTH;

input wire TXIF;
output reg [7:0] TXREG;
input wire [RESOLUTION-1:0] tx_data;
output wire tx_done;
input wire enable;

reg done;
assign tx_done = done;
reg signed [31:0] tidx;

always@(posedge TXIF or negedge enable) begin
	if(!enable) begin
		TXREG <= 8'h0d;
		tidx <= TOTAL_NIBBLES-1;
		done <= 0;
	end else if(tidx>=0) begin
		if(BINARY)
			TXREG <= tx_data[tidx*8+:8];
		else begin
			if(tx_data[tidx*4+:4] > 4'h9)
				TXREG <= 8'h3f + tx_data[tidx*4+:3];
			else
				TXREG <= 8'h30 + tx_data[tidx*4+:4];
		end
		tidx <= tidx-1;
		done <= 0;
	end else begin
		TXREG <= 8'h0d;
		tidx <= TOTAL_NIBBLES-1;
		done <= 1;
	end
end
endmodule
