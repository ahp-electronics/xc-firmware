#!/bin/bash
project=$(filename $PWD)
implementation=$(echo $1 | cut -d '_' -f 1)
target=$(echo $1 | cut -d '_' -f 2)
svf="${PWD}/output/flash_${implementation}_${target}.svf"
tmpfile="/tmp/$$.xcf"
echo $project $implementation $target
sed -e "s/IMPLEMENTATION/${implementation}/g" "${PWD}/boards/flash_${target}.xcf" | \
sed -e "s/PROJECT/${project}/g" \
> "${tmpfile}"
ddtcmd -oft -svfchain -revd -of "${svf}" -if "${tmpfile}"
rm "${tmpfile}"
program_jtag "${svf}"
