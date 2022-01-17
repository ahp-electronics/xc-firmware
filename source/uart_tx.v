/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module uart_tx(
	tx,
	din,
	tx_done,
	tx_start,
	clk
);

parameter SHIFT=0;
parameter STOP_BITS=1;

output reg tx;
input wire [7:0] din;
output reg tx_done;
input wire tx_start;
input wire clk;

wire[3:0] current_bit;
reg [3+SHIFT:0] bit_count = (8+STOP_BITS)<<SHIFT;
assign current_bit = bit_count[SHIFT+:4];

always@(posedge clk) begin
	if(current_bit < 8) begin
		tx_done <= 0;
		tx <= din[current_bit];
		bit_count <= bit_count+1;
	end else if(current_bit <= 8+STOP_BITS) begin
		tx <= 1;
		bit_count <= bit_count+1;
	end else begin
		tx_done <= 1;
		if(tx_start) begin 
			bit_count <= 0;
			tx <= 0;
		end else begin 
			tx <= 1;
		end
	end
end

endmodule
