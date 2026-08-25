// SPDX-FileCopyrightText: © 2025 LibreLane Template Contributors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

// TODO: seperate out digital power again once we have the splitter cells
module chip_top #(
	parameter NUM_VSSA   = 5,
	parameter NUM_VDDA   = 2,
	parameter NUM_IOVSSA = 2,
	parameter NUM_IOVDDA = NUM_IOVSSA,
	// Signal pads
	parameter EDGE_INFO_W = 8,
	parameter NUM_ANALOG_PADS = 8
	)(
	`ifdef USE_POWER_PINS
	//inout wire IOAVDD, IODVDD,
	inout wire IOVDDA,
	inout wire IOVSSA,
	//inout wire VDDD, VSSD,
	inout wire  VDDA,
	inout wire  VSSA,
	`endif
	inout  wire clk_p_PAD,
	inout  wire clk_n_PAD,

	inout  wire rst_n_PAD,

	inout  wire tx_p_PAD,
	inout  wire tx_n_PAD,
	inout  wire rx_p_PAD,
	inout  wire rx_n_PAD,
	
	inout  wire [NUM_ANALOG_PADS-1:0] analog_PAD,

	inout  wire spi_sclk_PAD,
	inout  wire spi_ncs_PAD,
	inout  wire spi_si_PAD,
	inout  wire spi_so_PAD,

	inout  wire test_mode_PAD, 
	inout  wire clk_mon_PAD, 
	inout  wire unused_PAD, 

	inout  wire [EDGE_INFO_W-1:0] edge_info_PAD
);
`ifdef USER_POWER_PINS
	wire VDDD, VSSD; 
	assign VDDD = VDDA; // TODO remove once we have splitter cells
	assign VSSD = VSSA; 
`endif

	(* keep *) wire digital_clk;
	wire                       rst_n_PAD2CORE;
	wire [NUM_ANALOG_PADS-1:0] analog_PADRES;

	// Power/gnd
	// IO ring power
	generate 
	for (genvar i = 0; i  < NUM_IOVDDA; i = i+1) begin: iovdda 
   		(* keep *)
   		sg13cmos5l_IOPadIOVdd iovdda_pad(
   	`ifdef USE_POWER_PINS
   		.iovdd  (IOVDDA),
   		.iovss  (IOVSSA),
   		.vdd(VDDA),
   	   	.vss(VSSA)
   	   	`endif
   		 );
	end
	for (genvar i = 0; i  < NUM_IOVSSA; i = i+1) begin: iovssa 
	(* keep *)
	sg13cmos5l_IOPadIOVss iovssa_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IOVDDA),
	.iovss  (IOVSSA),
	.vdd    (VDDA),
	.vss    (VSSA)
	`endif
	);
	end
	/*
	(* keep *)
	sg13cmos5l_IOPadIOVdd iodvdd_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IODVDD),
	.iovss  (IODVSS),
	.vdd    (DVDD),
	.vss    (DVSS)
	`endif
	);
	(* keep *)
	sg13cmos5l_IOPadIOVss iodvss_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IODVDD),
	.iovss  (IODVSS),
	.vdd    (DVDD),
	.vss    (DVSS)
	`endif
	);*/
	// Analog power domain
	for (genvar i = 0; i  < NUM_VDDA; i = i+1) begin: vdda 
	(* keep *)
	sg13cmos5l_IOPadVdd vdda_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IOVDDA),
	.iovss  (IOVSSA),
	.vdd    (VDDA),
	.vss    (VSSA)
	`endif
	);
	end
	for (genvar i = 0; i  < NUM_VSSA; i = i+1) begin: vssa 
	(* keep *)
	sg13cmos5l_IOPadVss vssa_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IOVDDA),
	.iovss  (IOVSSA),
	.vdd    (VDDA),
	.vss    (VSSA)
	`endif
	);
	end
	
	/* Digital power domain
	(* keep *)
	sg13cmos5l_IOPadVdd dvdd_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IODVDD),
	.iovss  (IODVSS),
	.vdd    (DVDD),
	.vss    (DVSS)
	`endif
	);
	(* keep *)
	sg13cmos5l_IOPadVss dvss_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IODVDD),
	.iovss  (IODVSS),
	.vdd    (DVDD),
	.vss    (DVSS)
	`endif
	);*/
	endgenerate // power


	// Signal IO pad instances
	(* keep *)
	sg13cmos5l_IOPadIn rst_n_pad(
	`ifdef USE_POWER_PINS
	.iovdd  (IOVDDA),
	.iovss  (IOVSSA),
	.vdd    (VDDA),
	.vss    (VSSA),
	`endif
	.p2c    (rst_n_PAD2CORE),
	.pad    (rst_n_PAD)
	);
	
	generate
	for (genvar i=0; i<NUM_ANALOG_PADS; i++) begin : analogs
	(* keep *)
	sg13cmos5l_IOPadAnalog analog_pad (
	    `ifdef USE_POWER_PINS
	    .iovdd  (IOVDDA),
	    .iovss  (IOVSSA),
	    .vdd    (VDDA),
	    .vss    (VSSA),
	    `endif
	    .padres (analog_PADRES[i]),
	    .pad    (analog_PAD[i])
	);
	end
	endgenerate

	// named analog pads
	wire clk_p, clk_n;
	wire tx_p, tx_n;
	wire rx_p, rx_n;
	(* keep *) sg13cmos5l_IOPadAnalog tx_p_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (tx_p),
	.pad    (tx_p_PAD)
	);

	(* keep *) sg13cmos5l_IOPadAnalog tx_n_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (tx_n),
	.pad    (tx_n_PAD)
	);
	(* keep *) sg13cmos5l_IOPadAnalog rx_p_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (rx_p),
	.pad    (rx_p_PAD)
	);

	(* keep *) sg13cmos5l_IOPadAnalog rx_n_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (rx_n),
	.pad    (rx_n_PAD)
	);   
	(* keep *) sg13cmos5l_IOPadAnalog clk_p_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (clk_p),
	.pad    (clk_p_PAD)
	);

	(* keep *) sg13cmos5l_IOPadAnalog clk_n_pad (
	`ifdef USE_POWER_PINS
	.iovdd(IOVDDA), .iovss(IOVSSA), .vdd(VDDA), .vss(VSSA),
	`endif
	.padres (clk_n),
	.pad    (clk_n_PAD)
	);

	// SPI pads
	wire spi_sclk, spi_ncs, spi_si, spi_so_en, spi_so;
	(* keep *) sg13cmos5l_IOPadIn spi_sclk_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.p2c(spi_sclk),	
		.pad(spi_sclk_PAD)
	 ); 
	(* keep *) sg13cmos5l_IOPadIn spi_ncs_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.p2c(spi_ncs), 
		.pad(spi_ncs_PAD)
	 ); 
	(* keep *) sg13cmos5l_IOPadIn spi_si_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.p2c(spi_si), 
		.pad(spi_si_PAD)
	 ); 
	(* keep *) sg13cmos5l_IOPadTriOut30mA spi_so_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.pad(spi_so_PAD), 
		.c2p(spi_so), 
		.c2p_en(spi_so_en)
	);
	// edge info pads
	wire [EDGE_INFO_W-1:0] edge_info_pad2core;
	generate
	for (genvar i=0; i< EDGE_INFO_W; i++) begin : edge_info
	(* keep *)
	sg13cmos5l_IOPadOut30mA edge_info_pad (
	    `ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
	    `endif
	    .c2p(edge_info_pad2core[i]),
	    .pad(edge_info_PAD[i])
	);
	end
	endgenerate
	// misc digital pads
	wire test_mode, clk_mon, unused_pad2core; 
	(* keep *) sg13cmos5l_IOPadIn test_mode_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.p2c(test_mode), 
		.pad(test_mode_PAD)
	 ); 
	(* keep *) sg13cmos5l_IOPadIn unused_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.p2c(unused_pad2core), 
		.pad(unused_PAD)
	 ); 	
	(* keep *) sg13cmos5l_IOPadOut30mA clk_mon_pad (
		`ifdef USE_POWER_PINS
		.iovdd(IOVDDA), .iovss(IOVSSA),	.vdd(VDDA),	.vss(VSSA),
		`endif
		.c2p(clk_mon), 
		.pad(clk_mon_PAD)
	 ); 
	

	// Digital core design
	(* keep *) chip_core i_chip_core (
	`ifdef USE_POWER_PINS
		.VDD(VDDA),
		.VSS(VSSA),
	`endif
		.clk        (digital_clk),
		.rst_n      (rst_n_PAD2CORE),

		.spi_sclk    (spi_sclk), 
		.spi_ncs_i   (spi_ncs), 
		.spi_si_i    (spi_si),
		.spi_so_en_o (spi_so_en),
		.spi_so_o    (spi_so),

		.edge_info_o (edge_info_pad2core), 
		.test_mode_i (test_mode), 
		.clk_mon_o   (clk_mon),
		.unused_pad_i(unused_pad2core)
	);

	// Dummy analog design
	(* keep *) analog_dummy #(
		.NUM_ANALOG_PADS(NUM_ANALOG_PADS)
	) m_analog (
	`ifdef USE_POWER_PINS
		.VDD(VDDA),
		.VSS(VSSA),
	`endif
		.clk_p_io(clk_p),
		.clk_n_io(clk_n),
		
		.tx_p_io(tx_p),
		.tx_n_io(tx_n),
		.rx_p_io(rx_p),
		.rx_n_io(rx_n),

		.analog_io(analog_PADRES),
		.digital_clk_o(digital_clk)
	);

endmodule
