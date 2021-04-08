
implementation=xc8

all: erase program verify

erase:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_erase.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_erase.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_erase.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_erase.xcf"
	erase_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_erase.svf

program:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_program.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_program.xcf"
	program_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_program.svf

verify:
	sed -e 's/IMPLEMENTATION/$(implementation)/g' "$(PWD)/boards/xc-firmware_verify.xcf" > "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.xcf"
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.xcf"
	verify_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation)_verify.svf

ac1:
	$(MAKE) implementation=ac1

xc8:
	$(MAKE) implementation=xc8

xc32:
	$(MAKE) implementation=xc32

xc64:
	$(MAKE) implementation=xc64
