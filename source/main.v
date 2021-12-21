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
	spiclk,
	strobe,
	enable
);

parameter PLL_FREQUENCY = 400000000;
parameter CLK_FREQUENCY = 10000000;
parameter CLK_DIVISOR = 2;
parameter SIN_FREQUENCY = 50;
parameter MUX_LINES = 1;
parameter NUM_LINES = 8;
parameter DELAY_SIZE = 1;
parameter LAG_CROSS = 1;
parameter LAG_AUTO = 1;
parameter RESOLUTION = 24;
parameter HAS_LEDS = 1;
parameter HAS_CROSSCORRELATOR = 1;
parameter HAS_PSU = 0;
parameter HAS_CUMULATIVE_ONLY = 0;
parameter BAUD_RATE = 57600;
parameter WORD_WIDTH = 1;
parameter USE_UART = 1;
parameter BINARY = 0;

localparam SHIFT = 1;
localparam SECOND = 1000000000;
localparam TICK_CYCLES = CLK_DIVISOR*MUX_LINES;
localparam TICK_FREQUENCY = PLL_FREQUENCY/TICK_CYCLES;
localparam NUM_INPUTS = NUM_LINES*MUX_LINES;
localparam[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
localparam NUM_BASELINES = NUM_INPUTS*(NUM_INPUTS-1)/2;
localparam MAX_LAG = (LAG_AUTO>LAG_CROSS?LAG_AUTO:LAG_CROSS);
localparam SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
localparam CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
localparam CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
localparam PAYLOAD_SIZE = (CORRELATIONS_SIZE*2+SPECTRA_SIZE*2+NUM_INPUTS)*RESOLUTION;
localparam HEADER_SIZE = 64;
localparam FOOTER_SIZE = 64;
localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE+FOOTER_SIZE;

localparam MAX_LAG_AUTO = DELAY_SIZE+LAG_AUTO-1;
localparam MAX_LAG_CROSS = DELAY_SIZE+LAG_CROSS-1;
localparam BAUD_CYCLES = ((CLK_FREQUENCY>>SHIFT)/BAUD_RATE);

localparam MAX_COUNT=(1<<RESOLUTION)-1;
localparam TOTAL_NIBBLES=(PACKET_SIZE)/4;

input wire enable;
input wire spiclk;
output wire TX;
input wire RX;

input wire[NUM_LINES*WORD_WIDTH-1:0] line_in;
output reg[NUM_LINES*4-1:0] line_out;
output reg[MUX_LINES-1:0] mux_out;
wire[NUM_INPUTS*4-1:0] lineout;
input wire sysclk;
input wire extclk;
output reg refclk;
output wire intclk;
output wire smpclk;
input wire strobe;

wire smpclk_full;
wire smpclk_pulse;
wire external_clock;
wire integrating;

wire[NUM_INPUTS*WORD_WIDTH-1:0] pulse_in;
wire[WORD_WIDTH-1:0] adc_data[0:NUM_INPUTS];
wire[NUM_INPUTS-1:0] adc_done;

wire pllclk;
wire uart_clk;
wire reset_delayed;
 
wire[NUM_INPUTS-1:0] pwm_out;
wire[NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;

wire tx_done;
reg signed[PACKET_SIZE-1:0] tx_data;
wire [PAYLOAD_SIZE-1:0] pulses;

wire[NUM_INPUTS*WORD_WIDTH-1:0] delay_lines [0:DELAY_SIZE*2+MAX_LAG];

reg[11:0] cross [0:NUM_INPUTS];
reg[11:0] auto [0:NUM_INPUTS];

reg[NUM_INPUTS-1:0] signal_in;

reg[7:0] mux_line = 0;

wire[(DELAY_SIZE+MAX_LAG)*WORD_WIDTH-1:0] delays[0:NUM_INPUTS];
wire integrate;
wire in_capture;
reg enable_tx;

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
wire[63:0] timestamp;
wire timestamp_reset;
wire timestamp_overflow;

wire spi_done;
wire RXIF;
wire[7:0] RXREG;
wire TXIF;
wire[7:0] TXREG;

assign integrating = strobe | integrate;
assign in_capture = enable_tx | integrating;
assign intclk = tx_done;

pll pll_block (refclk, pllclk);
dff reset_delay(smpclk, intclk, reset_delayed);
reg[7:0] CK;

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(NUM_INPUTS*1000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
	sysclk,
	~in_capture
);

CLK_GEN sampling_clock_block(
	TICK_CYCLES<<clock_divider,
	smpclk,
	pllclk,
	smpclk_pulse,
	enable
);

COUNTER #(.WORD_WIDTH(64)) timestamp_block(
	~(1<<63),
	-~(1<<63),
	timestamp,
	timestamp_overflow,
	1000000000/CLK_FREQUENCY,
	0,
	1,
	refclk,
	timestamp_reset|timestamp_overflow
);

if(USE_UART) begin
	CLK_GEN uart_clock_block(
		BAUD_CYCLES>>baud_rate,
		uart_clk,
		sysclk,
		,
		enable
	);
	uart_tx #(.SHIFT(SHIFT)) uart_tx_block(
		TX,
		TXREG,
		TXIF,
		in_capture,
		uart_clk
	);
	uart_rx #(.SHIFT(SHIFT)) uart_rx_block(
		RX,
		RXREG,
		RXIF,
		uart_clk
	);
