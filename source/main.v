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
localparam SPECTRA_SIZE = NUM_INPUTS*LAG_AUTO;
localparam CORRELATIONS_HEAD_TAIL_SIZE = LAG_CROSS*2-1;
localparam MAX_LAG = (LAG_AUTO > CORRELATIONS_HEAD_TAIL_SIZE) ? LAG_AUTO : CORRELATIONS_HEAD_TAIL_SIZE;
localparam CORRELATIONS_SIZE = (HAS_CROSSCORRELATOR*NUM_BASELINES*CORRELATIONS_HEAD_TAIL_SIZE);
localparam PAYLOAD_SIZE = ((CORRELATIONS_SIZE+SPECTRA_SIZE)*2+NUM_INPUTS)*RESOLUTION;
localparam HEADER_SIZE = 64;
localparam FOOTER_SIZE = 64;
localparam PACKET_SIZE = HEADER_SIZE+PAYLOAD_SIZE+FOOTER_SIZE;

localparam MAX_LAG_AUTO = DELAY_SIZE+LAG_AUTO-1;
localparam MAX_LAG_CROSS = DELAY_SIZE-1;
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
output wire pllclk;
input wire strobe;

wire external_clock;
wire integrating;

wire[NUM_INPUTS*WORD_WIDTH-1:0] pulse_in;
wire[WORD_WIDTH-1:0] adc_data[0:NUM_INPUTS];
wire[NUM_INPUTS-1:0] adc_done;

wire autoclk[NUM_INPUTS-1:0];
wire autoclk_full[NUM_INPUTS-1:0];
wire autoclk_pulse[NUM_INPUTS-1:0];

wire crossclk[NUM_INPUTS-1:0];
wire crossclk_full[NUM_INPUTS-1:0];
wire crossclk_pulse[NUM_INPUTS-1:0];

wire uart_clk;
wire reset_delayed;
 
wire[NUM_INPUTS-1:0] pwm_out;
wire[NUM_INPUTS-1:0] overflow;

wire[NUM_INPUTS-1:0] voltage;

wire tx_done;
reg signed[PACKET_SIZE-1:0] tx_data;
wire [PAYLOAD_SIZE-1:0] pulses;

wire[NUM_INPUTS*WORD_WIDTH-1:0] spectral_lines [0:DELAY_SIZE+MAX_LAG];
wire[NUM_INPUTS*WORD_WIDTH-1:0] cross_lines [0:DELAY_SIZE+MAX_LAG];

reg[NUM_INPUTS-1:0] signal_in;

reg[7:0] mux_line = 0;

wire[(DELAY_SIZE+MAX_LAG)*WORD_WIDTH-1:0] auto_delays[0:NUM_INPUTS];
wire[(DELAY_SIZE+MAX_LAG)*WORD_WIDTH-1:0] cross_delays[0:NUM_INPUTS];
wire integrate;
wire in_capture;
reg enable_tx;

wire[7:0] current_line;
wire[3:0] baud_rate;

wire[7:0] leds[0:NUM_INPUTS];
wire[3:0] test[0:NUM_INPUTS];
wire[8:0] voltage_pwm[0:NUM_INPUTS];

wire[12*NUM_INPUTS-1:0] cross_tmp_a;
wire[12*NUM_INPUTS-1:0] cross_len_a;
wire[12*NUM_INPUTS-1:0] auto_tmp_a;
wire[12*NUM_INPUTS-1:0] auto_len_a;

wire[4*NUM_INPUTS-1:0] cross_div_a;
wire[4*NUM_INPUTS-1:0] cross_div_len_a;
wire[4*NUM_INPUTS-1:0] auto_div_a;
wire[4*NUM_INPUTS-1:0] auto_div_len_a;

reg[15:0] cross_idx [0:NUM_INPUTS];
reg[15:0] auto_idx [0:NUM_INPUTS];

reg[11:0] cross [0:NUM_INPUTS];
reg[11:0] auto [0:NUM_INPUTS];
reg[3:0] cross_div [0:NUM_INPUTS];
reg[3:0] auto_div [0:NUM_INPUTS];

wire[11:0] cross_tmp [0:NUM_INPUTS];
wire[11:0] auto_tmp [0:NUM_INPUTS];
wire[11:0] cross_len [0:NUM_INPUTS];
wire[11:0] auto_len [0:NUM_INPUTS];

wire[3:0] cross_div_tmp [0:NUM_INPUTS];
wire[3:0] auto_div_tmp [0:NUM_INPUTS];
wire[3:0] cross_div_len [0:NUM_INPUTS];
wire[3:0] auto_div_len [0:NUM_INPUTS];

