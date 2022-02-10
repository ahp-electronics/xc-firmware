CHIP=LFE5U
SIZE=45F
FOOTPRINT=CABGA256
TECH=ECP5U
BOARD=pc03
PROG_TARGETS=bypass,erase,program
PROG_FREQ=1000000
PROGRAMMER=UsbBlaster
INCLUDES=-Isources/ -Itools/ispfpga/verilog/data/`echo "$(CHIP)" | tr '[:upper:]' '[:lower:]'`/

%:
	./flash.sh build $@_$(PROG_TARGETS)_$(TECH),$(CHIP)-$(SIZE)-$(FOOTPRINT)_$(BOARD)_$(PROGRAMMER)_$(PROG_FREQ)

%_program:
	./flash.sh program $@_$(PROG_TARGETS)_$(TECH),$(CHIP)-$(SIZE)-$(FOOTPRINT)_$(BOARD)_$(PROGRAMMER)_$(PROG_FREQ)