end else begin
	spi_slave spi_block(
		enable,
		in_capture,
		TXREG,
		0,
		~enable,
		spiclk,
		RX,
		TX,
		spi_done,
		RXREG
	);
	assign RXIF = spi_done;
	assign TXIF = spi_done;
end

TX_WORD #(.BINARY(BINARY), .RESOLUTION(PACKET_SIZE)) packet_generator(
	TXREG,
	TXIF,
	tx_data,
	tx_done,
	in_capture
);

CMD_PARSER #(.NUM_INPUTS(NUM_INPUTS), .HAS_LEDS(HAS_LEDS)) parser (
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
	timestamp_reset,
	RXIF
);

always@(*) begin
	signal_in[mux_line*NUM_LINES*WORD_WIDTH+:NUM_LINES*WORD_WIDTH] <= line_in;
	if(HAS_LEDS) begin
		line_out[0+:NUM_LINES] <= lineout[mux_line*NUM_LINES+:NUM_LINES];
		line_out[NUM_LINES+:NUM_LINES] <= lineout[NUM_INPUTS+mux_line*NUM_LINES+:NUM_LINES];
		line_out[NUM_LINES*2+:NUM_LINES] <= lineout[NUM_INPUTS*2+mux_line*NUM_LINES+:NUM_LINES];
		line_out[NUM_LINES*3+:NUM_LINES] <= lineout[NUM_INPUTS*3+mux_line*NUM_LINES+:NUM_LINES];
	end
	if(external_clock)
		refclk <= extclk;
	else
		refclk <= sysclk;
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
	enable_tx <= integrating;
	if(test[current_line][1]) begin
		if(auto[current_line] < MAX_LAG_AUTO-1)
			auto[current_line] <= auto[current_line]+1;
	end else
		auto[current_line] <= auto_tmp [current_line];
	if(test[current_line][2]) begin
		if(cross[current_line] < MAX_LAG_CROSS-1)
			cross[current_line] <= cross[current_line]+1;
	end else
		cross[current_line] <= cross_tmp [current_line];
	tx_data[0+:FOOTER_SIZE] <= timestamp;
	tx_data[FOOTER_SIZE+:PAYLOAD_SIZE] <= pulses;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+:16] <= TICK;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+:4] <= (HAS_CROSSCORRELATOR)|(HAS_LEDS<<1)|(HAS_PSU << 2)|(HAS_CUMULATIVE_ONLY << 3);
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+4+:8] <= LAG_CROSS-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+4+8+:8] <= LAG_AUTO-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+4+8+8+:12] <= DELAY_SIZE;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+4+8+8+12+:8] <= NUM_INPUTS-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+4+8+8+12+8+:8] <= RESOLUTION;
end

