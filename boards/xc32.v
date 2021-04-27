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

parameter PLL_FREQUENCY = 400000000;
parameter CLK_FREQUENCY = 10000000;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 8;
parameter NUM_LINES = 4;
parameter DELAY_SIZE = 150;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 1;
parameter RESOLUTION = 16;
parameter HAS_LEDS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter HAS_CUMULATIVE_ONLY = 1;
parameter BAUD_RATE = 500000;
parameter WORD_WIDTH = 1;
parameter USE_UART = 0;

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
wire strobe;

assign extclk = jp1[16];
assign jp1[17] = refclk;
assign jp1[18] = intclk;
assign jp1[19] = smpclk;

assign enable = jp2[16];
assign spiclk = jp2[17];
assign jp2[18] = TX;
assign RX = jp2[19];

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*4-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

assign line_in[0] = jp1[15];
assign line_in[1] = jp1[13];
assign line_in[2] = jp1[11];
assign line_in[3] = jp1[9];
assign jp1[14] = line_out[0];
assign jp1[12] = line_out[1];
assign jp1[10] = line_out[2];
assign jp1[8] = line_out[3];
assign jp1[6] = line_out[16];
assign jp1[4] = line_out[17];
assign jp1[2] = line_out[18];
assign jp1[0] = line_out[19];
assign jp1[7] = line_out[24];
assign jp1[5] = line_out[25];
assign jp1[3] = line_out[26];
assign jp1[1] = line_out[27];

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
.HAS_LEDS(HAS_LEDS),
.HAS_CROSSCORRELATOR(HAS_CROSSCORRELATOR),
.HAS_PSU(HAS_PSU),
.HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY),
.LAG_CROSS(LAG_CROSS),
.LAG_AUTO(LAG_AUTO),
.WORD_WIDTH(WORD_WIDTH),
.BAUD_RATE(BAUD_RATE),
.USE_UART(USE_UART)
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
        enable
);

endmodule
