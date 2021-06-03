# These functions can be used in the tcl scripts of generate symbol
# Copyright (c), 2008-2009, Lattice Semiconductor Corporation, All Rights Reserved

package provide symbol_generation 1.0.0

namespace eval ::bali {
}

# -----------------------------------------------------------------------
# generate parameter file which includes all source file path
# -----------------------------------------------------------------------
proc ::bali::GenerateFileList { listfile } {
	variable Para
	if [catch {open $listfile w} fileID ] {
		if [info exists ::DEBUG] { puts stdout "ERROR - Cannot open $listfile."	}
		return -1
	}

	foreach i $Para(FILELIST)	{
		puts $fileID "\"$i\""
	}
	
	close $fileID
}

proc ::bali::GenerateSymbol {} {
	variable Para	
	
	#set command_line "hdl2jhd -mod $Para(MODNAME) -nojhd -out $Para(MODNAME).naf -pf $Para(PRIMITIVEFILE) -pkg $Para(PACKAGE) -files"	
	#foreach i $Para(FILELIST)	{
	#	lappend command_line $i
	#}
	set list_file [file join [pwd] $Para(MODNAME).lst] 
	GenerateFileList $list_file	
	set command_line "hdl2jhd -mod $Para(MODNAME) -nojhd -out $Para(MODNAME).naf -pf $Para(PRIMITIVEFILE) -pkg $Para(PACKAGE) -lst \"$list_file\""
	
	#include path
	if { [llength $Para(INCLUDEPATH)]>0 } {
		lappend command_line "-includes"
		foreach i $Para(INCLUDEPATH) {
			lappend command_line $i
		}
	}
	set msg ""
	set ret [catch {eval exec $command_line} msg]
#	set Para(MessageList) [split $msg '\n']
	if {$ret == 0}  {
		# run success. return 0.	
		if { [string length $msg] > 0 } {		
			puts $msg	
		}		
	} else  {
	# run failure. return !0.
		if { [string length $msg] > 0 } {
			puts $msg
		}
	#	puts "\nERROR: 0 Child process exited abnormally."
		puts "\nERROR: Failed to generate naf file."
		return -code error
	}
				
	set ret [catch {exec naf2sym -i $Para(MODNAME).naf -o $Para(MODNAME).sym} msg]
#	set Para(MessageList) [split $msg '\n']
	if {$ret == 0}  {
		# run success. return 0.
		if { [string length $msg] > 0 } {
			puts $msg
		}
		puts "generate symbol $Para(MODNAME).sym done."
	} else  {
	# run failure. return !0.
		if { [string length $msg] > 0 } {
		puts $msg
		}
		puts "\nERROR: Failed to generate symbol file."
		return -code error
	}	
}
