/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
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
	pllclk,
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
parameter DELAY_SIZE = 4;
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
parameter USE_SOFT_CLOCK = 1;
parameter MAX_ORDER = 2;

localparam SHIFT = 1;
localparam SECOND = 1000000000;
localparam TICK_CYCLES = CLK_DIVISOR*MUX_LINES;
localparam TICK_FREQUENCY = PLL_FREQUENCY/TICK_CYCLES;
localparam NUM_INPUTS = NUM_LINES*MUX_LINES;
localparam[39:0] TICK = 40'd1000000000000/TICK_FREQUENCY;
localparam NUM_BASELINES = (NUM_INPUTS*(NUM_INPUTS-1))/2;
localparam SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
localparam CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
localparam MAX_LAG = (LAG_AUTO > CORRELATIONS_HEAD_TAIL_SIZE) ? LAG_AUTO : CORRELATIONS_HEAD_TAIL_SIZE;
localparam CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
localparam PAYLOAD_SIZE = ((CORRELATIONS_SIZE+SPECTRA_SIZE)*2+NUM_INPUTS)*RESOLUTION;
localparam HEADER_SIZE = 64;
localparam FOOTER_SIZE = 64;
localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE+FOOTER_SIZE;

localparam LAG_SIZE_AUTO = DELAY_SIZE+LAG_AUTO+1;
localparam LAG_SIZE_CROSS = DELAY_SIZE+LAG_CROSS+1;
localparam BAUD_CYCLES = ((PLL_FREQUENCY>>SHIFT)/BAUD_RATE);

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
output wire pllclk;
input wire strobe;

wire external_clock;
wire integrating;

wire[NUM_INPUTS*WORD_WIDTH-1:0] pulse_in;
reg[WORD_WIDTH:0] tmp_adc_data[0:NUM_INPUTS];
wire[WORD_WIDTH*NUM_INPUTS-1:0] adc_data_a;
wire[NUM_INPUTS-1:0] adc_done;

wire [NUM_INPUTS-1:0]auto_smpclk;
wire [NUM_INPUTS-1:0]cross_smpclk;
wire [NUM_INPUTS-1:0]auto_smpclk_pulse;
wire [NUM_INPUTS-1:0]cross_smpclk_pulse;

localparam SHANNON_OR_SINGLE = (DELAY_SIZE < 5);
localparam SHANNON = (DELAY_SIZE == 4);

reg comm_clk;

wire uart_clk;
wire reset_delayed;
 
wire[NUM_INPUTS-1:0] pwm_out;
wire[NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;

reg signed[PACKET_SIZE-1:0] tx_data;
wire [PAYLOAD_SIZE-1:0] pulses;

reg[NUM_INPUTS-1:0] signal_in;

reg capture_start;

reg[$clog2(MUX_LINES):0] mux_line = 0;

wire integrate;
wire in_capture;
reg enable_tx;

wire[$clog2(NUM_INPUTS):0] current_line;
wire[3:0] baud_rate;
wire[$clog2(NUM_INPUTS):0] order;

wire[8:0] voltage_pwm[0:NUM_INPUTS];
wire[8*NUM_INPUTS-1:0] leds_a;
wire[8*NUM_INPUTS-1:0] test_a;
wire[8*NUM_INPUTS-1:0] voltage_pwm_a;
wire[24*NUM_INPUTS-1:0] cross_current_a;
wire[24*NUM_INPUTS-1:0] cross_start_a;
wire[24*NUM_INPUTS-1:0] auto_current_a;
wire[24*NUM_INPUTS-1:0] auto_start_a;
wire[24*NUM_INPUTS-1:0] cross_increment_a;
wire[24*NUM_INPUTS-1:0] auto_increment_a;
wire[24*NUM_INPUTS-1:0] cross_len_a;
wire[24*NUM_INPUTS-1:0] auto_len_a;
wire[63:0] timestamp;
wire extra_commands;
wire timestamp_reset;
wire timestamp_overflow;

wire spi_done;
wire RXIF; 
wire[7:0] RXREG;
wire TXIF;
wire[7:0] TXREG;

assign integrating = strobe | integrate;
assign in_capture = enable_tx | integrating;

pll pll_block (refclk, pllclk);
dff reset_delay(TXIF, pllclk, intclk, reset_delayed);

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(NUM_INPUTS*1000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
	sysclk,
	~in_capture
);

DIFF_COUNTER #(.WORD_WIDTH(64)) timestamp_block(
	timestamp,
	timestamp_overflow,
	64'd1000000000/CLK_FREQUENCY,
	64'd0,
	1'd0,
	refclk,
	(timestamp_reset&~integrating)|timestamp_overflow
);

