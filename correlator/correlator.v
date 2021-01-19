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
	sh_reset,
	mux_out,
	line_in,
	line_out,
	integration_clk_pulse,
	sampling_clk,
	out_line,
	clki,
	enable
	);

parameter SECOND = 1000000000;
parameter MUX_LINES = 4;
parameter NUM_LINES = 2;
parameter CLK_FREQUENCY = 10000000;
parameter PLL_FREQUENCY = 400000000;
parameter TICK_FREQUENCY = (PLL_FREQUENCY/(1+MUX_LINES));
parameter BAUD_RATE = 57600;
   
parameter HAS_LIVE_SPECTRUM = 1;
parameter HAS_LIVE_CORRELATOR = 0;
parameter HAS_CORRELATOR = 1;
parameter HAS_LED_FLAGS = 1;
parameter JITTER_SIZE = 150;
parameter DELAY_SIZE = 150;
parameter RESOLUTION = 20;
parameter NUM_INPUTS = NUM_LINES*MUX_LINES;
parameter NUM_CORRELATORS = NUM_INPUTS*(NUM_INPUTS-1)/2;

output reg sh_reset; 
output reg[NUM_LINES*2-1:0] out_line;
output reg[MUX_LINES:0] mux_out;
input wire[NUM_LINES-1:0] line_in;
output reg[NUM_LINES-1:0] line_out;
output wire sampling_clk;
input wire enable;
input wire clki;
output wire TX;
input wire RX;
reg[NUM_INPUTS-1:0] pulse_in;
wire[NUM_INPUTS-1:0] pulse_out;
output wire integration_clk_pulse;
wire[NUM_INPUTS*2-1:0] active_line;
wire[NUM_INPUTS*4-1:0] active_leds;
wire[NUM_INPUTS-1:0] voltage;
wire clk;
wire integrating;
wire pll_clk;
wire[NUM_INPUTS-1:0] overflow;
wire [NUM_INPUTS-1:0] pwm_out;
reg index = 0;
reg [31:0] x = 0;

always@(posedge pll_clk) begin
	if(index >= 0 && index < MUX_LINES) begin
		sh_reset <= 0;
		mux_out <= 1<<index;
		index <= index+1;
		for (x = 0; x < NUM_LINES; x=x+1) begin
			pulse_in[index*NUM_LINES+x] <= line_in[x];
			line_out[x] <= pulse_out[index*NUM_LINES+x];
			out_line[x*2+:2] <= active_line[(index*NUM_LINES+x)*2+:2];
		end
	end else if(index == MUX_LINES) begin
		sh_reset <= 1;
		mux_out <= 0;
		index <= 0;
	end
end

generate 
	genvar a;
	for(a=0; a<NUM_INPUTS; a=a+1) begin
		assign active_line[a*2] = active_leds[a*4];
		assign active_line[a*2+1] = active_leds[a*4+1]&voltage[a];
	end
endgenerate

main #(.CLK_FREQUENCY(CLK_FREQUENCY), .TICK_FREQUENCY(TICK_FREQUENCY), .HAS_CORRELATOR(HAS_CORRELATOR), .HAS_LIVE_SPECTRUM(HAS_LIVE_SPECTRUM), .HAS_LIVE_CORRELATOR(HAS_LIVE_CORRELATOR), .HAS_LED_FLAGS(HAS_LED_FLAGS), .PLL_FREQUENCY(PLL_FREQUENCY), .RESOLUTION(RESOLUTION), .NUM_INPUTS(NUM_INPUTS), .BAUD_RATE(BAUD_RATE), .DELAY_SIZE(DELAY_SIZE), .JITTER_SIZE(JITTER_SIZE)) main_block(
	TX,
	RX,
	voltage,
	pulse_in,
	overflow,
	pll_clk,
	clk,
	clki,
	integration_clk_pulse,
	sampling_clk,
	integrating,
	active_leds,
	enable
);

pll pll_block (clki, pll_clk);
pwm_osc #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(10000), .RESOLUTION(8), .CHANNELS(8)) osc (
	pwm_out,
	clki,
	integrating
);
assign pulse_out = pwm_out&~overflow;

endmodule
