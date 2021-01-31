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

module CMD_PARSER(
	cmd,
	voltage_pwm,
	test,
	cross_idx,
	auto_idx,
	leds,
	clock_divider,
	baud_rate,
	current_line,
	integrating,
	clk
);

parameter NUM_INPUTS=8;
parameter HAS_LED_FLAGS=0;

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

output reg[4*NUM_INPUTS-1:0] voltage_pwm = 0;
output reg[4*NUM_INPUTS-1:0] test = 0;
output reg[4*NUM_INPUTS-1:0] leds = 0;
output reg[12*NUM_INPUTS-1:0] cross_idx = 0;
output reg[12*NUM_INPUTS-1:0] auto_idx = 0;
output reg[3:0] clock_divider = 0;
output reg[3:0] baud_rate = 0;
output reg[7:0] current_line = 0;
output reg integrating = 0;

always@(posedge clk) begin
	if (cmd[3:0] == CLEAR) begin
		cross_idx[current_line*12+:12] <= 0;
		auto_idx[current_line*12+:12] <= 0;
	end else if (cmd[3:0] == ENABLE_CAPTURE) begin
		integrating <= cmd[4];
	end else if (cmd[3:0] == SET_LINE) begin
		current_line[cmd[7:6]*2+:2] <= cmd[5:4];
	end else if (cmd[3:0] == SET_LEDS && HAS_LED_FLAGS) begin
		leds[current_line*4+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_BAUD_RATE) begin
		baud_rate <= cmd[7:4];
	end else if ((cmd[3:0]&4'b1100) == SET_DELAY) begin
		if (cmd[7])
			auto_idx [current_line*12+(cmd[1:0]*3)+:3] <= cmd[6:4];
		else
			cross_idx [current_line*12+(cmd[1:0]*3)+:3] <= cmd[6:4];
	end else if (cmd[3:0] == SET_FREQ_DIV) begin
		clock_divider <= cmd[7:4];
	end else if (cmd[3:0] == ENABLE_TEST) begin
		test[current_line*4+:4] <= cmd[7:4];
	end else if (cmd[3:0] == SET_VOLTAGE) begin
		voltage_pwm[current_line*4+:4] <= cmd[7:4];
	end
end

endmodule
