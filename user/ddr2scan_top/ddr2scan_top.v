/**
 * Filename     :       ddr2scan_top.v
 * Date         :       2020-03-06
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-03-23 create basic Version
 */
`include "../defines.v"
module ddr2scan_top (
	input 						clk				,
	input 						rd_clk			,
	input 						rst				,
	input 						rst_n			,

	// frame singal
    input               		Vsync			,
    input               		Hsync			,
    input               		DE				,

	// control signal
	// input 						ddr3_wr_finish,		// active high

	input 						wr_en_t			,
	input [`CACHE_WIDTH-1:0]	din_t			,

	output 						ddr3_dout_req	,
	output 						scan_en			,

	input 						rd_en_up		,
	output 						empty_up		,
	output 						pix_valid_up	,
	output [`DATA_WIDTH-1:0]	pix_data_up		,
	output [6:0]				data_count_up
	);
parameter COUNT_SIZE_1 = 8'd5;

localparam  WR_LEN = 8'd16;
localparam  WR_END = `REQ_ROW * `LINE_TRANS_NUM / 2;

/**
 * FIFO subfame
 */
wire rst_up0;
wire wr_en_up0, rd_en_up0, wr_clk_up0, rd_clk_up0;
wire [`CACHE_WIDTH-1:0] din_up0, dout_up0;
wire full_up0, almost_full_up0, prog_full_up0;
wire wr_ack_up0, overflow_up0;
wire empty_up0, almost_empty_up0;
wire valid_up0, underflow_up0;
wire wr_rst_busy_up0, rd_rst_busy_up0;
wire [COUNT_SIZE_1:0] wr_data_count_up0;
wire [COUNT_SIZE_1:0] rd_data_count_up0;

assign rst_up0 = (rst);
assign wr_clk_up0 = (clk);
assign rd_clk_up0 = (rd_clk);

fifo_subframe_up		fifo_subframe_up_inst0(
    .rst 						(rst_up0)			,		// clear signal, High_active
    .wr_clk 					(wr_clk_up0)		,
    .rd_clk 					(rd_clk_up0)		,
    .din 						(din_up0)			,
    .wr_en 						(wr_en_up0)			,
    .rd_en 						(rd_en_up0)			,
    .dout 						(dout_up0)			,
    .full 						(full_up0)			,
    .almost_full 				(almost_full_up0)	,
	.prog_full					(prog_full_up0)		,
    .wr_ack 					(wr_ack_up0)		,
    .overflow 					(overflow_up0)		,
    .empty 						(empty_up0)			,
    .almost_empty 				(almost_empty_up0)	,
    .valid 						(valid_up0)			,
    .underflow 					(underflow_up0)		,
	.wr_data_count				(wr_data_count_up0)	,
	.rd_data_count				(rd_data_count_up0)	,
    .wr_rst_busy 				(wr_rst_busy_up0)	,
    .rd_rst_busy 				(rd_rst_busy_up0)
	);

/**
 * [rst_down description]
 */
wire rst_down0;
wire wr_en_down0, rd_en_down0, wr_clk_down0, rd_clk_down0;
wire [`CACHE_WIDTH-1:0] din_down0, dout_down0;
(*mark_debug = "true"*) wire full_down0, almost_full_down0, prog_full_down0;
wire wr_ack_down0, overflow_down0;
(*mark_debug = "true"*) wire empty_down0, almost_empty_down0;
wire valid_down0, underflow_down0;
wire wr_rst_busy_down0, rd_rst_busy_down0;
wire [COUNT_SIZE_1:0] wr_data_count_down0;
wire [COUNT_SIZE_1:0] rd_data_count_down0;

assign rst_down0 = (rst);
assign wr_clk_down0 = (clk);
assign rd_clk_down0 = (rd_clk);

fifo_subframe_up		fifo_subframe_down_inst0(
    .rst 						(rst_down0)			,		// clear signal, High_active
    .wr_clk 					(wr_clk_down0)		,
    .rd_clk 					(rd_clk_down0)		,
    .din 						(din_down0)			,
    .wr_en 						(wr_en_down0)		,
    .rd_en 						(rd_en_down0)		,
    .dout 						(dout_down0)		,
    .full 						(full_down0)		,
    .almost_full 				(almost_full_down0)	,
	.prog_full					(prog_full_down0)	,
    .wr_ack 					(wr_ack_down0)		,
    .overflow 					(overflow_down0)	,
    .empty 						(empty_down0)		,
    .almost_empty 				(almost_empty_down0),
    .valid 						(valid_down0)		,
    .underflow 					(underflow_down0)	,
	.wr_data_count				(wr_data_count_down0),
	.rd_data_count				(rd_data_count_down0),
    .wr_rst_busy 				(wr_rst_busy_down0)	,
    .rd_rst_busy 				(rd_rst_busy_down0)
	);

/**
 * [rst_up description]
 */
wire rst_up1;
wire wr_en_up1, rd_en_up1, wr_clk_up1, rd_clk_up1;
wire [`CACHE_WIDTH-1:0] din_up1, dout_up1;
wire full_up1, almost_full_up1, prog_full_up1;
wire wr_ack_up1, overflow_up1;
wire empty_up1, almost_empty_up1;
wire valid_up1, underflow_up1;
wire wr_rst_busy_up1, rd_rst_busy_up1;
wire [COUNT_SIZE_1:0] wr_data_count_up1;
wire [COUNT_SIZE_1:0] rd_data_count_up1;

assign rst_up1 = (rst);
assign wr_clk_up1 = (clk);
assign rd_clk_up1 = (rd_clk);

fifo_subframe_up		fifo_subframe_up_inst1(
    .rst 						(rst_up1)			,		// clear signal, High_active
    .wr_clk 					(wr_clk_up1)		,
    .rd_clk 					(rd_clk_up1)		,
    .din 						(din_up1)			,
    .wr_en 						(wr_en_up1)			,
    .rd_en 						(rd_en_up1)			,
    .dout 						(dout_up1)			,
    .full 						(full_up1)			,
    .almost_full 				(almost_full_up1)	,
	.prog_full					(prog_full_up1)		,
    .wr_ack 					(wr_ack_up1)		,
    .overflow 					(overflow_up1)		,
    .empty 						(empty_up1)			,
    .almost_empty 				(almost_empty_up1)	,
    .valid 						(valid_up1)			,
    .underflow 					(underflow_up1)		,
	.wr_data_count				(wr_data_count_up1)	,
	.rd_data_count				(rd_data_count_up1)	,
    .wr_rst_busy 				(wr_rst_busy_up1)	,
    .rd_rst_busy 				(rd_rst_busy_up1)
	);

/**
 * [rst_down1 description]
 */
