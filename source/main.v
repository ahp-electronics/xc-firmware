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
	line_in,
	line_out,
	mux_out,
	clock,
	clki,
	enable
);

parameter CLK_FREQUENCY = 50000000;
parameter PLL_MULTIPLIER = 1;
parameter PLL_DIVIDER = 1;
parameter PLL_FREQUENCY = CLK_FREQUENCY*PLL_MULTIPLIER/PLL_DIVIDER;
parameter MUX_LINES = 1;
parameter NUM_LINES = 1;
parameter DELAY_SIZE = 1;
parameter RESOLUTION = 4;
parameter HAS_LED_FLAGS = 0;
parameter HAS_CORRELATOR = 0;
parameter HAS_PSU = 0;
parameter MAX_LAG = 1;
parameter HAS_LIVE_SPECTRUM = 0;
parameter HAS_LIVE_CORRELATOR = 0;
parameter BAUD_RATE = 57600;
parameter SHIFT = 1;

parameter SECOND = 1000000000;
parameter TICK_FREQUENCY = (PLL_FREQUENCY/(1+MUX_LINES));
parameter NUM_INPUTS = NUM_LINES*MUX_LINES;
parameter[127:0] UNIT = (SECOND<<63)/TICK_FREQUENCY;
parameter[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
parameter JITTER_SIZE = (HAS_LIVE_SPECTRUM|HAS_LIVE_CORRELATOR)?MAX_LAG:1;
parameter NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
parameter CORRELATIONS_JITTER_SIZE = (HAS_LIVE_CORRELATOR?JITTER_SIZE:1);
parameter SPECTRA_JITTER_SIZE = (HAS_LIVE_SPECTRUM?JITTER_SIZE:1);
parameter CORRELATIONS_SIZE = (HAS_CORRELATOR ? NUM_BASELINES*(CORRELATIONS_JITTER_SIZE*2-1) : 0);
parameter SPECTRA_SIZE = NUM_INPUTS*SPECTRA_JITTER_SIZE;
parameter PAYLOAD_SIZE = (CORRELATIONS_SIZE+SPECTRA_SIZE+NUM_INPUTS)*RESOLUTION;
parameter HEADER_SIZE = 64;
parameter PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

parameter MAX_LAG_AUTO = DELAY_SIZE+SPECTRA_JITTER_SIZE-1;
parameter MAX_LAG_CROSS = DELAY_SIZE+CORRELATIONS_JITTER_SIZE-1;
parameter BAUD_TIME = (SECOND/BAUD_RATE)>>SHIFT;

parameter MAX_COUNT=(1<<RESOLUTION);
parameter TOTAL_NIBBLES=PACKET_SIZE/4;

input wire enable;
output wire TX;
input wire RX;

input wire[NUM_LINES-1:0] line_in;
output reg[NUM_LINES*3-1:0] line_out;
output reg[MUX_LINES-1:0] mux_out;
wire[NUM_INPUTS-1:0] in_delayed;
wire[NUM_INPUTS-1:0] pulse_in;
wire[NUM_INPUTS-1:0] in;

input wire clock;
output wire clki;
wire sampling_clk;
wire pll_clk;
wire plli_clk;
wire clk;
wire integration_clk;
wire uart_clk;
wire voltage_clk;
wire reset_delayed;

reg integrating = 0;
wire[NUM_INPUTS-1:0] pwm_out;
wire [NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;
reg[NUM_INPUTS*4-1:0] leds;

wire [7:0] RXREG;
wire RXIF;

wire tx_done;
reg [PACKET_SIZE-1:0] tx_data;
wire [PAYLOAD_SIZE-1:0] pulses;

wire [NUM_INPUTS-1:0] delay_lines [0:DELAY_SIZE*2+JITTER_SIZE-1];

reg [11:0] cross [0:NUM_INPUTS-1];
reg [11:0] auto [0:NUM_INPUTS-1];
reg [11:0] cross_tmp [0:NUM_INPUTS-1];
reg [11:0] auto_tmp [0:NUM_INPUTS-1];

reg[3:0] test[NUM_INPUTS-1:0];
reg[3:0] voltage_pwm[NUM_INPUTS-1:0];
reg[NUM_INPUTS-1:0] signal_in;

reg [7:0]current_line = 0;
reg [7:0] mux_line = 0;
reg [7:0] k;

reg [3:0] baud_rate = 0;
reg [3:0] clock_divider = 0;

assign integration_clk = tx_done;
assign delay_lines[0] = pulse_in;

pll #(.MULTIPLIER(PLL_MULTIPLIER), .DIVIDER(PLL_DIVIDER)) pll_block (clock, clki, pll_clk);

always@(*) begin
	mux_out <= 1<<mux_line;
	signal_in[mux_line*NUM_LINES+:NUM_LINES] <= line_in;
	if(HAS_LED_FLAGS) begin
		line_out[0+:NUM_LINES] <= pwm_out[mux_line*NUM_LINES+:NUM_LINES]&~overflow[mux_line*NUM_LINES+:NUM_LINES];
		for(k=0; k<NUM_INPUTS; k=k+1) begin
			line_out[NUM_LINES+k*2] = leds[k*4]&(test[k][0] ? clk : 1);
			line_out[NUM_LINES+k*2+1] = leds[k*4+1]&(HAS_PSU ? ~voltage[k] : 1);
		end
	end
end
	
always@(posedge pll_clk) begin
	if(mux_line < MUX_LINES-1) begin
		mux_line <= mux_line+1;
	end else begin
		mux_line <= 0;
	end
end

generate
	genvar x;
	for (x = 0; x < NUM_INPUTS; x=x+1) begin
		if(HAS_LED_FLAGS) begin
			delay1 delay(pll_clk, in[x], in_delayed[x]);
			assign in[x] = leds[x*4+2]^signal_in[x];
			assign pulse_in[x] = (leds[x*4+3] ? 1 : ~in_delayed[x]) & in[x];
		end else begin
			assign pulse_in[x] = signal_in[x];
		end
	end
endgenerate

delay1 reset_delay(clk, integration_clk, reset_delayed);

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(5000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out[0+:NUM_INPUTS],
	clki,
	integrating
	);

CLK_GEN #(.CLK_FREQUENCY(PLL_FREQUENCY), .RESOLUTION(128)) divider_block(
	(UNIT>>(63-clock_divider)),
	clk,
	pll_clk,
	sampling_clk,
	enable
);

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY)) uart_clock_block(
	BAUD_TIME>>baud_rate,
	uart_clk,
	clki,
	,
	enable
);

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY)) pwm_clock_block(
	1250000,
	pwm_clk,
	clki,
	,
	enable&HAS_PSU
);

