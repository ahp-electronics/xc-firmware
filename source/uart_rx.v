/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
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
