#
# Copyright 2004-2013 University of Zagreb.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# This work was supported in part by Croatian Ministry of Science
# and Technology through the research contract #IP-2003-143.
#

# $Id: initgui.tcl 151 2015-03-27 17:14:57Z valter $


#****h* imunes/initgui.tcl
# NAME
#    initgui.tcl
# FUNCTION
#    Initialize GUI. Not included when operating in batch mode.
#****


#
# GUI-related global variables
#

#****v* initgui.tcl/global variables
# NAME
#    global variables
# FUNCTION
#    GUI-related global varibles
#
#    * newlink -- helps when creating a new link. If there is no
#      link currently created, this value is set to an empty string.
#    * selectbox -- the value of the box representing all the selected items
#    * selected -- containes the list of node_id's of all selected nodes.
#    * newCanvas --
#
#    * animatephase -- starting dashoffset. With this value the effect of
#      rotating line around selected itme is achived.
#    * undolevel -- control variable for undo.
#    * redolevel -- control variable for redo.
#    * undolog -- control variable for saving all the past configurations.
#    * changed -- control variable for indicating that there something changed
#      in active configuration.
#    * badentry -- control variable indicating that there has been a bad entry
#      in the text box.
#    * cursorstate -- control variable for animating cursor.
#    * clock_seconds -- control variable for animating cursor.
#    * oper_mode -- control variable reresenting operating mode, possible
#      values are edit and exec.
#    * grid -- control variable representing grid distance. All new
#      elements on the
#      canvas are snaped to grid. Default value is 24.
#    * sizex -- X size of the canvas.
#    * sizey -- Y size of the canvas.
#    * curcanvas -- the value of the current canvas.
#    * autorearrange_enabled -- control variable indicating is
#      autorearrange enabled.
#
#    * defLinkColor -- defines the default link color
#    * defLinkWidth -- defines the width of the link
#    * defEthBandwidth -- defines the ethernet bandwidth
#    * defSerBandwidth -- defines the serail link bandwidth
#    * defSerDelay -- defines the serail link delay
#    * show_interface_names -- control variable for showing interface names
#    * show_interface_ipv4 -- control variable for showing interface IPv4 addresses
#    * show_interface_ipv6 -- control variable for showing interface IPv6 addresses
#    * show_node_labels -- control variable for showing node labels
#    * show_link_labels -- control variable for showing link labels
#
#    * supp_router_models -- supproted router models, currently frr quagga
#      and static.
#    * def_router_model -- default router model
#****

set newlink ""
set newnode ""
set selectbox ""
set selected ""
set ns2srcfile ""
set animatephase 0
set changed 0
set force 0
set badentry 0
set cursorState 0
set clock_seconds 0
set grid 24
set autorearrange_enabled 0
set active_tool_group "select"
set tool_groups [dict create]
set active_tools [dict create]

# resize Oval/Rectangle, "false" or direction: north/west/east/...
set resizemode false

#
# Initialize a few variables to default values
#
set defLinkColor Red
set defFillColor Gray
set defLinkWidth 2
set defEthBandwidth 0
set defSerBandwidth 0
set defSerDelay 0

set newtext ""
set newoval ""
set defOvalColor #CFCFFF
set defOvalLabelFont "Arial 12"
set newrect ""
set newfree ""
set defRectColor #C0C0FF
set defRectLabelFont "Arial 12"
set defTextFont "Arial 12"
set defTextFontFamily "Arial"
set defTextFontSize 12
set defTextColor #000000
set showZFSsnapshots 0

set IPv4autoAssign 1
set IPv6autoAssign 1

set showTree 0
set zoom_stops [list 0.2 0.4 0.5 0.6 0.8 1 \
	1.25 1.5 1.75 2.0 3.0]
set canvasBkgMode "original"
set alignCanvasBkg "center"
set bgsrcfile ""

set def_router_model frr

set model frr
set router_model $model
set routerDefaultsModel $model
set ripEnable 1
set ripngEnable 1
set ospfEnable 0
set ospf6Enable 0
set bgpEnable 0
set ldpEnable 0
set routerRipEnable 1
set routerRipngEnable 1
set routerOspfEnable 0
set routerOspf6Enable 0
set routerBgpEnable 0
set routerLdpEnable 0
set rdconfig [list $routerRipEnable $routerRipngEnable $routerOspfEnable $routerOspf6Enable $routerBgpEnable $routerLdpEnable]
set brguielements {}
set selected_experiment ""
set copypaste_nodes 0
set cutNodes 0
set iconsrcfile [lindex [glob -directory $ROOTDIR/$LIBDIR/icons/normal/ *.gif] 0]
#interface selected in the topology tree
set selectedIfc ""

# Packets required for GUI
#package require Img

#
# Window / canvas setup section
#

wm minsize . 640 410
wm geometry . 1016x716-20+0

set iconlist ""
foreach size "256 128 64" {
	set path "$ROOTDIR/$LIBDIR/icons/imunes_icon$size.png"
	if { [file exists $path] } {
		set icon$size [image create photo -file $path]
		append iconlist "\$icon$size "
	}
}
if { $iconlist != "" } {
	eval wm iconphoto . -default $iconlist
}

ttk::style theme use imunes

ttk::panedwindow .panwin -orient horizontal
ttk::frame .panwin.f1
ttk::frame .panwin.f2 -width 200
.panwin add .panwin.f1 -weight 5
.panwin add .panwin.f2 -weight 0
.panwin forget .panwin.f2
pack .panwin -fill both -expand 1
pack propagate .panwin.f2 0

set mf .panwin.f1

menu .menubar
. configure -menu .menubar

.menubar add cascade -label File -underline 0 -menu .menubar.file
.menubar add cascade -label Edit -underline 0 -menu .menubar.edit
.menubar add cascade -label Canvas -underline 0 -menu .menubar.canvas
.menubar add cascade -label View -underline 0 -menu .menubar.view
.menubar add cascade -label Tools -underline 0 -menu .menubar.tools
.menubar add cascade -label TopoGen -underline 4 -menu .menubar.t_g
.menubar add cascade -label Widgets -underline 0 -menu .menubar.widgets
.menubar add cascade -label Events -underline 1 -menu .menubar.events
.menubar add cascade -label Experiment -underline 1 -menu .menubar.experiment
.menubar add cascade -label Help -underline 0 -menu .menubar.help

