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
	input  wire rst_n, 

	/* SPI bus interface */
	input  wire sclk,
	input  wire ncs_i, /* negative chip select, low enable */
	input  wire si_i, 
	output wire so_en_o, // enable so pin, held to high impedance by default
	output wire so_o,

	/* Control register interface
	request: read/write data from master */ 
	output wire              req_v_o, 
	output wire              req_rd_o,
	output wire [ADDR_W-1:0] req_addr_o,
	output wire [DATA_W-1:0] req_data_o,

	/* response: read data for slave response */
	input  wire [DATA_W-1:0] res_data_i
);

localparam OP_W = 8; 
/* read and write use address width ADDR_W and data width DATA_W */
localparam [OP_W-1:0] OP_READ  = 'd0; 
localparam [OP_W-1:0] OP_WRITE = 'd1; 

localparam FSM_W = 3;
localparam [FSM_W-1:0] IDLE   = 'd0;  
localparam [FSM_W-1:0] OPCODE = 'd1; 
localparam [FSM_W-1:0] ADDR   = 'd2; 
localparam [FSM_W-1:0] DATA   = 'd3;

reg [FSM_W-1:0] fsm_q; 

localparam BUF_W = DATA_W; // $max(OP_W, DATA_W);
localparam CNT_W = $clog2(DATA_W); //$clog2($max(OP_W, DATA_W, ADDR_W));
reg [CNT_W-1:0]  cnt_q; 
reg [BUF_W-1:0]  buf_q;
reg [ADDR_W-1:0] addr_q; 

wire op_rd_next;
reg  op_rd_q; 

wire op_finished; 
wire op_v; 
wire addr_finished; 
wire data_finished; 


always @(posedge sclk or negedge rst_n) begin
	if (~rst_n) begin
		fsm_q <= OPCODE; 
	end else begin
		if (ncs_i) begin
			fsm_q <= OPCODE;
		end else begin
			case(fsm_q) 
				OPCODE:	fsm_q <= op_finished ? (op_v ? ADDR: IDLE): OPCODE;  
				ADDR:	fsm_q <= addr_finished ? DATA: ADDR;  
				DATA:	fsm_q <= data_finished ? IDLE: DATA;  
				IDLE:   fsm_q <= IDLE; // loop in idle until cs is deasserted
				default: fsm_q <= IDLE; 
			endcase
		end
	end
end

always @(posedge sclk) 
	op_rd_q <= op_rd_next; 

/* data is allways latched on rising edge */ 
always @(posedge sclk) begin 
	if (fsm_q == ADDR) addr_q <= { addr_q[ADDR_W-1:1], si_i};
	buf_q <= { buf_q[BUF_W-1:1], si_i};
end

/* verilator lint_off WIDTHTRUNC */
localparam [CNT_W-1:0] OP_CNT   = OP_W - 1;
localparam [CNT_W-1:0] ADDR_CNT = ADDR_W - 1;
localparam [CNT_W-1:0] DATA_CNT = DATA_W - 1;
/* verilator lint_on WIDTHTRUNC */

wire cnt_rst; 
assign op_finished = (fsm_q == OPCODE) & cnt_q == OP_CNT; 
assign addr_finished = (fsm_q == ADDR) & cnt_q == ADDR_CNT; 
assign data_finished = (fsm_q == DATA) & cnt_q == DATA_CNT; 
assign cnt_rst = op_finished | addr_finished | data_finished; 

always @(posedge sclk or negedge rst_n) begin
	if (~rst_n) cnt_q <= {CNT_W{1'b0}};
	else begin
		if (ncs_i | cnt_rst) cnt_q <= {CNT_W{1'b0}};
		else cnt_q <= cnt_q + 1'b1; 
	end
end

/* opcode */ 
assign op_rd_next = buf_q[OP_W-1:0] == OP_READ; 
assign op_v = op_rd_next | buf_q[OP_W-1:0] == OP_WRITE; 

/* request output */ 
reg req_v_q; 
always @(posedge sclk) 
	req_v_q <= op_rd_q ? ((fsm_q == ADDR) & addr_finished) // read 
		                :((fsm_q == DATA) & data_finished); // write

assign req_v_o    = req_v_q; 
assign req_rd_o   = op_rd_q; 
assign req_addr_o = addr_q; 
assign req_data_o = buf_q[DATA_W-1:0];

/* read 
response is allways provided on falling edge */
reg so_en_q; 
reg [DATA_W-1:0] res_data_q; 

wire res_capture; 
assign res_capture = (fsm_q == ADDR) & addr_finished; 

always @(negedge sclk)
	if (res_capture) res_data_q <= res_data_i;
	else res_data_q <= {res_data_q[DATA_W-2:0], 1'bx};

always @(negedge sclk or negedge rst_n) 
	if (~rst_n) so_en_q <= 1'b0;
	else so_en_q <= op_rd_q & ((fsm_q == ADDR) & addr_finished)  | ((fsm_q == ADDR) & ~data_finished);

assign so_en_o = so_en_q; 
assign so_o = res_data_q[DATA_W-1];

endmodule
