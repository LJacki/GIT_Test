`include "../defines.v"
module	pixel_processor(
	input							clk				,
	input							rst_n			,
	input							rdempty			,
	input 							valid_en		,
	input	[`RGB_PORT*`RGB_DATA_WIDTH-1:0]					din				,
	input							en				,
	input							vs				,

	output [`CACHE_WIDTH-1:0]		fifo_dout		,
	output 							fifo_valid
	);

(*mark_debug = "true"*) reg	enable;
reg	[`RGB_PORT*`RGB_DATA_WIDTH-1:0] valid_data;
reg	valid_de;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		enable <= 0;
	end else if(vs) begin
		enable <= 1;
	end else begin
		enable <= enable;
	end
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		valid_data <= 0;
	end else begin
		valid_data <= din;
	end
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		valid_de <= 0;
	end else begin
		valid_de <= valid_en;
	end
end

/**
 * rgb data enable
 */
(*mark_debug = "true"*) wire [7:0] din_r0, din_g0, din_b0;
// (*mark_debug = "true"*) wire [7:0] din_r1, din_g1, din_b1;
(*mark_debug = "true"*) wire de_tmp;

// assign	din_r0 = enable ? valid_data[47:40] : 8'd0;
// assign	din_g0 = enable ? valid_data[39:32] : 8'd0;
// assign	din_b0 = enable ? valid_data[31:24] : 8'd0;
assign	din_r0 = enable ? valid_data[23:16] : 8'd0;
assign	din_g0 = enable ? valid_data[15:08] : 8'd0;
assign	din_b0 = enable ? valid_data[07:00] : 8'd0;

assign	de_tmp = enable && valid_de;


/**
 * PWM data generate
 */
(*mark_debug = "true"*) wire pwm_oe;
(*mark_debug = "true"*) wire[`PWM_NUM-1:0] pwm_dout_r0, pwm_dout_g0, pwm_dout_b0;
// (*mark_debug = "true"*) wire[`PWM_NUM-1:0] pwm_dout_r1, pwm_dout_g1, pwm_dout_b1;

pixel_pwm		pixel_pwm_inst_r0(
	.clk						(clk)				,
	.rst_n						(rst_n)				,
	.din						(din_r0)			,
	.en							(de_tmp)			,
	.dout						(pwm_dout_r0)		,
	.oe							(pwm_oe)
	);

pixel_pwm		pixel_pwm_inst_g0(
	.clk						(clk)				,
	.rst_n						(rst_n)				,
	.din						(din_g0)			,
	.en							(de_tmp)			,
	.dout						(pwm_dout_g0)		,
	.oe							()
	);

pixel_pwm		pixel_pwm_inst_b0(
	.clk						(clk)				,
	.rst_n						(rst_n)				,
	.din						(din_b0)			,
	.en							(de_tmp)			,
	.dout						(pwm_dout_b0)		,
	.oe							()
	);
//
// pixel_pwm		pixel_pwm_inst_r1(
// 	.clk						(clk)				,
// 	.rst_n						(rst_n)				,
// 	.din						(din_r1)			,
// 	.en							(de_tmp)			,
// 	.dout						(pwm_dout_r1)		,
// 	.oe							()
// 	);
//
// pixel_pwm		pixel_pwm_inst_g1(
// 	.clk						(clk)				,
// 	.rst_n						(rst_n)				,
// 	.din						(din_g1)			,
// 	.en							(de_tmp)			,
// 	.dout						(pwm_dout_g1)		,
// 	.oe							()
// 	);
//
// pixel_pwm		pixel_pwm_inst_b1(
// 	.clk						(clk)				,
// 	.rst_n						(rst_n)				,
// 	.din						(din_b1)			,
// 	.en							(de_tmp)			,
// 	.dout						(pwm_dout_b1)		,
// 	.oe							()
// 	);

/**
 * pixel convert bit : store the 19 subfarme PWM data, by count 128 times
 */
wire [`CACHE_WIDTH-1:0] sel_bit [0:18];
wire [18:0] sel_en;

genvar bit_cnt;
generate
	for (bit_cnt = 0; bit_cnt < 5'd19; bit_cnt = bit_cnt + 1'b1) begin : pixel_convert
		pixel_convert_bit		pixel_convert_bit_u(
			.clk						(clk)			,
			.rst_n						(rst_n)			,
			.din						(pwm_dout_b0[bit_cnt]),
			.en							(pwm_oe)		,
			.dout						(sel_bit[bit_cnt]),
			.oe							(sel_en[bit_cnt])
			);

	end
endgenerate



/**
 * fifo subframe buf : store the 19 subfarme PWM data
 */
(*mark_debug = "true"*) wire [18:0] fifo_subframe_rd_en;
wire [`CACHE_WIDTH-1:0] fifo_subframe_dout [0:18];
(*mark_debug = "true"*) wire [18:0] fifo_subframe_valid;
wire [18:0] fifo_subframe_full, fifo_subframe_almost_full, fifo_subframe_empty, fifo_subframe_almost_empty;
wire [3:0] fifo_subframe_data_count [0:18];