#
# File
#
menu .menubar.file -tearoff 0

.menubar.file add command -label New -underline 0 \
	-accelerator "Ctrl+N" -command { newProject }
bind . <Control-n> "newProject"

.menubar.file add command -label Open -underline 0 \
	-accelerator "Ctrl+O" -command { fileOpenDialogBox }
bind . <Control-o> "fileOpenDialogBox"

.menubar.file add command -label Save -underline 0 \
	-accelerator "Ctrl+S" -command { fileSaveDialogBox }
bind . <Control-s> "fileSaveDialogBox"

.menubar.file add command -label "Save As" -underline 5 \
	-command { fileSaveAsDialogBox }

.menubar.file add command -label "Close" -underline 0 -command { closeFile }

.menubar.file add separator

set tmp_command {
	set w .entry1
	catch { destroy $w }
	toplevel $w
	wm transient $w .
	wm resizable $w 0 0
	wm title $w "Printing options"
	wm iconname $w "Printing options"

	#dodan glavni frame "printframe"
	ttk::frame $w.printframe
	pack $w.printframe -fill both -expand 1

	ttk::label $w.printframe.msg -wraplength 5i -justify left -text "Print command:"
	pack $w.printframe.msg -side top

	ttk::frame $w.printframe.buttons
	pack $w.printframe.buttons -side bottom -fill x -pady 2m
	ttk::button $w.printframe.buttons.print -text Print -command "printCanvas $w"
	ttk::button $w.printframe.buttons.cancel -text "Cancel" -command "destroy $w"
	pack $w.printframe.buttons.print $w.printframe.buttons.cancel -side left -expand 1

	ttk::entry $w.printframe.e1
	$w.printframe.e1 insert 0 "lpr"
	pack $w.printframe.e1 -side top -pady 5 -padx 10 -fill x
}
.menubar.file add command -label "Print" -underline 0 \
	-command $tmp_command

set printFileType ps

set tmp_command {
	global winOS

	set w .entry1
	catch { destroy $w }
	toplevel $w
	wm transient $w .
	wm resizable $w 0 0
	wm title $w "Printing options"
	wm iconname $w "Printing options"

	ttk::frame $w.printframe
	pack $w.printframe -fill both -expand 1

	ttk::label $w.printframe.msg -wraplength 5i -justify left -text "File:"

	ttk::frame $w.printframe.ftype
	ttk::radiobutton $w.printframe.ftype.ps -text "PostScript" \
		-variable printFileType -value ps -state enabled
	ttk::radiobutton $w.printframe.ftype.pdf -text "PDF" \
		-variable printFileType -value pdf -state enabled

	ttk::frame $w.printframe.path

	if { $winOS } {
		$w.printframe.ftype.pdf configure -state disabled
	} else {
		catch { exec ps2pdf } msg
		if { [string match *ps2pdfwr* $msg] != 1 } {
			$w.printframe.ftype.pdf configure -state disabled
		}
	}

	pack $w.printframe.msg -side top -fill x -padx 5

	set tmp_command {
		global printFileType

		set printdest [tk_getSaveFile -initialfile print \
			-defaultextension .$printFileType]
		$w.printframe.path.e1 insert 0 $printdest
	}
	ttk::button $w.printframe.path.browse -text "Browse" -width 8 \
		-command $tmp_command

	ttk::frame $w.printframe.buttons
	pack $w.printframe.buttons -side bottom -fill x -pady 2m
	ttk::button $w.printframe.buttons.print -text Print -command "printCanvasToFile $w $w.printframe.path.e1"
	ttk::button $w.printframe.buttons.cancel -text "Cancel" -command "destroy $w"
	pack $w.printframe.buttons.print $w.printframe.buttons.cancel -side left -expand 1

	ttk::entry $w.printframe.path.e1
	pack $w.printframe.path -fill both
	pack $w.printframe.path.e1 -side left -pady 2 -padx 5
	pack $w.printframe.path.browse -side left -pady 2 -padx 5
	pack $w.printframe.ftype -anchor w
	pack $w.printframe.ftype.ps $w.printframe.ftype.pdf -side left -fill x -padx 10
}
.menubar.file add command -label "Print To File" -underline 9 \
	-command $tmp_command

.menubar.file add separator
.menubar.file add command -label Quit -underline 0 -command { exit }
.menubar.file add separator

#
# Edit
#
menu .menubar.edit -tearoff 0
.menubar.edit add command -label "Undo" -underline 0 \
	-accelerator "Ctrl+Z" -command undo -state disabled
bind . <Control-z> undo
.menubar.edit add command -label "Redo" -underline 0 \
	-accelerator "Ctrl+Y" -command redo -state disabled
bind . <Control-y> redo
.menubar.edit add separator
.menubar.edit add command -label "Cut" -underline 0 \
	-accelerator "Ctrl+X" -command cutSelection -state normal
bind . <Control-x> cutSelection
.menubar.edit add command -label "Copy" -underline 1 \
	-accelerator "Ctrl+C" -command copySelection -state normal
bind . <Control-c> copySelection
.menubar.edit add command -label "Paste" -underline 0 \
	-accelerator "Ctrl+V" -command paste -state normal
bind . <Control-v> paste
.menubar.edit add separator
.menubar.edit add command -label "Select all" \
	-accelerator "Ctrl+A" -underline 0 -command "selectAllObjects"
bind . <Control-a> selectAllObjects
.menubar.edit add command -label "Select adjacent" \
	-accelerator "Ctrl+D" -underline 7 -command selectAdjacent
bind . <Control-d> selectAdjacent

