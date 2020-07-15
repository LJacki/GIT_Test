`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/04/02 09:44:31
// Design Name:
// Module Name: Board_Check_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"
module Board_Check_top #(

	// video parameter
	parameter V_ACT		= `V_ACT		,
	parameter V_PW		= `V_PW			,
	parameter V_BP		= `V_BP			,
	parameter V_FP		= `V_FP			,

	parameter H_ACT		= `H_ACT		,
	parameter H_PW		= `H_PW			,
	parameter H_BP		= `H_BP			,
	parameter H_FP		= `H_FP

	)(

	// Reste and Clock
	input 				rst_n,
	input               clk_200m_p		,	// (i)
	input               clk_200m_n		,	// (i)

	// RGB Video IF
	input 				VIDEO_CLK		,	// (i)
	input 				VIDEO_VS		,	// (i)
	input 				VIDEO_HS		,	// (i)
	input 				VIDEO_DE		,	// (i)
	input [47:0]		VIDEO_DA		,	// (i)

	// // LVDS TX Port List
	// output 				LVDS_SEP		,
	// output 				LVDS_SEN		,
	// output 				LVDS_CLKP		,
	// output 				LVDS_CLKN		,
	//
	// output [4:0]		LVDS_OUTP		,
	// output [4:0]		LVDS_OUTN		,
	//
	// // Other Control Signals
	// // output 				RSTNA			,
	output 				HSNA			,
	// output 				LSNA			,
	//
	// // output 				TEST_MUX		,
	// //
	// output 				VCOM_EN			,
	// output 				VLED_EN			,
	// // Ctrl mode
	// output 				SEL_0			,
	// output 				SEL_1			,
	//
	// // Pll power
	output 				PWD_PLL			,
	//
	// // LVDS power
	// output 				PWD_LVDS		,
	//
	// // SPI Interface Port List
	// output 				SPI_MUX			,
	output 				SPI_CS			,
	// output 				SPI_CLK			,
	output 				SPI_SDI			,
	// input 				SPI_SDO			,
	//
	// // ADC Port List
	output 				CLK1M			,
	//
	// // DDR3 Physical Interface
	// output [14:0]		ddr3_addr		,	// (o)
	// output [2:0]		ddr3_ba			,	// (o)
	// output 				ddr3_cas_n		,	// (o)
	// output [0:0]		ddr3_ck_n		,	// (o)
	// output [0:0]		ddr3_ck_p		,	// (o)
	// output [0:0]		ddr3_cke		,	// (o)
	// output 				ddr3_ras_n		,	// (o)
	// output 				ddr3_we_n		,	// (o)
	//
	// inout  [63:0]		ddr3_dq			,	// (io)
	// inout  [7:0]		ddr3_dqs_n		,	// (io)
	// inout  [7:0]		ddr3_dqs_p		,	// (io)
	//
	// output 				ddr3_reset_n	,	// (o)
	//
	// output [0:0]        ddr3_cs_n		,	// (o)
	// output [7:0]		ddr3_dm			,	// (o)
	// output [0:0]		ddr3_odt		,	// (o)

	// AUX Peripheral Devices
	//
	input  [2:0]		PSW				,	// input push switch
	output [5:0]		LED


    );

//


//
parameter DATA_WIDTH = 16'd64 * 16'd8;
parameter DATA_WIDTH_1 = DATA_WIDTH - 1'b1;

/**
 * sys clock IBUFDS instantiation
 */
wire clk_200m;

IBUFGDS #(
	.DIFF_TERM("FALSE")
	)
u_ibufgds (
	.I						(clk_200m_p),
	.IB						(clk_200m_n),
	.O						(clk_200m)
	);

/**
 * sys clock and sys_rst_n
 */
wire sys_rst_n;
wire clk_100m, clk_ddr3_i, clk_spi;
wire clk_pclk, clk_pclk_d;
wire clk_SCLK, clk_SCLK_ph180, clk_tx_div, clk_tx, clk_tx_ph180;
wire idelay_ctrl_rdy;

clk_rst_top		clk_rst_top_u (
    .clk_200m               (clk_200m)			,   // (i) System Clock,200 MHz
    .rst_n                  (rst_n)				,   // (i) External Reset(Low active)

    .sys_rst_n              (sys_rst_n)			,   // (o) System Reset(Low active)
	.clk_100m				(clk_100m)			,	// (o) output 100 MHz,
	.clk_ddr3_i				(clk_ddr3_i)		,	// (o) output 200 MHz,
	.clk_spi				(clk_spi)			,	// (o) output 20 MHz,

	.clk_pclk				(clk_pclk)			,	// (o) 148.5 MHz
	.clk_pclk_d				(clk_pclk_d)		,	// (o) 297 MHz

	.clk_SCLK				(clk_SCLK)			,	// (o) SCAN clock 75 MHz
	.clk_SCLK_ph180			(clk_SCLK_ph180)	,	// (o) SCNA clock shift 180 degree
	.clk_tx_div				(clk_tx_div)		,	// (o) lvds output clk / 4 = 75 MHz
	.clk_tx					(clk_tx)			,	// (o) lvds output clk	300 MHz
	.clk_tx_ph180			(clk_tx_ph180)		,	// (o) lvds output clk 600 MHz degree

    .idelay_ctrl_rdy		(idelay_ctrl_rdy)		// (o)
    );

/**
 * Led Blink
 */
wire [5:0] led_signal_wire;
genvar i_cnt;
generate
	for (i_cnt = 0; i_cnt < 8'd6; i_cnt = i_cnt + 1'b1) begin : led
		led_signal #(
			.sys_clock(8'd100),
			.led_type(1'b0)
			) led_signal_inst (
		    .clk                (clk_100m)			,
		    .rst_n              (sys_rst_n)			,
		    .led_en             (1'b1)				,
		    .blink_type         (i_cnt[3:0])		,
		    .led_signal         (led_signal_wire[i_cnt])
		    );
	end
endgenerate

assign LED[2:0] = 3'b0;

/*
███████ ██████  ██         ███    ███  █████  ███████ ████████ ███████ ██████
██      ██   ██ ██         ████  ████ ██   ██ ██         ██    ██      ██   ██
███████ ██████  ██         ██ ████ ██ ███████ ███████    ██    █████   ██████
     ██ ██      ██         ██  ██  ██ ██   ██      ██    ██    ██      ██   ██
███████ ██      ██ ███████ ██      ██ ██   ██ ███████    ██    ███████ ██   ██
*/

//wire spi_rdy;
//spi_master	spi_master_inst(
//	.clk			(clk_spi)	,
//	.rst_n			(sys_rst_n)	,
//	.spi_sdo		(SPI_SDO)	,
//	.spi_sdi		(SPI_SDI)	,
//	.spi_cs			(SPI_CS)	,
//	.spi_sclk		(SPI_CLK)	,
//	.spi_rdy		(spi_rdy)
//);


/**
 * key to detected
 */
(*mark_debug = "true"*) wire neg_key_up;
(*mark_debug = "true"*) wire neg_key_down;
(*mark_debug = "true"*) wire neg_key_sel;
(*mark_debug = "true"*) wire neg_key_auto;
(*mark_debug = "true"*) wire [3:0] key_in, key_out;
key_detect_top 	key_detect_top_inst(
	.clk(clk_pclk),
	.rst_n(sys_rst_n),
	.key_in(key_in),
	.key_out(key_out)
);
assign key_in = {PSW[2], 1'b1, PSW[1], PSW[0]};
assign {neg_key_auto, neg_key_sel, neg_key_down, neg_key_up} = key_out;

wire led_toggle = |key_out;
reg led_tmp;

always @ ( posedge clk_pclk or negedge sys_rst_n ) begin
	if ( !sys_rst_n ) begin
		led_tmp <= 1'b0;
	end else if ( led_toggle ) begin
		led_tmp <= ~led_tmp;
	end else begin
		led_tmp <= led_tmp;
	end
end
assign LED[3] = (led_tmp);


/*
██    ██ ██ ██████  ███████  ██████          ██ ███████
██    ██ ██ ██   ██ ██      ██    ██         ██ ██
██    ██ ██ ██   ██ █████   ██    ██         ██ █████
 ██  ██  ██ ██   ██ ██      ██    ██         ██ ██
  ████   ██ ██████  ███████  ██████  ███████ ██ ██
*/

(*mark_debug = "true"*) wire init_calib_complete = 1'b1;
(*mark_debug = "true"*) wire video_clk_o, video_vs_o, video_hs_o, video_de_o;
(*mark_debug = "true"*) wire [47:0] video_da_o;
video_if_top #(
	.POL					(1'b0),
	.RGB_MAP_TYP			(2'b00)
	) video_if_top_inst (
	.clk					(clk_pclk),
	.rst_n					(sys_rst_n),
	.en						(init_calib_complete),
	.VIDEO_CLK				(VIDEO_CLK),
	.VIDEO_VS				(VIDEO_VS),
	.VIDEO_HS				(VIDEO_HS),
	.VIDEO_DE				(VIDEO_DE),
	.VIDEO_DA				(VIDEO_DA),

	.video_clk_o			(video_clk_o),
	.video_vs_o				(video_vs_o),
	.video_hs_o				(video_hs_o),
	.video_de_o				(video_de_o),
	.video_da_o				(video_da_o)
	);





/*
██████   ██████
██   ██ ██
██████  ██   ██��?
██      ██    ██
██       ██████
*/
/**
 * pattern generate top
 */
parameter RGB_PORT = `RGB_PORT;

