`include "../defines.v"
module ctrl_ddr3_addr (
    input                       clk     ,
    input                       rst_n   ,

    input                       Vsync   ,
    input                       Hsync   ,
    input                       DE      ,

    input                       ddr3_din_en  ,
    input [`CACHE_WIDTH-1:0]    ddr3_din,

    output                      ddr3_wr_en,
    output [`MEM_ADDR_SIZE-1:0] ddr3_wr_addr,
    output [`CACHE_WIDTH-1:0]   ddr3_wr_data,

	input 						ddr3_dout_req_i,
	output 						ddr3_dout_req_o,
	output [`MEM_ADDR_SIZE-1:0] ddr3_rd_addr

    );

/**
 * frame addr offset
 */
// start with negedge of Vsync, first frame or second frame
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

(*mark_debug = "true"*) reg [15:0] frame_num;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		frame_num <= 16'b0;
	end else if ( neg_Vsync ) begin
		frame_num <= frame_num + 1'b1;
	end else begin
		frame_num <= frame_num;
	end
end

(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_frame;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wr_addr_frame <= {`MEM_ADDR_SIZE{1'b0}};
	end else if ( frame_num[0] == 1'b1 ) begin
		wr_addr_frame <= `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * `PWM_NUM;
	end else begin
		wr_addr_frame <= {`MEM_ADDR_SIZE{1'b0}};
	end
end


/*
██     ██ ██████           █████  ██████  ██████  ██████
██     ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██  █  ██ ██████          ███████ ██   ██ ██   ██ ██████
██ ███ ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
 ███ ███  ██   ██ ███████ ██   ██ ██████  ██████  ██   ██
*/

/**
 * addr subframe offset
 */
parameter RD_CNT = `LINE_TRANS_NUM * `PWM_NUM;

(*mark_debug = "true"*) reg [11:0] ddr3_din_en_cnt;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_din_en_cnt <= 12'b0;
    end else if ( ddr3_din_en && ddr3_din_en_cnt <= RD_CNT - 1'b1 ) begin
        ddr3_din_en_cnt <= ddr3_din_en_cnt + 1'b1;
    end else begin
        ddr3_din_en_cnt <= 12'b0;
    end
end

(*mark_debug = "true"*) reg [`PWM_NUM_SIZE-1:0] subframe_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		subframe_cnt <= {`PWM_NUM_SIZE{1'b0}};
	end else if (ddr3_din_en && ddr3_din_en_cnt[1:0] == `LINE_TRANS_NUM - 1'b1) begin
		subframe_cnt <= subframe_cnt + 1'b1;
	end else if (ddr3_din_en ) begin
		subframe_cnt <= subframe_cnt;
	end else begin
		subframe_cnt <= {`PWM_NUM_SIZE{1'b0}};
	end
end

reg [15:0]test_num = 16'd512;

(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_subframe;
always @ ( * ) begin
    case (subframe_cnt)
		5'd0    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd0 ;
		5'd1    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd1 ;
		5'd2    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd2 ;
		5'd3    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd3 ;
		5'd4    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd4 ;
		5'd5    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd5 ;
		5'd6    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd6 ;
		5'd7    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd7 ;
		5'd8    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd8 ;
		5'd9    :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd9 ;
		5'd10   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd10;
		5'd11   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd11;
		5'd12   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd12;
		5'd13   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd13;
		5'd14   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd14;
		5'd15   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd15;
		5'd16   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd16;
		5'd17   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd17;
		5'd18   :   wr_addr_subframe = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * 8'd18;
		default :   wr_addr_subframe = {`MEM_ADDR_SIZE{1'b0}};
	endcase
end


/**
 * addr line offset
 */
(*mark_debug = "true"*) reg [11:0] DE_cnt;

/**
 * frame addr offset
 */
// start with negedge of DE, first frame or second frame
(*mark_debug = "true"*) reg DE_d0, DE_d1, DE_d2;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		DE_d0 <= 1'b0;
		DE_d1 <= 1'b0;
		DE_d2 <= 1'b0;
	end else begin
		DE_d0 <= DE;
		DE_d1 <= DE_d0;
		DE_d2 <= DE_d1;
	end
end

(*mark_debug = "true"*) wire neg_DE;
assign neg_DE = (!DE_d1) & (DE_d2);

always @ (negedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DE_cnt <= 12'b0;
    end else if ( neg_Vsync && DE_cnt == `CHIP_RES_ROW ) begin
        DE_cnt <= 12'b0;
    end else if ( neg_DE ) begin
        DE_cnt <= DE_cnt + 1'b1;
    end else begin
		DE_cnt <= DE_cnt;
	end
end

(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_line;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        wr_addr_line <= {`MEM_ADDR_SIZE{1'b0}};
    end else begin
        wr_addr_line <= (DE_cnt - 1'b1) << 3'b101;       // DE_cnt * `LINE_TRANS_NUM * `BURST_LENGTH
    end
end


/**
 * addr time in a line offset
 */
// (*mark_debug = "true"*) reg [3:0] times_cnt;
(*mark_debug = "true"*) reg [1:0] times_cnt;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        times_cnt <= 2'b0;
    end else if ( ddr3_din_en ) begin
        times_cnt <= times_cnt + 1'b1;
    end else begin
		times_cnt <= 2'b0;
	end
end

(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_times;

always @ ( * ) begin
	case ( times_cnt )
		2'd0 	:	wr_addr_times <= `BURST_LENGTH * 0 ;
		2'd1 	:	wr_addr_times <= `BURST_LENGTH * 1 ;
		2'd2 	:	wr_addr_times <= `BURST_LENGTH * 2 ;
		2'd3 	:	wr_addr_times <= `BURST_LENGTH * 3 ;
		// 4'd4 	:	wr_addr_times <= `BURST_LENGTH * 4 ;
		// 4'd5 	:	wr_addr_times <= `BURST_LENGTH * 5 ;
		// 4'd6 	:	wr_addr_times <= `BURST_LENGTH * 6 ;
		// 4'd7 	:	wr_addr_times <= `BURST_LENGTH * 7 ;
		// 4'd8 	:	wr_addr_times <= `BURST_LENGTH * 8 ;
		// 4'd9 	:	wr_addr_times <= `BURST_LENGTH * 9 ;
		// 4'd10	:	wr_addr_times <= `BURST_LENGTH * 10;
		// 4'd11	:	wr_addr_times <= `BURST_LENGTH * 11;
		// 4'd12	:	wr_addr_times <= `BURST_LENGTH * 12;
		// 4'd13	:	wr_addr_times <= `BURST_LENGTH * 13;
		// 4'd14	:	wr_addr_times <= `BURST_LENGTH * 14;
		// 4'd15	:	wr_addr_times <= `BURST_LENGTH * 15;
		default: ;
	endcase
end

/**
 * addr real, add all offset
 */
(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_real;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        wr_addr_real <= {`MEM_ADDR_SIZE{1'b0}};
    end else begin
        wr_addr_real <= wr_addr_frame + wr_addr_subframe + wr_addr_line + wr_addr_times;
    end
end

assign ddr3_wr_addr = (wr_addr_real);	// ddr3_din_en_d1 ? wr_addr_real : {`MEM_ADDR_SIZE{1'b0}};

/**
 * for output sync to ddr3_wr_addr
 */
reg ddr3_din_en_d0, ddr3_din_en_d1;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_din_en_d0 <= 1'b0;
        ddr3_din_en_d1 <= 1'b0;
    end else begin
        ddr3_din_en_d0 <= ddr3_din_en;
        ddr3_din_en_d1 <= ddr3_din_en_d0;
    end
end
assign ddr3_wr_en = (ddr3_din_en_d0);


reg [`CACHE_WIDTH-1:0] ddr3_din_d0, ddr3_din_d1;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_din_d0 <= {`CACHE_WIDTH{1'b0}};
        ddr3_din_d1 <= {`CACHE_WIDTH{1'b0}};
    end else begin
        ddr3_din_d0 <= ddr3_din;
        ddr3_din_d1 <= ddr3_din_d0;
    end
end

assign ddr3_wr_data = (ddr3_din_d0);



/*
██████  ██████           █████  ██████  ██████  ██████
██   ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██████  ██   ██         ███████ ██   ██ ██   ██ ██████
██   ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██   ██ ██████  ███████ ██   ██ ██████  ██████  ██   ██
*/
/**
 * addr offset, frame
 */
localparam  OFFSET_FRAME = `BURST_LENGTH * `LINE_TRANS_NUM * `CHIP_RES_ROW * `PWM_NUM;
(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] rd_addr_frame;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_frame <= {`MEM_ADDR_SIZE{1'b0}};
	end else if ( frame_num[0] == 1'b0 ) begin
		rd_addr_frame <= OFFSET_FRAME;
	end else begin
		rd_addr_frame <= {`MEM_ADDR_SIZE{1'b0}};
	end
end

/**
 * up & down in request row number offset addr;
 */
localparam  OFFSET_SF 		= `CHIP_RES_ROW * `LINE_TRANS_NUM * `BURST_LENGTH;
localparam  OFFSET_SF_HALF 	= OFFSET_SF / 2;

localparam  OFFSET_ROW 		= `BURST_LENGTH * `LINE_TRANS_NUM;
localparam  OFFSET_REQ_HALF = `BURST_LENGTH * `LINE_TRANS_NUM * `REQ_ROW / 2;
localparam  OFFSET_REQ 		= `BURST_LENGTH * `LINE_TRANS_NUM * `REQ_ROW;

localparam  REQ_ONCE_CNT	= `LINE_TRANS_NUM * `REQ_ROW;		// 16 * 32 = 512; 4 * 2 = 8;
localparam  REQ_ONCE_CNT_HALF = REQ_ONCE_CNT / 2;				// 16 * 32 / 2 = 256; 8 / 2 = 4;

localparam  REQ_CNT			= `CHIP_RES_ROW / `REQ_ROW;			// 2048 / 32 = 64; 8 / 2 = 4;
localparam  REQ_SF_CNT 		= REQ_CNT * `PWM_NUM;				// 64 * 19 = 1216; 4 * 19 = 76;
localparam  REQ_SF2_CNT 	= REQ_SF_CNT * 2;					// 1216 * 2 = 2432; 76 * 2 = 152;

localparam  REQ_SIZE		= 8'd16;


(*mark_debug = "true"*) reg ddr3_dout_req_d0, ddr3_dout_req_d1;
(*mark_debug = "true"*) reg ddr3_dout_req_d2, ddr3_dout_req_d3;
(*mark_debug = "true"*) reg ddr3_dout_req_d4;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_dout_req_d0 <= 1'b0;
        ddr3_dout_req_d1 <= 1'b0;
		ddr3_dout_req_d2 <= 1'b0;
		ddr3_dout_req_d3 <= 1'b0;
		ddr3_dout_req_d4 <= 1'b0;
    end else begin
        ddr3_dout_req_d0 <= ddr3_dout_req_i;
        ddr3_dout_req_d1 <= ddr3_dout_req_d0;
		ddr3_dout_req_d2 <= ddr3_dout_req_d1;
		ddr3_dout_req_d3 <= ddr3_dout_req_d2;
		ddr3_dout_req_d4 <= ddr3_dout_req_d3;
    end
end

/**
 * cnt for ddr3_dout_req_i
 * req_i_cnt from 1 to `LINE_TRANS_NUM * `REQ_ROW (16*16=256)
 * from number 1 to 128, the up addr enable;
 * from number 129 to 256, the down addr enable;
 */
(*mark_debug = "true"*) reg [REQ_SIZE-1:0] req_i_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		req_i_cnt <= {REQ_SIZE{1'b0}};
	end else if ( ddr3_dout_req_i && req_i_cnt <= REQ_ONCE_CNT - 1'b1 ) begin
		req_i_cnt <= req_i_cnt + 1'b1;
	end else if ( req_i_cnt <= REQ_ONCE_CNT - 1'b1 ) begin
		req_i_cnt <= req_i_cnt;
	end else begin
		req_i_cnt <= {REQ_SIZE{1'b0}};
	end
end


(*mark_debug = "true"*) reg rd_addr_up_en, rd_addr_down_en;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_up_en <= 1'b0;
		rd_addr_down_en <= 1'b0;
	end else if ( req_i_cnt >= 16'd1 && req_i_cnt <= REQ_ONCE_CNT_HALF ) begin
		rd_addr_up_en <= 1'b1;
		rd_addr_down_en <= 1'b0;
	end else if ( req_i_cnt >= (REQ_ONCE_CNT_HALF + 1'b1) && req_i_cnt <= REQ_ONCE_CNT ) begin
		rd_addr_up_en <= 1'b0;
		rd_addr_down_en <= 1'b1;
	end else begin
		rd_addr_up_en <= 1'b0;
		rd_addr_down_en <= 1'b0;
	end
end

(*mark_debug = "true"*) wire neg_rd_addr_up_en, neg_rd_addr_down_en;
(*mark_debug = "true"*) reg rd_addr_up_en_d0, rd_addr_down_en_d0;
(*mark_debug = "true"*) reg rd_addr_up_en_d1, rd_addr_down_en_d1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_up_en_d0 <= 1'b0;
		rd_addr_up_en_d1 <= 1'b0;
		rd_addr_down_en_d0 <= 1'b0;
		rd_addr_down_en_d1 <= 1'b0;
	end else begin
		rd_addr_up_en_d0 <= rd_addr_up_en;
		rd_addr_up_en_d1 <= rd_addr_up_en_d0;
		rd_addr_down_en_d0 <= rd_addr_down_en;
		rd_addr_down_en_d1 <= rd_addr_down_en_d0;
	end
end

assign neg_rd_addr_up_en = (!rd_addr_up_en) & (rd_addr_up_en_d0);
assign neg_rd_addr_down_en = (!rd_addr_down_en) & (rd_addr_down_en_d0);

(*mark_debug = "true"*) reg neg_rd_addr_up_en_d0, neg_rd_addr_down_en_d0;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		neg_rd_addr_up_en_d0 <= 1'b0;
		neg_rd_addr_down_en_d0 <= 1'b0;
	end else begin
		neg_rd_addr_up_en_d0 <= neg_rd_addr_up_en;
		neg_rd_addr_down_en_d0 <= neg_rd_addr_down_en;
	end
end



/**
 * rd addr up en cnt
 */
(*mark_debug = "true"*) reg [15:0] rd_addr_up_en_cnt;

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_up_en_cnt <= 16'b0;
	end else if ( neg_Vsync ) begin
		rd_addr_up_en_cnt <= 16'b0;
	end else if ( neg_rd_addr_up_en ) begin
		rd_addr_up_en_cnt <= rd_addr_up_en_cnt + 1'b1;
	end else begin
		rd_addr_up_en_cnt <= rd_addr_up_en_cnt;
	end
end



(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] rd_addr_up;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_up <= {`MEM_ADDR_SIZE{1'b0}} - `BURST_LENGTH;
	end else if ( ddr3_dout_req_d2 && rd_addr_up_en_d0 ) begin
		rd_addr_up <= rd_addr_up + `BURST_LENGTH;
	end else if ( neg_rd_addr_up_en_d0 && ( rd_addr_up_en_cnt == REQ_SF_CNT || rd_addr_up_en_cnt == REQ_SF2_CNT) ) begin
		rd_addr_up <= {`MEM_ADDR_SIZE{1'b0}} - `BURST_LENGTH;	// reset when back to first frame;
	end else if ( (neg_rd_addr_up_en_d0) ) begin
		rd_addr_up <= rd_addr_up + OFFSET_REQ_HALF;		// jump to next up addr;
	end else begin
		rd_addr_up <= rd_addr_up;
	end
end



/**
 * rd addr down en cnt
 */
(*mark_debug = "true"*) reg [15:0] rd_addr_down_en_cnt;

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_down_en_cnt <= 16'b0;
	end else if ( neg_Vsync ) begin
		rd_addr_down_en_cnt <= 16'b0;
	end else if ( neg_rd_addr_down_en ) begin
		rd_addr_down_en_cnt <= rd_addr_down_en_cnt + 1'b1;
	end else begin
		rd_addr_down_en_cnt <= rd_addr_down_en_cnt;
	end
end


(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] rd_addr_down;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_down <= OFFSET_REQ_HALF - `BURST_LENGTH;
	end else if ( ddr3_dout_req_d2 && rd_addr_down_en_d0 ) begin
		rd_addr_down <= rd_addr_down + `BURST_LENGTH;
	end else if ( neg_rd_addr_down_en_d0 && (rd_addr_down_en_cnt == REQ_SF_CNT || rd_addr_down_en_cnt == REQ_SF2_CNT) ) begin
		rd_addr_down <= OFFSET_REQ_HALF - `BURST_LENGTH;		// reset when back to first frame;
	end else if ( (neg_rd_addr_down_en_d0) ) begin
		rd_addr_down <= rd_addr_down + OFFSET_REQ_HALF;		// jump to next down addr;
	end else begin
		rd_addr_down <= rd_addr_down;
	end
end





/**
 * addr real, rd add all offset
 */
(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] rd_addr_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_tmp <= {`MEM_ADDR_SIZE{1'b0}} - `BURST_LENGTH;
	end else if ( rd_addr_up_en_d1 ) begin
		rd_addr_tmp <= rd_addr_up + rd_addr_frame;
	end else if ( rd_addr_down_en_d1 ) begin
		rd_addr_tmp <= rd_addr_down + rd_addr_frame;	// pay more attention here;
	end else begin
		// rd_addr_tmp <= {`MEM_ADDR_SIZE{1'b0}};
		rd_addr_tmp <= rd_addr_tmp;
	end
end

assign ddr3_rd_addr = rd_addr_tmp;

/**
 * for output sync to ddr3_rd_addr
 */
assign ddr3_dout_req_o = (ddr3_dout_req_d4);







endmodule // the end of ctrl_ddr3_addr