#
# Canvas
#
menu .menubar.canvas -tearoff 0
.menubar.canvas add command -label "New" -underline 0 -command {
	newCanvas ""

	switchCanvas last
	set changed 1
	updateUndoLog
}
.menubar.canvas add command -label "Rename" -underline 0 \
	-command { renameCanvasPopup }
.menubar.canvas add command -label "Delete" -underline 0 -command {
	set canvas_list [getFromRunning "canvas_list"]
	set curcanvas [getFromRunning "curcanvas"]

	if { [llength $canvas_list] == 1 } {
		return
	}

	selectAllObjects
	deleteSelection

	set i [lsearch $canvas_list $curcanvas]
	cfgUnset "canvases" $curcanvas
	set canvas_list [getCanvasList]
	setToRunning "canvas_list" $canvas_list
	set curcanvas [lindex $canvas_list $i]
	if { $curcanvas == "" } {
		set curcanvas [lindex $canvas_list end]
	}
	setToRunning "curcanvas" $curcanvas

	switchCanvas none
	set changed 1
	updateUndoLog
}
.menubar.canvas add separator
.menubar.canvas add command -label "Resize" -underline 2 -command resizeCanvasPopup
.menubar.canvas add command -label "Background image" -underline 0 \
	-command changeBkgPopup

.menubar.canvas add separator
.menubar.canvas add command -label "Previous" -accelerator "PgUp" \
	-command { switchCanvas prev }
bind . <Prior> { switchCanvas prev }
.menubar.canvas add command -label "Next" -accelerator "PgDown" \
	-command { switchCanvas next }
bind . <Next> { switchCanvas next }
.menubar.canvas add command -label "First" -accelerator "Home" \
	-command { switchCanvas first }
bind . <Home> { switchCanvas first }
.menubar.canvas add command -label "Last" -accelerator "End" \
	-command { switchCanvas last }
bind . <End> { switchCanvas last }


#
# Tools
#
menu .menubar.tools -tearoff 0
.menubar.tools add command -label "Auto rearrange all" -underline 0 \
	-command { rearrange all }
.menubar.tools add command -label "Auto rearrange selected" -underline 15 \
	-command { rearrange selected }
.menubar.tools add separator
.menubar.tools add command -label "Align to grid" -underline 9 \
	-command { align2grid }
.menubar.tools add separator
.menubar.tools add checkbutton -label "IPv4 auto-assign addresses/routes" \
	-variable IPv4autoAssign
.menubar.tools add checkbutton -label "IPv6 auto-assign addresses/routes" \
	-variable IPv6autoAssign
.menubar.tools add checkbutton -label "Auto-generate /etc/hosts file" \
	-variable auto_etc_hosts
.menubar.tools add separator
.menubar.tools add command -label "Randomize MAC bytes" -underline 10 \
	-command randomizeMACbytes

set tmp_command {
	set w .entry1
	catch { destroy $w }
	toplevel $w
	wm transient $w .
	#wm resizable $w 0 0
	wm title $w "IPv4 autonumbering address pool"
	wm iconname $w "IPv4 address pool"
	grab $w

	#dodan glavni frame "ipv4frame"
	ttk::frame $w.ipv4frame
	pack $w.ipv4frame -fill both -expand 1

	ttk::label $w.ipv4frame.msg -text "IPv4 address range:"
	pack $w.ipv4frame.msg -side top

	ttk::entry $w.ipv4frame.e1 -width 27 -validate focus -invalidcommand "focusAndFlash %W"
	$w.ipv4frame.e1 insert 0 $ipv4
	pack $w.ipv4frame.e1 -side top -pady 5 -padx 10 -fill x

	$w.ipv4frame.e1 configure -invalidcommand { checkIPv4Net %P }

	ttk::frame $w.ipv4frame.buttons
	pack $w.ipv4frame.buttons -side bottom -fill x -pady 2m
	ttk::button $w.ipv4frame.buttons.apply -text "Apply" -command "IPv4AddrApply $w"
	ttk::button $w.ipv4frame.buttons.cancel -text "Cancel" -command "destroy $w"

	bind $w <Key-Return> "IPv4AddrApply $w"
	bind $w <Key-Escape> "destroy $w"

	pack $w.ipv4frame.buttons.apply -side left -expand 1 -anchor e -padx 2
	pack $w.ipv4frame.buttons.cancel -side right -expand 1 -anchor w -padx 2
}
.menubar.tools add command -label "IPv4 address pool" -underline 3 \
	-command $tmp_command
set tmp_command {
	set w .entry1
	catch { destroy $w }
	toplevel $w
	wm transient $w .
	#wm resizable $w 0 0
	wm title $w "IPv6 autonumbering address pool"
	wm iconname $w "IPv6 address pool"
	grab $w

	ttk::frame $w.ipv6frame
	pack $w.ipv6frame -fill both -expand 1

	ttk::label $w.ipv6frame.msg -text "IPv6 address range:"
	pack $w.ipv6frame.msg -side top

	ttk::entry $w.ipv6frame.e1 -width 27 -validate focus -invalidcommand "focusAndFlash %W"
	$w.ipv6frame.e1 insert 0 $ipv6
	pack $w.ipv6frame.e1 -side top -pady 5 -padx 10 -fill x

	$w.ipv6frame.e1 configure -invalidcommand { checkIPv6Net %P }

	ttk::frame $w.ipv6frame.buttons
	pack $w.ipv6frame.buttons -side bottom -fill x -pady 2m
	ttk::button $w.ipv6frame.buttons.apply -text "Apply" -command "IPv6AddrApply $w"
	ttk::button $w.ipv6frame.buttons.cancel -text "Cancel" -command "destroy $w"

	bind $w <Key-Return> "IPv6AddrApply $w"
	bind $w <Key-Escape> "destroy $w"

	pack $w.ipv6frame.buttons.apply -side left -expand 1 -anchor e -padx 2
	pack $w.ipv6frame.buttons.cancel -side right -expand 1 -anchor w -padx 2
}
.menubar.tools add command -label "IPv6 address pool" -underline 3 \
	-command $tmp_command
