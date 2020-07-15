`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/02/18 11:39:06
// Design Name:
// Module Name: clk_rst_top
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


module clk_rst_top(
    input               clk_200m                ,   // (i) System Clock,200 MHz
    input               rst_n                   ,   // (i) External Reset(Low active)

    output              sys_rst_n               ,   // (o) System Reset(Low active)
	output 				clk_100m				,	// (o) output 100 MHz,
	output 				clk_ddr3_i				,	// (o) output 200 MHz,
	output 				clk_spi					,	// (o) output 20 MHz,

	output 				clk_pclk				,	// (o) pclk 148.5 MHz
	output 				clk_pclk_d				,	// (o) pclk 297 MHz

	output 				clk_SCLK				,	// (o) SCAN clock 112.066 MHz
	output 				clk_SCLK_ph180			,	// (o) SCAN clock shift 180 degree
	output 				clk_tx_div				,	// (o) lvds output clk / 4 = 112.066 MHz
	output 				clk_tx					,	// (o) lvds output clk	448.266 MHz
	output 				clk_tx_ph180			,	// (o) lvds output clk shift 180 degree

    output              idelay_ctrl_rdy				// (o)
    );


reg [8:0] poweron_rst_cnt;

always @ ( posedge clk_200m or negedge rst_n ) begin
	if ( !rst_n ) begin
		poweron_rst_cnt <= 9'h1FF;
	end else if ( poweron_rst_cnt[8] == 1'b1 ) begin
		poweron_rst_cnt <= poweron_rst_cnt - 1'b1;
	end else begin
		poweron_rst_cnt <= poweron_rst_cnt;
	end
end


// PLL Reset
wire pll_rst;
assign pll_rst = (poweron_rst_cnt[8]);

// System Reset
wire sys_xrst;
wire pll_lock_0, pll_lock_1, pll_lock_2;
reg [31:0] r_sys_xrst;

// assign sys_xrst = ((~pll_rst) & pll_lock_0 & pll_lock_2);
assign sys_xrst = ((~pll_rst) & (pll_lock_0 & pll_lock_1 & pll_lock_2));

always @ (posedge clk_200m or negedge sys_xrst) begin
	if ( !sys_xrst ) begin
		r_sys_xrst <= 32'b0;
	end else begin
		r_sys_xrst <= {1'b1, r_sys_xrst[31:1]};
	end

end
assign sys_rst_n = (r_sys_xrst[0]);

clk_wiz_0		clk_wiz_inst_u(
	// Clock in ports
	.clk_in1						(clk_200m)		, // (i)
	// Clock out ports
	.clk_100m						(clk_100m)		, // (o) 100 MHz
	.clk_ddr3_i						(clk_ddr3_i)	, // (o) 200 MHz
	.clk_spi						(clk_spi)		, // (o) 20 MHz
	// Status and control signals
	.reset							(pll_rst)		, // (i) PLL Reset, High active
	.locked							(pll_lock_0)

	);

clk_wiz_pclk	clk_wiz_pclk_u(
	// Clock in ports
	.clk_in1						(clk_200m)		, // (i)
	// Clock out ports
	.clk_pclk						(clk_pclk)		, // (o) 148.5MHz
	.clk_pclk_d						(clk_pclk_d)	, // (o) 297MHz
	// Status and control signals
	.reset							(pll_rst)		, // (i) PLL Reset, High active
	.locked							(pll_lock_1)				  // (o)

	);

clk_wiz_lvds_tx clk_wiz_lvds_tx_u(
	// Clock in ports
	.clk_in1						(clk_200m)		,
	// Clock out ports
	.SCLK							(clk_SCLK)		,	// (o) SCAN clock 112.066 MHz
	.SCLK_ph180						(clk_SCLK_ph180),	// (o) SCAN clock shift 180 degree
	.clk_tx_div						(clk_tx_div)	,	// (o) lvds output clk / 4 = 112.066 MHz
	.clk_tx							(clk_tx)		,	// (o) lvds output clk	448.266 MHz
	.clk_tx_ph180					(clk_tx_ph180)	,	// (o) lvds output clk shift 180 degree
	// Status and control signals
	.reset							(pll_rst)		,
	.locked							(pll_lock_2)
    );

//---------------------------------------------------------------------
// Idelay control
//---------------------------------------------------------------------
(* IODELAY_GROUP = " IODELAY_SERDES" *)
IDELAYCTRL #(
	.SIM_DEVICE								( "7SERIES"						)	// Set the device version (7SERIES, ULTRASCALE)
)
U_IDELAYCTRL (
	.RDY									( idelay_ctrl_rdy				),	// 1-bit output: Ready output
	.REFCLK									( clk_ddr3_i							),	// 1-bit input: Reference clock input
	.RST									( pll_rst						)	// 1-bit input: Active high reset input. Asynchronous assert, synchronous deassert to REFCLK.

);


endmodule
