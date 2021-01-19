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

module main (
	TX,
	RX,
	voltage,
	signal_in,
	overflow_out,
	pll_clk,
	clk,
	clki,
	integration_clk,
	sampling_clk,
	integrating,
	leds,
	enable
);

parameter SECOND = 1000000000;
parameter CLK_FREQUENCY = 50000000;
parameter PLL_FREQUENCY = 400000000;
parameter TICK_FREQUENCY = 200000000;

parameter BAUD_RATE = 57600;
parameter DELAY_SIZE = 150;
parameter HAS_CORRELATOR = 1;
parameter HAS_LIVE_SPECTRUM = 1;
parameter HAS_LIVE_CORRELATOR = 1;
parameter HAS_LED_FLAGS = 1;
parameter JITTER_SIZE = 1;
parameter RESOLUTION = 24;
parameter NUM_INPUTS = 8;
parameter NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
parameter[127:0] UNIT = (SECOND<<63)/TICK_FREQUENCY;
parameter[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
parameter SHIFT = 1;

parameter CORRELATIONS_JITTER_SIZE = (HAS_LIVE_CORRELATOR?JITTER_SIZE:1);
parameter SPECTRA_JITTER_SIZE = (HAS_LIVE_SPECTRUM?JITTER_SIZE:1);
parameter CORRELATIONS_SIZE = (HAS_CORRELATOR ? NUM_BASELINES*(CORRELATIONS_JITTER_SIZE*2-1) : 0);
parameter SPECTRA_SIZE = NUM_INPUTS*SPECTRA_JITTER_SIZE;
parameter PAYLOAD_SIZE = (CORRELATIONS_SIZE+SPECTRA_SIZE+NUM_INPUTS)*RESOLUTION;
parameter HEADER_SIZE = 64;
parameter PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

parameter BAUD_TIME = SECOND/BAUD_RATE;

parameter MAX_COUNT=(1<<RESOLUTION);
parameter TOTAL_NIBBLES=PACKET_SIZE/4;

output wire sampling_clk;
input wire enable;
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
output wire[NUM_INPUTS-1:0] voltage;

wire[NUM_INPUTS-1:0] in_delayed;
wire[NUM_INPUTS-1:0] pulse_in;
wire[NUM_INPUTS-1:0] in;
wire [7:0] RXREG;
wire RXIF;
wire [PAYLOAD_SIZE-1:0] pulse_t;
reg [PACKET_SIZE-1:0] tx_data;
wire [NUM_INPUTS-1:0] delay_lines [0:DELAY_SIZE*2+JITTER_SIZE-1];
reg [11:0] cross [0:NUM_INPUTS-1];
reg [11:0] auto [0:NUM_INPUTS-1];
reg [11:0] cross_tmp [0:NUM_INPUTS-1];
reg [11:0] auto_tmp [0:NUM_INPUTS-1];
wire uart_clk;
wire voltage_clk;
reg[3:0] voltage_pwm[NUM_INPUTS-1:0];

reg [7:0] index = 0;
reg [3:0] baud_rate = 0;
reg [5:0] clock_divider = 0;

delay1 #(.RESOLUTION(NUM_INPUTS)) delay(pll_clk, in, in_delayed);

generate
	genvar x;
	for (x = 0; x < NUM_INPUTS; x=x+1) begin
		if(HAS_LED_FLAGS) begin
			assign in[x] = leds[x*4+2]^signal_in[x];
			assign pulse_in[x] = (leds[x*4+3] ? 1 : ~in_delayed[x]) & in[x];
		end else begin
			assign pulse_in[x] = signal_in[x];
		end
	end
endgenerate

CLK_GEN #(.CLK_FREQUENCY(PLL_FREQUENCY), .RESOLUTION(128)) divider_block(
	(UNIT>>(63-clock_divider)),
	clk,
	pll_clk,
	sampling_clk,
	enable
);

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY)) uart_clock_block(
	BAUD_TIME>>(baud_rate+1),
	uart_clk,
	clki,
	,
	enable
);

TX_WORD #(.SHIFT(SHIFT), .RESOLUTION(PACKET_SIZE)) tx_block(
	TX,
	tx_data,
	uart_clk,
	,
	integration_clk,
	integrating
);
 
wire reset_delayed;
delay1 reset_delay(clk, integration_clk, reset_delayed);
integer v;


always@(posedge integration_clk) begin
	tx_data[0+:PAYLOAD_SIZE] <= pulse_t;
	tx_data[PAYLOAD_SIZE+:16] <= TICK;
	tx_data[PAYLOAD_SIZE+16+:4] <= (HAS_CORRELATOR << 3)|(HAS_LED_FLAGS<<2)|(HAS_LIVE_CORRELATOR<<1)|HAS_LIVE_SPECTRUM;
	tx_data[PAYLOAD_SIZE+16+4+:16] <= JITTER_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+16+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+16+12+:8] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+16+4+16+12+8+:8] <= RESOLUTION;
