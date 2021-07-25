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

module ac1 (
	sysclk,
	jp1,
	jp2
	);

parameter PLL_FREQUENCY = 400000000;
parameter CLK_FREQUENCY = 10000000;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 1;
parameter NUM_LINES = 1;
parameter DELAY_SIZE = 2048;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 200;
parameter RESOLUTION = 24;
parameter HAS_LEDS = 1;
parameter HAS_CROSSCORRELATOR = 0;
parameter HAS_PSU = 0;
parameter HAS_CUMULATIVE_ONLY = 1;
parameter BAUD_RATE = 500000;
parameter WORD_WIDTH = 1;
parameter USE_UART = 1;
parameter BINARY = 1;

input wire sysclk;
inout wire[19:0] jp1;
inout wire[19:0] jp2;

wire TX;
wire RX;
wire refclk;
wire enable;
wire extclk;
wire intclk;
wire smpclk;
wire spiclk;
wire external_clock;
wire strobe;

assign extclk = jp1[16];
assign jp1[17] = refclk;
assign jp1[18] = intclk;
assign jp1[19] = smpclk;

assign jp2[16] = strobe;
assign jp2[17] = 0;
assign jp2[18] = TX;
assign RX = jp2[19];

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*4-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

assign line_in[0] = jp1[0];
assign jp1[1] = line_out[0];
assign jp1[2] = line_out[1];
assign jp1[3] = line_out[2];

main #(
.PLL_FREQUENCY(PLL_FREQUENCY),
.CLK_FREQUENCY(CLK_FREQUENCY),
.SIN_FREQUENCY(SIN_FREQUENCY),
.MUX_LINES(MUX_LINES),
.NUM_LINES(NUM_LINES),
.DELAY_SIZE(DELAY_SIZE),
.LAG_CROSS(LAG_CROSS),
.LAG_AUTO(LAG_AUTO),
.RESOLUTION(RESOLUTION),
.HAS_LEDS(HAS_LEDS),
.HAS_CROSSCORRELATOR(HAS_CROSSCORRELATOR),
.HAS_PSU(HAS_PSU),
.HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY),
.BAUD_RATE(BAUD_RATE),
.WORD_WIDTH(WORD_WIDTH),
.USE_UART(USE_UART),
.BINARY(BINARY)
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
	spiclk,
	strobe,
	1'd1
);

endmodule
