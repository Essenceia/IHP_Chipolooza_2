// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_core #(
	parameter CTR_ADDR_W = 5,
	parameter CTR_DATA_W = 16,
	parameter EDGE_INFO_W = 8
    )(
    `ifdef USE_POWER_PINS
	inout wire VDD, 
	inout wire VSS,
	`endif
	input  logic clk,       // clock
    input  logic rst_n,     // reset (active low)
	
	input  wire spi_sclk, 
	input  wire spi_ncs_i,
	input  wire spi_si_i, 
	output wire spi_so_en_o,
	output wire spi_so_o,
	
	output wire [EDGE_INFO_W-1:0] edge_info_o,
	input  wire test_mode_i, 
	output wire clk_mon_o, 
	input  wire unused_pad_i
);
wire test_mode_unused; 
wire unused_pad_unused; 
assign test_mode_unused = test_mode_i; 
assign unused_pad_unused = unused_pad_i;

// TODO wire control 
wire ctr_v_unused; 
wire ctr_rd_unused;
wire [CTR_ADDR_W-1:0] ctr_addr_unused; 
wire [CTR_DATA_W-1:0] ctr_wr_data_unused; 
wire [CTR_DATA_W-1:0] ctr_rd_data; 
assign ctr_rd_data = {CTR_DATA_W{1'bX}}; 

spi #(.ADDR_W(CTR_ADDR_W), .DATA_W(CTR_DATA_W)) m_spi(
	.rst_n     (rst_n),

	.sclk      (spi_sclk), 
	.ncs_i     (spi_ncs_i),
	.si_i      (spi_si_i), 
	.so_en_o   (spi_so_en_o), 
	.so_o      (spi_so_o),
 
	.req_v_o   (ctr_v_unused), 
	.req_rd_o  (ctr_rd_unused), 
	.req_addr_o(ctr_addr_unused),
	.req_data_o(ctr_wr_data_unused),
	.res_data_i(ctr_rd_data)
);

/* output */
assign clk_mon_o    = clk; 
assign edge_info_o  = {EDGE_INFO_W{1'b0}};

endmodule
