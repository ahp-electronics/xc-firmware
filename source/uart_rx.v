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

module uart_rx(
	rx,
	dout,
	rx_done,
	clk
);

parameter SHIFT=1;
parameter STOP_BITS=1;

input wire rx;
output reg [7:0] dout;
output reg rx_done;
input wire clk;
reg [7+STOP_BITS:0] RXREG;
reg stop_bits;

wire[3:0] current_bit;
reg [3+SHIFT:0] bit_count = (7+STOP_BITS)<<SHIFT;
assign current_bit = bit_count[SHIFT+:4];

always@(posedge clk) begin
	if(current_bit < 8) begin
		dout[current_bit] <= rx;
		bit_count <= bit_count + 1;
	end else if(current_bit <= 8+STOP_BITS) begin
		rx_done <= rx;
		bit_count <= bit_count + 1;
	end else begin
		if(!rx) begin
			stop_bits <= 1;
			bit_count <= 0;
			dout <= 0;
			rx_done <= 0;
		end
	end
end

endmodule
