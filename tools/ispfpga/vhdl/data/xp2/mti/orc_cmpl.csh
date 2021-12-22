#!/bin/csh -f
cp modelsim.unx modelsim.ini
#
# Compile the MTI XP2 library
#
# Uncomment to include pre-compiled JTAGE/SSPIA models
#rm -rf work
#unzip -d . ../../../blackbox/jtage_sspia_vhdlib-mti_6.3f.zip
#vlog -refresh -work ./jtage_sspia_work
#mv jtage_sspia_work work
#
vlib ./work
echo Compiling the XP2 Component File...
vcom -explicit -work ./work ../src/XP2COMP.vhd
echo Compiling the XP2 Sequential Cells...
vcom -explicit -work ./work ../src/XP2_SEQ.vhd
echo Compiling the XP2 I/Os...
vcom -explicit -work ./work ../src/XP2_IO.vhd
echo Compiling the XP2 Combinational Cells...
vcom -explicit -work ./work ../src/XP2_CMB.vhd
echo Compiling the XP2 Counters...
vcom -explicit -work ./work ../src/XP2_CNT.vhd
echo Compiling the XP2 Memory Elements...
vcom -explicit -work ./work ../src/XP2_MEM.vhd
echo Compiling the XP2 Miscillaneous cells...
vcom -explicit -work ./work ../src/XP2_MISC.vhd
echo Compiling the XP2 LUTs...
vcom -explicit -work ./work ../src/XP2_LUT.vhd
echo Compiling the XP2 MULTs cells...
vcom -explicit -work ./work ../src/XP2_MULT.vhd
echo Compiling the XP2 Backanno cells...
vcom -explicit -work ./work ../src/XP2_SL.vhd
