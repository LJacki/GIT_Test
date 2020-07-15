`include "../defines.v"
module mig_ddr3_top (
    input               clk,
    input               rst_n,

	// DDR3 physical interface
	input 				sys_clk_i,
//	input 				clk_ref_i,
	input 				sys_rst,
	output [14:0]		ddr3_addr,
	output [2:0]		ddr3_ba,
	output 				ddr3_cas_n,
	output [0:0]		ddr3_ck_n,
	output [0:0]		ddr3_ck_p,
	output [0:0]		ddr3_cke,
	output 				ddr3_ras_n,
	output 				ddr3_we_n,

	inout [63:0]		ddr3_dq,
	inout [7:0]			ddr3_dqs_n,
	inout [7:0]			ddr3_dqs_p,

	output 				ddr3_reset_n,

	output [0:0]        ddr3_cs_n,
	output [7:0]		ddr3_dm,
	output [0:0]		ddr3_odt,

	output 				init_calib_complete,// (o)

	output 				ui_clk,
	output 				ui_clk_sync_rst,		// high active

    // frame singal
    input               Vsync,
    input               Hsync,
    input               DE,

	// control signal
	output 				ddr3_wr_finish,		// active high

    // Data flow pin assignment
    input 				ddr3_din_en,
    input [511:0]		ddr3_din,

	input 				ddr3_dout_req,
	output 				ddr3_dout_valid,
    output [511:0]		ddr3_dout

    );

parameter DATA_WIDTH = 16'd64 * 16'd8;
parameter DATA_WIDTH_1 = DATA_WIDTH - 1'b1;

// wire ui_clk;
// wire ui_clk_sync_rst;
parameter REQ_CNT 	= `LINE_TRANS_NUM * `REQ_ROW;
// parameter REQ_SIZE	= 8'd8 + 1'd1 + 1'd1;
// parameter REQ_CNT 	= 16'd512;
parameter REQ_SIZE	= 8'd16;

wire app_rdy;
// wire ddr3_wr_finish;
// assign ddr3_dout_req_i = (ddr3_dout_req & app_rdy & ddr3_wr_finish);

/*
██████  ███████  ██████
██   ██ ██      ██    ██
██████  █████   ██    ██
██   ██ ██      ██ ▄▄ ██
██   ██ ███████  ██████
                    ▀▀
*/

reg ddr3_dout_req_i;
reg [REQ_SIZE-1:0] ddr3_dout_req_cnt;
always @ (posedge ui_clk or posedge ui_clk_sync_rst	) begin
	if ( ui_clk_sync_rst ) begin
		ddr3_dout_req_cnt <= {REQ_SIZE{1'b0}};
		ddr3_dout_req_i <= 1'b0;
	end else if ( ddr3_dout_req ) begin
		ddr3_dout_req_cnt <= ddr3_dout_req_cnt + 1'b1;
		// ddr3_dout_req_i <= 1'b1;
	end else if ( ddr3_dout_req_cnt >= 1'b1 && ddr3_dout_req_cnt <= REQ_CNT && (app_rdy && ddr3_wr_finish) ) begin
		ddr3_dout_req_cnt <= ddr3_dout_req_cnt + 1'b1;
		ddr3_dout_req_i <= 1'b1;
	end else if ( ddr3_dout_req_cnt == REQ_CNT + 1'b1 ) begin
		ddr3_dout_req_cnt <= {REQ_SIZE{1'b0}};
		ddr3_dout_req_i <= 1'b0;
	end else begin
		ddr3_dout_req_cnt <= ddr3_dout_req_cnt;
		ddr3_dout_req_i <= 1'b0;
	end
end

/**
 * ctrl_ddr3_addr
 */
wire ddr3_wr_en_wire, ddr3_dout_req_wire;
wire [`MEM_ADDR_SIZE-1:0] ddr3_wr_addr_wire, ddr3_rd_addr_wire;
wire [`CACHE_WIDTH-1:0] ddr3_wr_data_wire;


ctrl_ddr3_addr		ctrl_ddr3_addr_inst(
	.clk						(ui_clk)				,	// (i)
	.rst_n   					(rst_n)					,	// (i)
	.Vsync   					(Vsync)					,	// (i)
	.Hsync   					(Hsync)					,	// (i)
	.DE      					(DE)					,	// (i)
	.ddr3_din_en  				(ddr3_din_en)			,	// (i)
	// .ddr3_din					(ddr3_din[511:128])		,	// (i)
	.ddr3_din					(ddr3_din[511:192])		,	// (i)

	.ddr3_wr_en					(ddr3_wr_en_wire)		,	// (o)
	.ddr3_wr_addr				(ddr3_wr_addr_wire)		,	// (o)
	.ddr3_wr_data				(ddr3_wr_data_wire)		,	// (o)

	.ddr3_dout_req_i			(ddr3_dout_req_i)		,	// (i)
	.ddr3_dout_req_o			(ddr3_dout_req_wire)	,	// (o)
	.ddr3_rd_addr				(ddr3_rd_addr_wire)
	);

/**
 * wr_addr_fifo
 */
wire fifo_ddr3_in_wr_en;
wire [DATA_WIDTH_1:0] fifo_ddr3_in_din;

wire fifo_ddr3_in_rd_en;
wire [DATA_WIDTH_1:0] fifo_ddr3_in_dout;
wire fifo_ddr3_in_valid;

wire fifo_ddr3_in_full;
wire fifo_ddr3_in_prog_full;
wire fifo_ddr3_in_almost_full;
wire fifo_ddr3_in_empty;
wire fifo_ddr3_in_almost_empty;

wire [7:0] fifo_ddr3_in_data_count;

fifo_ddr3_in    fifo_ddr3_in_u(
    // input
    .clk					(ui_clk)					,
    .rst_n					(ui_clk_sync_rst)			,
    .din					(fifo_ddr3_in_din)			,
    .wr_en					(fifo_ddr3_in_wr_en)		,
    .rd_en					(fifo_ddr3_in_rd_en)		,

    // output
    .dout					(fifo_ddr3_in_dout)			,
	.valid					(fifo_ddr3_in_valid)		,
    .full					(fifo_ddr3_in_full)			,
    .almost_full			(fifo_ddr3_in_almost_full)	,
	.prog_full				(fifo_ddr3_in_prog_full)	,
    .empty					(fifo_ddr3_in_empty)		,
    .almost_empty			(fifo_ddr3_in_almost_empty)	,
    .data_count				(fifo_ddr3_in_data_count)

    );
// End of instance
reg ddr3_wr_finish_d0, ddr3_wr_finish_d1, ddr3_wr_finish_d2;
always @ (posedge ui_clk or posedge ui_clk_sync_rst) begin
	if ( ui_clk_sync_rst ) begin
		ddr3_wr_finish_d0 <= 1'b0;
		ddr3_wr_finish_d1 <= 1'b0;
		ddr3_wr_finish_d2 <= 1'b0;
	end else begin
		ddr3_wr_finish_d0 <= fifo_ddr3_in_empty;
		ddr3_wr_finish_d1 <= ddr3_wr_finish_d0;
		ddr3_wr_finish_d2 <= ddr3_wr_finish_d1;
	end
end

wire app_writing;
// assign ddr3_wr_finish = (ddr3_wr_finish_d2 | (~app_writing));
assign ddr3_wr_finish = (~app_writing);


/**
 * wr_addr_fifo
 * Start of instance
 */
wire [`MEM_ADDR_SIZE-1:0] fifo_ddr3_wr_addr_dout;
wire fifo_ddr3_wr_addr_full;
wire fifo_ddr3_wr_addr_prog_full;
wire fifo_ddr3_wr_addr_almost_full;
wire fifo_ddr3_wr_addr_empty;
wire fifo_ddr3_wr_addr_almost_empty;
wire [7:0] fifo_ddr3_wr_addr_data_count;
fifo_ddr3_wr_addr		fifo_ddr3_wr_addr_inst(
	// input
    .clk					(ui_clk)						,
    .srst					(ui_clk_sync_rst)				,
    .din					(ddr3_wr_addr_wire)				,
    .wr_en					(fifo_ddr3_in_wr_en)			,
    .rd_en					(fifo_ddr3_in_rd_en)			,

    // output
    .dout					(fifo_ddr3_wr_addr_dout)		,
    .full					(fifo_ddr3_wr_addr_full)		,
    .almost_full			(fifo_ddr3_wr_addr_almost_full)	,
	.prog_full				(fifo_ddr3_wr_addr_prog_full)	,
    .empty					(fifo_ddr3_wr_addr_empty)		,
    .almost_empty			(fifo_ddr3_wr_addr_almost_empty),
    .data_count				(fifo_ddr3_wr_addr_data_count)
	);
