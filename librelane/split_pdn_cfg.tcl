puts  stderr "Reading custom PDN cfg file for split power domains" 

# cargo cult
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl

set d_pwr Core 
set a_pwr ANALOG
set a_pwr2 ANALOG_SECONDARY

#source $::env(DESIGN_DIR)/regions.tcl
proc log_db_core { domain } {
	set region [log_cmd [ord::get_db_block] findRegion $domain]
	puts "return $region" 
	set domain [log_cmd [ord::get_db_block] findPowerDomain $domain]
	puts "return $domain" 
}

#log_db_core Core

# set global power connections
proc global_connect_pwr_module { inst_regexp vdd vss region } {
	log_cmd add_global_connection -region $region -net $vdd -inst_pattern $inst_regexp -pin_pattern VDD -power
	log_cmd add_global_connection -region $region -net $vss -inst_pattern $inst_regexp -pin_pattern VSS -ground
}
global_connect_pwr_module {.*i_chip_core.*} VDDD VSSD DIGITAL  
global_connect_pwr_module {.*clkroot.*} VDDD VSSD DIGITAL
global_connect_pwr_module {.*m_analog.*} VDDA VSSA ANALOG

# tag pwr/gnd nets in odb
proc set_db_net_special { netname sigtype } {
	set db_net [[ord::get_db_block] findNet $netname]
	if {$db_net == "NULL"} {
	    set net [odb::dbNet_create [ord::get_db_block] $netname]
	    log_cmd $net setSpecial
	    log_cmd $net setSigType $sigtype
	} else {
	    log_cmd $db_net setSpecial
	    log_cmd $db_net setSigType $sigtype
	}
}

puts "Updating db net properties" 

set_db_net_special VDDD "POWER"
set_db_net_special VSSD "GROUND"
set_db_net_special VDDA "POWER"
set_db_net_special VSSA "GROUND"

proc log_voltage_domains { name } {
	puts "voltage domains: "
	set d [log_cmd pdn::find_domain $name] 
	puts "returned $d"

	set d [log_cmd pdn::get_voltage_domains $name] 
	puts "returned $d"
}
# define power domains
#log_cmd set_voltage_domain -name $d_pwr -region $d_pwr -power VDDD -ground VSSD 
log_cmd set_voltage_domain -name $d_pwr -power VDDD -ground VSSD 
puts "Redefining $d_pwr with region DIGITAL"
log_cmd set_voltage_domain -name $d_pwr -region DIGITAL -power VDDD -ground VSSD 
log_cmd set_voltage_domain -name $a_pwr -region $a_pwr -power VDDA -ground VSSA
log_cmd set_voltage_domain -name $a_pwr2 -region $a_pwr2 -power VDDA -ground VSSA

global_connect -verbose

#log_db_core Core 
#log_db_core $d_pwr 
#log_db_core $a_pwr 
#log_voltage_domains Core

pdn::report

# debug
#puts "volate domains: [get_voltage_domains]"

# don't add a core ring as we don't have unified power

# digital power grid: don't have an analog power grid, analog will handle it 
puts "\[INFO\] PDN Multilayer $::env(PDN_MULTILAYER)" 
puts "\[INFO\] PDN vertical layer $::env(PDN_VERTICAL_LAYER)" 
puts "\[INFO\] PDN horizontal layer $::env(PDN_HORIZONTAL_LAYER)" 


proc add_pwr_grid { domain grid_name } {
	puts "\[INFO\] Defining voltage domain $domain" 
	set arg_list [list]
	if { $::env(PDN_ENABLE_PINS) } {
		puts "\[INFO\] power layer vertical $::env(PDN_VERTICAL_LAYER) horizontal $::env(PDN_HORIZONTAL_LAYER)" 
	    lappend arg_list -pins "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"
	}
	
	log_cmd define_pdn_grid \
	    -name $grid_name \
	    -starts_with POWER \
	    -voltage_domain $domain \
	    {*}$arg_list
	
	set arg_list [list]
	append_if_equals arg_list PDN_EXTEND_TO "core_ring" -extend_to_core_ring
	append_if_equals arg_list PDN_EXTEND_TO "boundary" -extend_to_boundary
	
	log_cmd add_pdn_stripe \
	    -grid $grid_name \
	    -layer $::env(PDN_VERTICAL_LAYER) \
	    -width $::env(PDN_VWIDTH) \
	    -pitch $::env(PDN_VPITCH) \
	    -offset $::env(PDN_VOFFSET) \
	    -spacing $::env(PDN_VSPACING) \
	    -starts_with POWER \
	    {*}$arg_list
	
	log_cmd add_pdn_stripe \
	    -grid $grid_name \
	    -layer $::env(PDN_HORIZONTAL_LAYER) \
	    -width $::env(PDN_HWIDTH) \
	    -pitch $::env(PDN_HPITCH) \
	    -offset $::env(PDN_HOFFSET) \
	    -spacing $::env(PDN_HSPACING) \
	    -starts_with POWER \
	    {*}$arg_list
	
	log_cmd add_pdn_ring \
		-grid $grid_name \
		-layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)" \
        -widths "$::env(PDN_CORE_RING_VWIDTH) $::env(PDN_CORE_RING_HWIDTH)" \
        -spacings "$::env(PDN_CORE_RING_VSPACING) $::env(PDN_CORE_RING_HSPACING)" \
        -core_offset "$::env(PDN_CORE_RING_VOFFSET) $::env(PDN_CORE_RING_HOFFSET)" \
		-connect_to_pads

	log_cmd add_pdn_connect \
	    -grid $grid_name \
	    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"
}

add_pwr_grid $d_pwr digital_std_gates	
add_pwr_grid $a_pwr tmp_analog_grid
add_pwr_grid $a_pwr2 tmp_analog_grid2

log_cmd pdngen -check_only 
log_cmd pdngen -report_only 
puts "done" 
	
