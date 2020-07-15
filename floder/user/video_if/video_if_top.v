/**
 * Filename     :       video_if_top.v
 * Date         :       2020-07-07
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-07-07 create basic Version
 */
module video_if_top #(
	parameter POL			=	1'b1,	// setting the polar or the vs and hs
										//			__  	 ___________________
										// 1'b1 : 	  |_____|
										// 		 	   _____
										// 1'b0 :	__|     |___________________
	parameter RGB_MAP_TYP	=	2'b00

	)(
	input 					clk,
	input 					rst_n,
	input 					en,
	input 					VIDEO_CLK,
	input 					VIDEO_VS,
	input 					VIDEO_HS,
	input 					VIDEO_DE,
	input 	[47:0]			VIDEO_DA,

	output 					video_clk_o,
	output 					video_vs_o,
	output 					video_hs_o,
	output 					video_de_o,
	output [47:0]			video_da_o
	);

/**
 * clk in buff
 */
IBUFG U_IBUFG (
	.I  					(VIDEO_CLK			),
	.O  					(s_clk_ibufg		)
	);

BUFG U_BUFG_HDMICLK (
	.I						(s_clk_ibufg			),
	.O						(video_clk_o			)
	);

/**
 * rgb mapping
 */
// rgb[47:0] = {R0[7:0], G0[7:0], B0[7:0], R1[7:0], G1[7:0], B1[7:0]};
// rgb[47:0] = {24'b0, R0[7:0], G0[7:0], B0[7:0]};
reg [47:0] rgb_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rgb_tmp <= 48'b0;
	end else if ( en && RGB_MAP_TYP == 2'b00 ) begin
		rgb_tmp[47:40] <= VIDEO_DA[31:24];	// R0
		rgb_tmp[39:32] <= VIDEO_DA[47:40];	// G0
		rgb_tmp[31:24] <= VIDEO_DA[39:32];	// B0
		rgb_tmp[23:16] <= VIDEO_DA[07:00];	// R1
		rgb_tmp[15:08] <= VIDEO_DA[23:16];	// G1
		rgb_tmp[07:00] <= VIDEO_DA[15:08];	// B1
	end else if ( en && RGB_MAP_TYP == 2'b01) begin
		rgb_tmp[47:40] <= 8'b0;
		rgb_tmp[39:32] <= 8'b0;
		rgb_tmp[31:24] <= 8'b0;
		rgb_tmp[23:16] <= VIDEO_DA[35:28];	// R
		rgb_tmp[15:08] <= VIDEO_DA[23:16];	// G
		rgb_tmp[07:00] <= VIDEO_DA[11:04];	// B
	end else begin
		rgb_tmp <= 48'b0;
	end
end

/**
 * vs hs timing
 */
reg vs_tmp, hs_tmp, de_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		vs_tmp <= 1'b0;
		hs_tmp <= 1'b0;
		de_tmp <= 1'b0;
	end else if ( en && POL == 1'b1) begin
		vs_tmp <= VIDEO_VS;
		hs_tmp <= VIDEO_HS;
		de_tmp <= VIDEO_DE;
	end else if ( en && POL == 1'b0) begin
		vs_tmp <= ~VIDEO_VS;
		hs_tmp <= ~VIDEO_HS;
		de_tmp <= VIDEO_DE;
	end else begin
		vs_tmp <= 1'b0;
		hs_tmp <= 1'b0;
		de_tmp <= 1'b0;
	end
end

/**
 * video data
 */

reg vs_tmp_d0, vs_tmp_d1, vs_tmp_d2, vs_tmp_d3;
reg hs_tmp_d0, hs_tmp_d1, hs_tmp_d2, hs_tmp_d3;
reg de_tmp_d0, de_tmp_d1, de_tmp_d2, de_tmp_d3;
always @ (posedge video_clk_o or negedge rst_n ) begin
	if ( !rst_n ) begin
		vs_tmp_d0 <= 1'b0;
		vs_tmp_d1 <= 1'b0;
		vs_tmp_d2 <= 1'b0;
		vs_tmp_d3 <= 1'b0;
		hs_tmp_d0 <= 1'b0;
		hs_tmp_d1 <= 1'b0;
		hs_tmp_d2 <= 1'b0;
		hs_tmp_d3 <= 1'b0;
		de_tmp_d0 <= 1'b0;
		de_tmp_d1 <= 1'b0;
		de_tmp_d2 <= 1'b0;
		de_tmp_d3 <= 1'b0;
	end else begin
		vs_tmp_d0 <= VIDEO_VS;
		vs_tmp_d1 <= vs_tmp_d0;
		vs_tmp_d2 <= vs_tmp_d1;
		vs_tmp_d3 <= vs_tmp_d2;
		hs_tmp_d0 <= VIDEO_HS;
		hs_tmp_d1 <= hs_tmp_d0;
		hs_tmp_d2 <= hs_tmp_d1;
		hs_tmp_d3 <= hs_tmp_d2;
		de_tmp_d0 <= VIDEO_DE;
		de_tmp_d1 <= de_tmp_d0;
		de_tmp_d2 <= de_tmp_d1;
		de_tmp_d3 <= de_tmp_d2;
	end

end

reg [47:0] da_tmp_d0, da_tmp_d1, da_tmp_d2, da_tmp_d3;
always @ (posedge video_clk_o or negedge rst_n ) begin
	if ( !rst_n ) begin
		da_tmp_d0 <= 1'b0;
		da_tmp_d1 <= 1'b0;
		da_tmp_d2 <= 1'b0;
		da_tmp_d3 <= 1'b0;
	end else begin
		da_tmp_d0 <= VIDEO_DA;
		da_tmp_d1 <= da_tmp_d0;
		da_tmp_d2 <= da_tmp_d1;
		da_tmp_d3 <= da_tmp_d2;
	end
end



assign video_vs_o = (vs_tmp_d3);
assign video_hs_o = (hs_tmp_d3);
assign video_de_o = (de_tmp_d3);
assign video_da_o = (rgb_tmp);


endmodule // end of video_if_top