wire[8*NUM_INPUTS-1:0] leds_a;
wire[8*NUM_INPUTS-1:0] test_a;
wire[8*NUM_INPUTS-1:0] voltage_pwm_a;
wire[63:0] timestamp;
wire extra_commands;
wire timestamp_reset;
wire timestamp_overflow;

wire[NUM_LINES-1:0] auto_overflow;
wire[NUM_LINES-1:0] cross_overflow;

wire spi_done;
wire RXIF;
wire[7:0] RXREG;
wire TXIF;
wire[7:0] TXREG;

assign integrating = strobe | integrate;
assign in_capture = enable_tx | integrating;
assign intclk = tx_done;

pll pll_block (refclk, pllclk);
dff reset_delay(pllclk, uart_clk, intclk, reset_delayed);
reg[7:0] CK;

indicators #(.CLK_FREQUENCY(CLK_FREQUENCY), .CYCLE_MS(NUM_INPUTS*1000), .CHANNELS(NUM_INPUTS), .RESOLUTION(8)) indicators_block(
	pwm_out,
	sysclk,
	~in_capture
);

COUNTER #(.WORD_WIDTH(64)) timestamp_block(
	timestamp,
	timestamp_overflow,
	1000000000/CLK_FREQUENCY,
	1,
	1,
	1,
	refclk,
	(timestamp_reset&~integrating)|timestamp_overflow
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
	cross_len_a,
	auto_tmp_a,
	auto_len_a,
	cross_div_a,
	cross_div_len_a,
	auto_div_a,
	auto_div_len_a,
	leds_a,
	baud_rate,
	current_line,
	integrate,
	external_clock,
	timestamp_reset,
	extra_commands,
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
		assign leds[a] = leds_a[a*8+:8];
		assign test[a] = test_a[a*8+:8];
		assign voltage_pwm[a][7:0] = voltage_pwm_a[a*8+:8];

		assign cross_tmp[a] = cross_tmp_a[a*12+:12];
		assign auto_tmp[a] = auto_tmp_a[a*12+:12];
		assign cross_len[a] = cross_len_a[a*12+:12];
		assign auto_len[a] = auto_len_a[a*12+:12];

		assign cross_div_tmp[a] = cross_div_a[a*4+:4];
		assign auto_div_tmp[a] = auto_div_a[a*4+:4];
		assign cross_div_len[a] = cross_div_len_a[a*4+:4];
		assign auto_div_len[a] = auto_div_len_a[a*4+:4];

		assign auto_overflow[a] = (auto_idx[a] == ((auto_len[a]*(auto_div_len[a]*2+1))>>1));
		assign cross_overflow[a] = (cross_idx[a] == ((cross_len[a]*(cross_div_len[a]*2+1))>>1));

		CLK_GEN auto_clock_block(
			TICK_CYCLES<<auto_div[a],
			autoclk[a],
			pllclk,
			autoclk_pulse[a],
			enable
		);

		CLK_GEN cross_clock_block(
			TICK_CYCLES<<cross_div[a],
			crossclk[a],
			pllclk,
			crossclk_pulse[a],
			enable
		);

		always@(posedge intclk) begin
			if(test[a][1]) begin
				if(auto_overflow[a]) begin
					auto_idx[a] <= 0;
					auto[a] <= auto_tmp[a];
					auto_div[a] <= auto_div_tmp[a];
				end else begin
					auto_idx[a] <= auto_idx[a]+1;
					if(auto[a] == DELAY_SIZE) begin
						auto[a] <= auto[a]>>1;
						auto_div[a] <= auto_div[a]+1;
					end else
						auto[a] <= auto[a]+1;
				end
			end else
				auto[a] <= auto_tmp[a];
			if(test[a][2]) begin
				if(cross_overflow[a]) begin
					cross_idx[a] <= 0;
					cross[a] <= cross_tmp[a];
					cross_div[a] <= cross_div_tmp[a];
				end else begin
					if (cross[a] == DELAY_SIZE-1) begin
						cross[a] <= cross[a] >> 1;
						cross_div[a] <= cross_div[a]+1;
					end else
						cross_idx[a] <= cross_idx[a]+1;
				end
			end else
				cross[a] <= cross_tmp[a];
		end

		for(x = 0; x < DELAY_SIZE+MAX_LAG; x=x+512) begin
			for(j = x; j < x + 512 && j < DELAY_SIZE+MAX_LAG; j=j+1) begin
				assign spectral_lines[j][a*WORD_WIDTH+:WORD_WIDTH] = auto_delays[a][j*WORD_WIDTH+:WORD_WIDTH];
				assign cross_lines[j][a*WORD_WIDTH+:WORD_WIDTH] = cross_delays[a][j*WORD_WIDTH+:WORD_WIDTH];
			end
		end
				
		assign adc_data[a] = pulse_in[a*WORD_WIDTH+:WORD_WIDTH];
		
		if(HAS_LEDS) begin
			assign pulse_in[a] = (leds[a][2]?~signal_in[a*WORD_WIDTH+:WORD_WIDTH] : signal_in[a*WORD_WIDTH+:WORD_WIDTH]);
		end else begin
			assign pulse_in[a] = signal_in[a*WORD_WIDTH+:WORD_WIDTH];
		end
		
		if(HAS_LEDS) begin
			assign lineout[a] = (pwm_out[a]|in_capture)&~overflow[a];
			assign lineout[NUM_INPUTS+a] = adc_done[a];
			assign lineout[NUM_INPUTS*2+a] = ~test[a][3] ? leds[a][0] : leds[a][0]&(spectral_lines[auto[a]][a*WORD_WIDTH] ^ refclk);
			assign lineout[NUM_INPUTS*3+a] = HAS_PSU ? voltage[a] : leds[a][1];
		end

		fifo #(.WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) spectral_line(pllclk, autoclk[a], adc_data[a], auto_delays[a]);
		fifo #(.WORD_WIDTH(WORD_WIDTH), .DELAY_SIZE(DELAY_SIZE+MAX_LAG)) delay_line(pllclk, crossclk[a], adc_data[a], cross_delays[a]);

		COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) counters_block (
			pulses[(CORRELATIONS_SIZE*2+NUM_INPUTS*LAG_AUTO*2+NUM_INPUTS-1-a)*RESOLUTION+:RESOLUTION],
			overflow[a],
			spectral_lines[cross[a]][a*WORD_WIDTH+:WORD_WIDTH],
			0,
			leds[a][3],
			0,
			autoclk[a],
			reset_delayed
		);
		for(z=0; z < MAX_LAG*2; z=z+512) begin : jitter_block
			for(y=z; y < z+512 && y < MAX_LAG*2; y=y+1) begin : jitter_inner_block
				if(y<LAG_AUTO) begin
					COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) spectra_block_r (
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION*2+:RESOLUTION],
						,
						spectral_lines[0][a*WORD_WIDTH+:WORD_WIDTH],
						spectral_lines[auto[a]+y][a*WORD_WIDTH+:WORD_WIDTH],
						leds[a][3],
						~leds[a][4],
						pllclk,
						reset_delayed
					);
					COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH), .HAS_CUMULATIVE_ONLY(HAS_CUMULATIVE_ONLY)) spectra_block_i (
						pulses[((CORRELATIONS_SIZE+NUM_INPUTS-a)*LAG_AUTO-1-y)*RESOLUTION*2+RESOLUTION+:RESOLUTION],
						,
						~spectral_lines[0][a*WORD_WIDTH+:WORD_WIDTH],
						spectral_lines[auto[a]+y][a*WORD_WIDTH+:WORD_WIDTH],
						leds[a][3],
						~leds[a][4],
						pllclk,
						reset_delayed
					);
				end
				if(HAS_CROSSCORRELATOR) begin
					if(y!=LAG_CROSS&&y<CORRELATIONS_HEAD_TAIL_SIZE) begin
						for (b=a+1; b<NUM_INPUTS; b=b+1) begin : correlators_block
							COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) counters_block_r (
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION*2+:RESOLUTION],
								,
								cross_lines[(cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0))][a*WORD_WIDTH+:WORD_WIDTH],
								cross_lines[(cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0))][b*WORD_WIDTH+:WORD_WIDTH],
								leds[a][3]&leds[b][3],
								~(leds[a][4]&leds[b][4]),
								pllclk,
								reset_delayed
							);
							COUNTER #(.RESOLUTION(RESOLUTION), .WORD_WIDTH(WORD_WIDTH)) correlators_block_i (
								pulses[((CORRELATIONS_SIZE-((a*(NUM_INPUTS+NUM_INPUTS-a-1))>>1)-b+a+1)*CORRELATIONS_HEAD_TAIL_SIZE-(y>LAG_CROSS?y-1:y)-1)*RESOLUTION*2+RESOLUTION+:RESOLUTION],
								,
								~cross_lines[(cross[a]+(y<LAG_CROSS?LAG_CROSS-y-1:0))][a*WORD_WIDTH+:WORD_WIDTH],
								cross_lines[(cross[b]+(y>LAG_CROSS?y-LAG_CROSS:0))][b*WORD_WIDTH+:WORD_WIDTH],
								leds[a][3]&leds[b][3],
								~(leds[a][4]&leds[b][4]),
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
