#!/bin/bash

environment() {
	export frequency=$(echo $2 | cut -d '_' -f 4)
	export targets="$(echo $2 | cut -d '_' -f 3 | tr -s ',' ' ')"
	export TOOLSDIR=${PWD}/tools/
	export FOUNDRY=${TOOLSDIR}/ispfpga
	export TCL_LIBRARY=${TOOLSDIR}/tcltk/lib/tcl8.5
	export LM_LICENSE_FILE=${TOOLSDIR}/license/license.dat
	export ISPDIR=${FOUNDRY}/bin/lin64/
	export LD_LIBRARY_PATH=${TOOLSDIR}/bin/lin64/:${TOOLSDIR}/ispfpga/bin/lin64/
	export PATH=${PATH}:${TOOLSDIR}/bin/lin64/:${TOOLSDIR}/ispfpga/bin/lin64/
	export sources="$(grep .v project.ldf | grep Source | cut -d '"' -f 2 | tr -s '\n' ' ')"
	export includes="${TOOLSDIR}/ispfpga/verilog/data/ecp5u/VHI.v ${TOOLSDIR}/ispfpga/verilog/data/ecp5u/VLO.v"
	export project=$(grep '<BaliProject' project.ldf | cut -d '"' -f 4)
	export implementation=$(echo $2 | cut -d '_' -f 1)
	export target=$(echo $2 | cut -d '_' -f 2)
}

svf() {
	svf="${PWD}/output/flash_${implementation}_${1}.svf"
	tmpfile="/tmp/$$.xcf"
	echo $project ${implementation} $1
	sed -e "s:IMPLEMENTATION:${implementation}:g" "${PWD}/boards/flash_${1}.xcf" | \
	sed -e "s:PWD:${PWD}:g" | \
	sed -e "s:PROJECT:${project}:g" \
	> "${tmpfile}"
	ddtcmd -oft -svfchain -revd -of "${svf}" -if "${tmpfile}"
	rm "${tmpfile}"
}

program() {
	_svf="${PWD}/output/flash_${implementation}.svf"
	rm ${PWD}/output/flash_${implementation}*.svf
	echo "" > $svf
	for t in $targets; do
		rm "${PWD}/output/flash_${implementation}_${t}.svf"
		svf $t
		cat "${PWD}/output/flash_${implementation}_${t}.svf" >> $_svf
	done
        sed -i "s/\(RUNTEST DRPAUSE\).*$/d" output/*.svf "${_svf}"
	sed -i "s/\(FREQUENCY\).*$/\1\t$(($frequency/1000000)).00e+06 HZ ;/g" output/*.svf "${_svf}"
	program_jtag -i"${_svf}" -d"UsbBlaster" -f$frequency|| true
}

synthesize() {
rm -rf build/${implementation}
mkdir -p build/${implementation}
	echo "set_option -technology ECP5U
set_option -part LFE5U_45F
set_option -package BG256C
set_option -speed_grade -6
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true
set_option -vlog_std sysv
set_option -frequency 10
set_option -maxfan 4096
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming true; set_option -pipe true
set_option -force_gsr auto
set_option -compiler_compatible 0
set_option -dup false
set_option -frequency 1
set_option -default_enum_encoding default
set_option -write_verilog true
set_option -write_apr_constraint 1
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 1
set_option -resolve_multiple_driver 1
set_option -include_path {${PWD}}
` for file in source/*.v; do
echo \"add_file -verilog {${PWD}/${file}}\"
done
`
`echo \"add_file -verilog {${PWD}/boards/pc03.v}\"`
`echo \"add_file -verilog {${PWD}/boards/${implementation}.v}\"`
set_option -top_module ${implementation}
project -result_file {${PWD}/build/${implementation}/${project}_${implementation}.edi}
project -log_file {${project}_${implementation}.srf}
project -run
" > build/${implementation}/${project}_${implementation}_synplify.tcl
	pushd build/${implementation}
	synpwrap -msg -prj "${project}_${implementation}_synplify.tcl" -log "${project}_${implementation}.srf"
	popd
}

translate() {
	pushd build/${implementation}
	edif2ngd  -l ECP5U -d LFE5U-45F -path build/${implementation} -path ./ ${project}_${implementation}.edi ${project}_${implementation}.ngo
	ngdbuild  -a ECP5U -d LFE5U-45F -p ${TOOLSDIR}/ispfpga/sa5p00/data -p build/impl ${project}_${implementation}.ngo ${project}_${implementation}.ngd
	popd
}

mapper() {
	pushd build/${implementation}
	map -a ECP5U -p LFE5U-45F -t CABGA256 -s 6 -oc Commercial -ioreg b ${project}_${implementation}.ngd -o ${project}_${implementation}_map.ncd -pr ${project}_${implementation}.prf -mp ${project}_${implementation}.mrp -lpf ${project}_${implementation}_synplify.lpf -lpf ../../boards/pc03.lpf -retime -tdm -split_node -td_pack
	popd
}

route() {
	pushd build/${implementation}
	mpartrce -distrce -log ${project}_${implementation}_route.log -o ${project}_${implementation}_route_report.txt -pr ${project}_${implementation}.prf -p "${project}_${implementation}.p2t" -tf "${project}_${implementation}.pt" "${project}_${implementation}_map.ncd" "${project}_${implementation}.ncd"
	popd
}

generate() {
	pushd build/${implementation}
	bitgen -w ${project}_${implementation}.ncd -f ${project}_${implementation}.t2b -e -s ${project}.sec -k ${project}.bek ${project}_${implementation}.prf
	popd
}

build() {
	synthesize;
	translate;
	mapper;
	route;
	generate;
}

environment $@
rm -rf output/flash_${implementation}_${target}.svf
mkdir -p output/
$1
