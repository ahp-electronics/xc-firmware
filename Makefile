CHIP=ecp5u
BOARD=pc03
INCLUDES=-Isources/ -Itools/ispfpga/verilog/data/$(CHIP)/

%:
	./flash.sh build $@

%_program:
	./flash.sh program $@