end

uart_rx #(.SHIFT(SHIFT)) rx_block(
	RX,
	RXREG,
	RXIF,
	uart_clk
);

parameter[3:0]
	CLEAR = 0,
	SET_INDEX = 1,
	SET_LEDS = 2,
	SET_BAUD_RATE = 3,
	SET_DELAY = 4,
	SET_FREQ_DIV = 8,
	SET_VOLTAGE = 9,
	ENABLE_CAPTURE = 13;
	
always@(posedge RXIF) begin
	if (RXREG[3:0] == CLEAR) begin
		cross[index] <= 0;
		auto[index] <= 0;
	end else if (RXREG[3:0] == ENABLE_CAPTURE) begin
		integrating <= RXREG[4];
	end else if (RXREG[3:0] == SET_INDEX) begin
		index[RXREG[7:6]*2+:2] <= RXREG[5:4];
	end else if (RXREG[3:0] == SET_LEDS && HAS_LED_FLAGS) begin
		leds[index*4+:4] <= RXREG[7:4];
	end else if (RXREG[3:0] == SET_BAUD_RATE) begin
		baud_rate <= RXREG[7:4];
	end else if (RXREG[2]) begin
		if (RXREG[7])
			auto_tmp [index][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
		else
			cross_tmp [index][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
		auto[index] <= (auto_tmp [index] < DELAY_SIZE+(HAS_LIVE_SPECTRUM?SPECTRA_JITTER_SIZE:1)-1 ? auto_tmp [index] : DELAY_SIZE+JITTER_SIZE-2);
		cross[index] <= (cross_tmp [index] < DELAY_SIZE+(HAS_LIVE_CORRELATOR?CORRELATIONS_JITTER_SIZE:1)-1 ? cross_tmp [index] : DELAY_SIZE+JITTER_SIZE-2);
	end else if (RXREG[3:0] == SET_FREQ_DIV) begin
		clock_divider <= RXREG[7:4];
	end else if (RXREG[3:0] == SET_VOLTAGE) begin
		voltage_pwm[index] <= RXREG[7:4];
	end
end

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY), .RESOLUTION(64)) psu_block(
	64'd330000000,
	voltage_clk,
	clki,
	,
	enable
);
	
assign delay_lines[0] = pulse_in;
generate
	genvar a;
	genvar b;
	genvar c;
	genvar d;
	genvar y;
	genvar z;

	for(d=1; d<DELAY_SIZE+JITTER_SIZE-1; d=d+2000) begin : delay_iteration_block
		for(c=d; c < d+2000 && c < DELAY_SIZE+JITTER_SIZE-1; c=c+1) begin : delay_iteration_inner_block
			delay1 #(.RESOLUTION(NUM_INPUTS)) delay_line(clk, delay_lines[c-1], delay_lines[c]);
		end
	end
	for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
		PWM #(.RESOLUTION(4)) psu_pwm(
			voltage_pwm[a],
			voltage[a],
			,
			voltage_clk,
			1'd1
		);
		COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
			(1<<RESOLUTION)-1,
			pulse_t[(CORRELATIONS_SIZE+NUM_INPUTS*SPECTRA_JITTER_SIZE+a)*RESOLUTION+:RESOLUTION],
			,
			delay_lines[cross[a]][a],
			pll_clk,
			reset_delayed
		);
		for(z=0; z < JITTER_SIZE*2; z=z+2000) begin : jitter_block
			for(y=z; y < z+2000 && y < DELAY_SIZE+JITTER_SIZE-1; y=y+1) begin : jitter_inner_block
				if(y<SPECTRA_JITTER_SIZE) begin
					COUNTER #(.RESOLUTION(RESOLUTION)) spectra_block (
						(1<<RESOLUTION)-1,
						pulse_t[(CORRELATIONS_SIZE+a*SPECTRA_JITTER_SIZE+y)*RESOLUTION+:RESOLUTION],
						,
						delay_lines[cross[a]][a]&delay_lines[cross[a]+auto[a]+y][a],
						pll_clk,
						reset_delayed
					);
				end
				if(HAS_CORRELATOR) begin
					if(y!=CORRELATIONS_JITTER_SIZE&&y<(CORRELATIONS_JITTER_SIZE*2-1)) begin
						for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
							COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
								(1<<RESOLUTION)-1,
								pulse_t[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*(CORRELATIONS_JITTER_SIZE*2-1)+(y>CORRELATIONS_JITTER_SIZE?y-1:y)-1)*RESOLUTION+:RESOLUTION],
								,
								delay_lines[cross[a]+(y<CORRELATIONS_JITTER_SIZE?CORRELATIONS_JITTER_SIZE-y-1:0)][a]&delay_lines[cross[b]+(y>CORRELATIONS_JITTER_SIZE?y-CORRELATIONS_JITTER_SIZE:0)][b],
								pll_clk,
								reset_delayed
							);
						end
					end
				end
			end
		end
	end
endgenerate

endmodule
