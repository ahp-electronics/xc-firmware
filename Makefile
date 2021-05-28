
CHIP=ecp5u
BOARD=pc03
INCLUDES=-Isources/ -I/opt/lattice/diamond/ispfpga/verilog/data/$(CHIP)/

%:
	iverilog -tblif -o$@.edif boards/$(@).v boards/$(BOARD).v $(SOURCES) $(INCLUDES)

%_erase:
	./flash.sh $@

%_program:
	./flash.sh $@

%_verify:
	./flash.sh $@

%_test:
	./flash.sh $@
