// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_core #(
    parameter NUM_INPUT_PADS  = 2,
    parameter NUM_OUTPUT_PADS = 1,
    parameter NUM_BIDIR_PADS  = 8,
	parameter SPI_ADDR_W = 5,
	parameter SPI_DATA_W = 16
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
 
    input  wire [NUM_INPUT_PADS-1 :0] input_in,   // Input value
    output wire [NUM_OUTPUT_PADS-1:0] output_out, // Output value
    input  wire [NUM_BIDIR_PADS-1 :0] bidir_in,   // Input value
    output wire [NUM_BIDIR_PADS-1 :0] bidir_out,  // Output value
    output wire [NUM_BIDIR_PADS-1 :0] bidir_oe    // Output enable
);

// Set all bidir as output
assign bidir_oe = {NUM_BIDIR_PADS{1'b1}};

logic _unused;
assign _unused = &bidir_in | &input_in;

logic [NUM_BIDIR_PADS-1:0] count;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        count <= '0;
    end else begin
        if (&input_in) begin
            count <= count + 1;
        end
    end
end

assign bidir_out = count;
assign output_out = {NUM_OUTPUT_PADS{1'b0}};

// TODO wire control 
wire ctr_v_unused; 
wire ctr_rd_unused;
wire [SPI_ADDR_W-1:0] ctr_addr_unused; 
wire [SPI_DATA_W-1:0] ctr_wr_data_unused; 
wire [SPI_DATA_W-1:0] ctr_rd_data; 
assign ctr_rd_data = {SPI_DATA_W{1'bX}}; 

spi #(.ADDR_W(SPI_ADDR_W), .DATA_W(SPI_DATA_W)) m_spi(
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

endmodule
