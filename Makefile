
implementation=xc8

all: erase program verify

erase:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_eraseall.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_eraseall.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_eraseall.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_eraseall.xcf"
	program_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_eraseall.svf

program:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_program.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.xcf"
	program_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_program.svf

verify:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_verify.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.xcf"
	program_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.svf

AC1:
	$(MAKE) implementation=ac1

XC8:
	$(MAKE) implementation=xc8

XC32:
	$(MAKE) implementation=xc32

XC64:
	$(MAKE) implementation=xc64
