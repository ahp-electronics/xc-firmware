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
	cross_idx,
	cross_len,
	cross_increment,
	auto_idx,
	auto_len,
	auto_increment,
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

parameter NUM_INPUTS=8;
parameter HAS_LEDS=0;

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
	
input wire clk;
input wire [7:0] cmd;

output reg[8*NUM_INPUTS-1:0] voltage_pwm = 0;
output reg[8*NUM_INPUTS-1:0] test = 0;
output reg[8*NUM_INPUTS-1:0] leds = 0;
output reg[20*NUM_INPUTS-1:0] cross_idx = 0;
output reg[20*NUM_INPUTS-1:0] auto_idx = 0;
output reg[20*NUM_INPUTS-1:0] cross_len = 0;
output reg[20*NUM_INPUTS-1:0] auto_len = 0;
output reg[12*NUM_INPUTS-1:0] cross_increment = 1;
output reg[12*NUM_INPUTS-1:0] auto_increment = 1;
output reg[3:0] baud_rate = 0;
output reg[3:0] order = 0;
output reg[7:0] current_line = 0;
output reg integrating = 0;
output reg external_clock = 0;
output reg timestamp_reset = 1;
output reg extra_commands = 0;
always@(posedge clk) begin
	if (cmd[3:0] == CLEAR) begin
		cross_idx[current_line*12+:12] <= 0;
		auto_idx[current_line*12+:12] <= 0;
	end else if (cmd[3:0] == ENABLE_CAPTURE) begin
		integrating <= cmd[4];
		external_clock <= cmd[5];
		timestamp_reset <= cmd[6];
		extra_commands <= cmd[7];
	end else if (cmd[3:0] == SET_LINE) begin
		current_line[cmd[7:6]*2+:2] <= cmd[5:4];
	end else if (cmd[3:0] == SET_LEDS && HAS_LEDS) begin
		leds[current_line*8+4*extra_commands+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_BAUD_RATE) begin
		if (cmd[7])
			order <= cmd[7:4];
		else
			baud_rate <= cmd[7:4];
	end else if ((cmd[3:0]&4'b1100) == SET_DELAY) begin
		if(extra_commands) begin
			if(test[current_line*8+7]) begin
				if (cmd[7])
					auto_increment [current_line*12+(cmd[1:0]*3)+:3] <= cmd[6:4];
				else
					cross_increment [current_line*12+(cmd[1:0]*3)+:3] <= cmd[6:4];
			end else begin
				if (cmd[7])
					auto_len [current_line*20+(cmd[1:0]*3)+:3] <= cmd[6:4];
				else
					cross_len [current_line*20+(cmd[1:0]*3)+:3] <= cmd[6:4];
			end
		end else begin
			if (cmd[7])
				auto_idx [current_line*20+(cmd[1:0]*3)+:3] <= cmd[6:4];
			else
				cross_idx [current_line*20+(cmd[1:0]*3)+:3] <= cmd[6:4];
		end
	end else if (cmd[3:0] == SET_FREQ_DIV) begin
		if(extra_commands) begin
			if (cmd[7])
				auto_len [current_line*20+12+(cmd[6]*2)+:2] <= cmd[5:4];
			else
				cross_len [current_line*20+12+(cmd[6]*2)+:2] <= cmd[5:4];
		end else begin
			if (cmd[7])
				auto_idx [current_line*20+12+(cmd[6]*2)+:2] <= cmd[5:4];
			else
				cross_idx [current_line*20+12+(cmd[6]*2)+:2] <= cmd[5:4];
		end
	end else if (cmd[3:0] == ENABLE_TEST) begin
		test[current_line*8+4*extra_commands+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_VOLTAGE) begin
		voltage_pwm[current_line*8+cmd[7:6]*2+:2] <= cmd[5:4];
	end
end

endmodule
