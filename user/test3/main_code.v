module	main_code(
	input						clk			,
	input						rst_n		,
	input						rdy			,
	output	reg		[31:0]		pix_data	,
	output	reg					col_start	,
	output	reg					g1			,
	output	reg					lrn			,
	output	reg					col_shift_en,
	output	reg					g2			,
	output							ren			,
	output							woe			,
	output	reg					row_data
);

reg	rdy_1d,rdy_2d;

always @(posedge clk or negedge rst_n)	begin
	if(!rst_n)	begin
		rdy_1d <= 0;
		rdy_2d <= 0;
	end
	else	begin
		rdy_1d <= rdy;
		rdy_2d <= rdy_1d;
	end
end

wire sen = rdy_2d;

//	resolution 1280*720
//	data width 64bits
//	divided 42clks into 2 phases, blanking phase(0-20) and display phase(21-41)
//	each phase is assigned 21clks
//	row data transfer in the first 10clks
//	and in 11clk g2 opens
//	ren and woe valid after the column data getting ready
reg			[31:0]		cnt	;	//	40clk + 2clk + 2clk

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		cnt <= 0;
	else if(sen)
		if(cnt == 43)
			cnt <= 0;
		else
			cnt <= cnt + 1'b1;
	else
		cnt <= 0;
end

//	output cmd
always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		col_start <= 0;
	else if(sen && cnt == 0)
		col_start <= 1;
	else
		col_start <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		col_shift_en <= 0;
	else if(sen && cnt <= 41)
		col_shift_en <= 1;
	else
		col_shift_en <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g1 <= 0;
	else if(sen && cnt == 43)
		g1 <= 1;
	else
		g1 <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		lrn <= 0;
	else if(sen)
			lrn <= 1;
	else
		lrn <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g2 <= 0;
	else if(sen && cnt == 31)
		g2 <= 1;
	else
		g2 <= 0;
end

//	According to the post-simulaton, the worst case of WL delay is 3.45ns,
//	so the clock capability is at least 300Mhz
reg ren_reg,ren_1d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren_reg <= 0;
	else if(g1 == 1)
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

assign ren = ren_reg || ren_1d;
assign woe = ren_reg || ren_1d;

//	row data
reg [9:0]	row_dis;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		row_dis <= 0;
	else if(sen && cnt == 43)
		if(row_dis == 719)
			row_dis <= 0;
		else
			row_dis <= row_dis + 1'b1;
	else
		row_dis <= row_dis;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		row_data <= 0;
	else if(sen)
		case(cnt)
			21	:	row_data <= row_dis[0];
			22	:	row_data <= row_dis[1];
			23	:	row_data <= row_dis[2];
			24	:	row_data <= row_dis[3];
			25	:	row_data <= row_dis[4];
			26	:	row_data <= row_dis[5];
			27	:	row_data <= row_dis[6];
			28	:	row_data <= row_dis[7];
			29	:	row_data <= row_dis[8];
			30	:	row_data <= row_dis[9];
			default:row_data <= 0;
		endcase
	else
		row_data <= 0;
end

reg [31:0] one_row_cnt;

parameter NUM = 44 * 20_00;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		one_row_cnt <= 0;
	else if(sen)
		if(one_row_cnt == NUM - 1)
			one_row_cnt <= 0;
		else
			one_row_cnt <= one_row_cnt + 1'b1;
	else
		one_row_cnt <= 0;
end

reg [9:0] one_row;

always@ (posedge clk or negedge rst_n)	begin
	if(!rst_n)
		one_row <= 0;
	else if(one_row_cnt == NUM - 1)
		if(one_row == 719)
			one_row <= 0;
		else
			one_row <= one_row + 1'b1;
end

//	pixel data
always@ (posedge clk or negedge rst_n)	begin
	if(!rst_n)
		pix_data <= 0;
	else if(sen)
		if(row_dis == one_row)
//			if(cnt >= 0 && cnt < 10)
				pix_data <= 32'hffff_ffff;
			else
				pix_data <= 32'h0000_0000;
//		else
//			pix_data <= 0;
	else
		pix_data <= 0;
end

endmodule
