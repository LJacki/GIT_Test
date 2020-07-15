/**
 * Filename     :       lvds_tx_top.v
 * Function     :       lvds_tx_top
 * Date         :       2020-03-19
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-03-19 create basic Version
 */
module lvds_tx_top #(
	parameter 				P_IO_DW = 8'd18
	) (
	// clk&rst
	input 					clk,
	input 					rst_n,

	input 					clk_lvds_tx,
	input 					clk_lvds_tx_div,
	input 					tx_dvld,
	input [P_IO_DW*8-1:0]	tx_data,

	output 					lvds_clk_p,
	output 					lvds_clk_n,
	output [P_IO_DW-1:0]	lvds_tx_data_p,
	output [P_IO_DW-1:0]	lvds_tx_data_n

	);
//
//---------------------------------------------------------------------
// OSERDES Interface
//---------------------------------------------------------------------
wire IO_XRST = rst_n;
wire CLK_IO = clk_lvds_tx;
wire CLK_IO_DIV = clk_lvds_tx_div;

wire IO_CLK_P, IO_CLK_N;
wire [P_IO_DW-1:0] IO_DAT_P, IO_DAT_N;

// reg tx_dvld =  1'b1;
// reg [P_IO_DW*8-1:0] tx_data;
//
// always @ (posedge clk_100m or negedge rst_n ) begin
// 	if ( !rst_n ) begin
// 		tx_data <= 144'hff00_00ff_aa55_55aa_9966_6699_aa55_55aa_55aa;
// 	end else begin
// 		tx_data <= tx_data + 144'h1111_1111_1111_1111_1111_1111_1111_1111_1111;
// 	end
// end

oserdes_if #(
	.DB_W 									( P_IO_DW						)	// data bus width
)
U_OSERDES_IF (
	// clk&rst
	.XRST									( IO_XRST						),	// (i)	System reset signal low active
	.CLK									( CLK_IO						),	// (i)	clock input
	.CLK_DIV								( CLK_IO_DIV					),	// (i)	clock input
	// io signals
	.OSERDES_CLK_P							( IO_CLK_P						),	// (o)	OSERDES clock P
	.OSERDES_CLK_N							( IO_CLK_N						),	// (o)	OSERDES clock N
	.OSERDES_DAT_P							( IO_DAT_P						),	// (o)	OSERDES data P
	.OSERDES_DAT_N							( IO_DAT_N						),	// (o)	OSERDES data N
	// fabric signals to oserdes
	.TX_DVLD								( tx_dvld						),	// (i)	user txdata valid
	.TX_DATA								( tx_data						)	// (i)	user txdata
) ;

assign lvds_clk_p = IO_CLK_P;
assign lvds_clk_n = IO_CLK_N;
assign lvds_tx_data_p = IO_DAT_P;
assign lvds_tx_data_n = IO_DAT_N;

endmodule // the end of lvds_tx_top
