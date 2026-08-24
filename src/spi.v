/* Julia Desmazes, 2026

Designed as part of the SerDes Chipolooza challenge #2

SPI slave interface

Designed to work in serial mode 0
*/

`default_nettype none

module spi #(
	parameter ADDR_W = 5,
	parameter DATA_W = 16
)(
	/* SPI bus interface */
	input wire sclk,
	input wire ncs_i, /* negative chip select, low enable */
	input wire si_i, 
	output wire so_o,

	/* Control register interface
	request: read/write data from master */ 
	output wire req_v_o, 
	output wire req_rd_o,
	output wire [ADDR_W-1:0] req_addr_o,
	output wire [DATA_W-1:0] req_data_o,
	/* response: read data for slave response */
	input wire [DATA_W-1:0] res_data_i
);

localparam OP_W = 8; 
/* read and write use address width ADDR_W and data width DATA_W */
localparam [OP_W-1:0] OP_READ  = 1'b0; 
localparam [OP_W-1:0] OP_WRITE = 1'b1; 

localparam FSM_W = 3;
localparam [FSM_W-1:0] IDLE   = 'd0;  
localparam [FSM_W-1:0] OPCODE = 'd1; 
localparam [FSM_W-1:0] ADDR   = 'd2; 
localparam [FSM_W-1:0] DATA   = 'd3;

reg [FSM_W-1:0] fsm_q; 

localparam BUF_W = $max(ADDR_W, DATA_W);
localparam CNT_W = $clog2($max(BUF_W, OP_W));
reg [CNT_W-1:0] cnt_q; 
reg [BUF_W-1:0] buf_q;

wire opcode_finished; 
wire opcode_v; 
wire addr_finished; 
wire data_finished; 

always @(posedge sclk or posedge ncs_i) begin
	if (ncs_i) begin
		fsm_q <= OPCODE; 
	end else begin
		case(fsm_q) 
			OPCODE:	fsm_q <= opcode_finished ? (opcode_v ? ADDR: IDLE): OPCODE;  
			ADDR:	fsm_q <= addr_finished ? DATA: ADDR;  
			DATA:	fsm_q <= data_finished ? IDLE: DATA;  
			IDLE:   fsm_q <= IDLE; // loop in idle until cs is deasserted
		endcase
	end
end

/* data is allways latched on rising edge */ 
always @(posedge sclk or posedge ncs_i) begin
	if (ncs_i) buf_q <= {BUF_W{1'b0}};
	else buf_q <= { buf_q[BUF_W-2:1], si_i};
end

localparam [CNT_W-1:0] OPCODE_CNT = OP_W - 1;
localparam [CNT_W-1:0] ADDR_CNT = ADDR_W - 1;
localparam [CNT_W-1:0] DATA_CNT = DATA_W - 1;

wire cnt_rst; 
assign opcode_finished = (fsm_q == OPCODE) & cnt_q == OPCODE_CNT; 
assign addr_finished   = (fsm_q == ADDR) & cnt_q == ADDR_CNT; 
assign data_finished   = (fsm_q == DATA) & cnt_q == DATA_CNT; 
assign cnt_rst = opcode_finished | addr_finished | data_finished; 

always @(posedge sclk or posedge ncs_i) begin
	if (ncs_i | cnt_rst) cnt_q <= {CNT_W{1'b0}};
	else cnt_q <= cnt_q + 1'b1; 
end

/* response is allways provided on falling edge */


endmodule