// End of instance


/**
 * rd_addr_fifo
 * Start of instance
 */
wire fifo_ddr3_rd_addr_rd_en;
wire [`MEM_ADDR_SIZE-1:0] fifo_ddr3_rd_addr_dout;
wire fifo_ddr3_rd_addr_valid;
wire fifo_ddr3_rd_addr_full;
wire fifo_ddr3_rd_addr_prog_full;
wire fifo_ddr3_rd_addr_almost_full;
wire fifo_ddr3_rd_addr_empty;
wire fifo_ddr3_rd_addr_almost_empty;
wire [7:0] fifo_ddr3_rd_addr_data_count;
fifo_ddr3_wr_addr		fifo_ddr3_rd_addr_inst(
	// input
    .clk					(ui_clk)						,
    .srst					(ui_clk_sync_rst)				,
    .din					(ddr3_rd_addr_wire)				,
    .wr_en					(ddr3_dout_req_wire)			,
    .rd_en					(fifo_ddr3_rd_addr_rd_en)		,

    // output
    .dout					(fifo_ddr3_rd_addr_dout)		,
	.valid					(fifo_ddr3_rd_addr_valid)		,
    .full					(fifo_ddr3_rd_addr_full)		,
    .almost_full			(fifo_ddr3_rd_addr_almost_full)	,
	.prog_full				(fifo_ddr3_rd_addr_prog_full)	,
    .empty					(fifo_ddr3_rd_addr_empty)		,
    .almost_empty			(fifo_ddr3_rd_addr_almost_empty),
    .data_count				(fifo_ddr3_rd_addr_data_count)
	);
// End of instance

reg fifo_ddr3_rd_addr_empty_tmp;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_rd_addr_empty_tmp <= 1'b1;
	end else begin
		fifo_ddr3_rd_addr_empty_tmp <= 	( !ddr3_dout_req_wire && (fifo_ddr3_rd_addr_data_count[7:1] == 7'h0) )
										&& ( fifo_ddr3_rd_addr_data_count[0] == 0 || fifo_ddr3_rd_addr_rd_en);
	end
end

reg fifo_ddr3_rd_addr_wr_en_d0;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_rd_addr_wr_en_d0 <= 1'b1;
	end else begin
		fifo_ddr3_rd_addr_wr_en_d0 <= ddr3_dout_req_wire;
	end
end



// Start of instance
wire fifo_ddr3_out_wr_en;
wire [DATA_WIDTH_1:0] fifo_ddr3_out_din;

wire fifo_ddr3_out_rd_en;
wire [DATA_WIDTH_1:0] fifo_ddr3_out_dout;

wire fifo_ddr3_out_full;
wire fifo_ddr3_out_almost_full;
wire fifo_ddr3_out_prog_full;
wire fifo_ddr3_out_empty;
wire fifo_ddr3_out_almost_empty;

wire [6:0] fifo_ddr3_out_data_count;

fifo_ddr3_out   fifo_ddr3_out_u(
    // input
    .clk					(ui_clk)					,
    .rst_n					(ui_clk_sync_rst)			,
    .din					(fifo_ddr3_out_din)			,
    .wr_en					(fifo_ddr3_out_wr_en)		,
    .rd_en					(fifo_ddr3_out_rd_en)		,

    // output
    .dout					(fifo_ddr3_out_dout)		,
    .full					(fifo_ddr3_out_full)		,
    .almost_full			(fifo_ddr3_out_almost_full)	,
	.prog_full				(fifo_ddr3_out_prog_full)	,
    .empty					(fifo_ddr3_out_empty)		,
    .almost_empty			(fifo_ddr3_out_almost_empty),
    .data_count				(fifo_ddr3_out_data_count)

    );
// End of instance


// wire app_rdy;
wire wr_en_i;
wire [`MEM_ADDR_SIZE-1:0] wr_addr_i;
wire [DATA_WIDTH_1:0] wr_data_i;

