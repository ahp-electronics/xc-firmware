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
parameter HAS_CROSSCORRELATOR = 0;
parameter HAS_PSU = 1;
parameter LAG_AUTO = 1;
parameter LAG_CROSS = 1;
parameter BAUD_RATE = 57600;
parameter SHIFT = 1;

parameter SECOND = 1000000000;
parameter MAX_LAG = (LAG_AUTO>LAG_CROSS?LAG_AUTO:LAG_CROSS);
parameter HAS_LIVE_AUTO = (LAG_AUTO>1);
parameter HAS_LIVE_CROSS = (LAG_CROSS>1);
parameter TICK_FREQUENCY = (PLL_FREQUENCY/(1+MUX_LINES));
parameter NUM_INPUTS = NUM_LINES*MUX_LINES;
parameter[127:0] UNIT = (SECOND<<63)/TICK_FREQUENCY;
parameter[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
parameter NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
parameter CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
parameter CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR ? NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE : 0);
parameter SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
parameter PAYLOAD_SIZE = (CORRELATIONS_SIZE+SPECTRA_SIZE+NUM_INPUTS)*RESOLUTION;
parameter HEADER_SIZE = 64;
parameter PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

parameter MAX_LAG_AUTO = DELAY_SIZE+LAG_AUTO-1;
parameter MAX_LAG_CROSS = DELAY_SIZE+LAG_CROSS-1;
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
 
wire[NUM_INPUTS-1:0] pwm_out;
wire[NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;

wire tx_done;
reg[PACKET_SIZE-1:0] tx_data;
wire[PAYLOAD_SIZE-1:0] pulses;

wire[NUM_INPUTS-1:0] delay_lines [0:DELAY_SIZE+MAX_LAG-1];

reg[11:0] cross [0:NUM_INPUTS-1];
reg[11:0] auto [0:NUM_INPUTS-1];

reg[NUM_INPUTS-1:0] signal_in;

reg[7:0] mux_line = 0;
reg[7:0] k;

wire[NUM_INPUTS*(DELAY_SIZE+MAX_LAG)-1:0] delays;

wire integrating;
wire[7:0] current_line;
wire[3:0] baud_rate;
wire[3:0] clock_divider;

wire[3:0] leds[0:NUM_INPUTS-1];
wire[3:0] test[0:NUM_INPUTS-1];
wire[3:0] voltage_pwm[0:NUM_INPUTS-1];
wire[11:0] cross_tmp [0:NUM_INPUTS-1];
wire[11:0] auto_tmp [0:NUM_INPUTS-1];

wire[4*NUM_INPUTS-1:0] leds_a;
wire[4*NUM_INPUTS-1:0] test_a;
wire[4*NUM_INPUTS-1:0] voltage_pwm_a;
wire[12*NUM_INPUTS-1:0] cross_tmp_a;
wire[12*NUM_INPUTS-1:0] auto_tmp_a;

wire RXIF;
wire[7:0] RXREG;

assign integration_clk = tx_done;

fifo #(.RESOLUTION(NUM_INPUTS), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) delay_line(clk, pulse_in, delays);
pll #(.MULTIPLIER(PLL_MULTIPLIER), .DIVIDER(PLL_DIVIDER)) pll_block (clock, clki, pll_clk);
dff reset_delay(clk, integration_clk, reset_delayed);
dff #(.RESOLUTION(NUM_INPUTS)) input_delay(pll_clk, in, in_delayed);

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(5000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
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
	62500,
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

CMD_PARSER #(.NUM_INPUTS(NUM_INPUTS), .HAS_LED_FLAGS(HAS_LED_FLAGS)) parser (
	RXREG,
	voltage_pwm_a,
	test_a,
	cross_tmp_a,
	auto_tmp_a,
	leds_a,
	clock_divider,
	baud_rate,
	current_line,
	integrating,
	RXIF
);

always@(*) begin
	mux_out <= 1<<mux_line;
	signal_in[mux_line*NUM_LINES+:NUM_LINES] <= line_in;
	if(HAS_LED_FLAGS) begin
		line_out[0+:NUM_LINES] <= pwm_out[mux_line*NUM_LINES+:NUM_LINES]&~overflow[mux_line*NUM_LINES+:NUM_LINES];
		for(k=0; k<NUM_INPUTS; k=k+1) begin
			line_out[NUM_LINES+k*2] = leds[k][0]&(test[k][0] ? pll_clk : 1);
			line_out[NUM_LINES+k*2+1] = leds[k][1]&(HAS_PSU ? ~voltage[k] : 1);
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

always@(posedge integration_clk) begin
	auto[current_line] <= test[current_line][1] ? ((auto[current_line]+1) < MAX_LAG_AUTO ? auto[current_line]+1 : MAX_LAG_AUTO-1) : (auto_tmp [current_line] < MAX_LAG_AUTO ? auto_tmp [current_line] : MAX_LAG_AUTO-1);
	cross[current_line] <= test[current_line][2] ? ((cross[current_line]+1) < MAX_LAG_CROSS ? cross[current_line]+1 : MAX_LAG_CROSS-1) : (cross_tmp [current_line] < MAX_LAG_CROSS ? cross_tmp [current_line] : MAX_LAG_CROSS-1);
	tx_data[0+:PAYLOAD_SIZE] <= pulses;
	tx_data[PAYLOAD_SIZE+:16] <= TICK;
	tx_data[PAYLOAD_SIZE+16+:4] <= (HAS_CROSSCORRELATOR << 3)|(HAS_LED_FLAGS<<2)|(HAS_LIVE_CROSS<<1)|HAS_LIVE_AUTO;
	tx_data[PAYLOAD_SIZE+16+4+:16] <= MAX_LAG;
	tx_data[PAYLOAD_SIZE+16+4+16+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+16+12+:8] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+16+4+16+12+8+:8] <= RESOLUTION;
