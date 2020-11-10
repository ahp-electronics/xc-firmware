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

module correlator (
	TX,
	RX,
	pulse_in,
	pulse_out,
	integration_clk_pulse,
	active_line,
	clki
	);

parameter SECOND = 1000000000;
parameter CLK_FREQUENCY = 50000000;
parameter PLL_FREQUENCY = 400000000;

parameter BAUD_RATE = 57600;

parameter JITTER_SIZE = 1;
parameter DELAY_SIZE = 128;
parameter RESOLUTION = 24;
parameter NUM_INPUTS = 8;
parameter NUM_CORRELATORS = NUM_INPUTS*(NUM_INPUTS-1)/2;

input wire clki;
output wire TX;
input wire RX;
input wire[NUM_INPUTS-1:0] pulse_in;
output wire[NUM_INPUTS-1:0] pulse_out;
output wire[NUM_INPUTS-1:0] leds;
output wire integration_clk_pulse;
output wire[NUM_INPUTS*2-1:0] active_line;
wire[NUM_INPUTS*4-1:0] active_leds;
wire clk;
wire integrating;
wire pll_clk;
wire[NUM_INPUTS-1:0] overflow;
wire[NUM_INPUTS-1:0] in_line;

generate
	genvar a;
	for(a=0; a<NUM_INPUTS; a=a+1) begin
		assign active_line[a*2+:2] = active_leds[a*4+:2];
		assign in_line[a] = active_leds[a*4+2]^~pulse_in[a];
	end
endgenerate

main #(.CLK_FREQUENCY(CLK_FREQUENCY), .PLL_FREQUENCY(PLL_FREQUENCY), .BAUD_RATE(BAUD_RATE), .RESOLUTION(RESOLUTION), .NUM_INPUTS(NUM_INPUTS), .BAUD_RATE(BAUD_RATE), .DELAY_SIZE(DELAY_SIZE), .JITTER_SIZE(JITTER_SIZE)) main_block(
	TX,
	RX,
	in_line,
	overflow,
	pll_clk,
	clk,
	clki,
	integration_clk_pulse,
	integrating,
	active_leds
);

pll pll_block (clki, pll_clk);

pwm_osc #(.RESOLUTION(8), .DIVIDER(75), .CHANNELS(NUM_INPUTS)) osc (
	pwm_out,
	clki,
	integrating
);

wire [NUM_INPUTS-1:0] pwm_out;
assign pulse_out = pwm_out&~overflow;

endmodule