wire rst_down1;
wire wr_en_down1, rd_en_down1, wr_clk_down1, rd_clk_down1;
wire [`CACHE_WIDTH-1:0] din_down1, dout_down1;
(*mark_debug = "true"*) wire full_down1, almost_full_down1, prog_full_down1;
wire wr_ack_down1, overflow_down1;
(*mark_debug = "true"*) wire empty_down1, almost_empty_down1;
wire valid_down1, underflow_down1;
wire wr_rst_busy_down1, rd_rst_busy_down1;
wire [COUNT_SIZE_1:0] wr_data_count_down1;
wire [COUNT_SIZE_1:0] rd_data_count_down1;

assign rst_down1 = (rst);
assign wr_clk_down1 = (clk);
assign rd_clk_down1 = (rd_clk);

fifo_subframe_up		fifo_subframe_down_inst1(
    .rst 						(rst_down1)			,		// clear signal, High_active
    .wr_clk 					(wr_clk_down1)		,
    .rd_clk 					(rd_clk_down1)		,
    .din 						(din_down1)			,
    .wr_en 						(wr_en_down1)		,
    .rd_en 						(rd_en_down1)		,
    .dout 						(dout_down1)		,
    .full 						(full_down1)		,
    .almost_full 				(almost_full_down1)	,
	.prog_full					(prog_full_down1)	,
    .wr_ack 					(wr_ack_down1)		,
    .overflow 					(overflow_down1)	,
    .empty 						(empty_down1)		,
    .almost_empty 				(almost_empty_down1),
    .valid 						(valid_down1)		,
    .underflow 					(underflow_down1)	,
	.wr_data_count				(wr_data_count_down1),
	.rd_data_count				(rd_data_count_down1),
    .wr_rst_busy 				(wr_rst_busy_down1)	,
    .rd_rst_busy 				(rd_rst_busy_down1)
	);

// delay of empty_down0, empty_down1, add a clock for curr_state
(*mark_debug = "true"*) reg empty_down0_d0, empty_down1_d0;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		empty_down0_d0 <= 1'b0;
		empty_down1_d0 <= 1'b0;
	end else begin
		empty_down0_d0 <= empty_down0;
		empty_down1_d0 <= empty_down1;
	end
end

// delay of status transition
(*mark_debug = "true"*) reg empty_down0_r0, empty_down0_r1;
(*mark_debug = "true"*) reg empty_down1_r0, empty_down1_r1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		empty_down0_r0 <= 1'b0;
		empty_down0_r1 <= 1'b0;
		empty_down1_r0 <= 1'b0;
		empty_down1_r1 <= 1'b0;
	end else begin
		empty_down0_r0 <= empty_down0;
		empty_down0_r1 <= empty_down0_r0;
		empty_down1_r0 <= empty_down1;
		empty_down1_r1 <= empty_down1_r0;
	end
end

/**
 * Start rd ddr3 & scan
 */
// start with negedge of Vsync;
(*mark_debug = "true"*) reg Vsync_d0, Vsync_d1, Vsync_d2;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		Vsync_d0 <= 1'b0;
		Vsync_d1 <= 1'b0;
		Vsync_d2 <= 1'b0;
	end else begin
		Vsync_d0 <= Vsync;
		Vsync_d1 <= Vsync_d0;
		Vsync_d2 <= Vsync_d1;
	end
end

(*mark_debug = "true"*) wire neg_Vsync;
assign neg_Vsync = (!Vsync_d1) & (Vsync_d2);

(*mark_debug = "true"*) reg ddr3_rd_st;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		ddr3_rd_st <= 1'b0;
	end else if ( neg_Vsync ) begin
		ddr3_rd_st <= 1'b1;
	end else begin
		ddr3_rd_st <= ddr3_rd_st;
	end
end

/**
 * scan en for scan controller
 */
(*mark_debug = "true"*) reg scan_en_tmp;
always @ (posedge  clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		scan_en_tmp <= 1'b0;
	end else if ( full_down0 ) begin
		scan_en_tmp <= 1'b1;
	end else begin
		scan_en_tmp <= scan_en_tmp;
	end
end

(*mark_debug = "true"*) reg scan_en_tmp_d0, scan_en_tmp_d1, scan_en_tmp_d2;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		scan_en_tmp_d0 <= 1'b0;
		scan_en_tmp_d1 <= 1'b0;
		scan_en_tmp_d2 <= 1'b0;
	end else begin
		scan_en_tmp_d0 <= scan_en_tmp;
		scan_en_tmp_d1 <= scan_en_tmp_d0;
		scan_en_tmp_d2 <= scan_en_tmp_d1;
	end
end

assign scan_en = (scan_en_tmp_d2);

/**
 * FSM
 */
localparam 	IDLE	= 4'b0000;
localparam 	INIT	= 4'b0001;
localparam 	STA1	= 4'b0010;
localparam 	STA2	= 4'b0100;
localparam 	WAIT	= 4'b1000;


// Controller state machine
// (* syn_encoding = "safe" *) reg [2:0] curr_state;
// (* syn_encoding = "safe" *) reg [2:0] next_state;
(*mark_debug = "true"*) reg [3:0] curr_state;
(*mark_debug = "true"*) reg [3:0] next_state;
// state to ASCII
(*mark_debug = "true"*) reg [79:0] state_curr;
always @ ( curr_state ) begin
	case (curr_state)
		IDLE	:	state_curr = "IDLE";
		INIT	:	state_curr = "INIT";
		STA1	:	state_curr = "STA1";
		STA2	:	state_curr = "STA2";
		WAIT	:	state_curr = "WAIT";
		default	: 	state_curr = "DEFAULT";
	endcase
end

(*mark_debug = "true"*) reg [79:0] state_next;
always @ ( next_state ) begin
	case (next_state)
		IDLE	:	state_next = "IDLE";
		INIT	:	state_next = "INIT";
		STA1	:	state_next = "STA1";
		STA2	:	state_next = "STA2";
		WAIT	:	state_next = "WAIT";
		default	: 	state_next = "DEFAULT";
	endcase
end

// first part : state transition
always @ ( posedge clk or posedge rst_n ) begin
	if ( !rst_n ) begin
		curr_state <= IDLE;
	end else begin
		curr_state <= next_state;
	end
end


(*mark_debug = "true"*) reg [15:0]	sta2_cnt;
(*mark_debug = "true"*) wire sta2_en;
assign sta2_en = ( sta2_cnt == `STA2_TIMES ) ? 1'b1 : 1'b0;


(*mark_debug = "true"*) reg dout_buf_shf_finish0;
(*mark_debug = "true"*) reg dout_buf_shf_finish1;

// second part : transition condition
always @ ( curr_state or ddr3_rd_st or prog_full_down0 or prog_full_down1 or dout_buf_shf_finish0 or dout_buf_shf_finish1 or neg_Vsync or sta2_en) begin
	case (curr_state)
		IDLE	:	if ( ddr3_rd_st ) begin
			next_state = INIT;
		end else begin
			next_state = IDLE;
		end
		INIT	:	if ( prog_full_down0 ) begin
			next_state = STA1;
		end else begin
			next_state = INIT;
		end
		STA1	:	if ( dout_buf_shf_finish0 & prog_full_down1 ) begin
			next_state = STA2;
		end else begin
			next_state = STA1;
		end
		STA2	:	if ( dout_buf_shf_finish1 & (prog_full_down0 | sta2_en)) begin
			if ( sta2_en ) begin
				next_state = WAIT;
			end else begin
				next_state = STA1;
			end
		end else begin
			next_state = STA2;
		end
		WAIT	:	if ( neg_Vsync ) begin
			next_state = INIT;
		end else begin
			next_state = WAIT;
		end
		default	: 	next_state = IDLE;
	endcase
end

// third part : state output

