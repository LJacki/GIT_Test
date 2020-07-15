`include "../defines.v"
module	scan_ctrl(
		//system signals
		input							clk				,
		input							rst_n			,
		//other signals
		input							ctrl_ena		,
		output   						RSTN			,
		output   						HSN				,
		output	reg						edff			,
		output	reg						edff_un			,
		output							col_start		,
		output	reg						g1				,
		output	reg						lrn				,
		output	reg						col_shift_en	,
		output	reg						g2				,
		output							ren				,
		output							woe				,
		output	reg						row_data
);

//	=================================================================	\
//	************** Define Paramters	and Interal signals**************
//	=================================================================	/
parameter			DFF_CNT_PARAM		=			8'd48	;
parameter			CLEAR_DFF_PARAM		=			8'd48	;

reg				[ 7:0]					dff_cnt				;
reg				[15:0]					row_display			;
reg				[15:0]					row_clear			;
reg				[`PWM_NUM_SIZE-1:0]		field				;
reg										flag_next_field		;

//	============================================================================
//	************************	Main Code	**********************************
//	============================================================================
//	LRN parameter
parameter	SF0 = 45;
parameter	SF1 = 90;
parameter	SF2 = 180;
parameter	SF3 = 360;

/**
 * [dff_cnt description]
 */
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dff_cnt <= 8'b0;
	end else if ( ctrl_ena ) begin
		if ( dff_cnt == DFF_CNT_PARAM -1'b1 ) begin
			dff_cnt <= 8'b0;
		end else begin
			dff_cnt <= dff_cnt + 1'b1;
		end
	end else begin
		dff_cnt <= 8'b0;
	end
end

reg [7:0] dff_cnt_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dff_cnt_tmp <= 8'b0;
	end else begin
		dff_cnt_tmp <= dff_cnt;
	end
end


// //	40clk
// //	1-40
// always@	(posedge clk or negedge rst_n)	begin
// 	if (!rst_n) begin
// 		edff <= 0;
// 	end else if(ctrl_ena) begin
// 		if (dff_cnt >= 1 && dff_cnt <= 40) begin
// 			edff <= 1;
// 		end else begin
// 			edff <= 0;
// 		end
// 	end else begin
// 		edff <= 0;
// 	end
// end
//
// //	45-40
// always@	(posedge clk or negedge rst_n)	begin
// 	if (!rst_n) begin
// 		edff_un <= 0;
// 	end else if (ctrl_ena && (dff_cnt >= 41 || dff_cnt == 0)) begin
// 		edff_un <= 1;
// 	end else begin
// 		edff_un <= 0;
// 	end
// end

/**
 * RSTN
 */
assign RSTN = ctrl_ena;


assign HSN = (~ctrl_ena);


/**
 * column start
 */
// always@	(posedge clk or negedge rst_n)	begin
// 	if (!rst_n) begin
// 		col_start <= 1;
// 	end else if( ctrl_ena && dff_cnt == 0) begin
// 		col_start <= 0;
// 	end else begin
// 		col_start <= 1;
// 	end
// end
assign col_start = (ctrl_ena && dff_cnt == 0) ? 1'b0 : 1'b1;


/**
 * col shift en
 */
always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		col_shift_en <= 0;
	end else if(ctrl_ena) begin	//	0-42
		col_shift_en <= 1;
	end else begin
		col_shift_en <= 0;
	end
end


/*
 ██████   ██
██       ███
██   ███  ██
██    ██  ██
 ██████   ██
*/
reg g1_tmp;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		g1_tmp <= 1'b0;
	end else if (ctrl_ena && dff_cnt == DFF_CNT_PARAM - 1'b1) begin
		g1_tmp <= 1'b1;
	end else begin
		g1_tmp <= 1'b0;
	end
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		g1 <= 0;
	end else begin
		g1 <= g1_tmp;
	end
end


/*
 ██████  ██████
██            ██
██   ███  █████
██    ██ ██
 ██████  ███████
*/
always@	(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		g2 <= 1'b0;
	end else if((dff_cnt == 8'd42) && ctrl_ena) begin
		g2 <= 1'b1;
	end else begin
		g2 <= 1'b0;
	end
end


/**
 * [ren description]
 */
reg ren_tmp, ren_tmp0, ren_tmp1, ren_tmp2;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		ren_tmp <= 1'b0;
	end else if (dff_cnt > 45 && dff_cnt <= 47) begin
		ren_tmp <= 1'b1;
	end else begin
		ren_tmp <= 1'b0;
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		ren_tmp0 <= 1'b0;
		ren_tmp1 <= 1'b0;
		ren_tmp2 <= 1'b0;
	end else begin
		ren_tmp0 <= ren_tmp;
		ren_tmp1 <= ren_tmp0;
		ren_tmp2 <= ren_tmp1;
	end
end

assign ren = (ren_tmp2);

/**
 * [woe description]
 */
reg woe_tmp, woe_tmp0, woe_tmp1, woe_tmp2;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		woe_tmp <= 1'b0;
	end else if (dff_cnt > 45 && dff_cnt <= 47) begin
		woe_tmp <= 1'b1;
	end else begin
		woe_tmp <= 1'b0;
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		woe_tmp0 <= 1'b0;
		woe_tmp1 <= 1'b0;
		woe_tmp2 <= 1'b0;
	end else begin
		woe_tmp0 <= woe_tmp;
		woe_tmp1 <= woe_tmp0;
		woe_tmp2 <= woe_tmp1;
	end
end

assign woe = (woe_tmp2);


/**
 * LRN
 */
reg lrn_ena;
always@	(posedge clk or negedge rst_n)	begin
	if (!rst_n) begin
		lrn_ena <= 0;
	end else if(ctrl_ena) begin
		if ((field == 0 && row_display >= SF0) | (field == 1 && row_display < SF0)) begin
			lrn_ena <= 1;
		end else if ((field == 1 && row_display >= SF1) | (field == 2 && row_display < SF1)) begin
			lrn_ena <= 1;
		end else if ((field == 2 && row_display >= SF2) | (field == 3 && row_display < SF2)) begin
			lrn_ena <= 1;
		end else if ((field == 3 && row_display >= SF3) | (field == 4 && row_display < SF3)) begin
			lrn_ena <= 1;
		end else begin
			lrn_ena <= 0;
		end
	end	else begin
		lrn_ena <= 0;
	end
end

always@	(posedge clk or negedge rst_n)	begin
	if (!rst_n) begin
		lrn <= 0;
	end else if (lrn_ena && dff_cnt == CLEAR_DFF_PARAM - 1'b1) begin
		lrn <= 1;
	end else begin
		lrn <= 0;
	end
end


//	ROW CLEAR
always@	(posedge clk or negedge rst_n)	begin
	if (!rst_n) begin
		row_clear <= 0;
	end else if (lrn) begin
		if (row_clear == `CHIP_RES_ROW - 1) begin
			row_clear <= 0;
		end else begin
			row_clear <= row_clear + 1'b1;
		end
	end else begin
		row_clear <= row_clear;
	end
end

reg [9:0] row_clear_reg;

always@	(posedge clk or negedge rst_n)	begin
		if (!rst_n)
			row_clear_reg <= 0;
		else if (lrn)
			row_clear_reg <= row_clear;
		else
			row_clear_reg <= row_clear_reg;
end

always@	(posedge clk or negedge rst_n)	begin
		if (!rst_n)
			row_display <= 0;
		else if (dff_cnt == DFF_CNT_PARAM - 1)
			if (row_display == `CHIP_RES_ROW - 1)
				row_display <= 0;
			else
				row_display <= row_display + 1'b1;
		else
			row_display <= row_display;
end

reg [9:0] row_display_reg;

always@	(posedge clk or negedge rst_n)	begin
		if (!rst_n)
			row_display_reg <= 0;
		else if (dff_cnt == DFF_CNT_PARAM - 1)
			row_display_reg <= row_display;
		else
			row_display_reg <= row_display_reg;
end

always@	(posedge clk or negedge rst_n)	begin
	if (!rst_n)
		row_data <= 0;
	else if (ctrl_ena)
		case(dff_cnt)
			20	:	row_data <= row_clear_reg[0];
			21	:	row_data <= row_clear_reg[1];
			22	:	row_data <= row_clear_reg[2];
			23	:	row_data <= row_clear_reg[3];
			24	:	row_data <= row_clear_reg[4];
			25	:	row_data <= row_clear_reg[5];
			26	:	row_data <= row_clear_reg[6];
			27	:	row_data <= row_clear_reg[7];
			28	:	row_data <= row_clear_reg[8];
			29	:	row_data <= row_clear_reg[9];

			30	:	row_data <= 1;
			31	:	row_data <= 1;
			32	:	row_data <= 1;
			33	:	row_data <= 1;
			34	:	row_data <= 1;
			35	:	row_data <= 1;
			36	:	row_data <= 1;
			37	:	row_data <= 1;
			38	:	row_data <= 1;
			39	:	row_data <= 1;

			0	:	row_data <= row_display_reg[0];
			1	:	row_data <= row_display_reg[1];
			2	:	row_data <= row_display_reg[2];
			3	:	row_data <= row_display_reg[3];
			4	:	row_data <= row_display_reg[4];
			5	:	row_data <= row_display_reg[5];
			6	:	row_data <= row_display_reg[6];
			7	:	row_data <= row_display_reg[7];
			8	:	row_data <= row_display_reg[8];
			9	:	row_data <= row_display_reg[9];

			10	:	row_data <= 1;
			11	:	row_data <= 1;
			12	:	row_data <= 1;
			13	:	row_data <= 1;
			14	:	row_data <= 1;
			15	:	row_data <= 1;
			16	:	row_data <= 1;
			17	:	row_data <= 1;
			18	:	row_data <= 1;
			19	:	row_data <= 1;

			default:row_data <= 0;
		endcase
	else
		row_data <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
		if (!rst_n)
			flag_next_field <= 0;
		else if (row_display == `CHIP_RES_ROW - 1 && dff_cnt == DFF_CNT_PARAM - 1)
			flag_next_field <= 1;
		else
			flag_next_field <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
		if (!rst_n)
			field <= 0;
		else if (flag_next_field)
			if (field == `PWM_NUM - 1)
				field <= 0;
			else
				field <= field + 1'b1;
		else
			field <= field;
end
endmodule
