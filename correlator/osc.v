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

module pwm_osc (
	step_tau,
	pwm_out,
	clk,
	enable
	);
parameter CLK_FREQUENCY = 14000000;
parameter MICROSECOND = CLK_FREQUENCY/2000000000;
parameter mid_value = 7;
parameter max_value = mid_value<<1;

input wire[31:0] mid_value;
input wire[31:0] phase_offset;
input wire[31:0] step_tau;
input wire clk;
output wire pwm_out;
input wire enable;
reg pwm_clk;
reg sin_clk;
wire overflow;
reg[4:0] pwm_idx = 16;
reg[31:0] tick;
reg[31:0] index;
wire[4:0] pwm_value;
wire[4:0] idx_value;
assign max_value = mid_value << 1;

always@(posedge clk) begin
	tick <= tick+1;
	if(tick >= MICROSECOND) begin
		pwm_clk <= ~pwm_clk;
		tick <= 0;
	end
end

always@(posedge pwm_clk) begin
	if(enable)
		index <= index+1;
	if(index >= step_tau) begin
		pwm_idx <= pwm_idx+1;
		index <= 0;
	end
end
 
assign idx_value = pwm_idx % max_value;
assign pwm_value = (idx_value > mid_value) ? max_value-idx_value : idx_value;

endmodule