wire rd_en_i;
wire [`MEM_ADDR_SIZE-1:0] rd_addr_i;
wire [DATA_WIDTH_1:0] rd_data_o;
wire rd_data_o_valid;


/*
██ ███    ██ ███████ ██ ███████  ██████      ██     ██ ██████
██ ████   ██ ██      ██ ██      ██    ██     ██     ██ ██   ██
██ ██ ██  ██ █████   ██ █████   ██    ██     ██  █  ██ ██████
██ ██  ██ ██ ██      ██ ██      ██    ██     ██ ███ ██ ██   ██
██ ██   ████ ██      ██ ██       ██████       ███ ███  ██   ██
*/

assign fifo_ddr3_in_wr_en	= (init_calib_complete) ? (ddr3_wr_en_wire && !fifo_ddr3_in_prog_full) : 1'b0;
assign fifo_ddr3_in_din = (init_calib_complete) ? {ddr3_wr_data_wire, 192'b0} : 512'b0;


/*
██ ███    ██ ███████ ██ ███████  ██████      ██████  ██████
██ ████   ██ ██      ██ ██      ██    ██     ██   ██ ██   ██
██ ██ ██  ██ █████   ██ █████   ██    ██     ██████  ██   ██
██ ██  ██ ██ ██      ██ ██      ██    ██     ██   ██ ██   ██
██ ██   ████ ██      ██ ██       ██████      ██   ██ ██████
*/

// assign fifo_ddr3_in_rd_en = (app_rdy) && (!fifo_ddr3_in_empty);

reg fifo_ddr3_in_valid_d0;
reg fifo_ddr3_in_valid_d1;
reg [DATA_WIDTH_1:0] fifo_ddr3_in_dout_d0;
reg [DATA_WIDTH_1:0] fifo_ddr3_in_dout_d1;
reg [`MEM_ADDR_SIZE-1:0] fifo_ddr3_wr_addr_dout_d0;
reg [`MEM_ADDR_SIZE-1:0] fifo_ddr3_wr_addr_dout_d1;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_in_valid_d0 <= 1'b0;
		fifo_ddr3_in_valid_d1 <= 1'b0;
		fifo_ddr3_in_dout_d0 <= {DATA_WIDTH{1'b1}};
		fifo_ddr3_in_dout_d1 <= {DATA_WIDTH{1'b1}};
		fifo_ddr3_wr_addr_dout_d0 <= {`MEM_ADDR_SIZE{1'b0}};
		fifo_ddr3_wr_addr_dout_d1 <= {`MEM_ADDR_SIZE{1'b0}};
	end else begin
		fifo_ddr3_in_valid_d0 <= fifo_ddr3_in_valid;
		fifo_ddr3_in_valid_d1 <= fifo_ddr3_in_valid_d0;
		fifo_ddr3_in_dout_d0 <= fifo_ddr3_in_dout;
		fifo_ddr3_in_dout_d1 <= fifo_ddr3_in_dout_d0;
		fifo_ddr3_wr_addr_dout_d0 <= fifo_ddr3_wr_addr_dout;
		fifo_ddr3_wr_addr_dout_d1 <= fifo_ddr3_wr_addr_dout_d0;
	end
end

reg fifo_ddr3_in_rd_en_d0;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_in_rd_en_d0 <= 1'b0;
	end else begin
		fifo_ddr3_in_rd_en_d0 <= fifo_ddr3_in_rd_en;
	end
end


assign wr_en_i = (fifo_ddr3_in_wr_en);
assign wr_data_i = (fifo_ddr3_in_dout);
assign wr_addr_i = (fifo_ddr3_wr_addr_dout);


/*
 ██████  ██    ██ ████████ ███████ ██ ███████  ██████      ██     ██ ██████
██    ██ ██    ██    ██    ██      ██ ██      ██    ██     ██     ██ ██   ██
██    ██ ██    ██    ██    █████   ██ █████   ██    ██     ██  █  ██ ██████
██    ██ ██    ██    ██    ██      ██ ██      ██    ██     ██ ███ ██ ██   ██
 ██████   ██████     ██    ██      ██ ██       ██████       ███ ███  ██   ██
*/

// fifo ddr3 rd addr rd en
reg fifo_ddr3_rd_addr_rd_en_tmp;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_rd_addr_rd_en_tmp <= 1'b0;
	end else if ( app_rdy ) begin
		fifo_ddr3_rd_addr_rd_en_tmp <= 1'b1;
	end else begin
		fifo_ddr3_rd_addr_rd_en_tmp <= 1'b0;
	end
end
// assign fifo_ddr3_rd_addr_rd_en = (fifo_ddr3_rd_addr_rd_en_tmp) && (!fifo_ddr3_rd_addr_empty_tmp);
// assign fifo_ddr3_rd_addr_rd_en = (app_rdy) && (!fifo_ddr3_rd_addr_empty_tmp);

reg fifo_ddr3_rd_addr_valid_d0;
reg fifo_ddr3_rd_addr_valid_d1;
reg [`MEM_ADDR_SIZE-1:0] fifo_ddr3_rd_addr_dout_d0;
reg [`MEM_ADDR_SIZE-1:0] fifo_ddr3_rd_addr_dout_d1;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_rd_addr_valid_d0 <= 1'b0;
		fifo_ddr3_rd_addr_valid_d1 <= 1'b0;
		fifo_ddr3_rd_addr_dout_d0 <= {`MEM_ADDR_SIZE{1'b0}};
		fifo_ddr3_rd_addr_dout_d1 <= {`MEM_ADDR_SIZE{1'b0}};
	end else begin
		fifo_ddr3_rd_addr_valid_d0 <= fifo_ddr3_rd_addr_valid;
		fifo_ddr3_rd_addr_valid_d1 <= fifo_ddr3_rd_addr_valid_d0;
		fifo_ddr3_rd_addr_dout_d0 <= fifo_ddr3_rd_addr_dout;
		fifo_ddr3_rd_addr_dout_d1 <= fifo_ddr3_rd_addr_dout_d0;
	end
end

reg fifo_ddr3_rd_addr_rd_en_d0;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_rd_addr_rd_en_d0 <= 1'b0;
	end else begin
		fifo_ddr3_rd_addr_rd_en_d0 <= fifo_ddr3_rd_addr_rd_en;
	end
end


assign rd_en_i = (init_calib_complete) ? ddr3_dout_req_wire : 1'b0;
assign rd_addr_i =  (init_calib_complete) ?  fifo_ddr3_rd_addr_dout : {`MEM_ADDR_SIZE{1'b0}};
// think about before wr and after the really end of  wr;


assign fifo_ddr3_out_wr_en = (rd_data_o_valid);
assign fifo_ddr3_out_din = (rd_data_o);

/*
 ██████  ██    ██ ████████ ███████ ██ ███████  ██████      ██████  ██████
██    ██ ██    ██    ██    ██      ██ ██      ██    ██     ██   ██ ██   ██
██    ██ ██    ██    ██    █████   ██ █████   ██    ██     ██████  ██   ██
██    ██ ██    ██    ██    ██      ██ ██      ██    ██     ██   ██ ██   ██
 ██████   ██████     ██    ██      ██ ██       ██████      ██   ██ ██████
*/
assign fifo_ddr3_out_rd_en = (!fifo_ddr3_out_empty);
reg fifo_ddr3_out_rd_en_d0;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		fifo_ddr3_out_rd_en_d0 <= 1'b0;
	end else begin
		fifo_ddr3_out_rd_en_d0 <= fifo_ddr3_out_rd_en;
	end
end

assign ddr3_dout_valid = (fifo_ddr3_out_rd_en_d0);
assign ddr3_dout = (fifo_ddr3_out_dout);


/*
██████  ██████  ██████  ██████
██   ██ ██   ██ ██   ██      ██
██   ██ ██   ██ ██████   █████
██   ██ ██   ██ ██   ██      ██
██████  ██████  ██   ██ ██████
*/

// Start of instance
ctrl_ddr3_top   ctrl_ddr3_top_u(
	.sys_clk_i						(sys_clk_i),		// input
//	.clk_ref_i                      (clk_ref_i),		// input
	.sys_rst						(sys_rst),			// input

	// DDR3 physical pin connected
	.init_calib_complete			(init_calib_complete), // (o)

	.ddr3_addr						(ddr3_addr),		// output [14:0]
	.ddr3_ba                        (ddr3_ba),			// output [2:0]
	.ddr3_cas_n                     (ddr3_cas_n),		// output
	.ddr3_ck_n                      (ddr3_ck_n),		// output [0:0]
	.ddr3_ck_p                      (ddr3_ck_p),		// output [0:0]
	.ddr3_cke                       (ddr3_cke),			// output [0:0]
	.ddr3_ras_n                     (ddr3_ras_n),		// output
	.ddr3_we_n                      (ddr3_we_n),		// output

	.ddr3_dq                        (ddr3_dq),			// inout [63:0]
	.ddr3_dqs_n                     (ddr3_dqs_n),		// inout [7:0]
	.ddr3_dqs_p                     (ddr3_dqs_p),		// inout [7:0]
	.ddr3_reset_n                   (ddr3_reset_n),		// output
	// DDR3 physical pin connected
	.ddr3_cs_n                      (ddr3_cs_n),		// output [0:0]
	.ddr3_dm                        (ddr3_dm),			// output [3:0]
	.ddr3_odt                       (ddr3_odt),			// output [0:0]

	// ui_clk : MIG output for user clock, maybe 200Mhz
	.ui_clk                         (ui_clk),			// output

	// ui_clk_sync_rst : MIG output rst, connect to wire
	.ui_clk_sync_rst                (ui_clk_sync_rst),	// output, active high

	.app_rdy						(app_rdy),

	// DDR3 user interface
	.app_writing					(app_writing),
	.fifo_ddr3_in_rd_en				(fifo_ddr3_in_rd_en),
	// .wr_st							(fifo_ddr3_in_wr_en),
	.wr_en_i						(wr_en_i),
	.wr_addr_i						(wr_addr_i),
	.wr_data_i						(wr_data_i),

	.fifo_ddr3_rd_addr_rd_en		(fifo_ddr3_rd_addr_rd_en),
	// .rd_st							(fifo_ddr3_rd_addr_rd_en),
	.rd_en_i						(rd_en_i),
	.rd_addr_i						(rd_addr_i),
	.rd_data_o						(rd_data_o),
	.rd_data_o_valid				(rd_data_o_valid)

    );
// End of instance

endmodule // the end of mig_ddr3_top