(*mark_debug = "true"*) wire pg_frm_st;
(*mark_debug = "true"*) wire DE_pg, Vsync_pg, Hsync_pg;
(*mark_debug = "true"*) wire [RGB_PORT*`RGB_DATA_WIDTH-1:0] data_rgb_pg;

pg_top #(
	// video parameter
	.V_ACT					(V_ACT)			,
	.V_PW					(V_PW)			,
	.V_BP					(V_BP)			,
	.V_FP					(V_FP)			,

	.H_ACT					(H_ACT)			,
	.H_PW					(H_PW)			,
	.H_BP					(H_BP)			,
	.H_FP					(H_FP)			,
	.RGB_PORT				(RGB_PORT)

	) pg_top_inst(
	.clk					(clk_pclk)				,	// (i) block clock
	.rst_n					(sys_rst_n)				,	// (i) block reset, Low_active
	.en						(init_calib_complete)	,	// (i) block enable, High_active

	.pg_frm_st				(pg_frm_st)				,	// (i) frame start signal
	.DE						(DE_pg)				,	// (o)
	.Vsync					(Vsync_pg)			,	// (o)
	.Hsync					(Hsync_pg)			, 	// (o)
	.data_rgb				(data_rgb_pg)			,	// (o) [47:0]

	.key_up					(neg_key_up)			,
	.key_down				(neg_key_down)			,
	// .key_sel				(neg_key_sel)			,
	.key_auto				()// (neg_key_auto)
	);

assign LED[4] = (DE_pg);



/**
 * SEL video or pg
 */
parameter video_en = 1'b1;

(*mark_debug = "true"*) wire DE_wire, Vsync_wire, Hsync_wire;
(*mark_debug = "true"*) wire [RGB_PORT*`RGB_DATA_WIDTH-1:0] data_rgb_wire;
wire video_clk_wire;

