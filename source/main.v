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
	sysclk,
	refclk,
	extclk,
	intclk,
	smpclk,
	strobe,
	enable
);

parameter CLK_FREQUENCY = 10000000;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 1;
parameter NUM_LINES = 8;
parameter DELAY_SIZE = 1;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 1;
parameter RESOLUTION = 24;
parameter HAS_LED_FLAGS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter BAUD_RATE = 57600;
parameter WORD_WIDTH = 1;

localparam SHIFT = 1;
localparam SECOND = 1000000000;
localparam PLL_FREQUENCY = 400000000;
localparam MAX_LAG = (LAG_AUTO>LAG_CROSS?LAG_AUTO:LAG_CROSS);
localparam HAS_LIVE_AUTO = (LAG_AUTO>1);
localparam HAS_LIVE_CROSS = (LAG_CROSS>1);
localparam TICK_FREQUENCY = (PLL_FREQUENCY>>WORD_WIDTH)/MUX_LINES;
localparam NUM_INPUTS = NUM_LINES*MUX_LINES;
localparam TICK_CYCLES = PLL_FREQUENCY/TICK_FREQUENCY;
localparam[15:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
localparam NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
localparam CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
localparam CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
localparam SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
localparam PAYLOAD_SIZE = (CORRELATIONS_SIZE+SPECTRA_SIZE+NUM_INPUTS)*RESOLUTION;
localparam HEADER_SIZE = 64;
localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

localparam MAX_LAG_AUTO = DELAY_SIZE+LAG_AUTO-1;
localparam MAX_LAG_CROSS = DELAY_SIZE+LAG_CROSS-1;
localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

localparam MAX_COUNT=(1<<RESOLUTION)-1;
localparam TOTAL_NIBBLES=PACKET_SIZE/4;

input wire enable;
output wire TX;
input wire RX;

input wire[NUM_LINES-1:0] line_in;
output reg[NUM_LINES*4-1:0] line_out;
output reg[MUX_LINES-1:0] mux_out;
input wire sysclk;
input wire extclk;
output reg refclk;
output wire intclk;
output wire smpclk;
input wire strobe;

wire external_clock;
wire integrating;

wire[NUM_INPUTS-1:0] pulse_in;
wire[WORD_WIDTH-1:0] adc_data[0:NUM_INPUTS];
wire[NUM_INPUTS-1:0] adc_done;

wire pllclk;
wire uart_clk;
wire reset_delayed;
 
wire[NUM_INPUTS-1:0] pwm_out;
wire[NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;

wire tx_done;
reg[PACKET_SIZE-1:0] tx_data;
wire[PAYLOAD_SIZE-1:0] pulses;

wire[NUM_INPUTS*WORD_WIDTH-1:0] delay_lines [0:DELAY_SIZE+MAX_LAG];

reg[11:0] cross [0:NUM_INPUTS];
reg[11:0] auto [0:NUM_INPUTS];

reg[NUM_INPUTS-1:0] signal_in;

reg[7:0] mux_line = 0;

wire[(DELAY_SIZE+MAX_LAG)*WORD_WIDTH-1:0] delays[0:NUM_INPUTS];
wire integrate;

wire[7:0] current_line;
wire[3:0] baud_rate;
wire[3:0] clock_divider;

wire[3:0] leds[0:NUM_INPUTS];
wire[3:0] test[0:NUM_INPUTS];
wire[8:0] voltage_pwm[0:NUM_INPUTS];
wire[11:0] cross_tmp [0:NUM_INPUTS];
wire[11:0] auto_tmp [0:NUM_INPUTS];
wire[4*NUM_INPUTS-1:0] leds_a;
wire[4*NUM_INPUTS-1:0] test_a;
wire[8*NUM_INPUTS-1:0] voltage_pwm_a;
wire[12*NUM_INPUTS-1:0] cross_tmp_a;
wire[12*NUM_INPUTS-1:0] auto_tmp_a;

wire RXIF;
wire[7:0] RXREG;

assign integrating = strobe | integrate;
assign intclk = tx_done;

pll pll_block (refclk, pllclk);
dff reset_delay(sysclk, intclk, reset_delayed);

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(NUM_INPUTS*1000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
	sysclk,
	integrating
	);

CLK_GEN sampling_clock_block(
	TICK_CYCLES<<clock_divider,
	smpclk,
	pllclk,
	,
	enable
);

CLK_GEN uart_clock_block(
	BAUD_CYCLES>>baud_rate,
	uart_clk,
	sysclk,
	,
	enable
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
	integrate,
	external_clock,
	RXIF
);
 
always@(*) begin
	if(external_clock)
		refclk <= extclk;
	else
		refclk <= sysclk;
	signal_in[mux_line*NUM_LINES+:NUM_LINES] <= line_in;
end

always@(posedge pllclk) begin
	mux_out <= 1<<mux_line;
	if(mux_line < MUX_LINES-1) begin
		mux_line <= mux_line+1;
	end else begin
		mux_line <= 0;
	end
end

always@(posedge intclk) begin
	auto[current_line] <= test[current_line][1] ? ((auto[current_line]+1) < MAX_LAG_AUTO ? auto[current_line]+1 : MAX_LAG_AUTO-1) : (auto_tmp [current_line] < MAX_LAG_AUTO ? auto_tmp [current_line] : MAX_LAG_AUTO-1);
	cross[current_line] <= test[current_line][2] ? ((cross[current_line]+1) < MAX_LAG_CROSS ? cross[current_line]+1 : MAX_LAG_CROSS-1) : (cross_tmp [current_line] < MAX_LAG_CROSS ? cross_tmp [current_line] : MAX_LAG_CROSS-1);
	tx_data[0+:PAYLOAD_SIZE] <= pulses;
	tx_data[PAYLOAD_SIZE+:16] <= TICK;
	tx_data[PAYLOAD_SIZE+16+:4] <= (HAS_CROSSCORRELATOR)|(HAS_LED_FLAGS<<1)|(HAS_PSU << 2);
	tx_data[PAYLOAD_SIZE+16+4+:8] <= LAG_CROSS-1;
	tx_data[PAYLOAD_SIZE+16+4+8+:8] <= LAG_AUTO-1;
	tx_data[PAYLOAD_SIZE+16+4+8+8+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+16+4+8+8+12+:8] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+16+4+8+8+12+8+:8] <= RESOLUTION;
end

generate
	genvar a;
	genvar b;
	genvar j;
	genvar x;
	genvar y;
	genvar z;
	genvar k;

	for(k=0; k<NUM_LINES; k=k+1) begin
		if(WORD_WIDTH>1)
			ADC #(.WORD_WIDTH(WORD_WIDTH)) adc(pulse_in[mux_line*NUM_LINES+k], adc_data[mux_line*NUM_LINES+k], adc_done[mux_line*NUM_LINES+k], , mux_out[mux_line], enable);
		always@(*) begin
			if(HAS_LED_FLAGS) begin
					line_out[k] <= pwm_out[mux_line*NUM_LINES+k]&~overflow[mux_line*NUM_LINES+k];
				line_out[NUM_LINES+k] <= adc_done[mux_line*NUM_LINES+k];
				if(!test[mux_line*NUM_LINES+k][3])
					line_out[NUM_LINES*2+k*2] <= leds[mux_line*NUM_LINES+k][0]^(test[mux_line*NUM_LINES+k][0] & pllclk);
				else
					line_out[NUM_LINES*2+k*2] <= leds[mux_line*NUM_LINES+k][0]&(adc_data[a][0] ^ smpclk);
				if(HAS_PSU)
					line_out[NUM_LINES*2+k*2+1] <= voltage[mux_line*NUM_LINES+k];
				else
					line_out[NUM_LINES*2+k*2+1] <= leds[mux_line*NUM_LINES+k][1];
			end
		end
	end

	for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
		assign leds[a] = leds_a[a*4+:4];
		assign test[a] = test_a[a*4+:4];
		assign voltage_pwm[a][7:0] = voltage_pwm_a[a*8+:8];
		assign cross_tmp[a] = cross_tmp_a[a*12+:12];
		assign auto_tmp[a] = auto_tmp_a[a*12+:12];
		
		for(x = 0; x < DELAY_SIZE+MAX_LAG; x=x+512)
			for(j = x; j < x + 512 && j < DELAY_SIZE+MAX_LAG; j=j+1)
				assign delay_lines[j][a*WORD_WIDTH+:WORD_WIDTH] = delays[a][j*WORD_WIDTH+:WORD_WIDTH];
				
		if(WORD_WIDTH==1)
			assign adc_data[a] = pulse_in[a];
		
		if(HAS_LED_FLAGS) begin
			assign pulse_in[a] = leds[a][2]^signal_in[a];
		end else begin
			assign pulse_in[a] = signal_in[a];
		end
		 
		fifo #(.WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) delay_line(smpclk, adc_data[a], delays[a]);

		if(HAS_PSU) begin
		end
		COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) counters_block (
			~64'd0,
			pulses[(CORRELATIONS_SIZE+NUM_INPUTS*LAG_AUTO+NUM_INPUTS-1-a)*RESOLUTION+:RESOLUTION],
			overflow[a],
			delay_lines[0][a*WORD_WIDTH+:WORD_WIDTH],
			leds[a][3],
			smpclk,
			reset_delayed
		);
		for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
				if(y<LAG_AUTO) begin
					COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) spectra_block (
						~0,
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION+:RESOLUTION],
						,
						delay_lines[0][a*WORD_WIDTH+:WORD_WIDTH]&delay_lines[auto[a]+y][a*WORD_WIDTH+:WORD_WIDTH],
						leds[a][3],
						smpclk,
						reset_delayed
					);
				end
				if(HAS_CROSSCORRELATOR) begin
					if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
						for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
							COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) counters_block (
								~0,
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION+:RESOLUTION],
								,
								delay_lines[cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH]&delay_lines[cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH],
								leds[a][3]&leds[b][3],
								smpclk,
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
