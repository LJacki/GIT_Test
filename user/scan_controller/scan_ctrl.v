`include "../defines.v"
module	scan_ctrl(
		//system signals
		input							clk				,
		input							rst_n			,
		//other signals
		input							ctrl_ena		,
		output	reg						edff			,
		output	reg						edff_un			,
		output	reg						col_start		,
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
parameter			DFF_CNT_PARAM		=			45		;	//	40+2+2+1=42
parameter			CLEAR_DFF_PARAM		=			20		;

reg				[ 7:0]					dff_cnt				;
reg				[`DATA_WIDTH-1:0]		row_display			;
reg				[`DATA_WIDTH-1:0]		row_clear			;
reg				[`PWM_NUM_SIZE-1:0]		field				;
reg										flag_next_field		;

//	============================================================================
//	************************	Main Code	**********************************
//	============================================================================
//	LRN
parameter	SF0 = 45;
parameter	SF1 = 90;
parameter	SF2 = 180;
parameter	SF3 = 360;

//	DFF_CNT
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			dff_cnt <= 0;
		else if(ctrl_ena)	begin
			if(dff_cnt == DFF_CNT_PARAM - 1)
				dff_cnt <= 0;
			else
				dff_cnt <= dff_cnt + 1'b1;
		end
		else
			dff_cnt <= 0;
end

//	40clk
//	1-40
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			edff <= 0;
		else if(ctrl_ena)
			if(dff_cnt >= 1 && dff_cnt <= 40)
				edff <= 1;
			else
				edff <= 0;
		else
			edff <= 0;
end

//	45-40
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			edff_un <= 0;
		else if(ctrl_ena && (dff_cnt >= 41 || dff_cnt == 0))
			edff_un <= 1;
		else
			edff_un <= 0;
end

// column start
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			col_start <= 0;
		else if(ctrl_ena && dff_cnt == 0)
			col_start <= 1;
		else
			col_start <= 0;
end

//	shift_en
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			col_shift_en <= 0;
		else if(ctrl_ena && (dff_cnt <= 42))	//	0-42
			col_shift_en <= 1;
		else
			col_shift_en <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g1 <= 0;
	else if(ctrl_ena && dff_cnt == DFF_CNT_PARAM - 1)
		g1 <= 1;
	else
		g1 <= 0;
end

reg lrn_ena;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g2 <= 0;
	else if(dff_cnt == 10 || dff_cnt == 20 || ((dff_cnt == 30 || dff_cnt == 40) && lrn_ena))
		g2 <= 1;
	else
		g2 <= 0;
end

reg ren_reg,ren_1d,ren_2d,ren_3d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren_reg <= 0;
	else if(g2)
		ren_reg <= 1;
	else
		ren_reg <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren_1d <= 0;
	else
		ren_1d <= ren_reg;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren_2d <= 0;
	else
		ren_2d <= ren_1d;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren_3d <= 0;
	else
		ren_3d <= ren_2d;
end

assign ren = ren_reg || ren_1d || ren_2d || ren_3d;
assign woe = ren_reg || ren_1d || ren_2d || ren_3d;

//	LRN

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			lrn_ena <= 0;
		else if(ctrl_ena)	begin
			if((field == 0 && row_display >= SF0) | (field == 1 && row_display < SF0))
				lrn_ena <= 1;
			else if((field == 1 && row_display >= SF1) | (field == 2 && row_display < SF1))
				lrn_ena <= 1;
			else if((field == 2 && row_display >= SF2) | (field == 3 && row_display < SF2))
				lrn_ena <= 1;
			else if((field == 3 && row_display >= SF3) | (field == 4 && row_display < SF3))
				lrn_ena <= 1;
			else
				lrn_ena <= 0;
		end
		else
			lrn_ena <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			lrn <= 0;
		else if(lrn_ena && dff_cnt == CLEAR_DFF_PARAM - 1)
			lrn <= 1;
		else
			lrn <= 0;
end

//	ROW CLEAR
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			row_clear <= 0;
		else if(lrn)
			if(row_clear == `CHIP_RES_ROW - 1)
				row_clear <= 0;
			else
				row_clear <= row_clear + 1'b1;
		else
			row_clear <= row_clear;
end

reg [9:0] row_clear_reg;

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			row_clear_reg <= 0;
		else if(lrn)
			row_clear_reg <= row_clear;
		else
			row_clear_reg <= row_clear_reg;
end

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			row_display <= 0;
		else if(dff_cnt == DFF_CNT_PARAM - 1)
			if(row_display == `CHIP_RES_ROW - 1)
				row_display <= 0;
			else
				row_display <= row_display + 1'b1;
		else
			row_display <= row_display;
end

reg [9:0] row_display_reg;

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			row_display_reg <= 0;
		else if(dff_cnt == DFF_CNT_PARAM - 1)
			row_display_reg <= row_display;
		else
			row_display_reg <= row_display_reg;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		row_data <= 0;
	else if(ctrl_ena)
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
		if(!rst_n)
			flag_next_field <= 0;
		else if(row_display == `CHIP_RES_ROW - 1 && dff_cnt == DFF_CNT_PARAM - 1)
			flag_next_field <= 1;
		else
			flag_next_field <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			field <= 0;
		else if(flag_next_field)
			if(field == `PWM_NUM - 1)
				field <= 0;
			else
				field <= field + 1'b1;
		else
			field <= field;
end

endmodule //  the end of scan_ctrl