assign video_clk_wire = (video_en) ? video_clk_o : clk_pclk;
assign Vsync_wire = (video_en) ? video_vs_o : Vsync_pg;
assign Hsync_wire = (video_en) ? video_hs_o : Hsync_pg;
assign DE_wire    = (video_en) ? video_de_o : DE_pg;

assign data_rgb_wire = (video_en) ? video_da_o[23:0] : data_rgb_pg;



// ODDR #(
// 	.DDR_CLK_EDGE		("SAME_EDGE"			), // "OPPOSITE_EDGE" or "SAME_EDGE"
// 	.INIT				(1'b0					), // Initial value of Q: 1'b0 or 1'b1
// 	.SRTYPE				("SYNC"					) // Set/Reset type: "SYNC" or "ASYNC"
// 	) ODDR_inst (
// 	.Q					(CLK1M				), // 1-bit DDR output
// 	.C					(video_clk_o				), // 1-bit clock input
// 	.CE					(1'b1					), // 1-bit clock enable input
// 	.D1					(1'b1					), // 1-bit data input (positive edge)
// 	.D2					(1'b0					), // 1-bit data input (negative edge)
// 	.R					(1'b0					), // 1-bit reset
// 	.S					(1'b0					) // 1-bit set
// 	);

// assign CLK1M = (video_clk_o);
// assign SPI_CS = (VIDEO_VS);
// assign HSNA = (Hsync_wire);
// assign SPI_SDI = (VIDEO_DE);
// assign PWD_PLL = (DE_pg);
//
assign CLK1M = (DE_pg);
assign SPI_CS = (DE_pg);
assign HSNA = (DE_pg);
assign SPI_SDI = (DE_pg);
assign PWD_PLL = (DE_pg);



