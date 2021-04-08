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

parameter CLK_FREQUENCY = 1000000;
parameter PWM_FREQUENCY = 100000;
parameter SIN_FREQUENCY = 1000;
parameter BAUD_RATE = 1000000;
parameter MUX_LINES = 1;
parameter NUM_LINES = 1;
parameter DELAY_SIZE = 1024;
parameter RESOLUTION = 4;
parameter HAS_PSU = 1;
parameter HAS_LED_FLAGS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter WORD_WIDTH = 1;
parameter MAX_CPS = 2500000;

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
 
main #(.CLK_FREQUENCY(CLK_FREQUENCY), .PWM_FREQUENCY(PWM_FREQUENCY), .SIN_FREQUENCY(SIN_FREQUENCY), .NUM_LINES(NUM_LINES), .MUX_LINES(MUX_LINES), .HAS_CROSSCORRELATOR(HAS_CROSSCORRELATOR), .HAS_LED_FLAGS(HAS_LED_FLAGS), .HAS_PSU(HAS_PSU), .RESOLUTION(RESOLUTION), .BAUD_RATE(BAUD_RATE), .DELAY_SIZE(DELAY_SIZE), .MAX_CPS(MAX_CPS)) main_block(
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
	external_clock,
	strobe,
	1
);

endmodule
