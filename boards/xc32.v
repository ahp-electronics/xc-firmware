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
	sysclk,
	jp1,
	jp2 
	);
	
parameter CLK_FREQUENCY = 10000000;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 8;
parameter NUM_LINES = 4;
parameter DELAY_SIZE = 128;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 1;
parameter RESOLUTION = 24;
parameter HAS_LED_FLAGS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter BAUD_RATE = 57600;
parameter WORD_WIDTH = 1;

input wire sysclk;
inout wire[19:0] jp1;
inout wire[19:0] jp2;

wire TX;
wire RX;
wire clko;
wire enable;
wire clke;
wire clk;
wire integration_clk;
wire sampling_clk;
wire external_clock;
wire integrating;

assign clke = jp1[16];
assign jp1[17] = clko;
assign jp1[18] = integration_clk;
assign jp1[19] = sampling_clk;

assign jp2[16] = integrating;
assign enable = jp2[17];
assign jp2[18] = TX;
assign RX = jp2[19];

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*4-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

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

assign jp2[0] = mux_out[0];
assign jp2[1] = mux_out[1];
assign jp2[2] = mux_out[2];
assign jp2[3] = mux_out[3];
assign jp2[4] = mux_out[4];
assign jp2[5] = mux_out[5];
assign jp2[6] = mux_out[6];
assign jp2[7] = mux_out[7];

main #(
.CLK_FREQUENCY(CLK_FREQUENCY),
.SIN_FREQUENCY(SIN_FREQUENCY),
.RESOLUTION(RESOLUTION),
.MUX_LINES(MUX_LINES),
.NUM_LINES(NUM_LINES),
.DELAY_SIZE(DELAY_SIZE),
.HAS_LED_FLAGS(HAS_LED_FLAGS),
.HAS_CROSSCORRELATOR(HAS_CROSSCORRELATOR),
.HAS_PSU(HAS_PSU),
.LAG_CROSS(LAG_CROSS),
.LAG_AUTO(LAG_AUTO),
.WORD_WIDTH(WORD_WIDTH),
.BAUD_RATE(BAUD_RATE)
) main_block(
	TX,
	RX,
	line_in,
	line_out,
	mux_out,
	sysclk,
	refclk,
	extclk,
	intclk,
	smpclk,
	strobe,
	1'd1
);

endmodule