set tmp_command {
	global router_model supp_router_models routerDefaultsModel
	global routerRipEnable routerRipngEnable routerOspfEnable routerOspf6Enable routerBgpEnable routerLdpEnable

	set wi .popup
	catch { destroy $wi }
	toplevel $wi
	wm transient $wi .
	wm resizable $wi 0 0
	wm title $wi "Router Defaults"
	grab $wi

	#dodan glavni frame "routerframe"
	ttk::frame $wi.routerframe
	pack $wi.routerframe -fill both -expand 1

	set w $wi.routerframe

	ttk::labelframe $w.model -text "Model:"
	ttk::labelframe $w.protocols -text "Protocols:"

	set protocols {
		"rip rip routerRipEnable"
		"ripng ripng routerRipngEnable"
		"ospf ospf routerOspfEnable"
		"ospf6 ospfv3 routerOspf6Enable"
		"bgp bgp routerBgpEnable"
		"ldp ldp routerLdpEnable"
	}

	set protocol_list {}
	foreach item $protocols {
		lassign $item protocol protocol_label protocol_variable 
		lappend protocol_list $protocol
		ttk::checkbutton $w.protocols.$protocol \
			-text $protocol_label \
			-variable $protocol_variable
	}

	# set last argument as empty string
	set tmp_command [list apply {
		{ popup_window protocol_list state } {
			foreach protocol $protocol_list {
				$popup_window.protocols.$protocol configure -state $state
			}
		}
	} \
		$w \
		$protocol_list \
		""
	]

	# replace last argument for each binding
	ttk::radiobutton $w.model.frr -text frr -variable router_model \
		-value frr -command [lreplace $tmp_command end end "normal"]
	ttk::radiobutton $w.model.quagga -text quagga -variable router_model \
		-value quagga -command [lreplace $tmp_command end end "normal"]
	ttk::radiobutton $w.model.static -text static -variable router_model \
		-value static -command [lreplace $tmp_command end end "disabled"]

	if { $router_model == "static" } {
		foreach protocol $protocol_list {
			$w.protocols.$protocol configure -state "disabled"
		}
	}

	if { "frr" ni $supp_router_models } {
		$w.model.frr configure -state disabled
	}

	ttk::frame $w.buttons
	ttk::button $w.buttons.b1 -text "Apply" -command "routerDefaultsApply $wi"

	set tmp_command [list apply {
		{ top_widget } {
			global rdconfig router_model routerDefaultsModel
			global routerRipEnable routerRipngEnable routerOspfEnable routerOspf6Enable routerBgpEnable routerLdpEnable

			set router_model $routerDefaultsModel
			lassign $rdconfig routerRipEnable routerRipngEnable routerOspfEnable routerOspf6Enable routerBgpEnable routerLdpEnable
			destroy $top_widget
		}
	} \
		$wi
	]
	ttk::button $w.buttons.b2 -text "Cancel" -command $tmp_command

	pack $w.model -side top -fill x -pady 5
	pack $w.model.frr $w.model.quagga $w.model.static \
		-side left -expand 1
	pack $w.protocols -side top -pady 5

	set protocols_to_pack {}
	foreach protocol $protocol_list {
		lappend protocols_to_pack $w.protocols.$protocol
	}
	pack {*}$protocols_to_pack -side left

	pack $w.buttons -side bottom -fill x  -pady 2
	pack $w.buttons.b1 -side left -expand 1 -anchor e -padx 2
	pack $w.buttons.b2 -side right -expand 1 -anchor w -padx 2
}
.menubar.tools add command -label "Routing protocol defaults" -underline 0 \
	-command $tmp_command

#.menubar.tools add separator
#.menubar.tools add command -label "ns2imunes converter" \
#	-underline 0 -command {
#
#	#dodana varijabla ns2imdialog, dodan glavni frame "ns2convframe"
#	set ns2imdialog .ns2im-dialog
#	catch { destroy $ns2imdialog }
#	toplevel $ns2imdialog
#	wm transient $ns2imdialog .
#	wm resizable $ns2imdialog 0 0
#	wm title $ns2imdialog "ns2imunes converter"
#
#	ttk::frame $ns2imdialog.ns2convframe
#	pack $ns2imdialog.ns2convframe -fill both -expand 1
#
#	set f1 [ttk::frame $ns2imdialog.ns2convframe.entry1]
#	set f2 [ttk::frame $ns2imdialog.ns2convframe.buttons]
#
#	ttk::label $f1.l -text "ns2 file:"
#
#	#entry $f1.e -width 25 -textvariable ns2srcfile
#	ttk::entry $f1.e -width 25 -textvariable ns2srcfile
#	ttk::button $f1.b -text "Browse" -width 8 \
#		-command {
#			set srcfile [tk_getOpenFile -parent $ns2imdialog \
#				-initialfile $ns2srcfile]
#			$f1.e delete 0 end
#			$f1.e insert 0 "$srcfile"
#	}
#	ttk::button $f2.b1 -text "OK" -command {
#		ns2im $srcfile
#		destroy $ns2imdialog
#	}
#	ttk::button $f2.b2 -text "Cancel" -command { destroy $ns2imdialog }
#
#	pack $f1.b $f1.e -side right
#	pack $f1.l -side right -fill x -expand 1
#	pack $f2.b1 -side left -expand 1 -anchor e
#	pack $f2.b2 -side right -expand 1 -anchor w
#	pack $f1 $f2 -fill x
#}

#
# View
#
menu .menubar.view -tearoff 0

set m .menubar.view.iconsize
menu $m -tearoff 0
.menubar.view add cascade -label "Icon size" -menu $m -underline 5
$m add radiobutton -label "Small" -variable icon_size \
	-value small -command { updateIconSize; redrawAll }
$m add radiobutton -label "Normal" -variable icon_size \
	-value normal -command { updateIconSize; redrawAll }

.menubar.view add separator

.menubar.view add checkbutton -label "Show Interface Names" \
	-underline 5 -variable show_interface_names \
	-command { redrawAllLinks }
