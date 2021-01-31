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

module xc_firmware (
	TX,
	RX,
	jp1,
	jp2
	);

parameter CLK_FREQUENCY = 13300000;
parameter PLL_MULTIPLIER = 60;
parameter PLL_DIVIDER = 2;
parameter MUX_LINES = 1;

parameter NUM_LINES = 8;
parameter DELAY_SIZE = 150;
parameter RESOLUTION = 16;
parameter HAS_PSU = 0;
parameter HAS_LED_FLAGS = 1;
parameter HAS_CORRELATOR = 1;
parameter MAX_LAG = 1;
parameter HAS_LIVE_SPECTRUM = 0;
parameter HAS_LIVE_CORRELATOR = 0;
parameter BAUD_RATE = 57600;

output wire TX;
input wire RX;

wire clki;
wire clko;

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*3-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

inout wire[19:0] jp1;
inout wire[19:0] jp2;

assign line_in[0] = jp1[14];
assign line_in[1] = jp1[12];
assign line_in[2] = jp1[10];
assign line_in[3] = jp1[8];
assign jp1[15] = line_out[0];
assign jp1[13] = line_out[1];
assign jp1[11] = line_out[2];
assign jp1[9] = line_out[3];
assign jp1[6] = line_out[8];
assign jp1[7] = line_out[9];
assign jp1[4] = line_out[10];
assign jp1[5] = line_out[11];
assign jp1[2] = line_out[12];
assign jp1[3] = line_out[13];
assign jp1[0] = line_out[14];
assign jp1[1] = line_out[15];

assign line_in[4] = jp2[14];
assign line_in[5] = jp2[12];
assign line_in[6] = jp2[10];
assign line_in[7] = jp2[8];
assign jp2[15] = line_out[4];
assign jp2[13] = line_out[5];
assign jp2[11] = line_out[6];
assign jp2[9] = line_out[7];
assign jp2[6] = line_out[16];
assign jp2[7] = line_out[17];
assign jp2[4] = line_out[18];
assign jp2[5] = line_out[19];
assign jp2[2] = line_out[20];
assign jp2[3] = line_out[21];
assign jp2[0] = line_out[22];
assign jp2[1] = line_out[23];

OSCH #(.NOM_FREQ("13.30")) intosc (1'b0, clki, );

main #(.CLK_FREQUENCY(CLK_FREQUENCY), .PLL_MULTIPLIER(PLL_MULTIPLIER), .PLL_DIVIDER(PLL_DIVIDER), .NUM_LINES(NUM_LINES), .MUX_LINES(MUX_LINES), .HAS_CORRELATOR(HAS_CORRELATOR), .HAS_LIVE_SPECTRUM(HAS_LIVE_SPECTRUM), .HAS_LIVE_CORRELATOR(HAS_LIVE_CORRELATOR), .HAS_LED_FLAGS(HAS_LED_FLAGS), .HAS_PSU(HAS_PSU), .RESOLUTION(RESOLUTION), .BAUD_RATE(BAUD_RATE), .DELAY_SIZE(DELAY_SIZE), .MAX_LAG(MAX_LAG)) main_block(
	TX,
	RX,
	line_in,
	line_out,
	mux_out,
	clki,
	clko,
	1'b1
);

endmodule
