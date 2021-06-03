// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2007 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A.
//
//                     TEL: 1-800-Lattice  (USA and Canada)
//                          1-408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// Simulation Library File for XO2
//
// $Header: 
//

`resetall
`timescale 1 ns / 1 ps

`celldefine

module IDDRX4E(D, ECLK, SCLK, RST, ALIGNWD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7);

input  D, ECLK, SCLK, RST, ALIGNWD;
output Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7;

wire Db, SCLKB, ECLKB, RSTB, ALIGNWDB;

reg QP0, QP1, QP2, QP3, QP4, QP5, QP6, S0, S1, S2, S3, S4, S5, S6, S7;
reg last_SCLKB, last_ECLKB;
reg DATA0, DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7;
reg Q00, Q21, Q43, Q65, Q_6, Q54, Q32, Q10;
reg SEL, CNT0, CNT1;
reg slip_reg0, slip_regn1, slip_state;
 
buf (Db, D);
buf (SCLKB, SCLK);
buf (ECLKB, ECLK);
buf (RSTB, RST);
buf (ALIGNWDB, ALIGNWD);

buf (Q0, DATA0);
buf (Q1, DATA1);
buf (Q2, DATA2);
buf (Q3, DATA3);
buf (Q4, DATA4);
buf (Q5, DATA5);
buf (Q6, DATA6);
buf (Q7, DATA7);

      function DataSame;
        input a, b;
        begin
          if (a === b)
            DataSame = a;
          else
            DataSame = 1'bx;
        end
      endfunction

initial
begin
QP0 = 0;
QP1 = 0;
QP2 = 0;
QP3 = 0;
QP4 = 0;
QP5 = 0;
QP6 = 0;
Q00 = 0;
Q21 = 0;
Q43 = 0;
Q65 = 0;
Q_6 = 0;
Q54 = 0;
Q32 = 0;
Q10 = 0;
S0 = 0;
S1 = 0;
S2 = 0;
S3 = 0;
S4 = 0;
S5 = 0;
S6 = 0;
S7 = 0;
DATA0 = 0;
DATA1 = 0;
DATA2 = 0;
DATA3 = 0;
DATA4 = 0;
DATA5 = 0;
DATA6 = 0;
DATA7 = 0;
SEL = 0;
CNT0 = 0;
CNT1 = 0;
slip_reg0 = 0;
slip_regn1 = 1'b1;
slip_state = 0;
end

initial
begin
last_SCLKB = 1'b0;
last_ECLKB = 1'b0;
end

always @ (SCLKB or ECLKB)
begin
   last_SCLKB <= SCLKB;
   last_ECLKB <= ECLKB;
end

// UPDATE and SEL signal generation
                                                                                   
always @ (ECLKB or RSTB)     // pos edge
begin
   if (RSTB == 1'b1)
   begin
      slip_reg0 <= 1'b0;
      slip_regn1 <= 1'b1;
   end
   else
   begin
      if (ECLKB === 1'b1 && last_ECLKB === 1'b0)
      begin
         slip_reg0 <= ALIGNWDB;
         slip_regn1 <= ~slip_reg0;
      end
   end
end

and INST2 (slip_rst, slip_reg0, slip_regn1);
assign slip_trig = slip_rst;
nand INST3 (cnt_en, slip_rst, slip_state);
assign UPDATE = (CNT1 & ~CNT0);

always @ (ECLKB or RSTB)
begin
   if (RSTB == 1'b1)
   begin
      CNT0 <= 1'b0;
      CNT1 <= 1'b0;
      slip_state <= 1'b0;
      SEL <= 1'b0;
   end
   else
   begin
      if (ECLKB === 1'b1 && last_ECLKB === 1'b0)
      begin
         if (slip_rst == 1'b0)
         begin
            slip_state <= slip_state;
         end
         else if (slip_rst == 1'b1)
         begin
            slip_state <= ~slip_state;
         end

         if (cnt_en == 1'b0)
         begin
            CNT0 <= CNT0;
         end
         else if (cnt_en == 1'b1)
         begin
            CNT0 <= ~CNT0;
         end
                                                                                   
         if (cnt_en == 1'b0)
         begin
            CNT1 <= CNT1;
         end
         else if (cnt_en == 1'b1)
         begin
            CNT1 <= (CNT0 ^ CNT1);
         end

         if (slip_trig == 1'b0)
         begin
            SEL <= SEL;
         end
         else if (slip_trig == 1'b1)
         begin
            SEL <= ~SEL;
         end
      end
   end
end

always @ (ECLKB or RSTB)     // pos edge
begin
   if (RSTB == 1'b1)
   begin
      Q00 <= 1'b0;
      Q21 <= 1'b0;
      Q43 <= 1'b0;
      Q65 <= 1'b0;
      Q_6 <= 1'b0;
      Q54 <= 1'b0;
      Q32 <= 1'b0;
      Q10 <= 1'b0;
   end
   else
   begin
      if (ECLKB === 1'b1 && last_ECLKB === 1'b0)
      begin
         Q00 <= Q21;
         Q21 <= Q43;
         Q43 <= Q65;
         Q65 <= Db;
         Q_6 <= Db;
         Q54 <= Q_6;
         Q32 <= Q54;
         Q10 <= Q32;
      end
   end
end

always @ (Q00 or Q10 or SEL)
begin
   case (SEL)
        1'b0 :  QP0 = Q00;
        1'b1 :  QP0 = Q10;
        default QP0 = DataSame(Q10, Q00);
   endcase
end

always @ (Q21 or Q32 or SEL)
begin
   case (SEL)
        1'b0 :  QP1 = Q21;
        1'b1 :  QP1 = Q32;
        default QP1 = DataSame(Q32, Q21);
   endcase
end

always @ (Q43 or Q54 or SEL)
begin
   case (SEL)
        1'b0 :  QP2 = Q43;
        1'b1 :  QP2 = Q54;
        default QP2 = DataSame(Q54, Q43);
   endcase
end

always @ (Q65 or Q_6 or SEL)
begin
   case (SEL)
        1'b0 :  QP3 = Q65;
        1'b1 :  QP3 = Q_6;
        default QP3 = DataSame(Q_6, Q65);
   endcase
end

always @ (Q65 or Q54 or SEL)
begin
   case (SEL)
        1'b0 :  QP4 = Q54;
        1'b1 :  QP4 = Q65;
        default QP4 = DataSame(Q65, Q54);
   endcase
end

always @ (Q32 or Q43 or SEL)
begin
   case (SEL)
        1'b0 :  QP5 = Q32;
        1'b1 :  QP5 = Q43;
        default QP5 = DataSame(Q43, Q32);
   endcase
end

always @ (Q10 or Q21 or SEL)
begin
   case (SEL)
        1'b0 :  QP6 = Q10;
        1'b1 :  QP6 = Q21;
        default QP6 = DataSame(Q21, Q10);
   endcase
end

always @ (ECLKB or RSTB)     // pos edge
begin
   if (RSTB == 1'b1)
   begin
      S0 <= 1'b0;
      S2 <= 1'b0;
      S4 <= 1'b0;
      S6 <= 1'b0;
      S7 <= 1'b0;
      S5 <= 1'b0;
      S3 <= 1'b0;
      S1 <= 1'b0;
   end
   else
   begin
      if (ECLKB === 1'b1 && last_ECLKB === 1'b0)
      begin
         if (UPDATE == 1'b1)
         begin
            S0 <= QP0;
            S2 <= QP1;
            S4 <= QP2;
            S6 <= QP3;
            S7 <= Q_6;
            S5 <= QP4;
            S3 <= QP5;
            S1 <= QP6;
         end
      end
   end
end

always @ (SCLKB or RSTB)     // pos edge
begin
   if (RSTB == 1'b1)
   begin
      DATA0 <= 1'b0;
      DATA2 <= 1'b0;
      DATA4 <= 1'b0;
      DATA6 <= 1'b0;
      DATA7 <= 1'b0;
      DATA5 <= 1'b0;
      DATA3 <= 1'b0;
      DATA1 <= 1'b0;
   end
   else
   begin
      if (SCLKB === 1'b1 && last_SCLKB === 1'b0)
      begin
         DATA0 <= S0;
         DATA2 <= S2;
         DATA4 <= S4;
         DATA6 <= S6;
         DATA7 <= S7;
         DATA5 <= S5;
         DATA3 <= S3;
         DATA1 <= S1;
      end
   end
end

endmodule

`endcelldefine
