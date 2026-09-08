puts  stderr "Reading custom PDN cfg file for split power domains" 

# cargo cult
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

source $::env(DESIGN_DIR)/regions.tcl

# tag pwr/gnd nets in odb
#set secondary []
#foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
#	puts "\[INFO\] VDD $vdd GND $gnd" 
#    if { $vdd != $::env(VDD_NET)} {
#        lappend secondary $vdd
#
#        set db_net [[ord::get_db_block] findNet $vdd]
#        if {$db_net == "NULL"} {
#            set net [odb::dbNet_create [ord::get_db_block] $vdd]
#            $net setSpecial
#            $net setSigType "POWER"
#        }
#    }
#
#    if { $gnd != $::env(GND_NET)} {
#        lappend secondary $gnd
#
#        set db_net [[ord::get_db_block] findNet $gnd]
#        if {$db_net == "NULL"} {
#            set net [odb::dbNet_create [ord::get_db_block] $gnd]
#            $net setSpecial
#            $net setSigType "GROUND"
#        }
#    }
#}

proc set_db_net_special { netname sigtype } {
	set db_net [[ord::get_db_block] findNet $netname]
	if {$db_net == "NULL"} {
	    set net [odb::dbNet_create [ord::get_db_block] $netname]
	    log_cmd $net setSpecial
	    log_cmd $net setSigType $sigtype
	} else {
	    $db_net setSpecial
	    $db_net setSigType $sigtype
		puts $netname
	}
}

set_db_net_special VDDD "POWER"
set_db_net_special VSSD "GROUND"
set_db_net_special VDDA "POWER"
set_db_net_special VSSA "GROUND"

# define power domains
# CORE digital domain exists by default 
set d_pwr DIGITAL 
set a_pwr ANALOG
set a_pwr2 ANALOG_SECONDARY
set_voltage_domain -name $d_pwr -region $d_pwr -power VDDD -ground VSSD 
set_voltage_domain -name $a_pwr -region $a_pwr -power VDDA -ground VSSA
set_voltage_domain -name $a_pwr2 -region $a_pwr2 -power VDDA -ground VSSA

# don't add a core ring as we don't have unified power

# digital power grid: don't have an analog power grid, analog will handle it 

puts "\[INFO\] Defining digital voltage domain $d_pwr" 
puts "\[INFO\] PDN Multilayer $::env(PDN_MULTILAYER)" 
puts "\[INFO\] PDN vertical layer $::env(PDN_VERTICAL_LAYER)" 
puts "\[INFO\] PDN horizontal layer $::env(PDN_HORIZONTAL_LAYER)" 

set arg_list [list]
if { $::env(PDN_ENABLE_PINS) } {
	puts "\[INFO\] power layer vertical $::env(PDN_VERTICAL_LAYER) horizontal $::env(PDN_HORIZONTAL_LAYER)" 
    lappend arg_list -pins "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"
}

log_cmd define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain $d_pwr \
    {*}$arg_list

set arg_list [list]
append_if_equals arg_list PDN_EXTEND_TO "core_ring" -extend_to_core_ring
append_if_equals arg_list PDN_EXTEND_TO "boundary" -extend_to_boundary

log_cmd add_pdn_stripe \
    -grid stdcell_grid \
    -layer $::env(PDN_VERTICAL_LAYER) \
    -width $::env(PDN_VWIDTH) \
    -pitch $::env(PDN_VPITCH) \
    -offset $::env(PDN_VOFFSET) \
    -spacing $::env(PDN_VSPACING) \
    -starts_with POWER \
    {*}$arg_list

log_cmd add_pdn_stripe \
    -grid stdcell_grid \
    -layer $::env(PDN_HORIZONTAL_LAYER) \
    -width $::env(PDN_HWIDTH) \
    -pitch $::env(PDN_HPITCH) \
    -offset $::env(PDN_HOFFSET) \
    -spacing $::env(PDN_HSPACING) \
    -starts_with POWER \
    {*}$arg_list

log_cmd add_pdn_connect \
    -grid stdcell_grid \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

