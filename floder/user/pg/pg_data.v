/**
 * Filename     :       pg_data.v
 * Date         :       2020-01-09
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *
 */
// `define	Simulation
`define FPGA_Simulation
// `define		SIMPIC
// `define		SIMPIC_HALF
`include "../defines.v"
module pg_data #(
	parameter V_ACT 		= 12'd 2048				,
	parameter H_ACT 		= 12'd 2048				,
	parameter RGB_PORT		= 08'd 1				,
	parameter PORT_NUM		= 08'd 1

	)(
    input                   clk						,
    input                   rst_n					,
    input                   pg_frm_st				,

    input                   normalpic_fifo_rd		,
    output wire             normalpic_fifo_empty	,
    output reg [23:0]       normalpic_fifo_rddata	,

	output 	   [23:0]		raw_data_test			,

	input					key_up					,
	input					key_down				,
	input					key_sel					,
	input					key_auto
);

/**
 * parameter of picture number
 */
parameter COLORFRAME    = 5'd00;
parameter BLACK			= 5'd01;
parameter WHITE         = 5'd02;
parameter BLUE			= 5'd03;
parameter CHESSBOARD    = 5'd04;
parameter GRAYBARH      = 5'd05;
parameter GRAYBARV      = 5'd06;
parameter FLICKER       = 5'd07;
parameter CROSSTALK     = 5'd08;
parameter GRAY192		= 5'd09;
parameter GRAY127		= 5'd10;
parameter GRAY64		= 5'd11;
parameter GRAY32		= 5'd12;
parameter PURECOLOR     = 5'd13;
parameter CHESSBOARDN   = 5'd14;
parameter GRAYBARHN     = 5'd15;
parameter GRAYBARVN     = 5'd16;

/**
 * Doesn't needed
 */
parameter RED			= 5'd23;
parameter GREEN			= 5'd24;
parameter COLORBARH     = 5'd25;
parameter COLORBARV     = 5'd26;
parameter ETCOLORSCALE  = 5'd27;
parameter COLORBAR3     = 5'd28;
parameter COLORBARHN    = 5'd29;
parameter COLORBARVN    = 5'd30;

parameter FIRSTPIC		= 5'd00;
parameter LASTPIC		= 5'd16;

parameter DEBUG_PIC		= COLORFRAME;
parameter DEFAULTPIC	= DEBUG_PIC;

parameter	AUTO_TIMER		=	30'd150000000;

/*
 *	parameter for display parameter
 */
`ifdef Simulation
parameter	pic_width		=	12'd128;
parameter	pic_height		=	12'd24;
`else
parameter	pic_width		=	H_ACT * RGB_PORT;
parameter	pic_height		=	V_ACT;
parameter	hact			=	H_ACT * RGB_PORT;
parameter	vact			= 	V_ACT;
`endif

`ifdef FPGA_Simulation
parameter	chess_hres		=	8'd5;
parameter	chess_vres		=	8'd4;

parameter	r_var_tmp		=	8'd0;
parameter	g_var_tmp		=	8'd0;
parameter	b_var_tmp		=	8'd0;
parameter	chess_size		=	8'd0;
parameter	bar_size		=	8'd2;
parameter	ff32hdiv		=	(pic_width + 16) / 32;
parameter	ff32vdiv		=	(pic_height + 16) / 32;
parameter	ff3hdiv			=	(pic_width + 255) / 255;
parameter	ff3vdiv			=	(pic_height + 255) / 255;

parameter	ffchesshdiv		=	(pic_width + chess_hres/2) / chess_hres;
parameter	ffchessvdiv		=	(pic_height + chess_vres/2) / chess_vres;

parameter	flk_mode		= 	16'h00ff;
parameter	flk_gray		=	8'd255;

// CROSSTALK pattern parameter
parameter	ffcrosshdiv		=	pic_width / 6;
parameter	ffcrossvdiv		=	pic_height / 6;
parameter	cross_r_gray	=	8'd0;
parameter	cross_g_gray	=	8'd0;
parameter	cross_b_gray	=	8'd0;
parameter	cross1_gray		=	8'hff;
parameter	cross2_gray		=	8'h00;

parameter	cross1_hst		=	16'h0002;
parameter	cross1_hend		=	16'h0004;
parameter	cross1_vst		=	16'h0002;
parameter	cross1_vend		=	16'h0004;

parameter	cross2_hst		=	16'h0001;
parameter	cross2_hend		=	16'h0002;
parameter	cross2_vst		=	16'h0001;
parameter	cross2_vend		=	16'h0002;

parameter line_disp_en      =   2'b01;      // line display enable
parameter line_disp_n1      =   pic_width/2;    // line display cnt
parameter line_disp_n2      =   pic_width/3;    // line display cnt
parameter line_disp_n3      =   pic_height/2;    // line display cnt
parameter line_disp_n4      =   pic_height/3;    // line display cnt

`endif

