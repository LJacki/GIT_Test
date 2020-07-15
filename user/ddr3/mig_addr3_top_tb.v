`include "../defines.v"
module mig_ddr3_top_tb(
	input 				clk,
	input 				rst_n,

	input 				init_calib_complete,
	// data in flow
	output 				ddr3_din_en,
	output [511:0]		ddr3_din,
	input 				ddr3_wr_finish,

	// data out flow
	output 				ddr3_dout_req,
	input 				ddr3_dout_valid,
	input [511:0]		ddr3_dout,

	output 				check_out			// Low, status : check OK !
	);

parameter DATA_WIDTH = 16'd64 * 16'd8;
parameter DATA_WIDTH_1 = DATA_WIDTH - 1'b1;

localparam  INIT_CNT = 16'd512;
localparam 	TOTAL_CNT = 16'd2048;
localparam 	CNT_SIZE = 8'd11;

localparam  WR_ST = 16'd100;
localparam  WR_ED = 16'd611;

localparam  RD_ST = 16'd800;
localparam  RD_ED = 16'd1311;

localparam  DATA_STEP = {32{16'd1}};

/*
██ ███    ██ ██ ████████ ██  █████  ██
██ ████   ██ ██    ██    ██ ██   ██ ██
██ ██ ██  ██ ██    ██    ██ ███████ ██
██ ██  ██ ██ ██    ██    ██ ██   ██ ██
██ ██   ████ ██    ██    ██ ██   ██ ███████
*/

reg [15:0] init_cnt;
always @ (posedge  clk or posedge rst_n ) begin
	if ( rst_n ) begin
		init_cnt <= 16'b0;
	end else if (init_calib_complete && init_cnt < INIT_CNT) begin
		init_cnt <= init_cnt + 1'b1;
	end else begin
		init_cnt <= init_cnt;
	end
end

/*
 ██████ ███    ██ ████████
██      ████   ██    ██
██      ██ ██  ██    ██
██      ██  ██ ██    ██
 ██████ ██   ████    ██
*/
(*mark_debug = "true"*) reg [CNT_SIZE-1:0] step_cnt;
always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		step_cnt <= {CNT_SIZE{1'b0}};
	end else if ( init_calib_complete && init_cnt == INIT_CNT ) begin
		step_cnt <= step_cnt + 1'b1;
	end else begin
		step_cnt <= {CNT_SIZE{1'b0}};
	end
end

/*
██     ██ ██████
██     ██ ██   ██
██  █  ██ ██████
██ ███ ██ ██   ██
 ███ ███  ██   ██
*/

(*mark_debug = "true"*) reg wr_en_tmp;
// (*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] wr_addr_tmp;
(*mark_debug = "true"*) reg [DATA_WIDTH_1:0] wr_data_tmp;

always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		wr_en_tmp <= 1'b0;
	end else if ( step_cnt >= WR_ST && step_cnt <= WR_ED ) begin
		wr_en_tmp <= 1'b1;
	end else begin
		wr_en_tmp <= 1'b0;
	end
end

always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		wr_data_tmp <= {DATA_WIDTH{1'b0}};
	end else if ( step_cnt >= WR_ST && step_cnt <= WR_ED ) begin
		wr_data_tmp <=  wr_data_tmp + DATA_STEP;
	end else begin
		wr_data_tmp <= wr_data_tmp;
	end
end

assign ddr3_din_en = (wr_en_tmp);
assign ddr3_din = (wr_data_tmp);


/*
██████  ██████
██   ██ ██   ██
██████  ██   ██
██   ██ ██   ██
██   ██ ██████
*/
(*mark_debug = "true"*) reg rd_en_tmp;
(*mark_debug = "true"*) reg [`MEM_ADDR_SIZE-1:0] rd_addr_tmp;

always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		rd_en_tmp <= 1'b0;
	end else if ( step_cnt >= RD_ST && step_cnt <= RD_ED ) begin
		rd_en_tmp <= 1'b1;
	end else begin
		rd_en_tmp <= 1'b0;
	end
end

assign ddr3_dout_req = (step_cnt == RD_ST);

/**
 * rd_data
 */
reg [DATA_WIDTH_1:0] rd_data_tmp;
always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		rd_data_tmp <= {DATA_WIDTH{1'b0}};
	end else if ( ddr3_dout_valid ) begin
		rd_data_tmp <= ddr3_dout;
	end else begin
		rd_data_tmp <= rd_data_tmp;
	end
end


/*
 ██████ ███    ███ ██████
██      ████  ████ ██   ██
██      ██ ████ ██ ██████
██      ██  ██  ██ ██
 ██████ ██      ██ ██
*/
reg [DATA_WIDTH_1:0] rd_data_cmp;

always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		rd_data_cmp <= {DATA_WIDTH{1'b0}};
	end else if ( ddr3_dout_valid ) begin
		rd_data_cmp <= rd_data_cmp + DATA_STEP;
	end else begin
		rd_data_cmp <= rd_data_cmp;
	end
end

(*mark_debug = "true"*) reg [15:0] cmp;
always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		cmp <= 16'b0;
	end else if ( ddr3_dout_valid ) begin
		cmp <= rd_data_cmp[511:496];
	end else begin
		cmp <= 16'b0;
	end
end

(*mark_debug = "true"*) reg [15:0] tmp;
always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		tmp <= 16'b0;
	end else if ( ddr3_dout_valid ) begin
		tmp <= rd_data_tmp[511:496];
	end else begin
		tmp <= 16'b0;
	end
end

(*mark_debug = "true"*) reg check_tmp;
always @ (posedge clk or posedge rst_n ) begin
	if ( rst_n ) begin
		check_tmp <= 1'b0;
	end else if ( cmp != tmp ) begin
		check_tmp <= 1'b1;
	end else begin
		check_tmp <= check_tmp;
	end
end

assign check_out = check_tmp;

endmodule // the end of mig_ddr3_top_tb