if(USE_UART) begin
	CLK_GEN uart_clock_block(
		BAUD_CYCLES>>baud_rate,
		uart_clk,
		pllclk,
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
	intclk,
	in_capture
);

CMD_PARSER #(.NUM_INPUTS(NUM_INPUTS), .HAS_LEDS(HAS_LEDS)) parser (
	RXREG,
	voltage_pwm_a,
	test_a,
	cross_start_a,
	cross_increment_a,
	cross_len_a,
	auto_start_a,
	auto_increment_a,
	auto_len_a,
	leds_a,
	baud_rate,
	order,
	current_line,
	integrate,
	external_clock,
	timestamp_reset,
	extra_commands,
	RXIF
);

COUNTER #(.RESOLUTION(RESOLUTION), .NUM_INPUTS(NUM_INPUTS), .WORD_WIDTH(WORD_WIDTH)) counter (
	pulses[CORRELATIONS_SIZE*RESOLUTION*2+SPECTRA_SIZE*RESOLUTION*2+:NUM_INPUTS*RESOLUTION],
	pllclk,
	adc_data_a,
	leds_a,
	overflow,
	reset_delayed,
	enable
);

CORRELATOR #(
	.NUM_INPUTS(NUM_INPUTS),
	.DELAY_SIZE(DELAY_SIZE),
	.NUM_BASELINES(NUM_INPUTS),
	.RESOLUTION(RESOLUTION),
	.WORD_WIDTH(WORD_WIDTH),
	.USE_SOFT_CLOCK(USE_SOFT_CLOCK),
	.MAX_ORDER(1)
	) autocorrelator (
	pulses[CORRELATIONS_SIZE*RESOLUTION*2+:SPECTRA_SIZE*RESOLUTION*2],
	pllclk,
	auto_current_a,
	adc_data_a,
	auto_smpclk,
	leds_a,
	0,
	reset_delayed,
	enable
);

if(HAS_CROSSCORRELATOR) begin
CORRELATOR #(
	.NUM_INPUTS(NUM_INPUTS),
	.DELAY_SIZE(DELAY_SIZE),
	.NUM_BASELINES(NUM_BASELINES),
	.TAIL_SIZE(LAG_CROSS),
	.HEAD_SIZE(LAG_CROSS),
	.RESOLUTION(RESOLUTION),
	.WORD_WIDTH(WORD_WIDTH),
	.USE_SOFT_CLOCK(USE_SOFT_CLOCK),
	.MAX_ORDER(MAX_ORDER)
	) crosscorrelator (
	pulses[0+:CORRELATIONS_SIZE*RESOLUTION*2],
	pllclk,
	cross_current_a,
	adc_data_a,
	cross_smpclk,
	leds_a,
	order+1,
	reset_delayed,
	enable
);
end

always@(posedge pllclk) begin
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
	mux_out <= 1<<mux_line;
	if(mux_line < MUX_LINES-1) begin
		mux_line <= mux_line+1;
	end else begin
		mux_line <= 0;
	end
end

always@(posedge intclk) begin
	enable_tx <= integrating;
	tx_data[0+:FOOTER_SIZE] <= timestamp;
	tx_data[FOOTER_SIZE+:PAYLOAD_SIZE] <= pulses;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+:16] <= TICK;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+:8] <= (HAS_CROSSCORRELATOR)|(HAS_LEDS<<1)|(HAS_PSU << 2)|(HAS_CUMULATIVE_ONLY << 3);
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+8+:4] <= LAG_CROSS-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+8+4+:4] <= LAG_AUTO-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+8+4+4+:24] <= NUM_INPUTS-1;
	tx_data[FOOTER_SIZE+PAYLOAD_SIZE+16+8+4+4+24+:8] <= RESOLUTION;
end

