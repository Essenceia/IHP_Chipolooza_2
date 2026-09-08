puts "Creating analog power regions"

# chip is a square
set min 365 
#[lindex $::env(CORE_AREA) 0]
set max 1215 
#[lindex $::env(CORE_AREA) 2]
set mid [expr (($max - $min)/2) + $min]

# create analog region for pwr { min_x min_y max_x max_y }
# analog domain is an mirrored L 
log_cmd create_voltage_domain ANALOG -area [list $min $min $max $mid]
log_cmd create_voltage_domain ANALOG_SECONDARY -area [list $min $min $mid $mid]
log_cmd create_voltage_domain DIGITAL -area [list $min $mid $mid $max]
#log_cmd delete_voltage_domain Core

#delete_voltage_domain {Core} 
