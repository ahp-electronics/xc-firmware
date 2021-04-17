#!/bin/bash
project=$1
implementation=$2
target=$3
svf="${PWD}/output/flash_${implementation}_${target}.svf"
tmpfile="/tmp/$$.xcf"

sed -e "s/IMPLEMENTATION/${implementation}/g" "${PWD}/boards/flash_${target}.xcf" | \
sed -e "s/PROJECT/${project}/g" \
> "${tmpfile}"
ddtcmd -oft -svfchain -revd -of "${svf}" -if "${tmpfile}"
rm "${tmpfile}"
program_jtag "${svf}"