/**
 * pattern generate data to pixel processor fifo
 */
(*mark_debug = "true"*) wire rd_empty, valid_en;
(*mark_debug = "true"*) wire [RGB_PORT*`RGB_DATA_WIDTH-1:0] rgb2pp_wire;
(*mark_debug = "true"*) wire De_out_wire;
pg2pp_fifo_top #(
	.RGB_PORT				(RGB_PORT)
	) pg2pp_top_inst(
	.wr_clk					(video_clk_wire)			,
	.rd_clk					(ui_clk)			,
	.rst					(pg_frm_st)			,
	.rst_n					(sys_rst_n)			,	// (i) block reset, Low_active

	.Vsync					(Vsync_wire)		,
	.Hsync					(Hsync_wire)		,
	.DE						(DE_wire)			,
	.Din					(data_rgb_wire)		,

	.rd_empty				(rd_empty)			,
	.Vs_out					(),
	.Hs_out					(),
	.De_out					(De_out_wire),

	.valid_en				(valid_en)			,
	.Dout					(rgb2pp_wire)

	);


/**
 * pixel processor top
 */
// (*mark_debug = "true"*) wire [`CACHE_WIDTH-1:0] fifo_dout_wire;
// (*mark_debug = "true"*) wire fifo_valid_wire;
// pixel_processor		pixel_processor_inst(
// 	.clk						(ui_clk)				,	// (i) block Clock
// 	.rst_n						(sys_rst_n)				,	// (i) block reset, Low_active
// 	.rdempty					(rd_empty)				,	// (i)
// 	.valid_en					(valid_en)				,	// (i)
// 	.din						(rgb2pp_wire)			,	// (i)
// 	.en							(De_out_wire)			,	// (i)
// 	.vs							(Vsync_wire)			,	// (o)
//
// 	.fifo_valid					(fifo_valid_wire)		,	// (o)
// 	.fifo_dout					(fifo_dout_wire)			// (o)
// 	);



/*
██████  ██████  ██████  ██████
██   ██ ██   ██ ██   ██      ██
██   ██ ██   ██ ██████   ████��?
██   ██ ██   ██ ██   ██      ██
██████  ██████  ██   ██ ██████
*/
//
// (*mark_debug = "true"*) wire ddr3_wr_finish_wire;
// (*mark_debug = "true"*) wire ddr3_din_en;
// wire [511:0] ddr3_din;
//
// assign ddr3_din_en = (fifo_valid_wire);
// assign ddr3_din = ({fifo_dout_wire,192'b0});
//
// (*mark_debug = "true"*) wire ddr3_dout_req_wire;
// (*mark_debug = "true"*) wire ddr3_dout_valid;
// wire [511:0] ddr3_dout;
//
// mig_ddr3_top    mig_ddr3_top_u(
//     .clk							(clk_200m),
//     .rst_n							(sys_rst_n),
// 	// DDR3 physical interface
// 	.sys_clk_i						(clk_ddr3_i),			// input
// //	.clk_ref_i                      (clk_ref_i),			// input
// 	.sys_rst						(sys_rst_n),		// input
// 	.ddr3_addr						(ddr3_addr),		// output [14:0]
// 	.ddr3_ba                        (ddr3_ba),			// output [2:0]
// 	.ddr3_cas_n                     (ddr3_cas_n),		// output
// 	.ddr3_ck_n                      (ddr3_ck_n),		// output [0:0]
// 	.ddr3_ck_p                      (ddr3_ck_p),		// output [0:0]
// 	.ddr3_cke                       (ddr3_cke),			// output [0:0]
// 	.ddr3_ras_n                     (ddr3_ras_n),		// output
// 	.ddr3_we_n                      (ddr3_we_n),		// output
//
// 	.ddr3_dq                        (ddr3_dq),			// inout [63:0]
// 	.ddr3_dqs_n                     (ddr3_dqs_n),		// inout [7:0]
// 	.ddr3_dqs_p                     (ddr3_dqs_p),		// inout [7:0]
// 	.ddr3_reset_n                   (ddr3_reset_n),		// output
//
// 	.ddr3_cs_n                      (ddr3_cs_n),		// output [0:0]
// 	.ddr3_dm                        (ddr3_dm),			// output [3:0]
// 	.ddr3_odt                       (ddr3_odt),			// output [0:0]
//
// 	.init_calib_complete			(init_calib_complete), // (o)
//
// 	// ui_clk : MIG output for user clock, maybe 200 MHz
// 	.ui_clk                         (ui_clk),			// output
//
// 	// ui_clk_sync_rst : MIG output rst, connect to wire
// 	.ui_clk_sync_rst                (ui_clk_sync_rst),	// output, active high
//
// 	// frame signal
// 	.Vsync							(Vsync_wire),
// 	.Hsync							(Hsync_wire),
// 	.DE								(DE_wire),
//
// 	.ddr3_wr_finish					(ddr3_wr_finish_wire),
// 	// Data flow pin assignment
//     .ddr3_din_en					(ddr3_din_en),
//     .ddr3_din						(ddr3_din),
//
// 	.ddr3_dout_req					(ddr3_dout_req_wire),
// 	.ddr3_dout_valid				(ddr3_dout_valid),
//     .ddr3_dout						(ddr3_dout)
//
//     );
// // End of instance
//
//
// assign LED[5] = (init_calib_complete);



