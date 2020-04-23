module correlator (
	TX,
	RX,
	pulse_in,
	pulse_out,
	clki,
	sample_clk_pulse,
	integration_clk_pulse,
	active_line
	);

parameter SECOND = 1000000000;
parameter CLK_FREQUENCY = 400000000;
parameter BAUD_RATE = 2000000;

parameter RESOLUTION = 16;
parameter NUM_INPUTS = 12;
parameter MAX_DELAY = 1;
parameter NUM_CORRELATORS = NUM_INPUTS*(NUM_INPUTS-1)/2;

output wire TX;
input wire RX;
input wire[NUM_INPUTS-1:0] pulse_in;
output wire[NUM_INPUTS-1:0] pulse_out;
output wire sample_clk_pulse;
output wire integration_clk_pulse;
output wire[31:0] active_line;
input wire clki;
wire clk;
wire[NUM_INPUTS-1:0] in;

pll (clki, clk);

delay1 #(.RESOLUTION(NUM_INPUTS)) delay(clk, ~pulse_in, in);
assign pulse_out = ~in&~pulse_in;

main #(.CLK_FREQUENCY(CLK_FREQUENCY), .RESOLUTION(RESOLUTION), .NUM_INPUTS(NUM_INPUTS), .BAUD_RATE(BAUD_RATE), .MAX_DELAY(MAX_DELAY)) main_block(
	TX,
	RX,
	pulse_out,
	clk,
	sample_clk_pulse,
	integration_clk_pulse,
	active_line
);
endmodule
