CHIP=LFE5U
SIZE=45F
FOOTPRINT=CABGA256
TECH=ECP5U
FLASH=W25Q128JV
BOARD=pc03
PROG_TARGETS=test,erase,program
PROG_FREQ=1000000
PROGRAMMER=UsbBlaster
INCLUDES=-Isources/ -Itools/ispfpga/verilog/data/`echo "$(CHIP)" | tr '[:upper:]' '[:lower:]'`/

%:
	./flash.sh $@_build_$(PROG_TARGETS)_$(TECH),$(CHIP)-$(SIZE)-$(FOOTPRINT)_$(FLASH)_$(BOARD)_$(PROGRAMMER)_$(PROG_FREQ)

%_program:
	./flash.sh $@_$(PROG_TARGETS)_$(TECH),$(CHIP)-$(SIZE)-$(FOOTPRINT)_$(FLASH)_$(BOARD)_$(PROGRAMMER)_$(PROG_FREQ)

%_generate:
	./flash.sh $@_$(PROG_TARGETS)_$(TECH),$(CHIP)-$(SIZE)-$(FOOTPRINT)_$(FLASH)_$(BOARD)_$(PROGRAMMER)_$(PROG_FREQ)
