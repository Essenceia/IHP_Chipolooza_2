current_design $::env(DESIGN_NAME)
set_units -time ns

# Common 

set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]
if { [info exists ::env(MAX_TRANSITION_CONSTRAINT)] } {
    set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]
}
if { [info exists ::env(MAX_CAPACITANCE_CONSTRAINT)] } {
    set_max_capacitance $::env(MAX_CAPACITANCE_CONSTRAINT) [current_design]
}

set cap_load [expr $::env(OUTPUT_CAP_LOAD) / 1000.0]
puts "\[INFO] Setting load to: $cap_load"
set_load $cap_load [all_outputs]

# SPI 
set SCLK_MHZ 10
set SCLK_PERIOD [expr 1000.0/ $SCLK_MHZ]
set spi_clk sclk
puts "clk $spi_clk $SCLK_MHZ MHz period $SCLK_PERIOD ns"

create_clock [get_pins -hierarchical -regexp {.*m_spi_sclk_clkroot.m_magic_clkroot_anchor/X}] \
	-name $spi_clk \
	-period $SCLK_PERIOD

puts "\[WARNING\] TODO: Julia don't forget to update the sdc for proper SPI timing"

set spi_input_delay_value [expr $SCLK_PERIOD * $::env(IO_DELAY_CONSTRAINT) / 100]
set spi_output_delay_value [expr $SCLK_PERIOD * $::env(IO_DELAY_CONSTRAINT) / 100]
puts "\[INFO] Setting SPI output delay to: $spi_output_delay_value"
puts "\[INFO] Setting SPI input delay to: $spi_input_delay_value"

# Input-only pads
set spi_input_ports [get_ports { 
  rst_n_PAD
  spi_si_PAD
  spi_ncs_PAD
}] 

set_input_delay -min 0 -clock $spi_clk $spi_input_ports
set_input_delay -max $spi_input_delay_value -clock $spi_clk $spi_input_ports

# Bidirectional pads
set spi_inout_ports [get_ports { 
	spi_so_PAD
}] 

set_input_delay -min 0 -clock $spi_clk $spi_inout_ports
set_input_delay -max $spi_input_delay_value -clock $spi_clk $spi_inout_ports
set_output_delay $spi_output_delay_value -clock $spi_clk $spi_inout_ports

puts "\[INFO] Setting SPI clock uncertainty to: $::env(CLOCK_UNCERTAINTY_CONSTRAINT)"
set_clock_uncertainty $::env(CLOCK_UNCERTAINTY_CONSTRAINT) $spi_clk

puts "\[INFO] Setting SPI clock transition to: $::env(CLOCK_TRANSITION_CONSTRAINT)"
set_clock_transition $::env(CLOCK_TRANSITION_CONSTRAINT) $spi_clk

# Digital clk
puts "\[WARNING\] TODO: Julia D2A timing assums max of 10G and 32b wide interface, update for 25G and different interface widths"
puts "\[WARNING\] TODO: Update digital clk with proper analog -> digital parameters"

set A2D_W 32 
set DIGITAL_CLK_MHZ 322.26562 
puts "\[INFO\] DIGITAL_CLK_MHZ $DIGITAL_CLK_MHZ MHz"
set DIGITAL_CLK_PERIOD [expr 1000 / $DIGITAL_CLK_MHZ]
set digital_clk digital_clk

create_clock [get_pins -hierarchical -regexp {.*m_digital_clk_clkroot.m_magic_clkroot_anchor/X}] \
	-name $digital_clk \
	-period $DIGITAL_CLK_PERIOD

puts "\[INFO] Setting digital clock uncertainty to: $::env(CLOCK_UNCERTAINTY_CONSTRAINT)"
set_clock_uncertainty $::env(CLOCK_UNCERTAINTY_CONSTRAINT) $digital_clk

puts "\[INFO] Setting digital clock transition to: $::env(CLOCK_TRANSITION_CONSTRAINT)"
set_clock_transition $::env(CLOCK_TRANSITION_CONSTRAINT) $digital_clk


# Common 
puts "\[INFO] Setting timing derate to: $::env(TIME_DERATING_CONSTRAINT)%"
set_timing_derate -early [expr 1-[expr $::env(TIME_DERATING_CONSTRAINT) / 100]]
set_timing_derate -late [expr 1+[expr $::env(TIME_DERATING_CONSTRAINT) / 100]]

if { [info exists ::env(OPENLANE_SDC_IDEAL_CLOCKS)] && $::env(OPENLANE_SDC_IDEAL_CLOCKS) } {
    unset_propagated_clock [all_clocks]
} else {
    set_propagated_clock [all_clocks]
}



