-- Copyright (c) 2002-2007 by Lattice Semiconductor Corporation 
-- -------------------------------------------------------------------- 
-- 
-- 
--                     Lattice Semiconductor Corporation 
--                     5555 NE Moore Court 
--                     Hillsboro, OR 97214 
--                     U.S.A 
-- 
--                     TEL: 1-800-Lattice (USA and Canada) 
--                          408-826-6000 (other locations) 
-- 
--                     web: http:--www.latticesemi.com/ 
--                     email: techsupport@latticesemi.com 
-- 
-- -------------------------------------------------------------------- 
-- 
-- Header files for XP family.
-- 
-- -------------------------------------------------------------------- 
-- 
-- Revision History : 
-- last modified : 9-22-2008:
-- 1. added LU4/LB4/LD4 cells per CR41999
-- 05-19-07
-- 1. Added GSR=ENABLE generic to cell FD1P3AX, per feedback from mentor.
-- 04-19-07
-- removed the init for distributed memory.
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date   :| Changes Made:
--   V5.0 :| LSV               :| 05/16/2007  :| Added Headers 
-- --------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--library synplify;
--use synplify.attributes.all;

package Components is
   attribute syn_black_box: boolean ;
   attribute syn_black_box of Components : package is true;
   attribute black_box_pad_pin: string ;
   attribute syn_tpd1: string;
   attribute syn_tpd2: string;
   attribute syn_tpd3: string;
   attribute syn_noprune: boolean ; --ct111505
   attribute syn_noprune of Components : package is true;

COMPONENT ILVDS
PORT(
        A : IN STD_LOGIC := 'X';
        AN: IN STD_LOGIC := 'X';
        Z : OUT STD_LOGIC
 );
END COMPONENT;
attribute black_box_pad_pin of ilvds : component is "a,an";
--
COMPONENT olvds
PORT(
        A  : IN STD_LOGIC := 'X';
        Z  : OUT STD_LOGIC ;
        ZN : OUT STD_LOGIC
 );
END COMPONENT;
attribute black_box_pad_pin of olvds : component is "z,zn";

COMPONENT FL1S1A
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S1AY
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S1B
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	PD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S1D
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	CD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S1I
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	CD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S1J
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	PD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S3AX
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;
-- 
COMPONENT FL1S3AY
    GENERIC (GSR : string := "ENABLED");
PORT( 
	D0: IN STD_LOGIC := 'X';
	D1: IN STD_LOGIC := 'X';
	CK: IN STD_LOGIC := 'X';
	SD: IN STD_LOGIC := 'X';
	Q: OUT STD_LOGIC := 'X'
  );
END COMPONENT;

COMPONENT MULT2
   PORT(
      A0                             :  IN    STD_ULOGIC;
      A1                             :  IN    STD_ULOGIC;
      A2                             :  IN    STD_ULOGIC;
      A3                             :  IN    STD_ULOGIC;
      B0                             :  IN    STD_ULOGIC;
      B1                             :  IN    STD_ULOGIC;
      B2                             :  IN    STD_ULOGIC;
      B3                             :  IN    STD_ULOGIC;
      CI                             :  IN    STD_ULOGIC;
      P0                             :  OUT   STD_ULOGIC;
      P1                             :  OUT   STD_ULOGIC;
      CO                             :  OUT   STD_ULOGIC);
END COMPONENT;

COMPONENT CB2
  PORT (
    CI      : IN STD_LOGIC;
    PC0     : IN STD_LOGIC;
    PC1     : IN STD_LOGIC;
    CON     : IN STD_LOGIC;
    CO      : OUT STD_LOGIC;
    NC0     : OUT STD_LOGIC;
    NC1     : OUT STD_LOGIC);
END COMPONENT;

COMPONENT FADSU2
   PORT(
      A0             :  IN    STD_LOGIC;
      A1             :  IN    STD_LOGIC;
      B0             :  IN    STD_LOGIC;
      B1             :  IN    STD_LOGIC;
      BCI            :  IN    STD_LOGIC;
      CON            :  IN    STD_LOGIC;
      BCO            :  OUT   STD_LOGIC;
      S0             :  OUT   STD_LOGIC;
      S1             :  OUT   STD_LOGIC);
END COMPONENT;

