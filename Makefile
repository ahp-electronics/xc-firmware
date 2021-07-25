CHIP=ecp5u
BOARD=pc03
INCLUDES=-Isources/ -Itools/ispfpga/verilog/data/$(CHIP)/

%:
	./flash.sh build $@

%_erase:
	./flash.sh program $@

%_program:
	./flash.sh program $@

%_verify:
	./flash.sh program $@

%_test:
	./flash.sh program $@