.menubar.view add checkbutton -label "Show IPv4 Addresses " \
	-underline 8 -variable show_interface_ipv4 \
	-command { redrawAllLinks }
.menubar.view add checkbutton -label "Show IPv6 Addresses " \
	-underline 8 -variable show_interface_ipv6 \
	-command { redrawAllLinks }

set tmp_command {
	foreach object [.panwin.f1.c find withtag nodelabel] {
		if { $show_node_labels } {
			.panwin.f1.c itemconfigure $object -state normal
		} else {
			.panwin.f1.c itemconfigure $object -state hidden
		}
	}
}
.menubar.view add checkbutton -label "Show Node Labels" \
	-underline 5 -variable show_node_labels -command $tmp_command

set tmp_command {
	foreach object [.panwin.f1.c find withtag linklabel] {
		if { $show_link_labels } {
			.panwin.f1.c itemconfigure $object -state normal
		} else {
			.panwin.f1.c itemconfigure $object -state hidden
		}
	}
}
.menubar.view add checkbutton -label "Show Link Labels" \
	-underline 5 -variable show_link_labels -command $tmp_command

set tmp_command {
	global show_interface_names show_interface_ipv4 show_interface_ipv6
	global show_node_labels show_link_labels

	set show_interface_names 1
	set show_interface_ipv4 1
	set show_interface_ipv6 1
	set show_node_labels 1
	set show_link_labels 1

	redrawAll

	foreach object [.panwin.f1.c find withtag linklabel] {
		.panwin.f1.c itemconfigure $object -state normal
	}
}
.menubar.view add command -label "Show All" \
	-underline 5 -command $tmp_command

set tmp_command {
	global show_interface_names show_interface_ipv4 show_interface_ipv6
	global show_node_labels show_link_labels

	set show_interface_names 0
	set show_interface_ipv4 0
	set show_interface_ipv6 0
	set show_node_labels 0
	set show_link_labels 0

	redrawAll

	foreach object [.panwin.f1.c find withtag linklabel] {
		.panwin.f1.c itemconfigure $object -state hidden
	}
}
.menubar.view add command -label "Show None" \
	-underline 6 -command $tmp_command

.menubar.view add separator

#.menubar.view add checkbutton -label "Show ZFS snaphots" \
#	-variable showZFSsnapshots

#.menubar.view add separator
.menubar.view add checkbutton -label "Show Topology Tree" \
	-variable showTree -underline 5 \
	-command { topologyElementsTree }

.menubar.view add separator

.menubar.view add checkbutton -label "Show Unsupported Nodes" \
	-variable show_unsupported_nodes -underline 5 \
	-command { refreshToolBarNodes }

.menubar.view add separator

.menubar.view add checkbutton -label "Show Background Image" \
	-underline 5 -variable show_background_image \
	-command { redrawAll }
.menubar.view add checkbutton -label "Show Annotations" \
	-underline 8 -variable show_annotations \
	-command { redrawAll }
.menubar.view add checkbutton -label "Show Grid" \
	-underline 5 -variable show_grid \
	-command { redrawAll }


.menubar.view add separator
.menubar.view add command -label "Zoom In" -accelerator "+" \
	-command "zoom up"
bind . "+" "zoom up"
.menubar.view add command -label "Zoom Out" -accelerator "-" \
	-command "zoom down"
bind . "-" "zoom down"

#dodan element "Themes"
.menubar.view add separator
set m .menubar.view.themes
menu $m -tearoff 0
set currentTheme imunes
.menubar.view add cascade -label "Themes" -menu $m
$m add radiobutton -label "alt" -variable currentTheme \
	-value alt -command "ttk::style theme use alt"
$m add radiobutton -label "classic" -variable currentTheme\
	-value classic -command "ttk::style theme use classic"
$m add radiobutton -label "default" -variable currentTheme\
	-value default -command "ttk::style theme use default"
$m add radiobutton -label "clam" -variable currentTheme\
	-value clam -command "ttk::style theme use clam"
$m add radiobutton -label "imunes" -variable currentTheme\
	-value imunes -command "ttk::style theme use imunes"

#
# Show
#
menu .menubar.widgets
global showConfig
set showConfig "None"
global lastObservedNode
set lastObservedNode ""
.menubar.widgets add radiobutton -label "None" \
	-variable showConfig -underline 0 -value "None"
.menubar.widgets add separator

set widgetlist { \
	{ "ifconfig" "ifconfig" } \
	{ "IPv4 Routing table" "netstat -4 -rn" } \
	{ "IPv6 Routing table" "netstat -6 -rn" } \
	{ "RIP routes info" "vtysh -c \"show ip rip\"" } \
	{ "RIPng routes info" "vtysh -c \"show ipv6 ripng\"" } \
	{ "Process list" "ps ax" } \
	{ "IPv4 sockets" "netstat -4 -an" } \
	{ "IPv6 sockets" "netstat -6 -an" } \
	{ "View ifaces startup script" "cat boot_ifaces.conf" } \
	{ "View ifaces startup logs" "cat out_ifaces.log err_ifaces.log" } \
	{ "View startup script" "cat boot.conf custom.conf" } \
	{ "View startup logs" "cat out.log err.log" } \
	{ "List files" "ls" } \
}

foreach widget $widgetlist {
	.menubar.widgets add radiobutton -label [lindex $widget 0] \
		-variable showConfig -underline 0 -value [lindex $widget 1]
}

