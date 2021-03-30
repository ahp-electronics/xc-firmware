
datadir=/opt/lattice/diamond/ispfpga/sa5p00/data
implementation=xc8
device=ECP5U
chip=LFE5U-45F
package=CABGA256
board=pc03

all: synthesize translate map placeroute export program

prepare:
	bash -c "cat $(PWD)/boards/synplify.tcl.header | sed -e 's:BOARD:$(board):g' | sed -e 's:CHIP:$(chip):g' | sed -e 's:DEVICE:$(device):g' | sed -e 's:IMPLEMENTATION:$(implementation):g' | sed -e 's:PACKAGE:$(package):g' | sed -e 's:REPOSITORY:$(PWD):g' > xc-firmware_$(implementation)_synplify.tcl"
	find /home/plato/dev/github/xc-firmware/source/ -type f -name "*.v" -exec echo add_file -verilog \{{}\} >> $(PWD)/$(implementation)/xc-firmware_$(implementation)_synplify.tcl \;
	echo add_file -verilog {$(PWD)/boards/$(implementation).v} >> "$(PWD)/$(implementation)/xc-firmware_$(implementation)_synplify.tcl"
	echo add_file -verilog {$(PWD)/boards/$(board).v} >> "$(PWD)/$(implementation)/xc-firmware_$(implementation)_synplify.tcl"
	bash -c "cat $(PWD)/boards/synplify.tcl.footer | sed -e 's:BOARD:$(board):g' | sed -e 's:CHIP:$(chip):g' | sed -e 's:DEVICE:$(device):g' | sed -e 's:IMPLEMENTATION:$(implementation):g' | sed -e 's:PACKAGE:$(package):g' | sed -e 's:REPOSITORY:$(PWD):g' >> xc-firmware_$(implementation)_synplify.tcl"

synthesize: prepare
	synpwrap -msg -prj "$(PWD)/$(implementation)/xc-firmware_$(implementation)_synplify.tcl" -log "$(PWD)/$(implementation)/xc-firmware_$(implementation).srf"

translate: synthesize
	edif2ngd  -l "$(device)" -d $(chip) -path "$(PWD)" -path "$(PWD)/$(implementation)"   "$(PWD)/$(implementation)/xc-firmware_$(implementation).edi" "$(PWD)/$(implementation)/xc-firmware_$(implementation).ngo"
	ngdbuild  -a "$(device)" -d $(chip)  -p "$(datadir)/sa5p00/data"  -p "$(PWD)/$(implementation)" -p "$(PWD)"  "$(PWD)/$(implementation)/xc-firmware_$(implementation).ngo" "$(PWD)/$(implementation)/xc-firmware_$(implementation).ngd"

map: translate
	map -a $(device) -p $(chip) -t $(package) -s 6 -oc Commercial  -ioreg b $(PWD)/$(implementation)/xc-firmware_$(implementation).ngd -o $(PWD)/$(implementation)/xc-firmware_$(implementation)_map.ncd -pr $(PWD)/$(implementation)/xc-firmware_$(implementation).prf -mp $(PWD)/$(implementation)/xc-firmware_$(implementation).mrp -lpf $(PWD)/$(implementation)/xc-firmware_$(implementation)_synplify.lpf -lpf boards/pc03.lpf      -retime -tdm -split_node -td_pack

placeroute: map
	mpartrce -p "$(PWD)/$(implementation)/xc-firmware_$(implementation).p2t" -f "$(PWD)/$(implementation)/xc-firmware_$(implementation).p3t" -tf "$(PWD)/$(implementation)/xc-firmware_$(implementation).pt" "$(PWD)/$(implementation)/xc-firmware_$(implementation)_map.ncd" "$(PWD)/$(implementation)/xc-firmware_$(implementation).ncd"

export: placeroute
	tmcheck -par "$(PWD)/$(implementation)/xc-firmware_$(implementation).par" -nocheck
	bitgen -w "$(PWD)/$(implementation)/xc-firmware_$(implementation).ncd" -f "$(PWD)/$(implementation)/xc-firmware_$(implementation).t2b" -e -s "xc-firmware.sec" -k "xc-firmware.bek" "$(PWD)/$(implementation)/xc-firmware_$(implementation).prf"

program: export
	ddtcmd -oft -svfchain -revd -of "$(PWD)/$(implementation)/xc-firmware_$(implementation).svf" -if "$(PWD)/$(implementation)/xc-firmware_$(implementation).xcf"
	program_jtag $(PWD)/$(implementation)/xc-firmware_$(implementation).svf

clean:
	bash -c "tmpfile='`cat $(PWD)/$(implementation)/xc-firmware_$(implementation).xcf`'; rm -r $(PWD)/$(implementation)/*; ln -s $(PWD)/boards/Makefile $(PWD)/$(implementation)/Makefile; echo $tmpfile > $(PWD)/$(implementation)/xc-firmware_$(implementation).xcf"
