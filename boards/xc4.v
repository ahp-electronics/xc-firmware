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
parameter NUM_LINES = 4;
parameter DELAY_SIZE = 4;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 1;
parameter RESOLUTION = 8;
parameter HAS_LEDS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter HAS_CUMULATIVE_ONLY = 1;
parameter BAUD_RATE = 57600;
parameter WORD_WIDTH = 1;
parameter USE_UART = 1;
parameter BINARY = 0;
parameter USE_SOFT_CLOCK = 1;
parameter MAX_ORDER = NUM_LINES*MUX_LINES;

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

assign smpclk = intclk;
assign extclk = jp1[16];
assign jp1[17] = refclk;
assign jp1[18] = intclk;
assign jp1[19] = smpclk;

assign strobe = jp2[16];
assign jp2[17] = 1'd0;
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
.MAX_ORDER(MAX_ORDER),
.LOG(LOG)
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