// (*mark_debug = "true"*) reg [15:0]	sta2_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		sta2_cnt <= 16'b0;
	end else if ( curr_state != STA1 && next_state == STA1 ) begin
		sta2_cnt <= sta2_cnt + 1'b1;
	end else if ( neg_Vsync ) begin
		sta2_cnt <= 16'b0;
	end else begin
		sta2_cnt <= sta2_cnt;
	end
end





(*mark_debug = "true"*) wire ddr3_dout_req_INIT;
(*mark_debug = "true"*) wire ddr3_dout_req_STA1, ddr3_dout_req_STA2;
// assign ddr3_dout_req_STA1 = (curr_state == STA1) ? (full_up1 & prog_full_down1) ? 1'b0 : 1'b1 : 1'b0;
// assign ddr3_dout_req_STA2 = (curr_state == STA2) ? (full_up0 & prog_full_down0) ? 1'b0 : 1'b1 : 1'b0;
assign ddr3_dout_req_INIT = ((curr_state == IDLE | curr_state == WAIT ) && next_state == INIT) ? 1'b1 : 1'b0;
// assign ddr3_dout_req_STA1 = (curr_state == INIT && next_state == STA1) |
// 							(curr_state == STA2 && next_state == STA1) |
// 							(curr_state == WAIT && next_state == STA1) ? 1'b1 : 1'b0;
assign ddr3_dout_req_STA1 = (curr_state != STA1 && next_state == STA1) ? 1'b1 : 1'b0;
assign ddr3_dout_req_STA2 = (curr_state == STA1 && next_state == STA2) ? ( sta2_cnt == `STA2_TIMES ) ? 1'b0 : 1'b1 : 1'b0;


assign ddr3_dout_req = (ddr3_dout_req_INIT | ddr3_dout_req_STA1 | ddr3_dout_req_STA2);


// wr_en_up0
(*mark_debug = "true"*) reg [WR_LEN-1:0] wr_en_up0_cnt, wr_en_down0_cnt;
(*mark_debug = "true"*) reg wr_en_up0_tmp, wr_en_down0_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wr_en_up0_cnt <= {WR_LEN{1'b0}};
		wr_en_down0_cnt <= {WR_LEN{1'b0}};
	end else if ( next_state == INIT || next_state == STA2 ) begin
		if ( wr_en_t && wr_en_up0_cnt <= WR_END - 1'b1 ) begin
			wr_en_up0_cnt <= wr_en_up0_cnt + 1'b1;
			wr_en_down0_cnt <= wr_en_down0_cnt;
		end else if ( wr_en_t && wr_en_down0_cnt <= WR_END - 1'b1) begin
			wr_en_up0_cnt <= wr_en_up0_cnt;
			wr_en_down0_cnt <= wr_en_down0_cnt + 1'b1;
		end else begin
			wr_en_down0_cnt <= wr_en_down0_cnt;
			wr_en_up0_cnt <= wr_en_up0_cnt;
			// wr_en_up0_cnt <= {WR_LEN{1'b0}};
			// wr_en_down0_cnt <= {WR_LEN{1'b0}};
		end
	end else begin
		wr_en_up0_cnt <= {WR_LEN{1'b0}};
		wr_en_down0_cnt <= {WR_LEN{1'b0}};
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wr_en_up0_tmp <= 1'b0;
		wr_en_down0_tmp <= 1'b0;
	end else if ( next_state == INIT || next_state == STA2 ) begin
		if ( wr_en_t && wr_en_up0_cnt <= WR_END - 1'b1 ) begin
			wr_en_up0_tmp <= wr_en_t;
			wr_en_down0_tmp <= 1'b0;
		end else if ( wr_en_t && wr_en_down0_cnt <= WR_END - 1'b1 ) begin
			wr_en_up0_tmp <= 1'b0;
			wr_en_down0_tmp <= wr_en_t;
		end else begin
			wr_en_up0_tmp <= 1'b0;
			wr_en_down0_tmp <= 1'b0;
		end
	end else begin
		wr_en_up0_tmp <= 1'b0;
		wr_en_down0_tmp <= 1'b0;
	end
end

assign wr_en_up0 = (wr_en_up0_tmp);
assign wr_en_down0 = (wr_en_down0_tmp);

// din_up0, din_down0
(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] din_up0_tmp, din_down0_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		din_up0_tmp <= {`CACHE_WIDTH-1{1'b0}};
		din_down0_tmp <= {`CACHE_WIDTH-1{1'b0}};
	end else if ( next_state == INIT || next_state == STA2 ) begin
		if ( wr_en_t && wr_en_up0_cnt <= WR_END - 1'b1 ) begin
			din_up0_tmp <= din_t;
			din_down0_tmp <= {`CACHE_WIDTH-1{1'b0}};
		end else if ( wr_en_t && wr_en_down0_cnt <= WR_END - 1'b1 ) begin
			din_up0_tmp <= {`CACHE_WIDTH-1{1'b0}};
			din_down0_tmp <= din_t;
		end else begin
			din_up0_tmp <= {`CACHE_WIDTH-1{1'b0}};
			din_down0_tmp <= {`CACHE_WIDTH-1{1'b0}};
		end
	end else begin
		din_up0_tmp <= {`CACHE_WIDTH-1{1'b0}};
		din_down0_tmp <= {`CACHE_WIDTH-1{1'b0}};
	end
end

assign din_up0 = (din_up0_tmp);
assign din_down0 = (din_down0_tmp);


// wr_en_up1
(*mark_debug = "true"*) reg [WR_LEN-1:0] wr_en_up1_cnt, wr_en_down1_cnt;
(*mark_debug = "true"*) reg wr_en_up1_tmp, wr_en_down1_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wr_en_up1_cnt <= {WR_LEN{1'b0}};
		wr_en_down1_cnt <= {WR_LEN{1'b0}};
	end else if ( next_state == STA1 ) begin
		if ( wr_en_t && wr_en_up1_cnt <= WR_END - 1'b1 ) begin
			wr_en_up1_cnt <= wr_en_up1_cnt + 1'b1;
			wr_en_down1_cnt <= wr_en_down1_cnt;
		end else if ( wr_en_t && wr_en_down1_cnt <= WR_END - 1'b1) begin
			wr_en_up1_cnt <= wr_en_up1_cnt;
			wr_en_down1_cnt <= wr_en_down1_cnt + 1'b1;
		end else begin
			wr_en_down0_cnt <= wr_en_down0_cnt;
			wr_en_up0_cnt <= wr_en_up0_cnt;
			// wr_en_up1_cnt <= {WR_LEN{1'b0}};
			// wr_en_down1_cnt <= {WR_LEN{1'b0}};
		end
	end else begin
		wr_en_up1_cnt <= {WR_LEN{1'b0}};
		wr_en_down1_cnt <= {WR_LEN{1'b0}};
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wr_en_up1_tmp <= 1'b0;
		wr_en_down1_tmp <= 1'b0;
	end else if ( next_state == STA1 ) begin
		if ( wr_en_t && wr_en_up1_cnt <= WR_END - 1'b1 ) begin
			wr_en_up1_tmp <= wr_en_t;
			wr_en_down1_tmp <= 1'b0;
		end else if ( wr_en_t && wr_en_down1_cnt <= WR_END - 1'b1) begin
			wr_en_up1_tmp <= 1'b0;
			wr_en_down1_tmp <= wr_en_t;
		end else begin
			wr_en_up1_tmp <= 1'b0;
			wr_en_down1_tmp <= 1'b0;
		end
	end else begin
		wr_en_up1_tmp <= 1'b0;
		wr_en_down1_tmp <= 1'b0;
	end
end

assign wr_en_up1 = (wr_en_up1_tmp);
assign wr_en_down1 = (wr_en_down1_tmp);

// din_up1, din_down1
(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] din_up1_tmp, din_down1_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		din_up1_tmp <= {`CACHE_WIDTH-1{1'b0}};
		din_down1_tmp <= {`CACHE_WIDTH-1{1'b0}};
	end else if ( next_state == STA1 ) begin
		if ( wr_en_t && wr_en_up1_cnt <= WR_END - 1'b1 ) begin
			din_up1_tmp <= din_t;
			din_down1_tmp <= {`CACHE_WIDTH-1{1'b0}};
		end else if ( wr_en_t && wr_en_down1_cnt <= WR_END - 1'b1) begin
			din_up1_tmp <= {`CACHE_WIDTH-1{1'b0}};
			din_down1_tmp <= din_t;
		end else begin
			din_up1_tmp <= {`CACHE_WIDTH-1{1'b0}};
			din_down1_tmp <= {`CACHE_WIDTH-1{1'b0}};
		end
	end else begin
		din_up1_tmp <= {`CACHE_WIDTH-1{1'b0}};
		din_down1_tmp <= {`CACHE_WIDTH-1{1'b0}};
	end
end

assign din_up1 = (din_up1_tmp);
assign din_down1 = (din_down1_tmp);


/*
██████  ██████          ██████   █████  ████████  █████
██   ██ ██   ██         ██   ██ ██   ██    ██    ██   ██
██████  ██   ██         ██   ██ ███████    ██    ███████
██   ██ ██   ██         ██   ██ ██   ██    ██    ██   ██
██   ██ ██████  ███████ ██████  ██   ██    ██    ██   ██
*/
localparam  RD_EN_CNT = 7'd90;

(*mark_debug = "true"*) reg [6:0] rd_en_cnt0;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_en_cnt0 <= 7'b00;
	end else if ( curr_state == STA1 && rd_en_cnt0 <= RD_EN_CNT - 1 ) begin
		rd_en_cnt0 <= rd_en_cnt0 + 1'b1;
	end else if ( curr_state == STA1 && rd_en_cnt0 == RD_EN_CNT ) begin
		rd_en_cnt0 <= 7'b01;
	end else begin
		rd_en_cnt0 <= 7'b00;
	end
end


always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_finish0 = 1'b0;
	end else if ( rd_en_cnt0 == RD_EN_CNT && empty_down0_r1 ) begin
		dout_buf_shf_finish0 = 1'b1;
	end else begin
		dout_buf_shf_finish0 = 1'b0;
	end
end

// assign dout_buf_shf_finish0 = (rd_en_cnt0 == RD_EN_CNT && empty_down0_r1) ? 1'b1 : 1'b0;


(*mark_debug = "true"*) wire rd_en_up0_tmp, rd_en_down0_tmp;
assign rd_en_up0_tmp = 	(rd_en_cnt0 >= 7'd1 && rd_en_cnt0 <= 7'd4) ? 1'b1 : 1'b0;
assign rd_en_down0_tmp = ( rd_en_cnt0 >= 7'd46 && rd_en_cnt0 <= 7'd49) ? 1'b1 : 1'b0;

assign rd_en_up0 = (rd_en_up0_tmp);
assign rd_en_down0 = (rd_en_down0_tmp);

(*mark_debug = "true"*) reg valid_up0_d0, valid_up0_d1, valid_up0_d2, valid_up0_d3;
(*mark_debug = "true"*) reg valid_down0_d0, valid_down0_d1, valid_down0_d2, valid_down0_d3;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_up0_d0 <= 1'b0;
		valid_up0_d1 <= 1'b0;
		valid_up0_d2 <= 1'b0;
		valid_up0_d3 <= 1'b0;
		valid_down0_d0 <= 1'b0;
		valid_down0_d1 <= 1'b0;
		valid_down0_d2 <= 1'b0;
		valid_down0_d3 <= 1'b0;
	end else begin
		valid_up0_d0 <= valid_up0;
		valid_up0_d1 <= valid_up0_d0;
		valid_up0_d2 <= valid_up0_d1;
		valid_up0_d3 <= valid_up0_d2;
		valid_down0_d0 <= valid_down0;
		valid_down0_d1 <= valid_down0_d0;
		valid_down0_d2 <= valid_down0_d1;
		valid_down0_d3 <= valid_down0_d2;
	end
end

(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] dout_up0_d0; // , dout_up0_d1, dout_up0_d2, dout_up0_d3;
(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] dout_down0_d0; //, dout_down0_d1, dout_down0_d2, dout_down0_d3;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_up0_d0 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up0_d1 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up0_d2 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up0_d3 <= {`CACHE_WIDTH-1{1'b0}};
		dout_down0_d0 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down0_d1 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down0_d2 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down0_d3 <= {`CACHE_WIDTH-1{1'b0}};
	end else begin
		dout_up0_d0 <= dout_up0;
		// dout_up0_d1 <= dout_up0_d0;
		// dout_up0_d2 <= dout_up0_d1;
		// dout_up0_d3 <= dout_up0_d2;
		dout_down0_d0 <= dout_down0;
		// dout_down0_d1 <= dout_down0_d0;
		// dout_down0_d2 <= dout_down0_d1;
		// dout_down0_d3 <= dout_down0_d2;
	end
end


(*mark_debug = "true"*) reg [`CACHE_WIDTH*4-1:0] dout_buf_up0, dout_buf_down0;
always @ ( posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_up0 = {`CACHE_WIDTH*4{1'b0}};
	end else begin
		case ({valid_up0_d0, valid_up0_d1, valid_up0_d2, valid_up0_d3})
			4'b1000	:	dout_buf_up0[`CACHE_WIDTH*4-1:`CACHE_WIDTH*3] = dout_up0_d0;
			4'b1100	:	dout_buf_up0[`CACHE_WIDTH*3-1:`CACHE_WIDTH*2] = dout_up0_d0;
			4'b1110	:	dout_buf_up0[`CACHE_WIDTH*2-1:`CACHE_WIDTH*1] = dout_up0_d0;
			4'b1111	:	dout_buf_up0[`CACHE_WIDTH*1-1:`CACHE_WIDTH*0] = dout_up0_d0;
			default	: 	;
		endcase
	end
end

always @ ( posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_down0 = {`CACHE_WIDTH*4{1'b0}};
	end else begin
		case ({valid_down0_d0, valid_down0_d1, valid_down0_d2, valid_down0_d3})
			4'b1000	:	dout_buf_down0[`CACHE_WIDTH*4-1:`CACHE_WIDTH*3] = dout_down0_d0;
			4'b1100	:	dout_buf_down0[`CACHE_WIDTH*3-1:`CACHE_WIDTH*2] = dout_down0_d0;
			4'b1110	:	dout_buf_down0[`CACHE_WIDTH*2-1:`CACHE_WIDTH*1] = dout_down0_d0;
			4'b1111	:	dout_buf_down0[`CACHE_WIDTH*1-1:`CACHE_WIDTH*0] = dout_down0_d0;
			default	: 	;
		endcase
	end
end


parameter SHF_EN_CNT = 8'd40;

(*mark_debug = "true"*) wire dout_buf_shf_st_up0 = valid_up0_d2 & (~valid_up0_d3);
(*mark_debug = "true"*) wire dout_buf_shf_st_down0 = valid_down0_d2 & (~valid_down0_d3);
(*mark_debug = "true"*) reg [6:0] dout_buf_shf_cnt_up0, dout_buf_shf_cnt_down0;
(*mark_debug = "true"*) reg dout_buf_shf_en_up0, dout_buf_shf_en_down0;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_cnt_up0 <= 7'd0;
		dout_buf_shf_en_up0 <= 1'b0;
	end else if ( dout_buf_shf_st_up0 ) begin
		dout_buf_shf_cnt_up0 <= dout_buf_shf_cnt_up0 + 1'b1;
		dout_buf_shf_en_up0 <= 1'b1;
	end else if ( dout_buf_shf_cnt_up0 >= 7'd1 && dout_buf_shf_cnt_up0 <= SHF_EN_CNT - 1'b1) begin
		dout_buf_shf_cnt_up0 <= dout_buf_shf_cnt_up0 + 1'b1;
		dout_buf_shf_en_up0 <= 1'b1;
	end else begin
		dout_buf_shf_cnt_up0 <= 7'd0;
		dout_buf_shf_en_up0 <= 1'b0;
	end
end

always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_cnt_down0 <= 7'd0;
		dout_buf_shf_en_down0 <= 1'b0;
	end else if ( dout_buf_shf_st_down0 ) begin
		dout_buf_shf_cnt_down0 <= dout_buf_shf_cnt_down0 + 1'b1;
		dout_buf_shf_en_down0 <= 1'b1;
	end else if ( dout_buf_shf_cnt_down0 >= 7'd1 && dout_buf_shf_cnt_down0 <= SHF_EN_CNT - 1'b1 ) begin
		dout_buf_shf_cnt_down0 <= dout_buf_shf_cnt_down0 + 1'b1;
		dout_buf_shf_en_down0 <= 1'b1;
	end else begin
		dout_buf_shf_cnt_down0 <= 7'd0;
		dout_buf_shf_en_down0 <= 1'b0;
	end
end

(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] pix_data_up0, pix_data_down0;
always @ ( dout_buf_shf_cnt_up0 ) begin
	case ( dout_buf_shf_cnt_up0 )
        7'd1    :       pix_data_up0 <= dout_buf_up0[1279:1248];
        7'd2    :       pix_data_up0 <= dout_buf_up0[1247:1216];
        7'd3    :       pix_data_up0 <= dout_buf_up0[1215:1184];
        7'd4    :       pix_data_up0 <= dout_buf_up0[1183:1152];
        7'd5    :       pix_data_up0 <= dout_buf_up0[1151:1120];
        7'd6    :       pix_data_up0 <= dout_buf_up0[1119:1088];
        7'd7    :       pix_data_up0 <= dout_buf_up0[1087:1056];
        7'd8    :       pix_data_up0 <= dout_buf_up0[1055:1024];
        7'd9    :       pix_data_up0 <= dout_buf_up0[1023:992 ];
        7'd10   :       pix_data_up0 <= dout_buf_up0[991 :960 ];
        7'd11   :       pix_data_up0 <= dout_buf_up0[959 :928 ];
        7'd12   :       pix_data_up0 <= dout_buf_up0[927 :896 ];
        7'd13   :       pix_data_up0 <= dout_buf_up0[895 :864 ];
        7'd14   :       pix_data_up0 <= dout_buf_up0[863 :832 ];
        7'd15   :       pix_data_up0 <= dout_buf_up0[831 :800 ];
        7'd16   :       pix_data_up0 <= dout_buf_up0[799 :768 ];
        7'd17   :       pix_data_up0 <= dout_buf_up0[767 :736 ];
        7'd18   :       pix_data_up0 <= dout_buf_up0[735 :704 ];
        7'd19   :       pix_data_up0 <= dout_buf_up0[703 :672 ];
        7'd20   :       pix_data_up0 <= dout_buf_up0[671 :640 ];
        7'd21   :       pix_data_up0 <= dout_buf_up0[639 :608 ];
        7'd22   :       pix_data_up0 <= dout_buf_up0[607 :576 ];
        7'd23   :       pix_data_up0 <= dout_buf_up0[575 :544 ];
        7'd24   :       pix_data_up0 <= dout_buf_up0[543 :512 ];
        7'd25   :       pix_data_up0 <= dout_buf_up0[511 :480 ];
        7'd26   :       pix_data_up0 <= dout_buf_up0[479 :448 ];
        7'd27   :       pix_data_up0 <= dout_buf_up0[447 :416 ];
        7'd28   :       pix_data_up0 <= dout_buf_up0[415 :384 ];
        7'd29   :       pix_data_up0 <= dout_buf_up0[383 :352 ];
        7'd30   :       pix_data_up0 <= dout_buf_up0[351 :320 ];
        7'd31   :       pix_data_up0 <= dout_buf_up0[319 :288 ];
        7'd32   :       pix_data_up0 <= dout_buf_up0[287 :256 ];
        7'd33   :       pix_data_up0 <= dout_buf_up0[255 :224 ];
        7'd34   :       pix_data_up0 <= dout_buf_up0[223 :192 ];
        7'd35   :       pix_data_up0 <= dout_buf_up0[191 :160 ];
        7'd36   :       pix_data_up0 <= dout_buf_up0[159 :128 ];
        7'd37   :       pix_data_up0 <= dout_buf_up0[127 :96  ];
        7'd38   :       pix_data_up0 <= dout_buf_up0[95  :64  ];
        7'd39   :       pix_data_up0 <= dout_buf_up0[63  :32  ];
        7'd40   :       pix_data_up0 <= dout_buf_up0[31  :0   ];
		default	: 		pix_data_up0 <= {`DATA_WIDTH-1{1'b0}};
	endcase
end



always @ ( dout_buf_shf_cnt_down0 ) begin
	case ( dout_buf_shf_cnt_down0 )
        7'd1    :       pix_data_down0 <= dout_buf_down0[1279:1248];
        7'd2    :       pix_data_down0 <= dout_buf_down0[1247:1216];
        7'd3    :       pix_data_down0 <= dout_buf_down0[1215:1184];
        7'd4    :       pix_data_down0 <= dout_buf_down0[1183:1152];
        7'd5    :       pix_data_down0 <= dout_buf_down0[1151:1120];
        7'd6    :       pix_data_down0 <= dout_buf_down0[1119:1088];
        7'd7    :       pix_data_down0 <= dout_buf_down0[1087:1056];
        7'd8    :       pix_data_down0 <= dout_buf_down0[1055:1024];
        7'd9    :       pix_data_down0 <= dout_buf_down0[1023:992 ];
        7'd10   :       pix_data_down0 <= dout_buf_down0[991 :960 ];
        7'd11   :       pix_data_down0 <= dout_buf_down0[959 :928 ];
        7'd12   :       pix_data_down0 <= dout_buf_down0[927 :896 ];
        7'd13   :       pix_data_down0 <= dout_buf_down0[895 :864 ];
        7'd14   :       pix_data_down0 <= dout_buf_down0[863 :832 ];
        7'd15   :       pix_data_down0 <= dout_buf_down0[831 :800 ];
        7'd16   :       pix_data_down0 <= dout_buf_down0[799 :768 ];
        7'd17   :       pix_data_down0 <= dout_buf_down0[767 :736 ];
        7'd18   :       pix_data_down0 <= dout_buf_down0[735 :704 ];
        7'd19   :       pix_data_down0 <= dout_buf_down0[703 :672 ];
        7'd20   :       pix_data_down0 <= dout_buf_down0[671 :640 ];
        7'd21   :       pix_data_down0 <= dout_buf_down0[639 :608 ];
        7'd22   :       pix_data_down0 <= dout_buf_down0[607 :576 ];
        7'd23   :       pix_data_down0 <= dout_buf_down0[575 :544 ];
        7'd24   :       pix_data_down0 <= dout_buf_down0[543 :512 ];
        7'd25   :       pix_data_down0 <= dout_buf_down0[511 :480 ];
        7'd26   :       pix_data_down0 <= dout_buf_down0[479 :448 ];
        7'd27   :       pix_data_down0 <= dout_buf_down0[447 :416 ];
        7'd28   :       pix_data_down0 <= dout_buf_down0[415 :384 ];
        7'd29   :       pix_data_down0 <= dout_buf_down0[383 :352 ];
        7'd30   :       pix_data_down0 <= dout_buf_down0[351 :320 ];
        7'd31   :       pix_data_down0 <= dout_buf_down0[319 :288 ];
        7'd32   :       pix_data_down0 <= dout_buf_down0[287 :256 ];
        7'd33   :       pix_data_down0 <= dout_buf_down0[255 :224 ];
        7'd34   :       pix_data_down0 <= dout_buf_down0[223 :192 ];
        7'd35   :       pix_data_down0 <= dout_buf_down0[191 :160 ];
        7'd36   :       pix_data_down0 <= dout_buf_down0[159 :128 ];
        7'd37   :       pix_data_down0 <= dout_buf_down0[127 :96  ];
        7'd38   :       pix_data_down0 <= dout_buf_down0[95  :64  ];
        7'd39   :       pix_data_down0 <= dout_buf_down0[63  :32  ];
        7'd40   :       pix_data_down0 <= dout_buf_down0[31  :0   ];
		default	:		pix_data_down0 <= {`DATA_WIDTH-1{1'b0}};
	endcase
end


/*
██████  ██    ██ ███████ ███████ ███████ ██████       ██
██   ██ ██    ██ ██      ██      ██      ██   ██     ███
██████  ██    ██ █████   █████   █████   ██████       ██
██   ██ ██    ██ ██      ██      ██      ██   ██      ██
██████   ██████  ██      ██      ███████ ██   ██      ██
*/

(*mark_debug = "true"*) reg [6:0] rd_en_cnt1;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_en_cnt1 <= 7'b00;
	end else if ( curr_state == STA2 && rd_en_cnt1 <= RD_EN_CNT - 1 ) begin
		rd_en_cnt1 <= rd_en_cnt1 + 1'b1;
	end else if ( curr_state == STA2 && rd_en_cnt1 == RD_EN_CNT ) begin
		rd_en_cnt1 <= 7'b01;
	end else begin
		rd_en_cnt1 <= 7'b00;
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_finish1 = 1'b0;
	end else if ( rd_en_cnt1 == RD_EN_CNT && empty_down1_r1 ) begin
		dout_buf_shf_finish1 = 1'b1;
	end else begin
		dout_buf_shf_finish1 = 1'b0;
	end
end

// assign dout_buf_shf_finish1 = (rd_en_cnt1 == RD_EN_CNT && empty_down1_r1) ? 1'b1 : 1'b0;


(*mark_debug = "true"*) wire rd_en_up1_tmp, rd_en_down1_tmp;

assign rd_en_up1_tmp = 	(rd_en_cnt1 >= 7'd1 && rd_en_cnt1 <= 7'd4) ? 1'b1 : 1'b0;
assign rd_en_down1_tmp = ( rd_en_cnt1 >= 7'd46 && rd_en_cnt1 <= 7'd49) ? 1'b1 : 1'b0;


assign rd_en_up1 = (rd_en_up1_tmp);
assign rd_en_down1 = (rd_en_down1_tmp);

(*mark_debug = "true"*) reg valid_up1_d0, valid_up1_d1, valid_up1_d2, valid_up1_d3;
(*mark_debug = "true"*) reg valid_down1_d0, valid_down1_d1, valid_down1_d2, valid_down1_d3;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_up1_d0 <= 1'b0;
		valid_up1_d1 <= 1'b0;
		valid_up1_d2 <= 1'b0;
		valid_up1_d3 <= 1'b0;
		valid_down1_d0 <= 1'b0;
		valid_down1_d1 <= 1'b0;
		valid_down1_d2 <= 1'b0;
		valid_down1_d3 <= 1'b0;
	end else begin
		valid_up1_d0 <= valid_up1;
		valid_up1_d1 <= valid_up1_d0;
		valid_up1_d2 <= valid_up1_d1;
		valid_up1_d3 <= valid_up1_d2;
		valid_down1_d0 <= valid_down1;
		valid_down1_d1 <= valid_down1_d0;
		valid_down1_d2 <= valid_down1_d1;
		valid_down1_d3 <= valid_down1_d2;
	end
end

(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] dout_up1_d0; // , dout_up1_d1, dout_up1_d2, dout_up1_d3;
(*mark_debug = "true"*) reg [`CACHE_WIDTH-1:0] dout_down1_d0; // , dout_down1_d1, dout_down1_d2, dout_down1_d3;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_up1_d0 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up1_d1 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up1_d2 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_up1_d3 <= {`CACHE_WIDTH-1{1'b0}};
		dout_down1_d0 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down1_d1 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down1_d2 <= {`CACHE_WIDTH-1{1'b0}};
		// dout_down1_d3 <= {`CACHE_WIDTH-1{1'b0}};
	end else begin
		dout_up1_d0 <= dout_up1;
		// dout_up1_d1 <= dout_up1_d0;
		// dout_up1_d2 <= dout_up1_d1;
		// dout_up1_d3 <= dout_up1_d2;
		dout_down1_d0 <= dout_down1;
		// dout_down1_d1 <= dout_down1_d0;
		// dout_down1_d2 <= dout_down1_d1;
		// dout_down1_d3 <= dout_down1_d2;
	end
end


(*mark_debug = "true"*) reg [`CACHE_WIDTH*4-1:0] dout_buf_up1, dout_buf_down1;
always @ ( posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_up1 = {`CACHE_WIDTH*4{1'b0}};
	end else begin
		case ({valid_up1_d0, valid_up1_d1, valid_up1_d2, valid_up1_d3})
			4'b1000	:	dout_buf_up1[`CACHE_WIDTH*4-1:`CACHE_WIDTH*3] = dout_up1_d0;
			4'b1100	:	dout_buf_up1[`CACHE_WIDTH*3-1:`CACHE_WIDTH*2] = dout_up1_d0;
			4'b1110	:	dout_buf_up1[`CACHE_WIDTH*2-1:`CACHE_WIDTH*1] = dout_up1_d0;
			4'b1111	:	dout_buf_up1[`CACHE_WIDTH*1-1:`CACHE_WIDTH*0] = dout_up1_d0;
			default	: 	;
		endcase
	end
end

always @ ( posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_down1 = {`CACHE_WIDTH*4{1'b0}};
	end else begin
		case ({valid_down1_d0, valid_down1_d1, valid_down1_d2, valid_down1_d3})
			4'b1000	:	dout_buf_down1[`CACHE_WIDTH*4-1:`CACHE_WIDTH*3] = dout_down1_d0;
			4'b1100	:	dout_buf_down1[`CACHE_WIDTH*3-1:`CACHE_WIDTH*2] = dout_down1_d0;
			4'b1110	:	dout_buf_down1[`CACHE_WIDTH*2-1:`CACHE_WIDTH*1] = dout_down1_d0;
			4'b1111	:	dout_buf_down1[`CACHE_WIDTH*1-1:`CACHE_WIDTH*0] = dout_down1_d0;
			default	: 	;
		endcase
	end
end

(*mark_debug = "true"*) wire dout_buf_shf_st_up1 = valid_up1_d2 & (~valid_up1_d3);
(*mark_debug = "true"*) wire dout_buf_shf_st_down1 = valid_down1_d2 & (~valid_down1_d3);
(*mark_debug = "true"*) reg [6:0] dout_buf_shf_cnt_up1, dout_buf_shf_cnt_down1;
(*mark_debug = "true"*) reg dout_buf_shf_en_up1, dout_buf_shf_en_down1;
always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_cnt_up1 <= 7'd0;
		dout_buf_shf_en_up1 <= 1'b0;
	end else if ( dout_buf_shf_st_up1 ) begin
		dout_buf_shf_cnt_up1 <= dout_buf_shf_cnt_up1 + 1'b1;
		dout_buf_shf_en_up1 <= 1'b1;
	end else if ( dout_buf_shf_cnt_up1 >= 7'd1 && dout_buf_shf_cnt_up1 <= SHF_EN_CNT - 1'b1 ) begin
		dout_buf_shf_cnt_up1 <= dout_buf_shf_cnt_up1 + 1'b1;
		dout_buf_shf_en_up1 <= 1'b1;
	end else begin
		dout_buf_shf_cnt_up1 <= 7'd0;
		dout_buf_shf_en_up1 <= 1'b0;
	end
end

always @ (posedge rd_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dout_buf_shf_cnt_down1 <= 7'd0;
		dout_buf_shf_en_down1 <= 1'b0;
	end else if ( dout_buf_shf_st_down1 ) begin
		dout_buf_shf_cnt_down1 <= dout_buf_shf_cnt_down1 + 1'b1;
		dout_buf_shf_en_down1 <= 1'b1;
	end else if ( dout_buf_shf_cnt_down1 >= 7'd1 && dout_buf_shf_cnt_down1 <= SHF_EN_CNT - 1'b1 ) begin
		dout_buf_shf_cnt_down1 <= dout_buf_shf_cnt_down1 + 1'b1;
		dout_buf_shf_en_down1 <= 1'b1;
	end else begin
		dout_buf_shf_cnt_down1 <= 7'd0;
		dout_buf_shf_en_down1 <= 1'b0;
	end
end


(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] pix_data_up1, pix_data_down1;
always @ ( dout_buf_shf_cnt_up1 ) begin
	case ( dout_buf_shf_cnt_up1 )
        7'd1    :       pix_data_up1 <= dout_buf_up1[1279:1248];
        7'd2    :       pix_data_up1 <= dout_buf_up1[1247:1216];
        7'd3    :       pix_data_up1 <= dout_buf_up1[1215:1184];
        7'd4    :       pix_data_up1 <= dout_buf_up1[1183:1152];
        7'd5    :       pix_data_up1 <= dout_buf_up1[1151:1120];
        7'd6    :       pix_data_up1 <= dout_buf_up1[1119:1088];
        7'd7    :       pix_data_up1 <= dout_buf_up1[1087:1056];
        7'd8    :       pix_data_up1 <= dout_buf_up1[1055:1024];
        7'd9    :       pix_data_up1 <= dout_buf_up1[1023:992 ];
        7'd10   :       pix_data_up1 <= dout_buf_up1[991 :960 ];
        7'd11   :       pix_data_up1 <= dout_buf_up1[959 :928 ];
        7'd12   :       pix_data_up1 <= dout_buf_up1[927 :896 ];
        7'd13   :       pix_data_up1 <= dout_buf_up1[895 :864 ];
        7'd14   :       pix_data_up1 <= dout_buf_up1[863 :832 ];
        7'd15   :       pix_data_up1 <= dout_buf_up1[831 :800 ];
        7'd16   :       pix_data_up1 <= dout_buf_up1[799 :768 ];
        7'd17   :       pix_data_up1 <= dout_buf_up1[767 :736 ];
        7'd18   :       pix_data_up1 <= dout_buf_up1[735 :704 ];
        7'd19   :       pix_data_up1 <= dout_buf_up1[703 :672 ];
        7'd20   :       pix_data_up1 <= dout_buf_up1[671 :640 ];
        7'd21   :       pix_data_up1 <= dout_buf_up1[639 :608 ];
        7'd22   :       pix_data_up1 <= dout_buf_up1[607 :576 ];
        7'd23   :       pix_data_up1 <= dout_buf_up1[575 :544 ];
        7'd24   :       pix_data_up1 <= dout_buf_up1[543 :512 ];
        7'd25   :       pix_data_up1 <= dout_buf_up1[511 :480 ];
        7'd26   :       pix_data_up1 <= dout_buf_up1[479 :448 ];
        7'd27   :       pix_data_up1 <= dout_buf_up1[447 :416 ];
        7'd28   :       pix_data_up1 <= dout_buf_up1[415 :384 ];
        7'd29   :       pix_data_up1 <= dout_buf_up1[383 :352 ];
        7'd30   :       pix_data_up1 <= dout_buf_up1[351 :320 ];
        7'd31   :       pix_data_up1 <= dout_buf_up1[319 :288 ];
        7'd32   :       pix_data_up1 <= dout_buf_up1[287 :256 ];
        7'd33   :       pix_data_up1 <= dout_buf_up1[255 :224 ];
        7'd34   :       pix_data_up1 <= dout_buf_up1[223 :192 ];
        7'd35   :       pix_data_up1 <= dout_buf_up1[191 :160 ];
        7'd36   :       pix_data_up1 <= dout_buf_up1[159 :128 ];
        7'd37   :       pix_data_up1 <= dout_buf_up1[127 :96  ];
        7'd38   :       pix_data_up1 <= dout_buf_up1[95  :64  ];
        7'd39   :       pix_data_up1 <= dout_buf_up1[63  :32  ];
        7'd40   :       pix_data_up1 <= dout_buf_up1[31  :0   ];
		default	: 		pix_data_up1 <= {`DATA_WIDTH-1{1'b0}};
	endcase
end



always @ ( dout_buf_shf_cnt_down1 ) begin
	case ( dout_buf_shf_cnt_down1 )
        7'd1    :       pix_data_down1 <= dout_buf_down1[1279:1248];
        7'd2    :       pix_data_down1 <= dout_buf_down1[1247:1216];
        7'd3    :       pix_data_down1 <= dout_buf_down1[1215:1184];
        7'd4    :       pix_data_down1 <= dout_buf_down1[1183:1152];
        7'd5    :       pix_data_down1 <= dout_buf_down1[1151:1120];
        7'd6    :       pix_data_down1 <= dout_buf_down1[1119:1088];
        7'd7    :       pix_data_down1 <= dout_buf_down1[1087:1056];
        7'd8    :       pix_data_down1 <= dout_buf_down1[1055:1024];
        7'd9    :       pix_data_down1 <= dout_buf_down1[1023:992 ];
        7'd10   :       pix_data_down1 <= dout_buf_down1[991 :960 ];
        7'd11   :       pix_data_down1 <= dout_buf_down1[959 :928 ];
        7'd12   :       pix_data_down1 <= dout_buf_down1[927 :896 ];
        7'd13   :       pix_data_down1 <= dout_buf_down1[895 :864 ];
        7'd14   :       pix_data_down1 <= dout_buf_down1[863 :832 ];
        7'd15   :       pix_data_down1 <= dout_buf_down1[831 :800 ];
        7'd16   :       pix_data_down1 <= dout_buf_down1[799 :768 ];
        7'd17   :       pix_data_down1 <= dout_buf_down1[767 :736 ];
        7'd18   :       pix_data_down1 <= dout_buf_down1[735 :704 ];
        7'd19   :       pix_data_down1 <= dout_buf_down1[703 :672 ];
        7'd20   :       pix_data_down1 <= dout_buf_down1[671 :640 ];
        7'd21   :       pix_data_down1 <= dout_buf_down1[639 :608 ];
        7'd22   :       pix_data_down1 <= dout_buf_down1[607 :576 ];
        7'd23   :       pix_data_down1 <= dout_buf_down1[575 :544 ];
        7'd24   :       pix_data_down1 <= dout_buf_down1[543 :512 ];
        7'd25   :       pix_data_down1 <= dout_buf_down1[511 :480 ];
        7'd26   :       pix_data_down1 <= dout_buf_down1[479 :448 ];
        7'd27   :       pix_data_down1 <= dout_buf_down1[447 :416 ];
        7'd28   :       pix_data_down1 <= dout_buf_down1[415 :384 ];
        7'd29   :       pix_data_down1 <= dout_buf_down1[383 :352 ];
        7'd30   :       pix_data_down1 <= dout_buf_down1[351 :320 ];
        7'd31   :       pix_data_down1 <= dout_buf_down1[319 :288 ];
        7'd32   :       pix_data_down1 <= dout_buf_down1[287 :256 ];
        7'd33   :       pix_data_down1 <= dout_buf_down1[255 :224 ];
        7'd34   :       pix_data_down1 <= dout_buf_down1[223 :192 ];
        7'd35   :       pix_data_down1 <= dout_buf_down1[191 :160 ];
        7'd36   :       pix_data_down1 <= dout_buf_down1[159 :128 ];
        7'd37   :       pix_data_down1 <= dout_buf_down1[127 :96  ];
        7'd38   :       pix_data_down1 <= dout_buf_down1[95  :64  ];
        7'd39   :       pix_data_down1 <= dout_buf_down1[63  :32  ];
        7'd40   :       pix_data_down1 <= dout_buf_down1[31  :0   ];
		default	:		pix_data_down1 <= {`DATA_WIDTH-1{1'b0}};
	endcase
end


(*mark_debug = "true"*) wire [`DATA_WIDTH-1:0] pix_data_wire;
assign pix_data_wire = 	( dout_buf_shf_en_up0 ) 	? pix_data_up0		:
						( dout_buf_shf_en_down0 ) 	? pix_data_down0 	:
						( dout_buf_shf_en_up1 ) 	? pix_data_up1 		:
						( dout_buf_shf_en_down1 ) 	? pix_data_down1 	:
						{`DATA_WIDTH-1{1'b0}};

(*mark_debug = "true"*) wire pix_data_valid;//
assign pix_data_valid = (dout_buf_shf_en_up0 | dout_buf_shf_en_down0 | dout_buf_shf_en_up1 | dout_buf_shf_en_down1);



/**
 * ddr2scan up
 */
(*mark_debug = "true"*) wire [`DATA_WIDTH-1:0] fifo_ddr2scan_up_din, fifo_ddr2scan_up_dout;
(*mark_debug = "true"*) wire fifo_ddr2scan_up_wr_en, fifo_ddr2scan_up_rd_en;
wire fifo_ddr2scan_up_full, fifo_ddr2scan_up_almost_full;
wire fifo_ddr2scan_up_wr_ack, fifo_ddr2scan_up_overflow;
wire fifo_ddr2scan_up_empty, fifo_ddr2scan_up_almost_empty;
(*mark_debug = "true"*) wire fifo_ddr2scan_up_valid, fifo_ddr2scan_up_underflow;
wire [6:0] fifo_ddr2scan_up_data_count;
assign fifo_ddr2scan_up_wr_en = (pix_data_valid);
assign fifo_ddr2scan_up_din = (pix_data_wire);

assign fifo_ddr2scan_up_rd_en = (rd_en_up);

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_ddr2scan 	fifo_ddr2scan_up (
	.clk						(rd_clk),                    				// input wire clk
	.srst						(rst),                  					// input wire srst
	.din						(fifo_ddr2scan_up_din),                    	// input wire [127 : 0] din
	.wr_en						(fifo_ddr2scan_up_wr_en),                	// input wire wr_en
	.rd_en						(fifo_ddr2scan_up_rd_en),                	// input wire rd_en
	.dout						(fifo_ddr2scan_up_dout),                  	// output wire [127 : 0] dout
	.full						(fifo_ddr2scan_up_full),                  	// output wire full
	.almost_full				(fifo_ddr2scan_up_almost_full),    			// output wire almost_full
	.wr_ack						(fifo_ddr2scan_up_wr_ack),              	// output wire wr_ack
	.overflow					(fifo_ddr2scan_up_overflow),          		// output wire overflow
	.empty						(fifo_ddr2scan_up_empty),                	// output wire empty
	.almost_empty				(fifo_ddr2scan_up_almost_empty),  			// output wire almost_empty
	.valid						(fifo_ddr2scan_up_valid),                	// output wire valid
	.underflow					(fifo_ddr2scan_up_underflow),        		// output wire underflow
	.data_count					(fifo_ddr2scan_up_data_count)      			// output wire [9 : 0] data_count
);
// INST_TAG_END ------ End INSTANTIATION Template ---------
assign pix_valid_up = ( fifo_ddr2scan_up_valid );
assign pix_data_up = ( fifo_ddr2scan_up_dout );
assign empty_up = ( fifo_ddr2scan_up_empty );
assign data_count_up = ( fifo_ddr2scan_up_data_count );


endmodule // end of pg2pp_top