COMPONENT AGEB2
    PORT(
          A0		:  IN	STD_ULOGIC;
          A1		:  IN	STD_ULOGIC;
          B0		:  IN	STD_ULOGIC;
          B1		:  IN	STD_ULOGIC;
          CI		:  IN	STD_ULOGIC;
          GE		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ALEB2
    PORT(
          A0		:  IN	STD_ULOGIC;
          A1		:  IN	STD_ULOGIC;
          B0		:  IN	STD_ULOGIC;
          B1		:  IN	STD_ULOGIC;
          CI		:  IN	STD_ULOGIC;
          LE		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT AND2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT AND3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT AND4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT AND5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ANEB2
    PORT(
          A0		:  IN	STD_ULOGIC;
          A1		:  IN	STD_ULOGIC;
          B0		:  IN	STD_ULOGIC;
          B1		:  IN	STD_ULOGIC;
          CI		:  IN	STD_ULOGIC;
          NE		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT BB
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC;
          B		:  INOUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of BB : COMPONENT is "B";

COMPONENT BBPD
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC;
          B		:  INOUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of BBPD : COMPONENT is "B";

COMPONENT BBPU
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC;
          B		:  INOUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of BBPU : COMPONENT is "B";

COMPONENT BBW
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC;
          B		:  INOUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of BBW : COMPONENT is "B";

COMPONENT CD2
    PORT(
          CI		:  IN	STD_ULOGIC;
          PC0		:  IN	STD_ULOGIC;
          PC1		:  IN	STD_ULOGIC;
          CO		:  OUT	STD_ULOGIC;
          NC0		:  OUT	STD_ULOGIC;
          NC1		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT CU2
    PORT(
          CI		:  IN	STD_ULOGIC;
          PC0		:  IN	STD_ULOGIC;
          PC1		:  IN	STD_ULOGIC;
          CO		:  OUT	STD_ULOGIC;
          NC0		:  OUT	STD_ULOGIC;
          NC1		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT DCS
   GENERIC(
      DCSMODE        : string  := "NEG");
    PORT(
          CLK0		:  IN	STD_ULOGIC;
          CLK1		:  IN	STD_ULOGIC;
          SEL		:  IN	STD_ULOGIC;
          DCSOUT	:  OUT	STD_ULOGIC
        );
END COMPONENT;
attribute syn_tpd1 of dcs : COMPONENT is
      "CLK0 -> DCSOUT = 0.1";
attribute syn_tpd2 of dcs : COMPONENT is
      "CLK1 -> DCSOUT = 0.1";
attribute syn_tpd3 of dcs : COMPONENT is
      "SEL  -> DCSOUT = 0.1";

COMPONENT DELAY
    PORT(
          A		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT DPR16X2B
  PORT (DI0  : IN STD_LOGIC;
        DI1  : IN STD_LOGIC;
        WCK  : IN STD_LOGIC;
        WRE  : IN STD_LOGIC;
        RAD0 : IN STD_LOGIC;
        RAD1 : IN STD_LOGIC;
        RAD2 : IN STD_LOGIC;
        RAD3 : IN STD_LOGIC;
        WAD0 : IN STD_LOGIC;
        WAD1 : IN STD_LOGIC;
        WAD2 : IN STD_LOGIC;
        WAD3 : IN STD_LOGIC;
        WDO0 : OUT STD_LOGIC;
        WDO1 : OUT STD_LOGIC;
        RDO0 : OUT STD_LOGIC;
        RDO1 : OUT STD_LOGIC);
END COMPONENT;

COMPONENT EPLLB
   GENERIC(
      FIN           : string  := "100.0";
      CLKI_DIV      : string  := "1";
      CLKOP_DIV     : string  := "8";
      CLKFB_DIV     : string  := "1";
      FDEL          : string  := "0";
      FB_MODE       : string  := "CLOCKTREE";
      WAKE_ON_LOCK  : string  := "OFF");
    PORT(
          CLKI          :       IN      STD_ULOGIC;
          RST           :       IN      STD_ULOGIC;
          CLKFB         :       IN      STD_ULOGIC;
          CLKOP         :       OUT     STD_ULOGIC;
          LOCK          :       OUT     STD_ULOGIC
        );
END COMPONENT;
attribute syn_tpd1 of epllb : COMPONENT is
      "CLKI -> CLKOP = 0.1";
attribute syn_tpd2 of epllb : COMPONENT is
      "RST -> LOCK = 0.1";

COMPONENT EHXPLLB 
   GENERIC(
      FIN             : string  := "100.0";
      CLKI_DIV        : string  := "1";
      CLKOP_DIV       : string  := "1";
      CLKFB_DIV       : string  := "1";
      FDEL            : string  := "0";
      CLKOK_DIV       : string  := "2";
      WAKE_ON_LOCK    : string  := "OFF";
      FB_MODE         : string  := "CLOCKTREE";
      DELAY_CNTL      : string  := "STATIC";
      PHASEADJ        : string  := "0";
      DUTY            : string  := "4");

   PORT(
      CLKI            : IN    STD_ULOGIC;
      CLKFB           : IN    STD_ULOGIC;
      RST             : IN    STD_ULOGIC := '0';

      DDAMODE           : IN    STD_ULOGIC;
      DDAIZR            : IN    STD_ULOGIC;
      DDAILAG           : IN    STD_ULOGIC;
      DDAIDEL0          : IN    STD_ULOGIC;
      DDAIDEL1          : IN    STD_ULOGIC;
      DDAIDEL2          : IN    STD_ULOGIC;

      CLKOP             : OUT   STD_ULOGIC;
      CLKOS             : OUT   STD_ULOGIC;
      CLKOK             : OUT   STD_ULOGIC;
      LOCK              : OUT   STD_ULOGIC;

      DDAOZR            : OUT   STD_ULOGIC;
      DDAOLAG           : OUT   STD_ULOGIC;
      DDAODEL0          : OUT    STD_ULOGIC;
      DDAODEL1          : OUT    STD_ULOGIC;
      DDAODEL2          : OUT    STD_ULOGIC
);
END COMPONENT;
attribute syn_tpd1 of ehxpllb : COMPONENT is
      "CLKI -> CLKOP = 0.1";
attribute syn_tpd2 of ehxpllb : COMPONENT is
      "RST -> LOCK = 0.1";

COMPONENT FADD2
    PORT(
          A0		:  IN	STD_ULOGIC;
          A1		:  IN	STD_ULOGIC;
          B0		:  IN	STD_ULOGIC;
          B1		:  IN	STD_ULOGIC;
          CI		:  IN	STD_ULOGIC;
          COUT0		:  OUT	STD_ULOGIC;
          COUT1		:  OUT	STD_ULOGIC;
          S0		:  OUT	STD_ULOGIC;
          S1		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT CCU2

   GENERIC (
      inject1_0 : string := "yes";
      inject1_1 : string := "yes";
      init0: string := "0x0000";
      init1: string := "0x0000"
   );

   PORT (
      A0,A1 : IN STD_ULOGIC;
      B0,B1 : IN STD_ULOGIC;
      C0,C1 : IN STD_ULOGIC;
      D0,D1 : IN STD_ULOGIC;
      CIN : IN STD_ULOGIC;
      S0,S1 : OUT STD_ULOGIC;
      COUT0,COUT1 : OUT STD_ULOGIC
   );

END COMPONENT;

COMPONENT FD1P3AX
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1P3AY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1P3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1P3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1P3IX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1P3JX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1A
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1AY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1B
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1D
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1I
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S1J
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3AX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3AY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3IX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FD1S3JX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3AY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3AZ
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3IY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FL1P3JY
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          CK		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT FSUB2
    PORT(
          A0		:  IN	STD_ULOGIC;
          A1		:  IN	STD_ULOGIC;
          B0		:  IN	STD_ULOGIC;
          B1		:  IN	STD_ULOGIC;
          BI		:  IN	STD_ULOGIC;
          BOUT0		:  OUT	STD_ULOGIC;
          BOUT1		:  OUT	STD_ULOGIC;
          S0		:  OUT	STD_ULOGIC;
          S1		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT GSR
    PORT(
          GSR		:  IN	STD_ULOGIC
        );
END COMPONENT;

attribute syn_black_box of GSR : COMPONENT is true;
attribute syn_noprune of GSR: COMPONENT is true;

COMPONENT SGSR
PORT(
      GSR: IN STD_ULOGIC;
      CLK : IN STD_ULOGIC
  );
END COMPONENT;
--
attribute syn_black_box of SGSR : COMPONENT is true;
attribute syn_noprune of SGSR: COMPONENT is true;

COMPONENT JTAGB
   GENERIC(
      ER1        : string  := "ENABLED";
      ER2        : string  := "ENABLED"
      );
    PORT(
          TCK		:  IN	STD_ULOGIC;
          TMS		:  IN	STD_ULOGIC;
          TDI		:  IN	STD_ULOGIC;
          JTDO1		:  IN	STD_ULOGIC;
          JTDO2		:  IN	STD_ULOGIC;
          TDO		:  OUT	STD_ULOGIC;
          JTCK		:  OUT	STD_ULOGIC;
          JTDI		:  OUT	STD_ULOGIC;
          JSHIFT	:  OUT	STD_ULOGIC;
          JUPDATE	:  OUT	STD_ULOGIC;
          JRSTN 	:  OUT	STD_ULOGIC;
          JCE1  	:  OUT	STD_ULOGIC;
          JCE2  	:  OUT	STD_ULOGIC;
          JRTI1  	:  OUT	STD_ULOGIC;
          JRTI2		:  OUT	STD_ULOGIC
        );
END COMPONENT;
attribute syn_black_box of JTAGB : COMPONENT is true;
attribute syn_noprune of JTAGB: COMPONENT is true;

COMPONENT IB
    PORT(
          I		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of IB : COMPONENT is "I";

COMPONENT IBPD
    PORT(
          I		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of IBPD : COMPONENT is "I";

COMPONENT IBPU
    PORT(
          I		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of IBPU : COMPONENT is "I";

COMPONENT IFS1P3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1P3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1P3IX
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1P3JX
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1S1B
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1S1D
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1S1I
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IFS1S1J
    GENERIC (GSR : string := "ENABLED");
    PORT(

          D		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT IDDRXB
    PORT(
          D		:  IN	STD_ULOGIC;
          ECLK	        :  IN	STD_ULOGIC;
          SCLK	        :  IN	STD_ULOGIC;
          LSR		:  IN	STD_ULOGIC;
          CE	        :  IN	STD_ULOGIC;
          DDRCLKPOL     :  IN	STD_ULOGIC;
          QA		:  OUT	STD_ULOGIC;
          QB		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT INV
    PORT(

          A		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT L6MUX21
    PORT(

          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT MUX161
    PORT(

          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          D2		:  IN	STD_ULOGIC;
          D3		:  IN	STD_ULOGIC;
          D4		:  IN	STD_ULOGIC;
          D5		:  IN	STD_ULOGIC;
          D6		:  IN	STD_ULOGIC;
          D7		:  IN	STD_ULOGIC;
          SD1		:  IN	STD_ULOGIC;
          SD2		:  IN	STD_ULOGIC;
          SD3		:  IN	STD_ULOGIC;
          SD4		:  IN	STD_ULOGIC;
          D8		:  IN	STD_ULOGIC;
          D9		:  IN	STD_ULOGIC;
          D10		:  IN	STD_ULOGIC;
          D11		:  IN	STD_ULOGIC;
          D12		:  IN	STD_ULOGIC;
          D13		:  IN	STD_ULOGIC;
          D14		:  IN	STD_ULOGIC;
          D15		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT MUX21
    PORT(

          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          SD		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT MUX321
    PORT(

          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          D2		:  IN	STD_ULOGIC;
          D3		:  IN	STD_ULOGIC;
          D4		:  IN	STD_ULOGIC;
          D5		:  IN	STD_ULOGIC;
          D6		:  IN	STD_ULOGIC;
          D7		:  IN	STD_ULOGIC;
          SD1		:  IN	STD_ULOGIC;
          SD2		:  IN	STD_ULOGIC;
          SD3		:  IN	STD_ULOGIC;
          SD4		:  IN	STD_ULOGIC;
          SD5		:  IN	STD_ULOGIC;
          D8		:  IN	STD_ULOGIC;
          D9		:  IN	STD_ULOGIC;
          D10		:  IN	STD_ULOGIC;
          D11		:  IN	STD_ULOGIC;
          D12		:  IN	STD_ULOGIC;
          D13		:  IN	STD_ULOGIC;
          D14		:  IN	STD_ULOGIC;
          D15		:  IN	STD_ULOGIC;
          D16		:  IN	STD_ULOGIC;
          D17		:  IN	STD_ULOGIC;
          D18		:  IN	STD_ULOGIC;
          D19		:  IN	STD_ULOGIC;
          D20		:  IN	STD_ULOGIC;
          D21		:  IN	STD_ULOGIC;
          D22		:  IN	STD_ULOGIC;
          D23		:  IN	STD_ULOGIC;
          D24		:  IN	STD_ULOGIC;
          D25		:  IN	STD_ULOGIC;
          D26		:  IN	STD_ULOGIC;
          D27		:  IN	STD_ULOGIC;
          D28		:  IN	STD_ULOGIC;
          D29		:  IN	STD_ULOGIC;
          D30		:  IN	STD_ULOGIC;
          D31		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT MUX41
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          D2		:  IN	STD_ULOGIC;
          D3		:  IN	STD_ULOGIC;
          SD1		:  IN	STD_ULOGIC;
          SD2		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT MUX81
    PORT(
          D0		:  IN	STD_ULOGIC;
          D1		:  IN	STD_ULOGIC;
          D2		:  IN	STD_ULOGIC;
          D3		:  IN	STD_ULOGIC;
          D4		:  IN	STD_ULOGIC;
          D5		:  IN	STD_ULOGIC;
          D6		:  IN	STD_ULOGIC;
          D7		:  IN	STD_ULOGIC;
          SD1		:  IN	STD_ULOGIC;
          SD2		:  IN	STD_ULOGIC;
          SD3		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ND2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ND3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ND4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ND5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT NR2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT NR3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT NR4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT NR5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OB
    PORT(
          I		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OB : COMPONENT is "O";

COMPONENT OBCO
    PORT(
          I		:  IN	STD_ULOGIC;
          OT		:  OUT	STD_ULOGIC;
          OC		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OBCO : COMPONENT is "OT,OC";

COMPONENT OBW
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OBW : COMPONENT is "O";

COMPONENT OBZ
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OBZ : COMPONENT is "O";

COMPONENT OBZPD
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OBZPD : COMPONENT is "O";

COMPONENT OBZPU
    PORT(
          I		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          O		:  OUT	STD_ULOGIC
        );
END COMPONENT;
   attribute black_box_pad_pin of OBZPU : COMPONENT is "O";

COMPONENT OFE1P3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          ECLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFE1P3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          ECLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFE1P3IX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          ECLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFE1P3JX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          ECLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFS1P3BX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFS1P3DX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFS1P3IX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          CD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OFS1P3JX
    GENERIC (GSR : string := "ENABLED");
    PORT(
          D		:  IN	STD_ULOGIC;
          SP		:  IN	STD_ULOGIC;
          SCLK		:  IN	STD_ULOGIC;
          PD		:  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OR2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OR3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OR4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT OR5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ORCALUT4
    GENERIC(  init      :	bit_vector);
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ORCALUT5
    GENERIC(  init      :	bit_vector);
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ORCALUT6
    GENERIC(  init      :	bit_vector);
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          F		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ORCALUT7
    GENERIC(  init      :	bit_vector);
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          F		:  IN	STD_ULOGIC;
          G		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ORCALUT8
    GENERIC(  init      :	bit_vector);
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          F		:  IN	STD_ULOGIC;
          G		:  IN	STD_ULOGIC;
          H		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ODDRXB
    PORT(
          DA		:  IN	STD_ULOGIC;
          DB		:  IN	STD_ULOGIC;
          CLK	        :  IN	STD_ULOGIC;
          LSR	        :  IN	STD_ULOGIC;
          Q		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT DQSBUFB
    GENERIC(DEL_ADJ          : string  := "PLUS";
            DEL_VAL          : string  := "0");
    PORT(
          DQSI		:  IN	STD_ULOGIC;
          CLK		:  IN	STD_ULOGIC;
          READ	        :  IN	STD_ULOGIC;
          DQSDEL        :  IN	STD_ULOGIC;
          DQSO		:  OUT	STD_ULOGIC;
          DDRCLKPOL	:  OUT	STD_ULOGIC;
          DQSC		:  OUT	STD_ULOGIC;
          PRMBDET	:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT DQSDLL
    GENERIC(DEL_ADJ          : string  := "PLUS";
            DEL_VAL          : string  := "0";
            LOCK_SENSITIVITY : string  := "LOW");
    PORT(
          CLK		:  IN	STD_ULOGIC;
          RST	        :  IN	STD_ULOGIC;
          UDDCNTL       :  IN	STD_ULOGIC;
          LOCK		:  OUT	STD_ULOGIC;
          DQSDEL	:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT PFUMX
    PORT(
          ALUT		:  IN	STD_ULOGIC;
          BLUT		:  IN	STD_ULOGIC;
          C0		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT PUR
   GENERIC (
      RST_PULSE          : Integer   := 1);
    PORT(
          PUR		:  IN	STD_ULOGIC
        );
END COMPONENT;

attribute syn_black_box of PUR : COMPONENT is true; --ct111505
attribute syn_noprune of PUR : COMPONENT is true;

COMPONENT ROM128X1
GENERIC(
        initval : string := "0x00000000000000000000000000000000"
  );
    PORT(
          AD0		:  IN	STD_ULOGIC;
          AD1		:  IN	STD_ULOGIC;
          AD2		:  IN	STD_ULOGIC;
          AD3		:  IN	STD_ULOGIC;
          AD4		:  IN	STD_ULOGIC;
          AD5		:  IN	STD_ULOGIC;
          AD6		:  IN	STD_ULOGIC;
          DO0		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ROM16X1
GENERIC(
        initval : string := "0x0000"
  );
    PORT(
          AD0		:  IN	STD_ULOGIC;
          AD1		:  IN	STD_ULOGIC;
          AD2		:  IN	STD_ULOGIC;
          AD3		:  IN	STD_ULOGIC;
          DO0		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ROM256X1
GENERIC(
        initval : string := "0x0000000000000000000000000000000000000000000000000000000000000000"
  );
    PORT(
          AD0		:  IN	STD_ULOGIC;
          AD1		:  IN	STD_ULOGIC;
          AD2		:  IN	STD_ULOGIC;
          AD3		:  IN	STD_ULOGIC;
          AD4		:  IN	STD_ULOGIC;
          AD5		:  IN	STD_ULOGIC;
          AD6		:  IN	STD_ULOGIC;
          AD7		:  IN	STD_ULOGIC;
          DO0		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ROM32X1
GENERIC(
        initval : string := "0x00000000"
  );
    PORT(
          AD0		:  IN	STD_ULOGIC;
          AD1		:  IN	STD_ULOGIC;
          AD2		:  IN	STD_ULOGIC;
          AD3		:  IN	STD_ULOGIC;
          AD4		:  IN	STD_ULOGIC;
          DO0		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT ROM64X1
GENERIC(
        initval : string := "0x0000000000000000"
  );
    PORT(
          AD0		:  IN	STD_ULOGIC;
          AD1		:  IN	STD_ULOGIC;
          AD2		:  IN	STD_ULOGIC;
          AD3		:  IN	STD_ULOGIC;
          AD4		:  IN	STD_ULOGIC;
          AD5		:  IN	STD_ULOGIC;
          DO0		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT SPR16X2B
  PORT (DI0  : IN STD_LOGIC;
        DI1  : IN STD_LOGIC;
        CK   : IN STD_LOGIC;
        WRE  : IN STD_LOGIC;
        AD0  : IN STD_LOGIC;
        AD1  : IN STD_LOGIC;
        AD2  : IN STD_LOGIC;
        AD3  : IN STD_LOGIC;
        DO0  : OUT STD_LOGIC;
        DO1  : OUT STD_LOGIC);
END COMPONENT;

COMPONENT STRTUP
    PORT(

          UCLK		:  IN	STD_ULOGIC
        );
END COMPONENT;
   attribute syn_noprune of strtup : COMPONENT is true;

COMPONENT VHI
    PORT(

          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT VLO
    PORT(

          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XNOR2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XNOR3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XNOR4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XNOR5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR11
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          F		:  IN	STD_ULOGIC;
          G		:  IN	STD_ULOGIC;
          H		:  IN	STD_ULOGIC;
          I		:  IN	STD_ULOGIC;
          J		:  IN	STD_ULOGIC;
          K		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR2
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR21
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          F		:  IN	STD_ULOGIC;
          G		:  IN	STD_ULOGIC;
          H		:  IN	STD_ULOGIC;
          I		:  IN	STD_ULOGIC;
          J		:  IN	STD_ULOGIC;
          K		:  IN	STD_ULOGIC;
          L		:  IN	STD_ULOGIC;
          M		:  IN	STD_ULOGIC;
          N		:  IN	STD_ULOGIC;
          O		:  IN	STD_ULOGIC;
          P		:  IN	STD_ULOGIC;
          Q		:  IN	STD_ULOGIC;
          R		:  IN	STD_ULOGIC;
          S		:  IN	STD_ULOGIC;
          T		:  IN	STD_ULOGIC;
          U		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR3
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR4
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT XOR5
    PORT(
          A		:  IN	STD_ULOGIC;
          B		:  IN	STD_ULOGIC;
          C		:  IN	STD_ULOGIC;
          D		:  IN	STD_ULOGIC;
          E		:  IN	STD_ULOGIC;
          Z		:  OUT	STD_ULOGIC
        );
END COMPONENT;

COMPONENT SP8KA
   GENERIC(
         REGMODE       : string     := "NOREG";
         GSR           : string     := "DISABLED";
         WRITEMODE     : string     := "NORMAL";
         RESETMODE     : string     := "SYNC";
         CSDECODE      : string     := "111";
         DATA_WIDTH    : INteger    := 18;
         INITVAL_00    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
 	 INITVAL_01    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_02    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_03    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_04    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_05    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_06    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_07    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_08    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_09    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_10    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_11    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_12    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_13    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_14    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_15    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_16    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_17    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_18    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_19    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
);
   PORT(
      CE                            :  IN    STD_ULOGIC;
      CLK                            :  IN    STD_ULOGIC;
      WE                             :  IN    STD_ULOGIC;
      CS0                            :  IN    STD_ULOGIC;
      CS1                            :  IN    STD_ULOGIC;
      CS2                            :  IN    STD_ULOGIC;
      RST                            :  IN    STD_ULOGIC;
      DI0                            :  IN    STD_ULOGIC;
      DI1                            :  IN    STD_ULOGIC;
      DI2                            :  IN    STD_ULOGIC;
      DI3                            :  IN    STD_ULOGIC;
      DI4                            :  IN    STD_ULOGIC;
      DI5                            :  IN    STD_ULOGIC;
      DI6                            :  IN    STD_ULOGIC;
      DI7                            :  IN    STD_ULOGIC;
      DI8                            :  IN    STD_ULOGIC;
      DI9                            :  IN    STD_ULOGIC;
      DI10                            :  IN    STD_ULOGIC;
      DI11                            :  IN    STD_ULOGIC;
      DI12                            :  IN    STD_ULOGIC;
      DI13                            :  IN    STD_ULOGIC;
      DI14                            :  IN    STD_ULOGIC;
      DI15                            :  IN    STD_ULOGIC;
      DI16                            :  IN    STD_ULOGIC;
      DI17                            :  IN    STD_ULOGIC;
      AD0                            :  IN    STD_ULOGIC;
      AD1                            :  IN    STD_ULOGIC;
      AD2                            :  IN    STD_ULOGIC;
      AD3                            :  IN    STD_ULOGIC;
      AD4                            :  IN    STD_ULOGIC;
      AD5                            :  IN    STD_ULOGIC;
      AD6                            :  IN    STD_ULOGIC;
      AD7                            :  IN    STD_ULOGIC;
      AD8                            :  IN    STD_ULOGIC;
      AD9                            :  IN    STD_ULOGIC;
      AD10                           :  IN    STD_ULOGIC;
      AD11                           :  IN    STD_ULOGIC;
      AD12                           :  IN    STD_ULOGIC;
      DO0                            :  OUT    STD_ULOGIC;
      DO1                            :  OUT    STD_ULOGIC;
      DO2                            :  OUT    STD_ULOGIC;
      DO3                            :  OUT    STD_ULOGIC;
      DO4                            :  OUT    STD_ULOGIC;
      DO5                            :  OUT    STD_ULOGIC;
      DO6                            :  OUT    STD_ULOGIC;
      DO7                            :  OUT    STD_ULOGIC;
      DO8                            :  OUT    STD_ULOGIC;
      DO9                            :  OUT    STD_ULOGIC;
      DO10                            :  OUT    STD_ULOGIC;
      DO11                            :  OUT    STD_ULOGIC;
      DO12                            :  OUT    STD_ULOGIC;
      DO13                            :  OUT    STD_ULOGIC;
      DO14                            :  OUT    STD_ULOGIC;
      DO15                            :  OUT    STD_ULOGIC;
      DO16                            :  OUT    STD_ULOGIC;
      DO17                            :  OUT    STD_ULOGIC);
END COMPONENT;

COMPONENT PDP8KA
   GENERIC(
         REGMODE       : string     := "NOREG";
         GSR           : string     := "DISABLED";
         RESETMODE     : string     := "SYNC";
         DATA_WIDTH_W  : INteger    := 18;
         DATA_WIDTH_R  : INteger    := 18;
         CSDECODE_W    : string     := "111";
         CSDECODE_R    : string     := "111";
         INITVAL_00    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
 	 INITVAL_01    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_02    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_03    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_04    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_05    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_06    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_07    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_08    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_09    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_10    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_11    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_12    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_13    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_14    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_15    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_16    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_17    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_18    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_19    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
);
   PORT(
      CEW                            :  IN    STD_ULOGIC;
      CLKW                            :  IN    STD_ULOGIC;
      CSW0                            :  IN    STD_ULOGIC;
      CSW1                            :  IN    STD_ULOGIC;
      CSW2                            :  IN    STD_ULOGIC;
      WE                              :  IN    STD_ULOGIC;
      CER                            :  IN    STD_ULOGIC;
      CLKR                            :  IN    STD_ULOGIC;
      CSR0                            :  IN    STD_ULOGIC;
      CSR1                            :  IN    STD_ULOGIC;
      CSR2                            :  IN    STD_ULOGIC;
      RST                             :  IN    STD_ULOGIC;
      DI0                            :  IN    STD_ULOGIC;
      DI1                            :  IN    STD_ULOGIC;
      DI2                            :  IN    STD_ULOGIC;
      DI3                            :  IN    STD_ULOGIC;
      DI4                            :  IN    STD_ULOGIC;
      DI5                            :  IN    STD_ULOGIC;
      DI6                            :  IN    STD_ULOGIC;
      DI7                            :  IN    STD_ULOGIC;
      DI8                            :  IN    STD_ULOGIC;
      DI9                            :  IN    STD_ULOGIC;
      DI10                            :  IN    STD_ULOGIC;
      DI11                            :  IN    STD_ULOGIC;
      DI12                            :  IN    STD_ULOGIC;
      DI13                            :  IN    STD_ULOGIC;
      DI14                            :  IN    STD_ULOGIC;
      DI15                            :  IN    STD_ULOGIC;
      DI16                            :  IN    STD_ULOGIC;
      DI17                            :  IN    STD_ULOGIC;
      DI18                            :  IN    STD_ULOGIC;
      DI19                            :  IN    STD_ULOGIC;
      DI20                            :  IN    STD_ULOGIC;
      DI21                            :  IN    STD_ULOGIC;
      DI22                            :  IN    STD_ULOGIC;
      DI23                            :  IN    STD_ULOGIC;
      DI24                            :  IN    STD_ULOGIC;
      DI25                            :  IN    STD_ULOGIC;
      DI26                            :  IN    STD_ULOGIC;
      DI27                            :  IN    STD_ULOGIC;
      DI28                            :  IN    STD_ULOGIC;
      DI29                            :  IN    STD_ULOGIC;
      DI30                            :  IN    STD_ULOGIC;
      DI31                            :  IN    STD_ULOGIC;
      DI32                            :  IN    STD_ULOGIC;
      DI33                            :  IN    STD_ULOGIC;
      DI34                            :  IN    STD_ULOGIC;
      DI35                            :  IN    STD_ULOGIC;
      ADW0                           :  IN    STD_ULOGIC;
      ADW1                           :  IN    STD_ULOGIC;
      ADW2                           :  IN    STD_ULOGIC;
      ADW3                           :  IN    STD_ULOGIC;
      ADW4                           :  IN    STD_ULOGIC;
      ADW5                           :  IN    STD_ULOGIC;
      ADW6                           :  IN    STD_ULOGIC;
      ADW7                           :  IN    STD_ULOGIC;
      ADW8                           :  IN    STD_ULOGIC;
      ADW9                           :  IN    STD_ULOGIC;
      ADW10                          :  IN    STD_ULOGIC;
      ADW11                          :  IN    STD_ULOGIC;
      ADW12                          :  IN    STD_ULOGIC;
      ADR0                           :  IN    STD_ULOGIC;
      ADR1                           :  IN    STD_ULOGIC;
      ADR2                           :  IN    STD_ULOGIC;
      ADR3                           :  IN    STD_ULOGIC;
      ADR4                           :  IN    STD_ULOGIC;
      ADR5                           :  IN    STD_ULOGIC;
      ADR6                           :  IN    STD_ULOGIC;
      ADR7                           :  IN    STD_ULOGIC;
      ADR8                           :  IN    STD_ULOGIC;
      ADR9                           :  IN    STD_ULOGIC;
      ADR10                          :  IN    STD_ULOGIC;
      ADR11                          :  IN    STD_ULOGIC;
      ADR12                          :  IN    STD_ULOGIC;
      DO0                            :  OUT    STD_ULOGIC;
      DO1                            :  OUT    STD_ULOGIC;
      DO2                            :  OUT    STD_ULOGIC;
      DO3                            :  OUT    STD_ULOGIC;
      DO4                            :  OUT    STD_ULOGIC;
      DO5                            :  OUT    STD_ULOGIC;
      DO6                            :  OUT    STD_ULOGIC;
      DO7                            :  OUT    STD_ULOGIC;
      DO8                            :  OUT    STD_ULOGIC;
      DO9                            :  OUT    STD_ULOGIC;
      DO10                            :  OUT    STD_ULOGIC;
      DO11                            :  OUT    STD_ULOGIC;
      DO12                            :  OUT    STD_ULOGIC;
      DO13                            :  OUT    STD_ULOGIC;
      DO14                            :  OUT    STD_ULOGIC;
      DO15                            :  OUT    STD_ULOGIC;
      DO16                            :  OUT    STD_ULOGIC;
      DO17                            :  OUT    STD_ULOGIC;
      DO18                            :  OUT    STD_ULOGIC;
      DO19                            :  OUT    STD_ULOGIC;
      DO20                            :  OUT    STD_ULOGIC;
      DO21                            :  OUT    STD_ULOGIC;
      DO22                            :  OUT    STD_ULOGIC;
      DO23                            :  OUT    STD_ULOGIC;
      DO24                            :  OUT    STD_ULOGIC;
      DO25                            :  OUT    STD_ULOGIC;
      DO26                            :  OUT    STD_ULOGIC;
      DO27                            :  OUT    STD_ULOGIC;
      DO28                            :  OUT    STD_ULOGIC;
      DO29                            :  OUT    STD_ULOGIC;
      DO30                            :  OUT    STD_ULOGIC;
      DO31                            :  OUT    STD_ULOGIC;
      DO32                            :  OUT    STD_ULOGIC;
      DO33                            :  OUT    STD_ULOGIC;
      DO34                            :  OUT    STD_ULOGIC;
      DO35                            :  OUT    STD_ULOGIC);
END COMPONENT;

COMPONENT DP8KA
   GENERIC(
         REGMODE_A     : string     := "NOREG";
         REGMODE_B     : string     := "NOREG";
         GSR           : string     := "DISABLED";
         WRITEMODE_A   : string     := "NORMAL";
         WRITEMODE_B   : string     := "NORMAL";
         RESETMODE     : string     := "SYNC";
         CSDECODE_A    : string     := "111";
         CSDECODE_B    : string     := "111";
         DATA_WIDTH_A  : INteger    := 18;
         DATA_WIDTH_B  : INteger    := 18;
         INITVAL_00    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
 	 INITVAL_01    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_02    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_03    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_04    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_05    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_06    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_07    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_08    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_09    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_0F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_10    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_11    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_12    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_13    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_14    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_15    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_16    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_17    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_18    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_19    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1A    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1B    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1C    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1D    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1E    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
	 INITVAL_1F    : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
);
   PORT(
      CEA                            :  IN    STD_ULOGIC;
      CLKA                            :  IN    STD_ULOGIC;
      WEA                             :  IN    STD_ULOGIC;
      CSA0                            :  IN    STD_ULOGIC;
      CSA1                            :  IN    STD_ULOGIC;
      CSA2                            :  IN    STD_ULOGIC;
      RSTA                            :  IN    STD_ULOGIC;
      CEB                            :  IN    STD_ULOGIC;
      CLKB                            :  IN    STD_ULOGIC;
      WEB                             :  IN    STD_ULOGIC;
      CSB0                            :  IN    STD_ULOGIC;
      CSB1                            :  IN    STD_ULOGIC;
      CSB2                            :  IN    STD_ULOGIC;
      RSTB                            :  IN    STD_ULOGIC;
      DIA0                           :  IN    STD_ULOGIC;
      DIA1                           :  IN    STD_ULOGIC;
      DIA2                           :  IN    STD_ULOGIC;
      DIA3                           :  IN    STD_ULOGIC;
      DIA4                           :  IN    STD_ULOGIC;
      DIA5                           :  IN    STD_ULOGIC;
      DIA6                           :  IN    STD_ULOGIC;
      DIA7                           :  IN    STD_ULOGIC;
      DIA8                           :  IN    STD_ULOGIC;
      DIA9                           :  IN    STD_ULOGIC;
      DIA10                          :  IN    STD_ULOGIC;
      DIA11                          :  IN    STD_ULOGIC;
      DIA12                          :  IN    STD_ULOGIC;
      DIA13                          :  IN    STD_ULOGIC;
      DIA14                          :  IN    STD_ULOGIC;
      DIA15                          :  IN    STD_ULOGIC;
      DIA16                          :  IN    STD_ULOGIC;
      DIA17                          :  IN    STD_ULOGIC;
      ADA0                           :  IN    STD_ULOGIC;
      ADA1                           :  IN    STD_ULOGIC;
      ADA2                           :  IN    STD_ULOGIC;
      ADA3                           :  IN    STD_ULOGIC;
      ADA4                           :  IN    STD_ULOGIC;
      ADA5                           :  IN    STD_ULOGIC;
      ADA6                           :  IN    STD_ULOGIC;
      ADA7                           :  IN    STD_ULOGIC;
      ADA8                           :  IN    STD_ULOGIC;
      ADA9                           :  IN    STD_ULOGIC;
      ADA10                          :  IN    STD_ULOGIC;
      ADA11                          :  IN    STD_ULOGIC;
      ADA12                          :  IN    STD_ULOGIC;
      DIB0                           :  IN    STD_ULOGIC;
      DIB1                           :  IN    STD_ULOGIC;
      DIB2                           :  IN    STD_ULOGIC;
      DIB3                           :  IN    STD_ULOGIC;
      DIB4                           :  IN    STD_ULOGIC;
      DIB5                           :  IN    STD_ULOGIC;
      DIB6                           :  IN    STD_ULOGIC;
      DIB7                           :  IN    STD_ULOGIC;
      DIB8                           :  IN    STD_ULOGIC;
      DIB9                           :  IN    STD_ULOGIC;
      DIB10                           :  IN    STD_ULOGIC;
      DIB11                           :  IN    STD_ULOGIC;
      DIB12                           :  IN    STD_ULOGIC;
      DIB13                           :  IN    STD_ULOGIC;
      DIB14                           :  IN    STD_ULOGIC;
      DIB15                           :  IN    STD_ULOGIC;
      DIB16                           :  IN    STD_ULOGIC;
      DIB17                           :  IN    STD_ULOGIC;
      ADB0                           :  IN    STD_ULOGIC;
      ADB1                           :  IN    STD_ULOGIC;
      ADB2                           :  IN    STD_ULOGIC;
      ADB3                           :  IN    STD_ULOGIC;
      ADB4                           :  IN    STD_ULOGIC;
      ADB5                           :  IN    STD_ULOGIC;
      ADB6                           :  IN    STD_ULOGIC;
      ADB7                           :  IN    STD_ULOGIC;
      ADB8                           :  IN    STD_ULOGIC;
      ADB9                           :  IN    STD_ULOGIC;
      ADB10                          :  IN    STD_ULOGIC;
      ADB11                          :  IN    STD_ULOGIC;
      ADB12                          :  IN    STD_ULOGIC;
      DOA0                           :  OUT    STD_ULOGIC;
      DOA1                           :  OUT    STD_ULOGIC;
      DOA2                           :  OUT    STD_ULOGIC;
      DOA3                           :  OUT    STD_ULOGIC;
      DOA4                           :  OUT    STD_ULOGIC;
      DOA5                           :  OUT    STD_ULOGIC;
      DOA6                           :  OUT    STD_ULOGIC;
      DOA7                           :  OUT    STD_ULOGIC;
      DOA8                           :  OUT    STD_ULOGIC;
      DOA9                           :  OUT    STD_ULOGIC;
      DOA10                           :  OUT    STD_ULOGIC;
      DOA11                           :  OUT    STD_ULOGIC;
      DOA12                           :  OUT    STD_ULOGIC;
      DOA13                           :  OUT    STD_ULOGIC;
      DOA14                           :  OUT    STD_ULOGIC;
      DOA15                           :  OUT    STD_ULOGIC;
      DOA16                           :  OUT    STD_ULOGIC;
      DOA17                           :  OUT    STD_ULOGIC;
      DOB0                           :  OUT    STD_ULOGIC;
      DOB1                           :  OUT    STD_ULOGIC;
      DOB2                           :  OUT    STD_ULOGIC;
      DOB3                           :  OUT    STD_ULOGIC;
      DOB4                           :  OUT    STD_ULOGIC;
      DOB5                           :  OUT    STD_ULOGIC;
      DOB6                           :  OUT    STD_ULOGIC;
      DOB7                           :  OUT    STD_ULOGIC;
      DOB8                           :  OUT    STD_ULOGIC;
      DOB9                           :  OUT    STD_ULOGIC;
      DOB10                           :  OUT    STD_ULOGIC;
      DOB11                           :  OUT    STD_ULOGIC;
      DOB12                           :  OUT    STD_ULOGIC;
      DOB13                           :  OUT    STD_ULOGIC;
      DOB14                           :  OUT    STD_ULOGIC;
      DOB15                           :  OUT    STD_ULOGIC;
      DOB16                           :  OUT    STD_ULOGIC;
      DOB17                           :  OUT    STD_ULOGIC);
END COMPONENT;

COMPONENT LB2P3AX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LB2P3AY
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LB2P3BX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LB2P3DX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LB2P3IX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LB2P3JX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CON: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3AX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3AY
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3BX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3DX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3IX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LD2P3JX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3AX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3AY
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3BX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3DX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3IX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        CD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
COMPONENT LU2P3JX
    GENERIC (GSR : String := "ENABLED");
PORT(
        D0, D1 : IN STD_LOGIC := 'X';
        CI: IN STD_LOGIC := 'X';
        SP: IN STD_LOGIC := 'X';
        CK: IN STD_LOGIC := 'X';
        SD: IN STD_LOGIC := 'X';
        PD: IN STD_LOGIC := 'X';
        CO: OUT STD_LOGIC := 'X';
        Q0, Q1 : OUT STD_LOGIC := 'X'
  );
END COMPONENT;
--
component LU4P3JX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3JX : component is true;
component LU4P3IX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3IX : component is true;
component LU4P3DX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3DX : component is true;
component LU4P3BX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3BX : component is true;
component LU4P3AY
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3AY : component is true;
component LU4P3AX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LU4P3AX : component is true;
--
component LD4P3JX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LD4P3JX : component is true;
--
component LD4P3IX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LD4P3IX : component is true;
--
component LD4P3DX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LD4P3DX : component is true;
--
component LD4P3BX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LD4P3BX : component is true;
--
component LD4P3AY
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LD4P3AY : component is true;
--
component LD4P3AX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
--
component LB4P3JX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3JX : component is true;
--
component LB4P3IX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3IX : component is true;
--
component LB4P3DX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3DX : component is true;
--
component LB4P3BX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   PD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3BX : component is true;
--
component LB4P3AY
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3AY : component is true;
--
component LB4P3AX
 GENERIC (gsr : String := "ENABLED");
 port (
   D0 : in std_logic;
   D1 : in std_logic;
   D2 : in std_logic;
   D3 : in std_logic;
   CI : in std_logic;
   SP : in std_logic;
   CK : in std_logic;
   SD : in std_logic;
   CON : in std_logic;
   CO : out std_logic;
   Q0 : out std_logic;
   Q1 : out std_logic;
   Q2 : out std_logic;
   Q3 : out std_logic
 );
end component;
attribute syn_black_box of LB4P3AX : component is true;
--
END COMPONENTS;