generate
	genvar a;
	genvar j;
	genvar x;

	for (a=0; a<NUM_INPUTS; a=a+1) begin : lines_block
		reg[23:0] cross_current;
		reg[23:0] auto_current;
		wire[7:0] leds;
		wire[7:0] test;
		wire[23:0] cross_start;
		wire[23:0] auto_start;
		wire[23:0] cross_increment;
		wire[23:0] auto_increment;
		wire[23:0] cross_len;
		wire[23:0] auto_len;

		assign leds = leds_a[a*8+:8];
		assign test = test_a[a*8+:8];
		assign voltage_pwm[a][7:0] = voltage_pwm_a[a*8+:8];
		assign auto_current_a[a*24+:24] = auto_current;
		assign cross_current_a[a*24+:24] = cross_current;
		assign cross_start = cross_start_a[a*24+:24];
		assign auto_start = auto_start_a[a*24+:24];
		assign cross_increment = cross_increment_a[a*24+:24];
		assign auto_increment = auto_increment_a[a*24+:24];
		assign cross_len = cross_len_a[a*24+:24];
		assign auto_len = auto_len_a[a*24+:24];
		assign adc_data_a[a*WORD_WIDTH+:WORD_WIDTH] = tmp_adc_data[a];

		always@(negedge intclk) begin
			if (!SHANNON_OR_SINGLE) begin
				if(!test[1] || !in_capture) begin
					auto_current[12+:12] <= auto_start[12+:12];
					auto_current[0+:12] <= auto_start[0+:12];
				end else begin
					if(auto_current[0+:12] >= DELAY_SIZE) begin
						auto_current[0+:12] <= auto_current[0+:12]-(DELAY_SIZE>>1);
						auto_current[12+:12] <= auto_current[12+:12]+(1+auto_increment/(2*DELAY_SIZE));
					end else if(auto_current[0+:12] < auto_start[0+:12]+auto_len[0+:12]) begin
						auto_current[0+:12] <= auto_current[0+:12]+auto_increment;
					end
				end
			end else begin
				if(!test[1] || !in_capture) begin
					auto_current <= auto_start;
				end else if (auto_current < auto_start + auto_len)
					auto_current <= auto_current+auto_increment;
			end

			if (!SHANNON_OR_SINGLE) begin
				if(!test[2] || !in_capture) begin
					cross_current[12+:12] <= cross_start[12+:12];
					cross_current[0+:12] <= cross_start[0+:12];
				end else begin
					if(cross_current[0+:12] >= DELAY_SIZE) begin
						cross_current[0+:12] <= cross_current[0+:12]-(DELAY_SIZE>>1);
						cross_current[12+:12] <= cross_current[12+:12]+(1+cross_increment/(2*DELAY_SIZE));
					end else if(cross_current[0+:12] < cross_start[0+:12]+cross_len[0+:12]) begin
						cross_current[0+:12] <= cross_current[0+:12]+cross_increment;
					end
				end
			end else begin
				if(!test[1] || !in_capture) begin
					cross_current <= cross_start;
				end else if (cross_current < cross_start + cross_len)
					cross_current <= cross_current+cross_increment;
			end

		end

		always @ (negedge pllclk) begin
			if(~leds[3]) begin
				if(tmp_adc_data[a] != pulse_in[a*WORD_WIDTH+:WORD_WIDTH])
					tmp_adc_data[a] <= pulse_in[a*WORD_WIDTH+:WORD_WIDTH];
				else
					tmp_adc_data[a] <= 0;
			end else
				tmp_adc_data[a] <= pulse_in[a*WORD_WIDTH+:WORD_WIDTH];
		end

		assign pulse_in[a] = (leds[2]?~signal_in[a*WORD_WIDTH+:WORD_WIDTH] : signal_in[a*WORD_WIDTH+:WORD_WIDTH]);
		
		if(HAS_LEDS) begin
			assign lineout[a] = (pwm_out[a]|in_capture)&~overflow[a];
			assign lineout[NUM_INPUTS+a] = adc_done[a];
			assign lineout[NUM_INPUTS*2+a] = ~test[3] ? leds[0] : leds[0]&(pulse_in[a*WORD_WIDTH+:WORD_WIDTH] ^ refclk);
			assign lineout[NUM_INPUTS*3+a] = HAS_PSU ? voltage[a] : leds[1];
		end
		
		CLK_GEN auto_sampling_clock_block(
			(!SHANNON_OR_SINGLE) ? TICK_CYCLES * auto_current_a[a*24+12+:12] : TICK_CYCLES * auto_current_a[a*24+:24],
			auto_smpclk[a],
			pllclk,
			auto_smpclk_pulse[a],
			enable
		);

		CLK_GEN cross_sampling_clock_block(
			(!SHANNON_OR_SINGLE) ? TICK_CYCLES * cross_current_a[a*24+12+:12] : TICK_CYCLES * cross_current_a[a*24+:24],
			cross_smpclk[a],
			pllclk,
			cross_smpclk_pulse[a],
			enable
		);
	end
endgenerate
endmodule