/*
██████  ██████  ██████  ██████  ██████��?  ██████  ████��?  ██��?    ██
██   ██ ██   ██ ██   ██      ██ ██      ██      ██   ██ ████   ██
██   ██ ██   ██ ██████   ████��?  ██████��? ██      ██████��? ██ ██  ██
██   ██ ██   ██ ██   ██ ██           ██ ██      ██   ██ ██  ██ ██
██████  ██████  ██   ██ ██████��? ██████��?  ██████ ██   ██ ██   ████
*/
//
// (*mark_debug = "true"*) wire scan_en_wire;
// (*mark_debug = "true"*) wire rd_en_up_wire, empty_up_wire;
// wire pix_valid_up_wire;
// wire [`DATA_WIDTH-1:0] pix_data_up_wire;
// (*mark_debug = "true"*) wire [6:0]	data_count_up_wire;
// ddr2scan_top		ddr2scan_top_inst(
// 	.clk							(ui_clk),
// 	.rd_clk							(clk_SCLK),
// 	.rst							(ui_clk_sync_rst),	// clear signal, High_active
// 	.rst_n							(sys_rst_n),
//
// 	// frame signal
// 	.Vsync							(Vsync_wire),
// 	.Hsync							(Hsync_wire),
// 	.DE								(DE_wire),
//
// 	// control signal
// 	// .ddr3_wr_finish					(ddr3_wr_finish_wire),
//
// 	.wr_en_t						(ddr3_dout_valid),
// 	.din_t							(ddr3_dout[511:192]),
//
// 	.ddr3_dout_req					(ddr3_dout_req_wire),
//
// 	.scan_en						(scan_en_wire),
//
// 	.rd_en_up						(rd_en_up_wire),
// 	.empty_up						(empty_up_wire),
// 	.pix_valid_up					(pix_valid_up_wire),
// 	.pix_data_up					(pix_data_up_wire),
// 	.data_count_up					(data_count_up_wire)
// 	);
//
//
// /*
// ██████��?  ██████  ████��?  ██��?    ██
// ██      ██      ██   ██ ████   ██
// ██████��? ██      ██████��? ██ ██  ██
//      ██ ██      ██   ██ ██  ██ ██
// ██████��?  ██████ ██   ██ ██   ████
// */
//
// (*mark_debug = "true"*) wire [`DATA_WIDTH-1:0] pix_data_up;
// (*mark_debug = "true"*) wire [7:0] scan_ctrl_up;
// // wire [7:0] row_data_up;
// wire scan_edff_up;
// scan_controller	scan_controller_up(
// 	.clk						(clk_SCLK)				,
// 	.rst_n						(sys_rst_n)				,
// 	.rdusedw					(data_count_up_wire)	,	//	(data_count_up_wire)	,
// 	.rdempty					(empty_up_wire)			,	//	(empty_up_wire)			,
// 	.pixel_data					(pix_data_up_wire)		,
// 	.d63_0						(pix_data_up)			,
// 	.ctrl						(scan_ctrl_up)			,
// 	// .row_data					(row_data_up)			,
// 	.edff						(scan_edff_up)
// );
//
// assign rd_en_up_wire = (scan_edff_up);
//
//
// (*mark_debug = "true"*) wire [7:0] scan_wire = scan_ctrl_up;
//
// /**
//  * for debug
//  */
// (*mark_debug = "true"*) reg scan_edff_up_d0, scan_edff_up_d1, scan_edff_up_d2;
// always @ (posedge clk_SCLK or negedge sys_rst_n ) begin
// 	if ( !sys_rst_n ) begin
// 		scan_edff_up_d0 <= 1'b0;
// 		scan_edff_up_d1 <= 1'b0;
// 		scan_edff_up_d2 <= 1'b0;
// 	end else begin
// 		scan_edff_up_d0 <= scan_edff_up;
// 		scan_edff_up_d1 <= scan_edff_up_d0;
// 		scan_edff_up_d2 <= scan_edff_up_d1;
// 	end
// end
//
// (*mark_debug = "true"*) wire scan_edff_up_pos;
// assign scan_edff_up_pos = (scan_edff_up) & (~scan_edff_up_d0);
//
//
// localparam LINE_NUM = `CHIP_RES_ROW;
//
// (*mark_debug = "true"*) reg [9:0] frame_cnt;
// (*mark_debug = "true"*) reg [4:0] sframe_cnt;
// (*mark_debug = "true"*) reg [9:0] line_cnt;
//
// always @ (posedge clk_SCLK or negedge sys_rst_n ) begin
// 	if ( !sys_rst_n ) begin
// 		frame_cnt <= 10'b0;
// 		sframe_cnt <= 5'b0;
// 		line_cnt <= 10'b0;
// 	end else if ( scan_edff_up_pos && line_cnt == LINE_NUM ) begin
// 		line_cnt <= 10'b1;
// 		if ( sframe_cnt == `PWM_NUM - 1'b1 ) begin
// 			sframe_cnt <= 5'b0;
// 			frame_cnt <= frame_cnt + 1'b1;
// 		end else begin
// 			sframe_cnt <= sframe_cnt + 1'b1;
// 		end
// 	end else if ( scan_edff_up_pos ) begin
// 		line_cnt <= line_cnt + 1'b1;
// 	end else begin
//
// 	end
// end
//
//
//
//
// //	scan test
// wire [31:0] pix_data_test;
// wire		col_start,g1,lrn,col_shift_en,g2,ren,woe,row_data;
// main_code	main_code_inst(
// 	.clk			(clk_SCLK)		,
// 	.rst_n			(sys_rst_n)		,
// 	.rdy			(spi_rdy)		,
// 	.pix_data		(pix_data_test)		,
// 	.col_start		(col_start)		,
// 	.g1				(g1)			,
// 	.lrn			(lrn)			,
// 	.col_shift_en	(col_shift_en)	,
// 	.g2				(g2)			,
// 	.ren			(ren)			,
// 	.woe			(woe)			,
// 	.row_data		(row_data)
// );
//
// wire [ 7:0] ctrl_test = ~{row_data,woe,ren,g2,col_shift_en,lrn,g1,col_start};
// wire [31:0] data_test = ~{pix_data_test};
//
//
// (*mark_debug = "true"*) reg test_en;
// always @ (posedge clk_SCLK or negedge sys_rst_n ) begin
// 	if ( !sys_rst_n ) begin
// 		test_en <= 1'b0;
// 	end else if ( neg_key_auto ) begin	// neg_key_auto need to align clk_SCLK
// 		test_en <= ~test_en;
// 	end else begin
// 		test_en <= test_en;
// 	end
// end
//
//
//
// /*
// ██     ██    ██ ██████  ██████��?      ████████ ██   ██
// ██     ██    ██ ██   ██ ██              ██     ██ ██
// ██     ██    ██ ██   ██ ██████��?         ██      ██��?
// ██      ██  ██  ██   ██      ██         ██     ██ ██
// ██████��?  ████   ██████  ██████��? ██████��? ██    ██   ██
// */
//
// /**
//  * Data Source
//  */
// localparam  P_IO_DW = 8'd5;
//
// /**
//  * lvds_tx_up
//  */
// (*mark_debug = "true"*) wire [7:0] ctrl_ch_up;
// // wire [7:0] row_data_ch_up;
// (*mark_debug = "true"*) wire [`DATA_WIDTH-1:0] data_ch_up;
// (*mark_debug = "true"*) wire [P_IO_DW*8-1:0] lvds_tx_in_up;
//
// assign ctrl_ch_up = test_en ? ctrl_test : (~scan_ctrl_up);
// // assign row_data_ch_up = (row_data_up);
// assign data_ch_up = test_en ? data_test : (~pix_data_up);
// // assign lvds_tx_in_up = ( {ctrl_ch_up, row_data_ch_up, data_ch_up} );
// assign lvds_tx_in_up = ( {ctrl_ch_up, data_ch_up} );
// // assign lvds_tx_in_up = (tx_data);
//
//
// wire lvds_clk_p_up, lvds_clk_n_up;
// wire [P_IO_DW-1:0] lvds_tx_data_p_up, lvds_tx_data_n_up;
// lvds_tx_top #(
// 	.P_IO_DW 					(P_IO_DW)
// 	) lvds_tx_top_up (
// 	// clk&rst
// 	.clk						(clk_200m),
// 	.rst_n						(sys_rst_n),
//
// 	.clk_lvds_tx				(clk_tx_ph180),
// 	.clk_lvds_tx_div			(clk_tx_div),
// 	.tx_dvld					(1'b1),
// 	.tx_data					(lvds_tx_in_up),
//
// 	.lvds_clk_p					(lvds_clk_p_up),
// 	.lvds_clk_n					(lvds_clk_n_up),
// 	.lvds_tx_data_p				(lvds_tx_data_p_up),
// 	.lvds_tx_data_n				(lvds_tx_data_n_up)
// 	);
//
//
// assign LVDS_OUTP = (lvds_tx_data_p_up);
// assign LVDS_OUTN = (lvds_tx_data_n_up);
//
// // assign LVDS_SEP = (clk_SCLK);
// // assign LVDS_SEN = (~clk_SCLK);
// OBUFDS #(
// 	.SLEW				( "FAST"			)   // Specify the output slew rate
// )
// U_OBUFDS_SE (
// 	.O					( LVDS_SEP	),	// Diff_p output (connect directly to top-level port)
// 	.OB					( LVDS_SEN	),	// Diff_n output (connect directly to top-level port)
// 	.I					( ~clk_SCLK_ph180	) 	// Buffer input
// );
//
//
// // assign LVDS_CLKP = (clk_tx_ph180);
// // assign LVDS_CLKN = (~clk_tx_ph180);
// OBUFDS #(
// 	.SLEW				( "FAST"			)   // Specify the output slew rate
// )
// U_OBUFDS_CLK_TX (
// 	.O					( LVDS_CLKP	),	// Diff_p output (connect directly to top-level port)
// 	.OB					( LVDS_CLKN	),	// Diff_n output (connect directly to top-level port)
// 	.I					( ~clk_tx_ph180	) 	// Buffer input
// );
//
// /**
//  * Other Signals
//  */
// // assign RSTNA 	= (1'b1);
// assign LSNA 	= sys_rst_n ? (spi_rdy == 0 ? 1'b1 : 1'b1) : 1'b0;
// assign HSNA 	= sys_rst_n ? (spi_rdy == 0 ? 1'b0 : 1'b1) : 1'b0;
//
// assign TEST_MUX = (1'b0);
//
// assign SEL_0	= (1'b0);
// assign SEL_1	= (1'b1);
//
// assign PWD_PLL 	= (1'b0);
// assign PWD_LVDS	= (1'b0);
//
// // assign RSTNB 	= (1'b0);
// // assign HSNB 	= (1'b0);
// // assign LSNB 	= (1'b0);
//
// assign SPI_MUX 	= (1'b0);
// // assign SPI_CS 	= (1'b1);// clk_SCLK_ph180; // (1'b1);
// // assign SPI_CLK 	= (1'b0);
// // assign SPI_SDI 	= (1'b0);
//
// // assign RSTNA	= (1'b1);
// assign CLK1M 	= (1'b1); // clk_SCLK; // (1'b1);
//
// assign VCOM_EN = (1'b0);
// // assign VLED_EN = (1'b1);
//
// /**
//  * Power manage
//  */
// reg vled_en_tmp;
// always @ (posedge clk_SCLK or negedge rst_n ) begin
// 	if ( !rst_n ) begin
// 		vled_en_tmp <= 1'b0;
// 	end else begin
// 		vled_en_tmp <= 1'b1;
// 	end
// end
// assign VLED_EN = (vled_en_tmp);


endmodule