wire[11:0] 	ff32hcnt;
wire[11:0]	ff32vcnt;
wire[11:0]	ff3hcnt;
wire[11:0]	ff3vcnt;
wire[11:0]	ffcrosshcnt;
wire[11:0]	ffcrossvcnt;
wire[11:0]	ffchesshcnt;
wire[11:0]	ffchessvcnt;

wire[11:0]	cs_ff8vcnt; //for colour step

reg [23:0]  raw_data;

//reg	[11:0]	ff32hdiv;
//reg	[11:0]	ff32vdiv;
//reg	[11:0]	ff3hdiv;
//reg	[11:0]	ff3vdiv;
//reg	[11:0]	ffcrosshdiv;
//reg	[11:0]	ffcrossvdiv;
//reg	[11:0]	ffchesshdiv;
//reg	[11:0]	ffchessvdiv;

/**
 * datas process
 */
wire [11:0] hcnt_pre_rst;
assign hcnt_pre_rst = (PORT_NUM == 8'd2) ? 12'h1 : (PORT_NUM == 8'd1) ? 12'h0 : 12'h0;
wire [7:0] hcnt_add;
assign hcnt_add = (RGB_PORT == 8'd2) ? 8'd2 : (RGB_PORT == 8'd1) ? 8'd1 : 8'd1;
wire [11:0] hcnt_end;
assign hcnt_end = (RGB_PORT == 8'd2 && PORT_NUM == 8'd1) ? hact - 2'b10  : hact - 1'b1;



wire        normalpic_fifo_full;
reg     [11:0]      hcnt_pre;
reg     [11:0]      vcnt_pre;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        hcnt_pre <= hcnt_pre_rst;
        vcnt_pre <= 12'h0;
    end else if ( pg_frm_st ) begin
        hcnt_pre <= hcnt_pre_rst;
        vcnt_pre <= 12'h0;
    end else if ( !normalpic_fifo_full ) begin  //counter stops while fifo full
        if ( hcnt_pre == hcnt_end ) begin
            if ( vcnt_pre == vact - 1'b1 ) begin
                vcnt_pre <= 12'h0;
                hcnt_pre <= hcnt_pre_rst;
            end else begin
                hcnt_pre <= hcnt_pre_rst;
                vcnt_pre <= vcnt_pre + 12'b1;
            end
        end else begin
            hcnt_pre <= hcnt_pre + hcnt_add;
        end
    end
end


/**
 * make cnt & ff32cnt simulataneous
 */
reg     [11:0]      hcnt;
reg     [11:0]      vcnt;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        hcnt <= 12'h0;
        vcnt <= 12'h0;
    end else begin
        hcnt <= hcnt_pre;
        vcnt <= vcnt_pre;
    end
end

/*
 *	auto enable state
 */
reg auto_enable;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		auto_enable <= 1'b0;
	end else if ( key_up & key_down ) begin
		if ( auto_enable == 1'b1 ) begin
			auto_enable <= 1'b0;
		end else begin
			auto_enable <= 1'b1;
		end
	end
end


/*
 *	pic_num state and auto run setting
 */
reg [4:0] picture_num;
reg	[29:0] auto_cnt;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		picture_num <= DEFAULTPIC;
		auto_cnt <= 30'b0;
`ifdef Simulation
	end else begin
		picture_num <= DEBUG_PIC;
	end
`else
	end else if ( key_up ) begin
		if ( picture_num < LASTPIC ) begin
			picture_num <= picture_num + 1'b1;
		end else begin
			picture_num <= FIRSTPIC;
		end
	end else if ( key_down ) begin
		if ( picture_num > FIRSTPIC ) begin
			picture_num <= picture_num - 1'b1;
		end else begin
			picture_num <= LASTPIC;
		end
	end else if ( auto_enable ) begin
		if ( auto_cnt == AUTO_TIMER ) begin
			if ( picture_num < LASTPIC ) begin
				picture_num <= picture_num + 1'b1;
			end else begin
				picture_num <= FIRSTPIC;
			end
			auto_cnt <= 30'b0;
		end else begin
			auto_cnt <= auto_cnt + 1'b1;
		end
	end
`endif
end


/**
 * Get var r g b
 */
reg     [7:0]   r_var, g_var, b_var;
reg     [4:0] 	pic_num;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        pic_num <= DEFAULTPIC;
        r_var   <= 8'b0;
        g_var   <= 8'b0;
        b_var   <= 8'b0;
    end else if ( pg_frm_st ) begin			// DE
        pic_num <= picture_num;
        g_var   <= g_var_tmp;
        r_var   <= r_var_tmp;
        b_var   <= b_var_tmp;
    end
end

/**
 *	flicker mode generate
 */
reg     [0:0]   frm_pol;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		frm_pol <= 1'b0;
	end else if ( ~flk_mode[6] ) begin
		frm_pol <= 1'b0;
	end else if ( pg_frm_st ) begin
		frm_pol <= ~frm_pol;
	end
end

wire flk_sub_en;
assign flk_sub_en = flk_mode[15];

/**
 * display state paral
 */

reg     [23:0]  raw_data_tmp;

always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        raw_data_tmp <= {8'h00, 8'h00, 8'h00};
    end else begin
        case ( pic_num )
            PURECOLOR   :   raw_data_tmp <= {r_var, g_var, b_var};
			GRAY192	   	:   raw_data_tmp <= {8'd192, 8'd192, 8'd192};
			GRAY127	   	:   raw_data_tmp <= {8'd127, 8'd127, 8'd127};
			GRAY64	   	:   raw_data_tmp <= {8'd64, 8'd64, 8'd64};
			GRAY32	   	:   raw_data_tmp <= {8'd32, 8'd32, 8'd32};
			BLACK		:   raw_data_tmp <= {8'h00, 8'h00, 8'h00};
            WHITE       :   raw_data_tmp <= {8'hff, 8'hff, 8'hff};
			BLUE		:   raw_data_tmp <= {8'h00, 8'h00, 8'hff};
			GREEN		:   raw_data_tmp <= {8'h00, 8'hff, 8'h00};
            RED			:	raw_data_tmp <= {8'hff, 8'h00, 8'h00};
			CHESSBOARD  :   if (({3'b0, ffchesshcnt}^{3'b0, ffchessvcnt}) & (8'b1<<chess_size)) begin
                raw_data_tmp <= {8'h00, 8'h00, 8'h00};
            end else begin
                raw_data_tmp <= {8'hff, 8'hff, 8'hff};
            end
			CHESSBOARDN  :   if (({3'b0, ffchesshcnt}^{3'b0, ffchessvcnt}) & (8'b1<<chess_size)) begin
                raw_data_tmp <= {8'hff, 8'hff, 8'hff};
            end else begin
                raw_data_tmp <= {8'h00, 8'h00, 8'h00};
            end
            GRAYBARH    :   raw_data_tmp <= {3{({ff32hcnt[4:0], 3'b0} & (8'hf8<<bar_size))}};
			GRAYBARHN   :   raw_data_tmp <= ~{3{({ff32hcnt[4:0], 3'b0} & (8'hf8<<bar_size))}} - 1'b1;
            GRAYBARV    :   raw_data_tmp <= {3{({ff32vcnt[4:0], 3'b0} & (8'hf8<<bar_size))}};
			GRAYBARVN   :   raw_data_tmp <= ~{3{({ff32vcnt[4:0], 3'b0} & (8'hf8<<bar_size))}} - 1'b1;
            COLORBARH   :   raw_data_tmp <= {{8{ff32hcnt[4]}}, {8{ff32hcnt[3]}}, {8{ff32hcnt[2]}}};
			COLORBARHN  :   raw_data_tmp <= ~{{8{ff32hcnt[4]}}, {8{ff32hcnt[3]}}, {8{ff32hcnt[2]}}};
            COLORBARV   :   raw_data_tmp <= {{8{ff32vcnt[4]}}, {8{ff32vcnt[3]}}, {8{ff32vcnt[2]}}};
			COLORBARVN  :   raw_data_tmp <= ~{{8{ff32vcnt[4]}}, {8{ff32vcnt[3]}}, {8{ff32vcnt[2]}}};
            FLICKER     :   if ( ^{{vcnt[2:0], hcnt[1:0]} & flk_mode[4:0], flk_mode[5], frm_pol}) begin
                if ( flk_sub_en ) begin
                    raw_data_tmp <= {8'h00, flk_gray, 8'h00};
                end else begin
                    raw_data_tmp <= {flk_gray, flk_gray, flk_gray};
                end
            end else begin
                if ( flk_sub_en ) begin
                    raw_data_tmp <= {flk_gray, 8'h00, flk_gray};
                end else begin
                    raw_data_tmp <= {8'h00, 8'h00, 8'h00};
                end
            end
            ETCOLORSCALE    :   if ( ff32vcnt <= 7 ) begin
                raw_data_tmp <= {3{{ff3hcnt[7:0]}}};
            end else if ( ff32vcnt <= 15 ) begin
                raw_data_tmp <= {{ff3hcnt[7:0]}, 8'h00, 8'h00};
            end else if ( ff32vcnt <= 23) begin
                raw_data_tmp <= {8'h00, {ff3hcnt[7:0]}, 8'h00};
            end else begin
                raw_data_tmp <= {8'h00, 8'h00, {ff3hcnt[7:0]}};
            end
// `ifdef SIMPIC
// 			COLORFRAME	:	if ( vcnt == 12'h0 & hcnt == 12'b0 ) begin
// 				raw_data_tmp <= 24'hff_ff_00;
// 			end else if ( vcnt == 12'h0 & hcnt == hact - 1'b1 ) begin
// 				raw_data_tmp <= 24'hff_ff_ff;
// 			end else if ( vcnt == vact - 1'b1 & hcnt == 12'b0 ) begin
// 				raw_data_tmp <= 24'hff_00_ff;
// 			end else if ( vcnt == vact - 1'b1 & hcnt == hact - 1'b1 ) begin
// 				raw_data_tmp <= 24'h00_ff_ff;
// 			end else if ( vcnt == vact - 1'b1 ) begin
//                 raw_data_tmp <= 24'h00_ff_00;
// 			end else if ( vcnt == 12'h0 ) begin
// 				raw_data_tmp <= 24'hff_00_ff;				//	YELLOW		PURPLE		WHITE
//             end else if ( hcnt == 12'h0 ) begin				//	RED						BLUE
// 				raw_data_tmp <= 24'hff_00_00;				//	PURPLE		GREEN		GRAY
//             end else if ( hcnt == hact - 1'b1 ) begin
//                 raw_data_tmp <= 24'h00_00_ff;
//             end else begin
//                 raw_data_tmp <= {3{hcnt[7:0]}};
//             end
// `else
// `ifdef SIMPIC_HALF
//             COLORFRAME  :   if ( vcnt == vact - 1'b1 ) begin
//                 raw_data_tmp <= 24'h00_ff_00;
// 			end else if ( vcnt == 12'h0 ) begin
// 				raw_data_tmp <= 24'hff_00_ff;				//	YELLOW		PURPLE		WHITE
//             end else if ( hcnt == 12'h0 ) begin				//	RED						BLUE
// 				raw_data_tmp <= 24'hff_00_00;				//	PURPLE		GREEN		GRAY
// 			end else if ( hcnt == ( hact/2 ) - 1'b1 ) begin
// 				raw_data_tmp <= 24'h00_00_ff;
// 			end else if ( hcnt == ( hact/2) ) begin
// 				raw_data_tmp <= 24'hff_00_00;
//             end else if ( hcnt == hact - 1'b1 ) begin
//                 raw_data_tmp <= 24'h00_00_ff;
//             end else begin
//                 raw_data_tmp <= 24'h00_00_00;
//             end
// `else
			COLORFRAME  :   if ( vcnt == vact - 1'b1 ) begin
                raw_data_tmp <= 24'hff_ff_ff;
			end else if ( vcnt == 12'h0 ) begin
				raw_data_tmp <= 24'hff_ff_ff;				//	YELLOW		PURPLE		WHITE
            end else if ( hcnt == 12'h0 ) begin				//	RED						BLUE
				raw_data_tmp <= 24'hff_ff_ff;				//	PURPLE		GREEN		GRAY
            end else if ( hcnt == hact - 1'b1 ) begin
                raw_data_tmp <= 24'hff_ff_ff;
            end else begin
                raw_data_tmp <= 24'h00_00_00;
            end

// `endif
// `endif
            COLORBAR3   :   if ( ff3vcnt >= vact / 2'b11 ) begin
                raw_data_tmp <= 24'h00_00_ff;				//	BLUE
            end else if ( ff3vcnt >= (vact * 2 / 2'b11 )) begin			//	GREEN
                raw_data_tmp <= 24'h00_ff_00;				//	RED
            end else begin
                raw_data_tmp <= 24'hff_00_00;
            end
            CROSSTALK   :   if ( (ffcrosshcnt >= cross1_hst) & (ffcrosshcnt < cross1_hend) & (ffcrossvcnt >= cross1_vst) & (ffcrossvcnt < cross1_vend) ) begin
                raw_data_tmp <= {3{cross1_gray}};
            end else if ((ffcrosshcnt >= cross2_hst) & (ffcrosshcnt < cross2_hend) & (ffcrossvcnt >= cross2_vst) & (ffcrossvcnt < cross2_vend) ) begin
                raw_data_tmp <= {3{cross2_gray}};
            end else begin
                raw_data_tmp <= {cross_r_gray, cross_g_gray, cross_b_gray};
            end
// ADD Picture Here
            default     :   raw_data_tmp <= {8'h00, 8'h00, 8'h00};
        endcase
    end
end

assign raw_data_test = raw_data_tmp;

/*
 *	line display
 */
reg [23:0] vray_line_data;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        vray_line_data <= 24'b0;
    end else if ( (line_disp_en[0] & (hcnt == line_disp_n1 | vcnt == line_disp_n3))
				| (line_disp_en[1] & (hcnt == line_disp_n2 | vcnt == line_disp_n4))
				& (pic_num == COLORFRAME) ) begin
        vray_line_data <= {8'h00, 8'h00, 8'hff};
    end else begin
        vray_line_data <= 24'h0;
    end
end

reg     [23:0]  raw_data_r;
always @ ( posedge clk or negedge rst_n ) begin
    if (! rst_n ) begin
        raw_data_r <= 24'b0;
    end else begin
        raw_data_r <= ( raw_data_tmp ^ vray_line_data );
    end
end

wire div_rst_h = (hcnt_pre == 12'h0);
wire div_rst_v = (vcnt_pre == 12'h0);

ff_divider  u_ff32hdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_h					),
	.dividend			(hcnt_pre					),
	.divisor			(ff32hdiv					),
	.ff_cnt				(ff32hcnt					)
	);


ff_divider  u_ff32vdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_v					),
	.dividend			(vcnt_pre					),
	.divisor			(ff32vdiv					),
	.ff_cnt				(ff32vcnt					)
	);


ff_divider  u_ff3hdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_h					),
	.dividend			(hcnt_pre					),
	.divisor			(ff3hdiv					),
	.ff_cnt				(ff3hcnt					)
	);


ff_divider  u_ff3vdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_v					),
	.dividend			(vcnt_pre					),
	.divisor			(ff3vdiv					),
	.ff_cnt				(ff3vcnt					)
	);


ff_divider  u_ffcrosshdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_h					),
	.dividend			(hcnt_pre					),
	.divisor			(ffcrosshdiv				),
	.ff_cnt				(ffcrosshcnt				)
	);


ff_divider  u_ffcrossvdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_v					),
	.dividend			(vcnt_pre					),
	.divisor			(ffcrossvdiv				),
	.ff_cnt				(ffcrossvcnt				)
	);


ff_divider  u_ffchesshdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_h					),
	.dividend			(hcnt_pre					),
	.divisor			(ffchesshdiv				),
	.ff_cnt				(ffchesshcnt				)
	);


ff_divider  u_ffchessvdivider(
	.clk				(clk						),
	.rst_n				(rst_n						),
	.reset				(div_rst_v					),
	.dividend			(vcnt_pre					),
	.divisor			(ffchessvdiv				),
	.ff_cnt				(ffchessvcnt				)
	);


reg normalpic_fifo_wr;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		normalpic_fifo_wr <= 1'b0;
	end else if ( pg_frm_st ) begin
		normalpic_fifo_wr <= 1'b0;
	end else begin
		normalpic_fifo_wr <=  (~normalpic_fifo_full);
	end
end

/**
 * Delay of normalpic_fifo_wr
 */
wire normalpic_fifo_wr_delay2;
delay_top delay_normalpic_fifo_wr_inst(
	.clk(clk),
	.rst_n(rst_n),
	.signal_in(normalpic_fifo_wr),
	.delay_num(5'd2),
	.signal_out(normalpic_fifo_wr_delay2)
	);


wire [23:0] normalpic_fifo_rddata_tmp;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		normalpic_fifo_rddata <= 24'b0;
	end else begin
		normalpic_fifo_rddata <= normalpic_fifo_rddata_tmp;
	end
end

reg [23:0] normalpic_fifo_wrdata;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        normalpic_fifo_wrdata <= 24'b0;
    end else begin
        normalpic_fifo_wrdata <= raw_data_r;
    end
end

wire [8:0] usedw_sig;
normalpic_fifo      normalpic_fifo_inst(
    .srst					(pg_frm_st)					,	// clear signal
	.clk					(clk)						,
	.din					(normalpic_fifo_wrdata)		,
	.wr_en					(normalpic_fifo_wr_delay2)	,
	.rd_en					(normalpic_fifo_rd)			,
	.dout					(normalpic_fifo_rddata_tmp)	,
	.empty					(normalpic_fifo_empty)		,
	.prog_full				(normalpic_fifo_full)		,
	.data_count 			(usedw_sig)
	);

endmodule	// the end of pg_data