genvar bit_cnt_tmp;
generate
	for (bit_cnt_tmp = 0; bit_cnt_tmp < 5'd19; bit_cnt_tmp = bit_cnt_tmp + 1'b1) begin : fifo_subframe
		fifo_subframe_buf			fifo_subframe_buf_u(
			.clk						(clk)									,
			.srst						(!rst_n)								,
			.wr_en						(sel_en[bit_cnt_tmp])					,
			.din						(sel_bit[bit_cnt_tmp])					,
			.rd_en						(fifo_subframe_rd_en[bit_cnt_tmp])		,
			.dout						(fifo_subframe_dout[bit_cnt_tmp])		,
			.valid						(fifo_subframe_valid[bit_cnt_tmp])		,
			.full						(fifo_subframe_full[bit_cnt_tmp])		,
			.almost_full				(fifo_subframe_almost_full[bit_cnt_tmp]),
			.empty						(fifo_subframe_empty[bit_cnt_tmp])		,
			.almost_empty				(fifo_subframe_almost_empty[bit_cnt_tmp]),
			.data_count					(fifo_subframe_data_count[bit_cnt_tmp])
		);
	end
endgenerate

assign fifo_valid = (|fifo_subframe_valid);
assign fifo_dout = 	(fifo_subframe_valid[18]) ? fifo_subframe_dout[18] : (fifo_subframe_valid[17]) ? fifo_subframe_dout[17] :
					(fifo_subframe_valid[16]) ? fifo_subframe_dout[16] : (fifo_subframe_valid[15]) ? fifo_subframe_dout[15] :
					(fifo_subframe_valid[14]) ? fifo_subframe_dout[14] : (fifo_subframe_valid[13]) ? fifo_subframe_dout[13] :
					(fifo_subframe_valid[12]) ? fifo_subframe_dout[12] : (fifo_subframe_valid[11]) ? fifo_subframe_dout[11] :
					(fifo_subframe_valid[10]) ? fifo_subframe_dout[10] : (fifo_subframe_valid[09]) ? fifo_subframe_dout[09] :
					(fifo_subframe_valid[08]) ? fifo_subframe_dout[08] : (fifo_subframe_valid[07]) ? fifo_subframe_dout[07] :
					(fifo_subframe_valid[06]) ? fifo_subframe_dout[06] : (fifo_subframe_valid[05]) ? fifo_subframe_dout[05] :
					(fifo_subframe_valid[04]) ? fifo_subframe_dout[04] : (fifo_subframe_valid[03]) ? fifo_subframe_dout[03] :
					(fifo_subframe_valid[02]) ? fifo_subframe_dout[02] : (fifo_subframe_valid[01]) ? fifo_subframe_dout[01] :
					(fifo_subframe_valid[00]) ? fifo_subframe_dout[00] : {`CACHE_WIDTH{1'b0}};


/**
 * get the negedge of en
 */
(*mark_debug = "true"*) reg en_d0, en_d1, en_d2;
(*mark_debug = "true"*) wire neg_en;

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		en_d0 <= 1'b0;
		en_d1 <= 1'b0;
		en_d2 <= 1'b0;
	end else begin
		en_d0 <= en;
		en_d1 <= en_d0;
		en_d2 <= en_d1;
	end
end
assign neg_en = (en_d2) && (!en_d1);

parameter RD_CNT	= `LINE_TRANS_NUM * `PWM_NUM;

reg fifo_subframe_rd_en_tmp;
reg [18:0] fifo_subframe_rd_en_tmp1;
reg [15:0] fifo_subframe_rd_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		fifo_subframe_rd_en_tmp <= 1'b0;
		fifo_subframe_rd_cnt <= 16'b0;
	end else if ( neg_en ) begin
		fifo_subframe_rd_en_tmp <= 1'b1;
		fifo_subframe_rd_cnt <= fifo_subframe_rd_cnt + 1'b1;
	end else if ( fifo_subframe_rd_en_tmp && fifo_subframe_rd_cnt <= RD_CNT - 1'b1) begin
		fifo_subframe_rd_en_tmp <= 1'b1;
		fifo_subframe_rd_cnt <= fifo_subframe_rd_cnt + 1'b1;
	end else begin
		fifo_subframe_rd_en_tmp <= 1'b0;
		fifo_subframe_rd_cnt <= 16'b0;
	end
end

always @ (posedge  clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		fifo_subframe_rd_en_tmp1 <= 19'b0;
	end else if ( neg_en ) begin
		fifo_subframe_rd_en_tmp1 <= 19'b100_0000_0000_0000_0000;
	// end else if (fifo_subframe_rd_en_tmp && fifo_subframe_rd_cnt[3:0] == 19'b0 ) begin
	end else if (fifo_subframe_rd_en_tmp && fifo_subframe_rd_cnt[1:0] == 16'b0 ) begin
		fifo_subframe_rd_en_tmp1 <= fifo_subframe_rd_en_tmp1 >> 1'b1;
	end else if ( fifo_subframe_rd_en_tmp ) begin
		fifo_subframe_rd_en_tmp1 <= fifo_subframe_rd_en_tmp1;
	end else begin
		fifo_subframe_rd_en_tmp1 <= 19'b0;
	end
end

assign fifo_subframe_rd_en = (fifo_subframe_rd_en_tmp1);

endmodule
