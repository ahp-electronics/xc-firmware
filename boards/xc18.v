/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module top_module (
	sysclk,
	jp1,
	jp2
	);

parameter PLL_FREQUENCY = 400000000;
parameter CLK_FREQUENCY = 10000000;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 1;
parameter NUM_LINES = 18;
parameter DELAY_SIZE = 0;
parameter RESOLUTION = 8;
parameter HAS_LEDS = 0;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter HAS_CUMULATIVE_ONLY = 0;
parameter BAUD_RATE = 2000000;
parameter WORD_WIDTH = 1;
parameter USE_UART = 1;
parameter BINARY = 0;
parameter USE_SOFT_CLOCK = 1;
parameter MAX_ORDER = MUX_LINES*NUM_LINES;

input wire sysclk;
inout wire[19:0] jp2;
inout wire[19:0] jp1;
 
wire TX;
wire RX;
wire refclk;
wire enable;
wire extclk;
wire intclk;
wire smpclk;
wire strobe;

assign smpclk = intclk;
assign extclk = jp2[16];
assign jp2[17] = intclk;
assign strobe = jp2[18];
assign jp2[19] = smpclk;

assign jp1[16] = refclk;
assign jp1[17] = 1'd0;
assign jp1[18] = TX;
assign RX = jp1[19];

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*4-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

assign line_in[4] = jp1[0];
assign line_in[7] = jp1[1];
assign line_in[12] = jp1[2];
assign line_in[15] = jp1[3];
assign line_in[20] = jp1[4];
assign line_in[23] = jp1[5];
assign line_in[28] = jp1[6];
assign line_in[31] = jp1[7];
assign line_in[5] = jp1[8];
assign line_in[6] = jp1[9];
assign line_in[13] = jp1[10];
assign line_in[14] = jp1[11];
assign line_in[21] = jp1[12];
assign line_in[22] = jp1[13];
assign line_in[29] = jp1[14];
assign line_in[30] = jp1[15];

assign line_in[0] = jp2[0];
assign line_in[3] = jp2[1];
assign line_in[8] = jp2[2];
assign line_in[11] = jp2[3];
assign line_in[16] = jp2[4];
assign line_in[19] = jp2[5];
assign line_in[24] = jp2[6];
assign line_in[27] = jp2[7];
assign line_in[1] = jp2[8];
assign line_in[2] = jp2[9];
assign line_in[9] = jp2[10];
assign line_in[10] = jp2[11];
assign line_in[17] = jp2[12];
assign line_in[18] = jp2[13];
assign line_in[25] = jp2[14];
assign line_in[26] = jp2[15];

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
.WORD_WIDTH(WORD_WIDTH),
.BAUD_RATE(BAUD_RATE),
.USE_SOFT_CLOCK(USE_SOFT_CLOCK),
.BINARY(BINARY),
.MAX_ORDER(MAX_ORDER)
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
       ,
       ,
       strobe,
       1'd1
);

endmodule
