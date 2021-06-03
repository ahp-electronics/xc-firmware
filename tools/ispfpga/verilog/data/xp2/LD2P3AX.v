// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005 by Lattice Semiconductor Corporation
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
// Simulation Library File for SC
//
// $Header: /home/dmsys/pvcs/RCSMigTest/rcs/verilog/pkg/versclibs/data/orca5/RCS/LD2P3AX.v,v 1.3 2005/05/19 19:06:43 pradeep Exp $ 
//
`resetall
`timescale 1 ns / 1 ps

`celldefine
module LD2P3AX (D0, D1, CI, SP, CK, SD, CO, Q0, Q1);
  parameter GSR = "ENABLED";
input  D0, D1, CI, SP, CK, SD;
output CO, Q0, Q1;
  reg n1;
  reg SR;

  tri1 GSR_sig = GSR_INST.GSRNET;
  tri1 PUR_sig = PUR_INST.PURNET;

and INST11 (I4, Q0, CII);
or INST12 (I6, CII, I4, Q0);
xnor INST13 (I7, Q0, CII);
and INST24 (I16, Q1, I6);
or INST25 (CO, I6, I16, Q1);
xnor INST26 (I19, Q1, I6);

//---- Programmable GSR ----

  always @ (GSR_sig or PUR_sig ) begin
    if (GSR == "ENABLED") begin
      SR = GSR_sig & PUR_sig ;
    end
    else if (GSR == "DISABLED")
      SR = PUR_sig;
  end
//--------------------------

FL1P3AZ_FUNC  INST68 (.D0(I7), .D1(D0), .SP(SP), .CK(CK), .SD(SD), .SR(SR), .notifier(n1), .Q(Q0));
FL1P3AZ_FUNC  INST69 (.D0(I19), .D1(D1), .SP(SP), .CK(CK), .SD(SD), .SR(SR), .notifier(n2), .Q(Q1));

buf    (CII, CI);

// For timing checks
and (SD_SP_CI_GSR, SP, SD, CI, GSR);
and (GSR_SP, SP, GSR);
and (GSR_CI, CI, GSR);
not (CIN, CI);

endmodule
`endcelldefine
