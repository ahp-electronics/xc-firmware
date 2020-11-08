/*
    AHP Interferometer - a telescope array firmware
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

module main (
	TX,
	RX,
	signal_in,
	overflow_out,
	pll_clk,
	clk,
	clki,
	integration_clk,
	integrating,
	leds
);

parameter SECOND = 1000000000;
parameter CLK_FREQUENCY = 50000000;
parameter PLL_FREQUENCY = 400000000;
parameter TICK_FREQUENCY = 200000000;

parameter BAUD_RATE = 57600;
parameter SHIFT = 1;
parameter DELAY_SIZE = 200;
parameter RESOLUTION = 24;
parameter NUM_INPUTS = 8;
parameter NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
parameter[127:0] UNIT = (SECOND<<63)/TICK_FREQUENCY;

parameter CORRELATIONS_SIZE = NUM_BASELINES;
parameter PAYLOAD_SIZE = (CORRELATIONS_SIZE+NUM_INPUTS+NUM_INPUTS)*RESOLUTION;
parameter HEADER_SIZE = 64;
parameter PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

parameter BAUD_TIME = SECOND/BAUD_RATE;

parameter MAX_COUNT=(1<<RESOLUTION);
parameter TOTAL_NIBBLES=NUM_BASELINES*RESOLUTION/4;

output wire TX;
input wire RX;
input wire[NUM_INPUTS-1:0] signal_in;
output reg[NUM_INPUTS-1:0] overflow_out;
input wire pll_clk;
input wire clki;
output wire clk;
output wire integration_clk;
output reg[NUM_INPUTS*4-1:0] leds;
wire [NUM_INPUTS-1:0] overflow;
output reg integrating = 0;

wire[NUM_INPUTS-1:0] pulse_in;
wire[NUM_INPUTS-1:0] in;
wire clk_pulse;
wire [7:0] RXREG;
wire RXIF;
wire [PAYLOAD_SIZE-1:0] pulse_t;
reg [PACKET_SIZE-1:0] tx_data;
wire [NUM_INPUTS-1:0] delay_lines [0:DELAY_SIZE-1];
reg [11:0] cross [0:NUM_INPUTS-1];
reg [11:0] auto [0:NUM_INPUTS-1];
reg [11:0] cross_tmp [0:NUM_INPUTS-1];
reg [11:0] auto_tmp [0:NUM_INPUTS-1];
wire uart_clk;
wire uart_clk_pulse;

reg [7:0] index = 0;
reg [3:0] baud_rate = 0;
reg [5:0] clock_divider = 0;

delay1 #(.RESOLUTION(NUM_INPUTS)) delay(clk, signal_in, in);
assign pulse_in = ~in&signal_in;

CLK_GEN #(.CLK_FREQUENCY(PLL_FREQUENCY), .RESOLUTION(128)) divider_block(
	(UNIT>>(63-clock_divider)),
	clk,
	pll_clk,
	clk_pulse,
	1'b1
);

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY)) uart_clock_block(
	BAUD_TIME>>baud_rate,
	uart_clk,
	clki,
	uart_clk_pulse,
	1'b1
);

TX_WORD #(.SHIFT(SHIFT), .RESOLUTION(PACKET_SIZE)) tx_block(
	TX,
	tx_data,
	uart_clk_pulse,
	clk_pulse,
	integration_clk,
	integrating
);
 
wire reset_delayed;
delay1 reset_delay(clk, integration_clk, reset_delayed);
integer k;

always@(posedge integration_clk) begin
	overflow_out <= overflow;
	tx_data[0+:PAYLOAD_SIZE] <= pulse_t;
	tx_data[PAYLOAD_SIZE+:32] <= TICK_FREQUENCY;
	tx_data[PAYLOAD_SIZE+32+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+32+12+:12] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+32+12+12+:8] <= RESOLUTION;
end

uart_rx #(.SHIFT(SHIFT)) rx_block(
	RX,
	RXREG,
	RXIF,
	uart_clk_pulse
);

parameter[3:0]
	CLEAR = 0,
	SET_INDEX = 1,
	SET_LEDS = 2,
	SET_BAUD_RATE = 3,
	SET_DELAY = 4,
	SET_FREQ_DIV = 8,
	ENABLE_CAPTURE = 13;
	
always@(posedge RXIF) begin
	if (RXREG[3:0] == CLEAR) begin
		cross[index] <= 0;
		auto[index] <= 0;
	end else if (RXREG[3:0] == ENABLE_CAPTURE) begin
		integrating <= RXREG[4];
	end else if (RXREG[3:0] == SET_INDEX) begin
		index[RXREG[7:6]*2+:2] <= RXREG[5:4];
	end else if (RXREG[3:0] == SET_LEDS) begin
		leds[index*4+:4] <= RXREG[7:4];
	end else if (RXREG[3:0] == SET_BAUD_RATE) begin
		baud_rate <= RXREG[7:4];
	end else if (RXREG[2]) begin
		if (RXREG[7])
			auto_tmp [index][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
		else
			cross_tmp [index][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
		auto[index] <= (auto_tmp [index] < DELAY_SIZE ? auto_tmp [index] : DELAY_SIZE-1);
		cross[index] <= (cross_tmp [index] < DELAY_SIZE ? cross_tmp [index] : DELAY_SIZE-1);
	end else if (RXREG[3])  begin
		clock_divider <= (RXREG[1:0]<<4)|RXREG[7:4];
	end
end

assign delay_lines[0] = pulse_in;
generate
	genvar a;
	genvar b;
	genvar c;

	for(c=1; c<DELAY_SIZE; c=c+1) begin : delay_iteration_block
		delay1 #(.RESOLUTION(NUM_INPUTS)) delay_line(clk, delay_lines[c-1], delay_lines[c]);
	end
	for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
		COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
			(1<<RESOLUTION)-1,
			pulse_t[RESOLUTION*(CORRELATIONS_SIZE+NUM_INPUTS+a)+:RESOLUTION],
			overflow[a],
			delay_lines[0][a],
			reset_delayed
		);
		COUNTER #(.RESOLUTION(RESOLUTION)) spectra_block (
			(1<<RESOLUTION)-1,
			pulse_t[RESOLUTION*(CORRELATIONS_SIZE+a)+:RESOLUTION],
			,
			delay_lines[0][a]&delay_lines[auto[a]][a],
			reset_delayed
		);
		for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
			COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
				(1<<RESOLUTION)-1,
				pulse_t[(((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*RESOLUTION+:RESOLUTION],
				,
				delay_lines[cross[a]][a]&delay_lines[cross[b]][b],
				reset_delayed
			);
		end
	end
endgenerate

endmodule
