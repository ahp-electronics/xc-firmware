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
parameter MUX_LINES = _MUX_LINES;
parameter NUM_LINES = _NUM_LINES;
parameter DELAY_SIZE = _DELAY_SIZE;
parameter LAG_CROSS = _LAG_CROSS;
parameter LAG_AUTO = _LAG_AUTO;
parameter RESOLUTION = _RESOLUTION;
parameter HAS_LEDS = _HAS_LEDS;
parameter HAS_CROSSCORRELATOR = _HAS_CROSSCORRELATOR;
parameter HAS_PSU = _HAS_PSU;
parameter HAS_CUMULATIVE_ONLY = _HAS_CUMULATIVE_ONLY;
parameter BAUD_RATE = 57600;
parameter WORD_WIDTH = _WORD_WIDTH;
parameter USE_UART = _USE_UART;
parameter BINARY = _BINARY;
parameter USE_SOFT_CLOCK = _USE_SOFT_CLOCK;
parameter MAX_ORDER = _MAX_ORDER;
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
assign jp1[17] = intclk;
assign strobe = jp1[18];
assign jp1[19] = smpclk;

assign jp2[16] = refclk;
assign jp2[17] = 1'd0;
assign jp2[18] = TX;
assign RX = jp2[19];

wire[NUM_LINES-1:0] line_in;
wire[NUM_LINES*4-1:0] line_out;
wire[MUX_LINES-1:0] mux_out;

assign line_in[0+:NUM_LINES/2] = jp1[15:0];
assign line_in[NUM_LINES/2+:NUM_LINES/2] = jp2[15:0];

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
.USE_SOFT_CLOCK(USE_SOFT_CLOCK),
.BINARY(BINARY),
.USE_UART(USE_UART),
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
       smpclk,
       ,
       strobe,
       1'd1
);

endmodule
