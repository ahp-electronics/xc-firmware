CHIP=ecp5u
BOARD=pc03
FREQ=1000000
TARGETS=bypass,erase,program
INCLUDES=-Isources/ -Itools/ispfpga/verilog/data/$(CHIP)/

%:
	./flash.sh build $@

%_program:
	./flash.sh program $@_$(TARGETS)_$(FREQ)
