/* Inspired by Luke Wren's clkroot_anchor */

// Clock root anchor buffer. No particular meaning in synthesis, but helps
// constraints to find a clock net in the netlist.


`default_nettype none

module clkroot_anchor (
	input  wire i,
	output wire o
);


/* verilator lint_off PINMISSING */
(* keep *) sg13cmos5l_buf_8 m_magic_clkroot_anchor(
	.A (i),
	.X (o)
);

endmodule