set tmp_command {
	global showConfig

	set w .entry1
	catch { destroy $w }
	toplevel $w
	wm transient $w .
	wm resizable $w 0 0
	wm title $w "Custom widget"
	wm iconname $w "Custom widget"

	ttk::frame $w.custom
	pack $w.custom -fill both -expand 1

	ttk::label $w.custom.label -wraplength 5i -justify left -text "Custom command:"
	pack $w.custom.label -side top

	ttk::frame $w.custom.buttons
	pack $w.custom.buttons -side bottom -fill x -pady 2m

	set tmp_command [list apply {
		{ top_window } {
			global showConfig

			set showConfig [$top_window.custom.e1 get]
			destroy $top_window
		}
	} \
		$w
	]
	ttk::button $w.custom.buttons.ok -text OK -command $tmp_command
	ttk::button $w.custom.buttons.cancel -text "Cancel" -command "destroy $w"
	pack $w.custom.buttons.ok $w.custom.buttons.cancel -side left -expand 1

	set commands {
		"ifconfig"
		"ps ax"
		"netstat -rnf inet"
		"netstat -rn"
		"ls"
		"cat boot.conf"
	}
	ttk::combobox $w.custom.e1 -width 30 -values $commands
	if { $showConfig != "None" } {
		$w.custom.e1 insert 0 $showConfig
	} else {
		$w.custom.e1 insert 0 [lindex $commands 0]
	}

	pack $w.custom.e1 -side top -pady 5 -padx 10 -fill x
}
.menubar.widgets add command -label "Custom..." \
	-underline 0 -command $tmp_command

#.menubar.widgets add separator
#.menubar.widgets add radiobutton -label "Route" \
#	-variable showConfig -underline 0 -value "route"

#
# Events
#
menu .menubar.events -tearoff 0
.menubar.events add command -label "Start scheduling" -underline 0 \
	-state normal -command "startEventScheduling"
.menubar.events add command -label "Stop scheduling" -underline 1 \
	-state disabled -command "stopEventScheduling"
.menubar.events add separator
.menubar.events add command -label "Event editor" -underline 0 \
	-command "elementsEventsEditor"

#
# Experiment
#
menu .menubar.experiment -tearoff 0
.menubar.experiment add command -label "Execute" -underline 0 \
	-command "setOperMode exec"
.menubar.experiment add command -label "Terminate" -underline 0 \
	-command "setOperMode edit" -state disabled
.menubar.experiment add command -label "Restart" -underline 0 \
	-command "setOperMode edit; setOperMode exec" -state disabled
.menubar.experiment add separator

set tmp_command {
	set auto_execution [getFromRunning "auto_execution"]

	setToRunning "auto_execution" [expr $auto_execution ^ 1]
	if { [getFromRunning "cfg_deployed"] && ! $auto_execution } {
		# when going from non-auto to auto execution, trigger (un)deployCfg
		undeployCfg
		deployCfg
	} else {
		setToExecuteVars "terminate_cfg" [cfgGet]
	}

	toggleAutoExecutionGUI
}
.menubar.experiment add command -label "Pause execution" -underline 2 \
	-command $tmp_command
.menubar.experiment add separator
.menubar.experiment add command -label "Attach to experiment" -underline 0 \
	-command "attachToExperimentPopup"

#
# Help
#
menu .menubar.help -tearoff 0
set tmp_command {
	toplevel .about
	wm title .about "About IMUNES"
	wm minsize .about 454 255

	set mainFrame .about.main

	ttk::frame $mainFrame -padding 4
	grid $mainFrame -column 0 -row 0 -sticky n
	grid columnconfigure .about 0 -weight 1
	grid rowconfigure .about 0 -weight 1

	set image [image create photo -file $ROOTDIR/$LIBDIR/icons/imunes_logo128.png]
	ttk::label $mainFrame.logoLabel
	$mainFrame.logoLabel configure -image $image

	ttk::label $mainFrame.imunesLabel -text "IMUNES" -font "-size 12 -weight bold"
	ttk::label $mainFrame.imunesVersion -text $imunesVersion -font "-size 10 -weight bold"
	ttk::label $mainFrame.lastChanged -text $imunesChangedDate
	ttk::label $mainFrame.imunesAdditions -text "$imunesAdditions" -font "-size 10 -weight bold"
	ttk::label $mainFrame.imunesDesc -text "Integrated Multiprotocol Network Emulator/Simulator."
	ttk::label $mainFrame.homepage -text "http://imunes.net/" -font "-underline 1 -size 10"
	ttk::label $mainFrame.github -text "http://github.com/imunes/imunes" -font "-underline 1 -size 10"
	ttk::label $mainFrame.copyright -text "Copyright (c) University of Zagreb 2004 - $imunesLastYear" -font "-size 8"

	grid $mainFrame.logoLabel -column 0 -row 0 -pady {10 5} -padx 5
	grid $mainFrame.imunesLabel -column 0 -row 1 -pady 5 -padx 5
	grid $mainFrame.imunesVersion -column 0 -row 2 -pady {5 1} -padx 5
	grid $mainFrame.lastChanged -column 0 -row 3 -pady {1 5} -padx 5
	if { $imunesAdditions != "" } {
		grid $mainFrame.imunesAdditions -column 0 -row 4 -pady {0 1} -padx 5
	}
	grid $mainFrame.imunesDesc -column 0 -row 5 -pady {5 10} -padx 5
	grid $mainFrame.homepage -column 0 -row 6 -pady 1 -padx 5
	grid $mainFrame.github -column 0 -row 7 -pady 1 -padx 5
	grid $mainFrame.copyright -column 0 -row 8 -pady {20 10} -padx 5

	bind $mainFrame.homepage <1> {
		launchBrowser [%W cget -text]
	}
	bind $mainFrame.homepage <Enter> \
		"%W configure -foreground blue; \
		$mainFrame config -cursor hand1"
	bind $mainFrame.homepage <Leave> \
		"%W configure -foreground black; \
		$mainFrame config -cursor arrow"

	bind $mainFrame.github <1> {
		launchBrowser [%W cget -text]
	}
	bind $mainFrame.github <Enter> \
		"%W configure -foreground blue; \
		$mainFrame config -cursor hand1"
	bind $mainFrame.github <Leave> \
		"%W configure -foreground black; \
		$mainFrame config -cursor arrow"
}
.menubar.help add command -label "About" -command $tmp_command

#
# Left-side toolbar
#
ttk::frame $mf.left
pack $mf.left -side left -fill y

