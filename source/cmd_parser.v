/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module CMD_PARSER(
	cmd,
	voltage_pwm,
	test,
	cross_start,
	cross_increment,
	cross_len,
	auto_start,
	auto_increment,
	auto_len,
	leds,
	baud_rate,
	order,
	current_line,
	integrating,
	external_clock,
	timestamp_reset,
	extra_commands,
	clk
);

parameter NUM_INPUTS=256;
parameter HAS_LEDS=0;
parameter DELAY_SIZE = 4;

parameter[3:0]
	CLEAR = 0,
	SET_LINE = 1,
	SET_LEDS = 2,
	SET_BAUD_RATE = 3,
	SET_VOLTAGE = 4,
	SET_DELAY = 8,
	ENABLE_TEST = 12,
	ENABLE_CAPTURE = 13;

localparam SHANNON=(DELAY_SIZE == 4);
localparam SINGLE=(DELAY_SIZE == 0);
localparam SHANNON_OR_SINGLE=(SHANNON|SINGLE);

localparam DELAY_SIZE_LEN = SHANNON_OR_SINGLE ? 24 : (($clog2(DELAY_SIZE) & ~3) + 4);
localparam NUM_INPUTS_LEN = (($clog2(NUM_INPUTS) & ~3) + 4);

input wire clk;
input wire [7:0] cmd;

output reg[8*NUM_INPUTS-1:0] voltage_pwm = 0;
output reg[8*NUM_INPUTS-1:0] test = 0;
output reg[8*NUM_INPUTS-1:0] leds = 0;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] cross_start = 0;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] auto_start = 0;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] cross_increment = 1;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] auto_increment = 1;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] cross_len = 1023;
output reg[DELAY_SIZE_LEN*NUM_INPUTS-1:0] auto_len = 1;
output reg[3:0] baud_rate = 0;
output reg[NUM_INPUTS_LEN:0] order = 0;
output reg[NUM_INPUTS_LEN:0] current_line = 0;
output reg integrating = 0;
output reg external_clock = 0;
output reg timestamp_reset = 1;
output reg extra_commands = 0;

reg[7:0] word_idx = 0;
reg[7:0] word_len = 0;

always@(posedge clk) begin
	if (cmd[3:0] == CLEAR) begin
		case (cmd[7:4])
			SET_LINE:
				current_line <= 0;
			SET_LEDS:
				leds <= 0;
			SET_BAUD_RATE:
				if(extra_commands)
					order <= 0;
				else
					baud_rate <= 0;
			SET_VOLTAGE: 
				voltage_pwm <= 0;
			SET_DELAY: begin
				cross_start <= 0;
				auto_start <= 0;
				cross_increment <= 1;
				auto_increment <= 1;
				cross_len <= 1;
				auto_len <= 1;
			end
			ENABLE_TEST:
				test <= 0;
			ENABLE_CAPTURE: begin
				integrating <= 0;
				external_clock <= 0;
				timestamp_reset <= 1;
				extra_commands <= 0;
			end
		endcase
		word_idx <= 0;
		word_len <= 0;
	end else if (cmd[3:0] == ENABLE_CAPTURE) begin
		integrating <= cmd[4];
		external_clock <= cmd[5];
		timestamp_reset <= cmd[6];
		extra_commands <= cmd[7];
		if(extra_commands) begin
		end
	end else if (cmd[3:0] == SET_LINE) begin
		if(word_len < 1) begin
			word_len <= cmd[7:4];
			word_idx <= 0;
			current_line <= 0;
		end else if(word_idx < word_len) begin
			current_line[word_idx*4+:4] <= cmd[7:4];
			word_idx <= word_idx+1;
		end else
			word_len <= 0;
	end else if (cmd[3:0] == SET_LEDS && HAS_LEDS) begin
		leds[current_line*8+4*extra_commands+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_BAUD_RATE) begin
		if (extra_commands)
			if(word_len < 1) begin
				word_len <= cmd[7:4];
				word_idx <= 0;
				order <= 0;
			end else if(word_idx < word_len) begin
				order[word_idx*4+:4] <= cmd[7:4];
				word_idx <= word_idx+1;
			end else
				word_len <= 0;
		else
			baud_rate <= cmd[7:4];
	end else if (cmd[3:0] == SET_DELAY) begin
		if(word_len < 1) begin 
			word_len <= cmd[7:4];
			word_idx <= 0;
				case(test[current_line*8+4+:2])
			0:
				if(extra_commands)
					auto_increment <= 0;
				else
					cross_increment <= 0;
			1:
				if(extra_commands) 
					auto_len <= 0;
				else
					cross_len <= 0;
			2:
				if(extra_commands)
					auto_start <= 0;
				else
					cross_start <= 0;
			endcase
		end else if(word_idx < word_len) begin
			case(test[current_line*8+4+:2])
			0:
				if(extra_commands)
					auto_increment [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
				else
					cross_increment [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
			1:
				if(extra_commands) 
					auto_len [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
				else
					cross_len [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
			2:
				if(extra_commands)
					auto_start [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
				else
					cross_start [current_line*DELAY_SIZE_LEN+word_idx*4+:4] <= cmd[7:4];
			endcase
				word_idx <= word_idx+1;
		end else
			word_len <= 0;
	end else if (cmd[3:0] == ENABLE_TEST) begin
		test[current_line*8+4*extra_commands+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_VOLTAGE) begin
		voltage_pwm[current_line*8+4*extra_commands+:4] <= cmd[7:4];
	end
end

endmodule
