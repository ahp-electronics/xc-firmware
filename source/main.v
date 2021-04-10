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
	external_clock,
	strobe,
	enable
);

parameter CLK_FREQUENCY = 50000000;
parameter PWM_FREQUENCY = 100000;
parameter SIN_FREQUENCY = 1000;
parameter PLL_MULTIPLIER = 1;
parameter PLL_DIVIDER = 1;
parameter MUX_LINES = 1;
parameter NUM_LINES = 1;
parameter DELAY_SIZE = 1;
parameter RESOLUTION = 4;
parameter HAS_LED_FLAGS = 0;
parameter HAS_CROSSCORRELATOR = 0;
parameter HAS_PSU = 1;
parameter MAX_LAG = 1;
parameter BAUD_RATE = 57600;
parameter SHIFT = 1;
parameter WORD_WIDTH = 1;

parameter SECOND = 1000000000;
parameter PLL_FREQUENCY = CLK_FREQUENCY*PLL_MULTIPLIER/PLL_DIVIDER;
parameter LAG_CROSS = MAX_LAG;
parameter LAG_AUTO = MAX_LAG;
parameter HAS_LIVE_AUTO = (LAG_AUTO>1);
parameter HAS_LIVE_CROSS = (LAG_CROSS>1);
parameter TICK_FREQUENCY = (PLL_FREQUENCY>>WORD_WIDTH)/MUX_LINES;
parameter NUM_INPUTS = NUM_LINES*MUX_LINES;
parameter[127:0] UNIT = SECOND/TICK_FREQUENCY;
parameter[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
parameter NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
parameter CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
parameter CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
parameter SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
parameter PAYLOAD_SIZE = (CORRELATIONS_SIZE+SPECTRA_SIZE+NUM_INPUTS)*RESOLUTION;
parameter HEADER_SIZE = 64;
parameter PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE;

parameter MAX_LAG_AUTO = DELAY_SIZE+LAG_AUTO-1;
parameter MAX_LAG_CROSS = DELAY_SIZE+LAG_CROSS-1;
parameter BAUD_TIME = (SECOND/BAUD_RATE);

parameter MAX_COUNT=(1<<RESOLUTION);
parameter TOTAL_NIBBLES=PACKET_SIZE/4;

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
input wire external_clock;
input wire strobe;

wire integrating;

wire[NUM_INPUTS-1:0] in_delayed;
wire[NUM_INPUTS-1:0] pulse_in;
wire[NUM_INPUTS-1:0] in;
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
dff #(.WORD_WIDTH(NUM_INPUTS)) input_delay(pllclk, in, in_delayed);

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(10000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
	sysclk,
	integrating
	);

CLK_GEN #(.CLK_FREQUENCY(PLL_FREQUENCY), .RESOLUTION(128)) divider_block(
	UNIT<<clock_divider,
	clk,
	pllclk,
	smpclk,
	enable
);

CLK_GEN #(.CLK_FREQUENCY(CLK_FREQUENCY)) uart_clock_block(
	BAUD_TIME>>(baud_rate+1),
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
	tx_data[PAYLOAD_SIZE+16+:8] <= ((MAX_LAG > 1)<<5)|(HAS_PSU << 4)|(HAS_CROSSCORRELATOR << 3)|(HAS_LED_FLAGS<<2);
	tx_data[PAYLOAD_SIZE+16+8+:12] <= MAX_LAG;
	tx_data[PAYLOAD_SIZE+16+8+12+:12] <= DELAY_SIZE;
	tx_data[PAYLOAD_SIZE+16+8+12+12+:8] <= NUM_INPUTS-1;
	tx_data[PAYLOAD_SIZE+16+8+12+12+8+:8] <= RESOLUTION;
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
		always@(*) begin
			if(HAS_LED_FLAGS) begin
					line_out[k] <= pwm_out[mux_line*NUM_LINES+k]&~overflow[mux_line*NUM_LINES+k];
				line_out[NUM_LINES+k] <= adc_done[mux_line*NUM_LINES+k];
				if(!test[mux_line*NUM_LINES+k][3])
					line_out[NUM_LINES*2+k*2] <= leds[mux_line*NUM_LINES+k][0]^(test[mux_line*NUM_LINES+k][0] & pllclk);
				else
					line_out[NUM_LINES*2+k*2] <= leds[mux_line*NUM_LINES+k][0]&(adc_data[a][0] ^ pllclk);
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
				
		if(HAS_LED_FLAGS) begin
			assign in[a] = leds[a][2]^signal_in[a];
			assign pulse_in[a] = ~(leds[a][3] & in_delayed[a]) & in[a];
		end else begin
			assign pulse_in[a] = signal_in[a];
		end
		 
		fifo #(.WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) delay_line(clk, adc_data[a], delays[a]);

		if(WORD_WIDTH>1)
			ADC #(.WORD_WIDTH(WORD_WIDTH)) adc(pulse_in[a], adc_data[a], adc_done[a], , clk, enable);
		else
			assign adc_data[a] = pulse_in[a];

		if(HAS_PSU) begin
			sine #(.RESOLUTION(8), .PWM_FREQUENCY(PWM_FREQUENCY), .SIN_FREQUENCY(SIN_FREQUENCY), .CLK_FREQUENCY(PLL_FREQUENCY)) psu(
				voltage_pwm[a],
				voltage[a],
				pllclk,
				enable
			);
		end
		COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) counters_block (
			~64'd0,
			pulses[(CORRELATIONS_SIZE+NUM_INPUTS*LAG_AUTO+NUM_INPUTS-1-a)*RESOLUTION+:RESOLUTION],
			overflow[a],
			delay_lines[0][a*WORD_WIDTH+:WORD_WIDTH],
			pllclk,
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
						pllclk,
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
								pllclk,
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