foreach b "select link" {
	addTool $b $b

	set image [image create photo -file $ROOTDIR/$LIBDIR/icons/tiny/$b.gif]

	ttk::button $mf.left.$b \
		-image $image \
		-style Toolbutton \
		-command "setActiveToolGroup $b"
	pack $mf.left.$b -side top

	# hover status line
	set msg ""
	if { $b == "select" } {
		set msg "Select tool"
	} elseif { $b == "link" } {
		set msg "Create link"
	}

	bind $mf.left.$b <Any-Enter> ".bottom.textbox config -text {$msg}"
	bind $mf.left.$b <Any-Leave> ".bottom.textbox config -text {}"
}

foreach node_type $all_modules_list {
	if { [$node_type.netlayer] == "LINK" } {
		addTool "link_layer" $node_type
	} elseif { [$node_type.netlayer] == "NETWORK" } {
		addTool "net_layer" $node_type
	}
}

refreshToolBarNodes
set image [image create photo -file $ROOTDIR/$LIBDIR/icons/tiny/l2.gif]
ttk::menubutton $mf.left.link_layer -image $image -style Toolbutton \
	-menu $mf.left.link_nodes -direction right
bind $mf.left.link_layer <Any-Enter> ".bottom.textbox config -text {Add new link layer node}"
bind $mf.left.link_layer <Any-Leave> ".bottom.textbox config -text {}"
pack $mf.left.link_layer

set image [image create photo -file $ROOTDIR/$LIBDIR/icons/tiny/l3.gif]
ttk::menubutton $mf.left.net_layer -image $image -style Toolbutton \
	-menu $mf.left.net_nodes -direction right
bind $mf.left.net_layer <Any-Enter> ".bottom.textbox config -text {Add new network layer node}"
bind $mf.left.net_layer <Any-Leave> ".bottom.textbox config -text {}"
pack $mf.left.net_layer

foreach b "rectangle oval freeform text" {
	addTool $b $b

	set image [image create photo -file $ROOTDIR/$LIBDIR/icons/tiny/$b.gif]

	ttk::button $mf.left.$b \
		-image $image \
		-style Toolbutton \
		-command "setActiveToolGroup $b"

	pack $mf.left.$b -side bottom
	# hover status line
	switch -exact -- $b {
		rectangle { set msg "Add a Rectangle" }
		oval { set msg "Add an Oval" }
		freeform { set msg "Add a Freeform" }
		text { set msg "Add a Textbox" }
		default { set msg "" }
	}

	bind $mf.left.$b <Any-Enter> ".bottom.textbox config -text {$msg}"
	bind $mf.left.$b <Any-Leave> ".bottom.textbox config -text {}"
}

set mask_width 8
set mask_height 8
# define gradient steps of the circle used for running nodes (center to rim)
# last one indicates the node label color and is ignored
set running_indicator_palette {
	"#1dd71f"
	"#1dc71f"
	"#1db71f"
	"#1da71f"
	"#1d971f"
	"#1d771f"
	"#1d571f"
	"#000000"
	"#1d671f"
}

set running_mask_image [image create photo -width $mask_width -height $mask_height]
drawGradientCircle $running_mask_image $running_indicator_palette $mask_width $mask_height

foreach b $all_modules_list {
	set $b [image create photo -file [$b.icon normal]]
	set $b\_iconwidth [image width [set $b]]
	set $b\_iconheight [image height [set $b]]
}
set pseudo [image create photo]
set pseudo_iconwidth 0
set pseudo_iconheight 0

. configure -background #808080
ttk::frame $mf.grid
ttk::frame $mf.hframe
ttk::frame $mf.vframe
set c [canvas $mf.c \
	-bd 0 \
	-relief sunken \
	-highlightthickness 0 \
	-background gray \
	-xscrollcommand "$mf.hframe.scroll set" \
	-yscrollcommand "$mf.vframe.scroll set"]

canvas $mf.hframe.t \
	-width 160 \
	-height 18 \
	-bd 0 \
	-highlightthickness 0 \
	-background #d9d9d9 \
	-xscrollcommand "$mf.hframe.ts set"

bind $mf.hframe.t <1> {
	global mf

	set canvas [lindex [$mf.hframe.t gettags current] 1]
	if { $canvas != "" && $canvas != [getFromRunning "curcanvas"] } {
		setToRunning "curcanvas" $canvas
		switchCanvas none
	}
}

bind $mf.hframe.t <Double-1> {
	global mf

	set canvas [lindex [$mf.hframe.t gettags current] 1]
	if { $canvas != "" } {
		if { $canvas != [getFromRunning "curcanvas"] } {
			setToRunning "curcanvas" $canvas
			switchCanvas none
		} else {
			renameCanvasPopup
		}
	} else {
		newCanvas ""
		switchCanvas last
		set changed 1
		updateUndoLog
	}
}

#scrollbar $mf.hframe.scroll -orient horiz -command "$c xview" \
#	-bd 1 -width 14
#scrollbar $mf.vframe.scroll -command "$c yview" \
#	-bd 1 -width 14
#scrollbar $mf.hframe.ts -orient horiz -command "$mf.hframe.t xview" \
#	-bd 1 -width 14

ttk::scrollbar $mf.hframe.scroll -orient horiz -command "$c xview"
ttk::scrollbar $mf.vframe.scroll -command "$c yview"
ttk::scrollbar $mf.hframe.ts -orient horiz -command ".panwin.f1.hframe.t xview"
pack $mf.hframe.ts -side left -padx 0 -pady 0
pack $mf.hframe.t -side left -padx 0 -pady 0 -fill both -expand true
pack $mf.hframe.scroll -side left -padx 0 -pady 0 -fill both -expand true
pack $mf.vframe.scroll -side top -padx 0 -pady 0 -fill both -expand true
pack $mf.grid -expand yes -fill both -padx 1 -pady 1
grid rowconfig $mf.grid 0 -weight 1 -minsize 0
grid columnconfig $mf.grid 0 -weight 1 -minsize 0
grid $mf.c -in $mf.grid -row 0 -column 0 \
	-rowspan 1 -columnspan 1 -sticky news