generate
	genvar a;
	genvar b;
	genvar j;
	genvar x;
	genvar y;
	genvar z;

	for (a=0; a<NUM_INPUTS; a=a+1) begin : correlators_initial_block
		assign leds[a] = leds_a[a*4+:4];
		assign test[a] = test_a[a*4+:4];
		assign voltage_pwm[a][7:0] = voltage_pwm_a[a*8+:8];
		assign cross_tmp[a] = cross_tmp_a[a*12+:12];
		assign auto_tmp[a] = auto_tmp_a[a*12+:12];
		
		for(x = 0; x < DELAY_SIZE+MAX_LAG; x=x+512)
			for(j = x; j < x + 512 && j < DELAY_SIZE+MAX_LAG; j=j+1)
				assign delay_lines[j][a*WORD_WIDTH+:WORD_WIDTH] = delays[a][j*WORD_WIDTH+:WORD_WIDTH];
				
		assign adc_data[a] = pulse_in[a*WORD_WIDTH+:WORD_WIDTH];
		
		if(HAS_LEDS) begin
			assign pulse_in[a] = (leds[a][2]?~signal_in[a*WORD_WIDTH+:WORD_WIDTH] : signal_in[a*WORD_WIDTH+:WORD_WIDTH]);
		end else begin
			assign pulse_in[a] = signal_in[a*WORD_WIDTH+:WORD_WIDTH];
		end
		
		if(HAS_LEDS) begin
			assign lineout[a] = (pwm_out[a]|in_capture)&~overflow[a];
			assign lineout[NUM_INPUTS+a] = adc_done[a];
			assign lineout[NUM_INPUTS*2+a] = ~test[a][3] ? leds[a][0]^(test[a][0] & pllclk) : leds[a][0]&(delay_lines[0][a*WORD_WIDTH] ^ smpclk);
			assign lineout[NUM_INPUTS*3+a] = HAS_PSU ? voltage[a] : leds[a][1];
		end
		 
		fifo #(.WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) delay_line(smpclk, adc_data[a], delays[a]);

		COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) counters_block (
			~(1<<(RESOLUTION-1)),
			-~(1<<(RESOLUTION-1)),
			pulses[(CORRELATIONS_SIZE*2+NUM_INPUTS*LAG_AUTO*2+NUM_INPUTS-1-a)*RESOLUTION+:RESOLUTION],
			overflow[a],
			delay_lines[cross[a]+(LAG_CROSS/2)][a*WORD_WIDTH+:WORD_WIDTH],
			0,
			leds[a][3],
			smpclk,
			reset_delayed
		);
		for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
				if(y<LAG_AUTO) begin
					COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) spectra_block_r (
						~(1<<(RESOLUTION-1)),
						-~(1<<(RESOLUTION-1)),
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION*2+:RESOLUTION],
						,
						delay_lines[cross[a]+(LAG_CROSS/2)][a*WORD_WIDTH+:WORD_WIDTH],
						delay_lines[cross[a]+(LAG_CROSS/2)+auto[a]+y][a*WORD_WIDTH+:WORD_WIDTH],
						leds[a][3],
						smpclk,
						reset_delayed
					);
					COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) spectra_block_i (
						~(1<<(RESOLUTION-1)),
						-~(1<<(RESOLUTION-1)),
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION*2+RESOLUTION+:RESOLUTION],
						,
						~delay_lines[cross[a]+(LAG_CROSS/2)][a*WORD_WIDTH+:WORD_WIDTH],
						delay_lines[cross[a]+(LAG_CROSS/2)+auto[a]+y][a*WORD_WIDTH+:WORD_WIDTH],
						leds[a][3],
						smpclk,
						reset_delayed
					);
				end
				if(HAS_CROSSCORRELATOR) begin
					if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
						for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
							COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) correlators_block_r (
								~(1<<(RESOLUTION-1)),
								-~(1<<(RESOLUTION-1)),
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION*2+:RESOLUTION],
								,
								delay_lines[cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH],
								delay_lines[cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH],
								leds[a][3]&leds[b][3],
								smpclk,
								reset_delayed
							);
							COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) correlators_block_i (
								~(1<<(RESOLUTION-1)),
								-~(1<<(RESOLUTION-1)),
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION],
								,
								~delay_lines[cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0)][a*WORD_WIDTH+:WORD_WIDTH],
								delay_lines[cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0)][b*WORD_WIDTH+:WORD_WIDTH],
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
