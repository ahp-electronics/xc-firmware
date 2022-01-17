/* Copyright (C) Ilia Platone - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Ilia Platone <info@iliaplatone.com>, January, 2017
 */

`timescale 1 ns / 1 ps

module sine (
	max_value,
	pwm_out,
	clk,
	enable
	);
parameter CLK_FREQUENCY = 10000000;
parameter PWM_FREQUENCY = 100000;
parameter SIN_FREQUENCY = 1000;
parameter RESOLUTION = 8;

parameter DIVIDER = CLK_FREQUENCY/(PWM_FREQUENCY<<RESOLUTION);
parameter CYCLE = PWM_FREQUENCY/SIN_FREQUENCY;
reg[7:0] sine[0:255];

initial begin
	sine[0] <= 8'd130;
	sine[1] <= 8'd133;
	sine[2] <= 8'd136;
	sine[3] <= 8'd139;
	sine[4] <= 8'd143;
	sine[5] <= 8'd146;
	sine[6] <= 8'd149;
	sine[7] <= 8'd152;
	sine[8] <= 8'd155;
	sine[9] <= 8'd158;
	sine[10] <= 8'd161;
	sine[11] <= 8'd164;
	sine[12] <= 8'd167;
	sine[13] <= 8'd170;
	sine[14] <= 8'd173;
	sine[15] <= 8'd176;
	sine[16] <= 8'd179;
	sine[17] <= 8'd182;
	sine[18] <= 8'd184;
	sine[19] <= 8'd187;
	sine[20] <= 8'd190;
	sine[21] <= 8'd193;
	sine[22] <= 8'd195;
	sine[23] <= 8'd198;
	sine[24] <= 8'd200;
	sine[25] <= 8'd203;
	sine[26] <= 8'd205;
	sine[27] <= 8'd208;
	sine[28] <= 8'd210;
	sine[29] <= 8'd213;
	sine[30] <= 8'd215;
	sine[31] <= 8'd217;
	sine[32] <= 8'd219;
	sine[33] <= 8'd221;
	sine[34] <= 8'd224;
	sine[35] <= 8'd226;
	sine[36] <= 8'd228;
	sine[37] <= 8'd229;
	sine[38] <= 8'd231;
	sine[39] <= 8'd233;
	sine[40] <= 8'd235;
	sine[41] <= 8'd236;
	sine[42] <= 8'd238;
	sine[43] <= 8'd239;
	sine[44] <= 8'd241;
	sine[45] <= 8'd242;
	sine[46] <= 8'd244;
	sine[47] <= 8'd245;
	sine[48] <= 8'd246;
	sine[49] <= 8'd247;
	sine[50] <= 8'd248;
	sine[51] <= 8'd249;
	sine[52] <= 8'd250;
	sine[53] <= 8'd251;
	sine[54] <= 8'd251;
	sine[55] <= 8'd252;
	sine[56] <= 8'd253;
	sine[57] <= 8'd253;
	sine[58] <= 8'd254;
	sine[59] <= 8'd254;
	sine[60] <= 8'd254;
	sine[61] <= 8'd254;
	sine[62] <= 8'd254;
	sine[63] <= 8'd254;
	sine[64] <= 8'd254;
	sine[65] <= 8'd254;
	sine[66] <= 8'd254;
	sine[67] <= 8'd254;
	sine[68] <= 8'd254;
	sine[69] <= 8'd253;
	sine[70] <= 8'd253;
	sine[71] <= 8'd252;
	sine[72] <= 8'd251;
	sine[73] <= 8'd251;
	sine[74] <= 8'd250;
	sine[75] <= 8'd249;
	sine[76] <= 8'd248;
	sine[77] <= 8'd247;
	sine[78] <= 8'd246;
	sine[79] <= 8'd245;
	sine[80] <= 8'd244;
	sine[81] <= 8'd242;
	sine[82] <= 8'd241;
	sine[83] <= 8'd239;
	sine[84] <= 8'd238;
	sine[85] <= 8'd236;
	sine[86] <= 8'd235;
	sine[87] <= 8'd233;
	sine[88] <= 8'd231;
	sine[89] <= 8'd229;
	sine[90] <= 8'd228;
	sine[91] <= 8'd226;
	sine[92] <= 8'd224;
	sine[93] <= 8'd221;
	sine[94] <= 8'd219;
	sine[95] <= 8'd217;
	sine[96] <= 8'd215;
	sine[97] <= 8'd213;
	sine[98] <= 8'd210;
	sine[99] <= 8'd208;
	sine[100] <= 8'd205;
	sine[101] <= 8'd203;
	sine[102] <= 8'd200;
	sine[103] <= 8'd198;
	sine[104] <= 8'd195;
	sine[105] <= 8'd193;
	sine[106] <= 8'd190;
	sine[107] <= 8'd187;
	sine[108] <= 8'd184;
	sine[109] <= 8'd182;
	sine[110] <= 8'd179;
	sine[111] <= 8'd176;
	sine[112] <= 8'd173;
	sine[113] <= 8'd170;
	sine[114] <= 8'd167;
	sine[115] <= 8'd164;
	sine[116] <= 8'd161;
	sine[117] <= 8'd158;
	sine[118] <= 8'd155;
	sine[119] <= 8'd152;
	sine[120] <= 8'd149;
	sine[121] <= 8'd146;
	sine[122] <= 8'd143;
	sine[123] <= 8'd140;
	sine[124] <= 8'd136;
	sine[125] <= 8'd133;
	sine[126] <= 8'd130;
	sine[127] <= 8'd127;
	sine[128] <= 8'd124;
	sine[129] <= 8'd121;
	sine[130] <= 8'd118;
	sine[131] <= 8'd115;
	sine[132] <= 8'd111;
	sine[133] <= 8'd108;
	sine[134] <= 8'd105;
	sine[135] <= 8'd102;
	sine[136] <= 8'd99;
	sine[137] <= 8'd96;
	sine[138] <= 8'd93;
	sine[139] <= 8'd90;
	sine[140] <= 8'd87;
	sine[141] <= 8'd84;
	sine[142] <= 8'd81;
	sine[143] <= 8'd78;
	sine[144] <= 8'd75;
	sine[145] <= 8'd72;
	sine[146] <= 8'd70;
	sine[147] <= 8'd67;
	sine[148] <= 8'd64;
	sine[149] <= 8'd61;
	sine[150] <= 8'd59;
	sine[151] <= 8'd56;
	sine[152] <= 8'd54;
	sine[153] <= 8'd51;
	sine[154] <= 8'd49;
	sine[155] <= 8'd46;
	sine[156] <= 8'd44;
	sine[157] <= 8'd41;
	sine[158] <= 8'd39;
	sine[159] <= 8'd37;
	sine[160] <= 8'd35;
	sine[161] <= 8'd33;
	sine[162] <= 8'd30;
	sine[163] <= 8'd28;
	sine[164] <= 8'd26;
	sine[165] <= 8'd25;
	sine[166] <= 8'd23;
	sine[167] <= 8'd21;
	sine[168] <= 8'd19;
	sine[169] <= 8'd18;
	sine[170] <= 8'd16;
	sine[171] <= 8'd15;
	sine[172] <= 8'd13;
	sine[173] <= 8'd12;
	sine[174] <= 8'd10;
	sine[175] <= 8'd9;
	sine[176] <= 8'd8;
	sine[177] <= 8'd7;
	sine[178] <= 8'd6;
	sine[179] <= 8'd5;
	sine[180] <= 8'd4;
	sine[181] <= 8'd3;
	sine[182] <= 8'd3;
	sine[183] <= 8'd2;
	sine[184] <= 8'd1;
	sine[185] <= 8'd1;
	sine[186] <= 8'd0;
	sine[187] <= 8'd0;
	sine[188] <= 8'd0;
	sine[189] <= 8'd0;
	sine[190] <= 8'd0;
	sine[191] <= 8'd0;
	sine[192] <= 8'd0;
	sine[193] <= 8'd0;
	sine[194] <= 8'd0;
	sine[195] <= 8'd0;
	sine[196] <= 8'd0;
	sine[197] <= 8'd1;
	sine[198] <= 8'd1;
	sine[199] <= 8'd2;
	sine[200] <= 8'd3;
	sine[201] <= 8'd3;
	sine[202] <= 8'd4;
	sine[203] <= 8'd5;
	sine[204] <= 8'd6;
	sine[205] <= 8'd7;
	sine[206] <= 8'd8;
	sine[207] <= 8'd9;
	sine[208] <= 8'd10;
	sine[209] <= 8'd12;
	sine[210] <= 8'd13;
	sine[211] <= 8'd15;
	sine[212] <= 8'd16;
	sine[213] <= 8'd18;
	sine[214] <= 8'd19;
	sine[215] <= 8'd21;
	sine[216] <= 8'd23;
	sine[217] <= 8'd25;
	sine[218] <= 8'd26;
	sine[219] <= 8'd28;
	sine[220] <= 8'd30;
	sine[221] <= 8'd33;
	sine[222] <= 8'd35;
	sine[223] <= 8'd37;
	sine[224] <= 8'd39;
	sine[225] <= 8'd41;
	sine[226] <= 8'd44;
	sine[227] <= 8'd46;
	sine[228] <= 8'd49;
	sine[229] <= 8'd51;
	sine[230] <= 8'd54;
	sine[231] <= 8'd56;
	sine[232] <= 8'd59;
	sine[233] <= 8'd61;
	sine[234] <= 8'd64;
	sine[235] <= 8'd67;
	sine[236] <= 8'd70;
	sine[237] <= 8'd72;
	sine[238] <= 8'd75;
	sine[239] <= 8'd78;
	sine[240] <= 8'd81;
	sine[241] <= 8'd84;
	sine[242] <= 8'd87;
	sine[243] <= 8'd90;
	sine[244] <= 8'd93;
	sine[245] <= 8'd96;
	sine[246] <= 8'd99;
	sine[247] <= 8'd102;
	sine[248] <= 8'd105;
	sine[249] <= 8'd108;
	sine[250] <= 8'd111;
	sine[251] <= 8'd114;
	sine[252] <= 8'd118;
	sine[253] <= 8'd121;
	sine[254] <= 8'd124;
	sine[255] <= 8'd127;
end

input wire clk;
input wire[RESOLUTION-1:0] max_value;
output wire pwm_out;
input wire enable;
reg pwm_clk;
wire overflow;
reg[7:0] pwm_idx = 0;
reg[31:0] index1;
reg[31:0] index2;

always@(posedge clk) begin
	index1 <= index1+1;
	if(index1 >= DIVIDER) begin
		pwm_clk <= ~pwm_clk;
		index1 <= 0;
	end
end

always@(posedge pwm_clk) begin
	if(enable)
		index2 <= index2+1;
	else
		index2 <= 0;
	if(index2 >= CYCLE) begin
		pwm_idx <= pwm_idx+1;
		index2 <= 0;
	end
end

PWM #(.RESOLUTION(RESOLUTION)) pwm(
	((sine[pwm_idx]*max_value)>>8),
	pwm_out,
	pwm_clk,
	1'b1
);

endmodule