grid $mf.vframe -in $mf.grid -row 0 -column 1 \
	-rowspan 1 -columnspan 1 -sticky news
grid $mf.hframe -in $mf.grid -row 1 -column 0 \
	-rowspan 1 -columnspan 1 -sticky news

ttk::frame .bottom
pack .bottom -side bottom -fill x
pack propagate $mf 0
ttk::label .bottom.textbox -relief sunken -anchor w -width 999
ttk::label .bottom.zoom -relief sunken -anchor w -width 10
bind .bottom.zoom <Double-1> "selectZoom %X %Y"
bind .bottom.zoom <3> "selectZoomPopupMenu %X %Y"
ttk::label .bottom.cpu_load -relief sunken -anchor e -width 9
ttk::label .bottom.mbuf -relief sunken -anchor w -width 15
ttk::label .bottom.oper_mode -relief sunken -anchor w -width 10
ttk::label .bottom.experiment_id -relief sunken -anchor w -width 20
pack .bottom.experiment_id .bottom.oper_mode .bottom.mbuf .bottom.cpu_load \
	.bottom.zoom .bottom.textbox -side right -padx 0 -fill both

#
# Event bindings and procedures for main canvas:
#
$c bind node <Any-Enter> "nodeEnter $c"
$c bind nodelabel <Any-Enter> "nodeEnter $c"
$c bind link <Any-Enter> "linkEnter $c"
$c bind linklabel <Any-Enter> "linkEnter $c"
$c bind node <Any-Leave> "anyLeave $c"
$c bind nodelabel <Any-Leave> "anyLeave $c"
$c bind link <Any-Leave> "anyLeave $c"
$c bind linklabel <Any-Leave> "anyLeave $c"

$c bind node <Double-1> "nodeConfigGUI $c {}"
$c bind nodelabel <Double-1> "nodeConfigGUI $c {}"

$c bind node <Control-Double-1> "nodeConfigGUI $c {}"
$c bind nodelabel <Control-Double-1> "nodeConfigGUI $c {}"

$c bind grid <Double-1> "double1onGrid $c %x %y"

$c bind link <Double-1> "linkConfigGUI $c {}"
$c bind linklabel <Double-1> "linkConfigGUI $c {}"

$c bind oval <Double-1> "annotationConfigGUI $c"
$c bind rectangle <Double-1> "annotationConfigGUI $c"
$c bind text <Double-1> "annotationConfigGUI $c"
$c bind freeform <Double-1> "annotationConfigGUI $c"

$c bind text <KeyPress> "textInsert $c %A"
$c bind text <Return> "textInsert $c \\n"
$c bind node <3> "button3node $c %x %y"
$c bind nodelabel <3> "button3node $c %x %y"
$c bind link <3> "button3link $c %x %y"
$c bind linklabel <3> "button3link $c %x %y"

$c bind route <Any-Enter> "anyLeave $c"
$c bind route <Any-Leave> "anyLeave $c"
$c bind showCfgPopup <Any-Leave> "anyLeave $c"
$c bind text <Any-Leave> "anyLeave $c"

$c bind oval <3> "button3annotation oval $c %x %y"
$c bind rectangle <3> "button3annotation rectangle $c %x %y"
$c bind text <3> "button3annotation text $c %x %y"
$c bind freeform <3> "button3annotation freeform $c %x %y"

$c bind selectmark <Any-Enter> "selectmarkEnter $c %x %y"
$c bind selectmark <Any-Leave> "selectmarkLeave $c %x %y"

$c bind background <3> "button3background $c %x %y"
#$c bind grid <3> "button3background $c %x %y"

bind $c <1> "button1 $c %x %y none"
bind $c <Control-Button-1> "button1 $c %x %y ctrl"
bind $c <B1-Motion> "button1-motion $c %x %y"
bind $c <B1-ButtonRelease> "button1-release $c %x %y"
bind . <Delete> deleteSelection

# Scrolling and panning support
bind $c <2> "$c scan mark %x %y"
bind $c <B2-Motion> "$c scan dragto %x %y 1"
bind $c <4> "$c yview scroll 1 units"
bind $c <5> "$c yview scroll -1 units"
bind . <Right> "$mf.c xview scroll 1 units"
bind . <Left> "$mf.c xview scroll -1 units"
bind . <Down> "$mf.c yview scroll 1 units"
bind . <Up> "$mf.c yview scroll -1 units"

# Escape to Select mode
bind . <Key-Escape> "setActiveToolGroup select; selectNode $c none"
bind . <F5> "redrawAll"
bind . <F7> {
	global showTree

	set showTree [expr {$showTree ^ 1}]
	topologyElementsTree
}

#
# Popup-menu hierarchy
#
menu .button3menu -tearoff 0
menu .button3menu.connect -tearoff 0
menu .button3menu.connect_iface -tearoff 0
menu .button3menu.moveto -tearoff 0
menu .button3menu.shell -tearoff 0
menu .button3menu.wireshark -tearoff 0
menu .button3menu.tcpdump -tearoff 0
menu .button3menu.canvases -tearoff 0
menu .button3menu.icon -tearoff 0
menu .button3menu.transform -tearoff 0
menu .button3menu.sett -tearoff 0
menu .button3menu.iface_settings -tearoff 0
menu .button3menu.services -tearoff 0
menu .button3menu.node_execute -tearoff 0
menu .button3menu.node_config -tearoff 0
menu .button3menu.ifaces_config -tearoff 0

menu .button3physifc -tearoff 0
menu .button3logifc -tearoff 0
#
# Invisible pseudo links
#
set invisible -1
bind . <Control-i> {
	global invisible
	set invisible [expr $invisible * -1]
	redrawAll
}

set key_bindings [list \
	"1"	"select" \
	"2"	"link" \
	"3"	"link_layer" \
	"4"	"net_layer" \
	"5"	"text" \
	"6"	"freeform" \
	"7"	"oval" \
	"8"	"rectangle" \
	]

foreach {key tool_group} $key_bindings {
	bind . $key "cycleToolGroup $tool_group"
}

focus -force .