TX_WORD #(.SHIFT(SHIFT), .RESOLUTION(PACKET_SIZE)) tx_block(
	TX,
	tx_data,
	uart_clk,
	, 
	tx_done,
	integrating
);

uart_rx #(.SHIFT(SHIFT)) rx_block(
	RX,
	RXREG,
	RXIF,
	uart_clk
);

always@(posedge integration_clk) begin
	auto[current_line] <= test[current_line][1] ? ((auto[current_line]+1) < MAX_LAG_AUTO ? auto[current_line]+1 : MAX_LAG_AUTO-1) : (auto_tmp [current_line] < MAX_LAG_AUTO ? auto_tmp [current_line] : MAX_LAG_AUTO-1);
	cross[current_line] <= test[current_line][2] ? ((cross[current_line]+1) < MAX_LAG_CROSS ? cross[current_line]+1 : MAX_LAG_CROSS-1) : (cross_tmp [current_line] < MAX_LAG_CROSS ? cross_tmp [current_line] : MAX_LAG_CROSS-1);
	tx_data[0+:PAYLOAD_SIZE] <= pulses;
	tx_data[PAYLOAD_SIZE+:16] <= TICK;
	tx_data[PAYLOAD_SIZE+16+:4] <= (HAS_CORRELATOR << 3)|(HAS_LED_FLAGS<<2)|(HAS_LIVE_CORRELATOR<<1)|HAS_LIVE_SPECTRUM;
	tx_data[PAYLOAD_SIZE+16+4+:16] <= JITTER_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+16+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+16+12+:8] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+16+4+16+12+8+:8] <= RESOLUTION;
end

parameter[3:0]
	CLEAR = 0,
	SET_LINE = 1,
	SET_LEDS = 2,
	SET_BAUD_RATE = 3,
	SET_DELAY = 4,
	SET_FREQ_DIV = 8,
	SET_VOLTAGE = 9,
	ENABLE_TEST = 12,
	ENABLE_CAPTURE = 13;
	
always@(posedge RXIF) begin
	if (RXREG[3:0] == CLEAR) begin
		cross_tmp[current_line] <= 0;
		auto_tmp[current_line] <= 0;
	end else if (RXREG[3:0] == ENABLE_CAPTURE) begin
		integrating <= RXREG[4];
	end else if (RXREG[3:0] == SET_LINE) begin
		current_line[RXREG[7:6]*2+:2] <= RXREG[5:4];
	end else if (RXREG[3:0] == SET_LEDS && HAS_LED_FLAGS) begin
		leds[current_line*4+:4] <= RXREG[7:4];
	end else if (RXREG[3:0] == SET_BAUD_RATE) begin
		baud_rate <= RXREG[7:4];
	end else if ((RXREG[3:0]&4'b1100) == SET_DELAY) begin
		if (RXREG[7])
			auto_tmp [current_line][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
		else
			cross_tmp [current_line][(RXREG[1:0]*3)+:3] <= RXREG[6:4];
	end else if (RXREG[3:0] == SET_FREQ_DIV) begin
		clock_divider <= RXREG[7:4];
	end else if (RXREG[3:0] == ENABLE_TEST) begin
		test[current_line] <= RXREG[7:4];
	end else if (RXREG[3:0] == SET_VOLTAGE) begin
		voltage_pwm[current_line] <= RXREG[7:4];
	end
end
	
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
		if(HAS_PSU) begin
			PWM #(.RESOLUTION(4)) pwm(
				voltage_pwm[a],
				voltage[a],
				,
				pwm_clk,
				enable
			);
		end
		COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
			~0,
			pulses[(CORRELATIONS_SIZE+NUM_INPUTS*SPECTRA_JITTER_SIZE+a)*RESOLUTION+:RESOLUTION],
			,
			delay_lines[cross[a]][a],
			pll_clk,
			reset_delayed
		);
		for(z=0; z < JITTER_SIZE*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < JITTER_SIZE*2; y=y+1) begin : jitter_inner_block
				if(y<SPECTRA_JITTER_SIZE) begin
					COUNTER #(.RESOLUTION(RESOLUTION)) spectra_block (
						~0,
						pulses[(CORRELATIONS_SIZE+a*SPECTRA_JITTER_SIZE+y)*RESOLUTION+:RESOLUTION],
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
								~0,
								pulses[((((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)+b-a-1)*(CORRELATIONS_JITTER_SIZE*2-1)+(y>CORRELATIONS_JITTER_SIZE?y-1:y)-1)*RESOLUTION+:RESOLUTION],
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
