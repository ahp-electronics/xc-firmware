#!/bin/csh -f
cp modelsim.unx modelsim.ini
#
# Compile the MTI ECP2/M library
#
# Uncomment to include pre-compiled JTAGC model
#rm -rf work
#unzip -d . ../../../blackbox/jtagc-mti_6.3f.zip
#vlog -refresh -work ./jtagc_work
#mv jtagc_work work
#
vlib ./work
echo Compiling the ECP2/M Component File...
vcom -explicit -work ./work ../src/ECP2COMP.vhd
echo Compiling the ECP2/M Sequential Cells...
vcom -explicit -work ./work ../src/ECP2_SEQ.vhd
echo Compiling the ECP2/M I/Os...
vcom -explicit -work ./work ../src/ECP2_IO.vhd
echo Compiling the ECP2/M Combinational Cells...
vcom -explicit -work ./work ../src/ECP2_CMB.vhd
echo Compiling the ECP2/M Counters...
vcom -explicit -work ./work ../src/ECP2_CNT.vhd
echo Compiling the ECP2/M Memory Elements...
vcom -explicit -work ./work ../src/ECP2_MEM.vhd
echo Compiling the ECP2/M Miscillaneous cells...
vcom -explicit -work ./work ../src/ECP2_MISC.vhd
echo Compiling the ECP2/M LUTs...
vcom -explicit -work ./work ../src/ECP2_LUT.vhd
echo Compiling the ECP2/M MULTs cells...
vcom -explicit -work ./work ../src/ECP2_MULT.vhd
echo Compiling the ECP2/M Backanno cells...
vcom -explicit -work ./work ../src/ECP2_SL.vhd
