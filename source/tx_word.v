/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
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
parameter HEADER_NIBBLES=16;

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
reg [7:0] checksum;

always@(posedge TXIF or negedge enable) begin
	if(!enable) begin
		TXREG = 8'h0d;
		tidx = TOTAL_NIBBLES-1;
		done = 0;
		checksum = 0;
	end else if(tidx>=0) begin
		if(BINARY)
			TXREG = tx_data[tidx*8+:8];
		else begin
			if(tx_data[tidx*4+:4] > 4'h9)
				TXREG = 8'h3f + tx_data[tidx*4+:3];
			else
				TXREG = 8'h30 + tx_data[tidx*4+:4];
		end
		if(tidx<TOTAL_NIBBLES-HEADER_NIBBLES)
			checksum = checksum + tx_data[tidx*4+:4];
		tidx = tidx-1;
		done = 0;
	end else if(tidx>=-1) begin
		if(checksum[4+:4] > 4'h9)
			TXREG = 8'h3f + checksum[4+:3];
		else
			TXREG = 8'h30 + checksum[4+:4];
		tidx = tidx-1;
		done = 0;
	end else if(tidx>=-2) begin
		if(checksum[0+:4] > 4'h9)
			TXREG = 8'h3f + checksum[0+:3];
		else
			TXREG = 8'h30 + checksum[0+:4];
		tidx = tidx-1;
		done = 0;
	end else begin
		TXREG = 8'h0d;
		tidx = TOTAL_NIBBLES-1;
		done = 1;
		checksum = 0;
	end
end
endmodule
