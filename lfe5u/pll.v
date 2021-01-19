/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.0.396.4 */
/* Module Version: 5.7 */
/* /opt/lattice/diamond/ispfpga/bin/lin64/scuba -w -n pll2 -lang verilog -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 10.00 -clkibuf LVTTL33 -fclkop 400.00 -fclkop_tol 0.0 -phase_cntl STATIC -fb_mode 1 -bw HIGH -fdc /home/plato/dev/github/correlator/intensity/source/pll/pll2/pll2.fdc  */
/* Sat Jan  2 14:48:54 2021 */


`timescale 1 ns / 1 ps
module pll (CLKI, CLKOP)/* synthesis NGD_DRC_MASK=1 */;
    input wire CLKI;
    output wire CLKOP;

    wire REFCLK;
    wire LOCK;
    wire CLKOP_t;
    wire buf_CLKI;
    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam PLLInst_0.PLLRST_ENA = "DISABLED" ;
    defparam PLLInst_0.INTFB_WAKE = "DISABLED" ;
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED" ;
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED" ;
    defparam PLLInst_0.CLKOS3_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS3_CPHASE = 0 ;
    defparam PLLInst_0.CLKOS2_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS2_CPHASE = 0 ;
    defparam PLLInst_0.CLKOS_FPHASE = 0 ;
    defparam PLLInst_0.CLKOS_CPHASE = 0 ;
    defparam PLLInst_0.CLKOP_FPHASE = 0 ;
    defparam PLLInst_0.CLKOP_CPHASE = 0 ;
    defparam PLLInst_0.PLL_LOCK_MODE = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0 ;
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING" ;
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD" ;
    defparam PLLInst_0.CLKOS3_ENABLE = "DISABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC" ;
    defparam PLLInst_0.CLKOS2_ENABLE = "DISABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB" ;
    defparam PLLInst_0.CLKOS_ENABLE = "DISABLED" ;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA" ;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED" ;
    defparam PLLInst_0.CLKOS3_DIV = 1 ;
    defparam PLLInst_0.CLKOS2_DIV = 1 ;
    defparam PLLInst_0.CLKOS_DIV = 1 ;
    defparam PLLInst_0.CLKOP_DIV = 1 ;
    defparam PLLInst_0.CLKFB_DIV = 40 ;
    defparam PLLInst_0.CLKI_DIV = 1 ;
    defparam PLLInst_0.FEEDBK_PATH = "CLKOP" ;
    EHXPLLL PLLInst_0 (.CLKI(buf_CLKI), .CLKFB(CLKOP_t), .PHASESEL1(scuba_vlo), 
        .PHASESEL0(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
        .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
        .RST(scuba_vlo), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), .ENCLKOS2(scuba_vlo), 
        .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(), .CLKOS2(), .CLKOS3(), 
        .LOCK(LOCK), .INTLOCK(), .REFCLK(REFCLK), .CLKINTFB())
             /* synthesis FREQUENCY_PIN_CLKOP="400.000000" */
             /* synthesis FREQUENCY_PIN_CLKI="10.000000" */
             /* synthesis ICP_CURRENT="16" */
             /* synthesis LPF_RESISTOR="8" */;

    assign CLKOP = CLKOP_t;


    // exemplar begin
    // exemplar attribute Inst1_IB IO_TYPE LVTTL33
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKOP 400.000000
    // exemplar attribute PLLInst_0 FREQUENCY_PIN_CLKI 10.000000
    // exemplar attribute PLLInst_0 ICP_CURRENT 16
    // exemplar attribute PLLInst_0 LPF_RESISTOR 8
    // exemplar end

endmodule
