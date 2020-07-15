module	scan_init_clr(
	input			clk		,
	input			rst_n	,
	output	reg		clr_op	,
	output	reg		col_start,
	output	reg		col_shift,
	output	reg		lrn,
	output	reg		g1,
	output	reg		g2,
	output	reg		ren,
	output	reg		woe,
	output	reg		row_data
);

reg [9:0] row;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		clr_op <= 1;
	else if(row == 1023)
		clr_op <= 0;
	else
		clr_op <= clr_op;
end

reg [5:0] cnt;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		cnt <= 0;
	else if(clr_op)
		if(cnt == 14)
			cnt <= 0;
		else
			cnt <= cnt + 1'b1;
	else
		cnt <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		col_start <= 0;
	else if(clr_op)
		col_start <= 0;
	else
		col_start <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		col_shift <= 0;
	else if(clr_op)
		col_shift <= 0;
	else
		col_shift <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g1 <= 0;
	else if(clr_op)
		g1 <= 0;
	else
		g1 <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		lrn <= 1;
	else if(clr_op)
		lrn <= 0;
	else
		lrn <= 1;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		g2 <= 0;
	else if(clr_op && cnt == 10)
		g2 <= 1;
	else
		g2 <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ren <= 0;
	else if(clr_op && (cnt > 10 && cnt <= 13))
		ren <= 1;
	else
		ren <= 0;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		woe <= 0;
	else if(clr_op && (cnt > 10 && cnt <= 13))
		woe <= 1;
	else
		woe <= 0;
end


always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		row <= 0;
	else if(clr_op && cnt == 14)
		row <= row + 1'b1;
	else
		row <= row;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		row_data <= 0;
	else if(clr_op)
		case(cnt)
			0	:	row_data <= row[0];
			1	:	row_data <= row[1];
			2	:	row_data <= row[2];
			3	:	row_data <= row[3];
			4	:	row_data <= row[4];
			5	:	row_data <= row[5];
			6	:	row_data <= row[6];
			7	:	row_data <= row[7];
			8	:	row_data <= row[8];
			9	:	row_data <= row[9];
			default: row_data <= 0;
		endcase
	else
		row_data <= 0;
end

endmodule
