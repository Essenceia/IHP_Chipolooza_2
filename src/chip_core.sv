// SPDX-FileCopyrightText: © 2025 XXX Authors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_core #(
    parameter NUM_INPUT_PADS  = 2,
    parameter NUM_OUTPUT_PADS = 1,
    parameter NUM_BIDIR_PADS  = 8
    )(
    `ifdef USE_POWER_PINS
	inout wire VDD, 
	inout wire VSS,
	`endif
	input  logic clk,       // clock
    input  logic rst_n,     // reset (active low)
    
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
endmodule