end

generate
	genvar a;
	genvar b;
	genvar c;
	genvar d;
	genvar j;
	genvar x;
	genvar y;
	genvar z;
	for(x = 0; x < DELAY_SIZE+MAX_LAG; x=x+512)
		for(j = x; j < x + 512 && j < DELAY_SIZE+MAX_LAG; j=j+1)
			assign delay_lines[j] = delays[j*NUM_INPUTS+:NUM_INPUTS];

	for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
		assign leds[a] = leds_a[a*4+:4];
		assign test[a] = test_a[a*4+:4];
		assign voltage_pwm[a] = voltage_pwm_a[a*4+:4];
		assign cross_tmp[a] = cross_tmp_a[a*12+:12];
		assign auto_tmp[a] = auto_tmp_a[a*12+:12];
		
		if(HAS_LED_FLAGS) begin
			assign in[a] = leds[a][2]^signal_in[a];
			assign pulse_in[a] = (leds[a][3] ? 1 : ~in_delayed[a]) & in[a];
		end else begin
			assign pulse_in[a] = signal_in[a];
		end
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
			pulses[(CORRELATIONS_SIZE+NUM_INPUTS*LAG_AUTO+NUM_INPUTS-1-a)*RESOLUTION+:RESOLUTION],
			,
			delay_lines[0][a],
			pll_clk,
			reset_delayed
		);
		for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
				if(y<LAG_AUTO) begin
					COUNTER #(.RESOLUTION(RESOLUTION)) spectra_block (
						~0,
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION+:RESOLUTION],
						,
						delay_lines[0][a]*delay_lines[auto[a]+y][a],
						clk,
						reset_delayed
					);
				end
				if(HAS_CROSSCORRELATOR) begin
					if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
						for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
							COUNTER #(.RESOLUTION(RESOLUTION)) counters_block (
								~0,
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION+:RESOLUTION],
								,
								delay_lines[cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a]*delay_lines[cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0)][b],
								clk,
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
