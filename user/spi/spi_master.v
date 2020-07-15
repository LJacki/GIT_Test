module	spi_master(
	input				clk		,
	input				rst_n	,
	input				spi_sdo	,
	output				spi_cs	,
	output				spi_sclk,
	output	reg			spi_sdi	,
	output	reg			spi_rdy
);

parameter	SPI_CYC = 400;
parameter	SPI_CS_SYC = 350;

reg		[ 9:0]		wrt_cnt		;

wire	spi_flag;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		wrt_cnt <= 0;
	else if(spi_flag)
		if(wrt_cnt == SPI_CYC - 1)
			wrt_cnt <= 0;
		else
			wrt_cnt <= wrt_cnt + 1'b1;
	else
		wrt_cnt <= 0;
end

reg		[ 7:0]		spi_state	;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		spi_state <= 0;
	else if(spi_flag)
		if(wrt_cnt == SPI_CYC - 1)
			spi_state <= spi_state + 1'b1;
		else
			spi_state <= spi_state;
	else
		spi_state <= 0;
end

reg [31:0] flag_cnt;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		flag_cnt <= 0;
	else if(spi_flag)
		flag_cnt <= flag_cnt + 1'b1;
	else
		flag_cnt <= flag_cnt;
end

assign spi_flag = (flag_cnt < SPI_CYC * 6 - 1) ? 1'b1 : 1'b0;

assign	spi_cs =  spi_state > 0 ? (wrt_cnt < SPI_CS_SYC ? 1'b0 : 1'b1) : 1'b1;

assign	spi_sclk = ~clk;

//	--------------------------------------------------------------------------------------------
//	ADDR	DATA
//	 00H	xxxxxx01
//	 01H	xxxxxx10
//	 02H	xxxxxx00	ADC ctrl mode
//	 03H	00000000	ADC data
//	 04H	00000000	PLL
//	 05H	xxxxxxx0	RGT, column data shift direction, 1 right->left, 0 left->right

//	0	:	wait
//	1	:	read version, address = 00, data = 01
//	2	:	read version, address = 01, data = 10
//	3	：	write RGT   , address = 05, data = 1 right->left, 0 left->right
//	4	：	write PLL
//	5	:	write POWER and HSN and..

//	--------------------------------------------------------------------------------------------
//	read version 0
reg		spi_sdi_s1;

always@	(*)	begin
	if(spi_state == 8'd1 && spi_flag)
		case(wrt_cnt)
			0		:	spi_sdi_s1 = 1	;	//	1 for read
			//	ADDR
			1		:	spi_sdi_s1 = 0	;	//	addr 6
			2		:	spi_sdi_s1 = 0	;	//	addr 5
			3		:	spi_sdi_s1 = 0	;	//	addr 4
			4		:	spi_sdi_s1 = 0	;	//	addr 3
			5		:	spi_sdi_s1 = 0	;	//	addr 2
			6		:	spi_sdi_s1 = 0	;	//	addr 1
			7		:	spi_sdi_s1 = 0	;	//	addr 0
			default	:	spi_sdi_s1 = 0	;
		endcase
	else
		spi_sdi_s1 = 0;
end

//	--------------------------------------------------------------------------------------------
//	read version 1
reg		spi_sdi_s2;

always@	(*)	begin
	if(spi_state == 8'd2 && spi_flag)
		case(wrt_cnt)
			0		:	spi_sdi_s2 = 1	;	//	1 for read
			//	ADDR
			1		:	spi_sdi_s2 = 0	;	//	addr 6
			2		:	spi_sdi_s2 = 0	;	//	addr 5
			3		:	spi_sdi_s2 = 0	;	//	addr 4
			4		:	spi_sdi_s2 = 0	;	//	addr 3
			5		:	spi_sdi_s2 = 0	;	//	addr 2
			6		:	spi_sdi_s2 = 0	;	//	addr 1
			7		:	spi_sdi_s2 = 1	;	//	addr 0
			default	:	spi_sdi_s2 = 0	;
		endcase
	else
		spi_sdi_s2 = 0;
end

//	--------------------------------------------------------------------------------------------
//	write rgt
//	write from LSB to HSB
reg	spi_sdi_s3;

always@	(*)	begin
	if(spi_state == 8'd3 && spi_flag)
		case(wrt_cnt)
			0		:	spi_sdi_s3 = 0	;	//	0 for write
			//	ADDR
			1		:	spi_sdi_s3 = 0	;	//	addr 6
			2		:	spi_sdi_s3 = 0	;	//	addr 5
			3		:	spi_sdi_s3 = 0	;	//	addr 4
			4		:	spi_sdi_s3 = 0	;	//	addr 3
			5		:	spi_sdi_s3 = 1	;	//	addr 2
			6		:	spi_sdi_s3 = 0	;	//	addr 1
			7		:	spi_sdi_s3 = 1	;	//	addr 0
			//	DATA
			8		:	spi_sdi_s3 = 1	;	//	data 0, RGT, 1 right->left, 0 left->right
			9		:	spi_sdi_s3 = 0	;	//	data 1
			10		:	spi_sdi_s3 = 0	;	//	data 2
			11		:	spi_sdi_s3 = 0	;	//	data 3
			12		:	spi_sdi_s3 = 0	;	//	data 4
			13		:	spi_sdi_s3 = 0	;	//	data 5
			14		:	spi_sdi_s3 = 0	;	//	data 6
			15		:	spi_sdi_s3 = 0	;	//	data 7
			default	:	spi_sdi_s3 = 0	;
		endcase
	else
		spi_sdi_s3 = 0;
end

//	--------------------------------------------------------------------------------------------
//	write 04H, config PLL
reg	spi_sdi_s4;

always@	(*)	begin
	if(spi_state == 8'd4 && spi_flag)
		case(wrt_cnt)
			0		:	spi_sdi_s4 = 0	;	//	0 for write
			//	ADDR
			1		:	spi_sdi_s4 = 0	;	//	addr 6
			2		:	spi_sdi_s4 = 0	;	//	addr 5
			3		:	spi_sdi_s4 = 0	;	//	addr 4
			4		:	spi_sdi_s4 = 0	;	//	addr 3
			5		:	spi_sdi_s4 = 1	;	//	addr 2
			6		:	spi_sdi_s4 = 0	;	//	addr 1
			7		:	spi_sdi_s4 = 0	;	//	addr 0
			//	DATA
			8		:	spi_sdi_s4 = 0	;	//	1 delay 0 clk
			9		:	spi_sdi_s4 = 0	;	//	1 delay 1 clk
			10		:	spi_sdi_s4 = 0	;	//	1 delay 2 clk
			11		:	spi_sdi_s4 = 1	;	//	1 delay 3 clk
			12		:	spi_sdi_s4 = 0	;	//	1 delay 4 clk
			13		:	spi_sdi_s4 = 0	;	//	1 delay 5 clk
			14		:	spi_sdi_s4 = 0	;	//	1 delay 6 clk
			15		:	spi_sdi_s4 = 0	;	//	1 PLL high speed clk revs
			default	:	spi_sdi_s4 = 0	;
		endcase
	else
		spi_sdi_s4 = 0;
end

//	--------------------------------------------------------------------------------------------
//	write 06H, config SEL, POWER, XSN
reg	spi_sdi_s5;

always@	(*)	begin
	if(spi_state == 8'd5 && spi_flag)
		case(wrt_cnt)
			0		:	spi_sdi_s5 = 0	;	//	0 for write
			//	ADDR
			1		:	spi_sdi_s5 = 0	;	//	addr 6
			2		:	spi_sdi_s5 = 0	;	//	addr 5
			3		:	spi_sdi_s5 = 0	;	//	addr 4
			4		:	spi_sdi_s5 = 0	;	//	addr 3
			5		:	spi_sdi_s5 = 1	;	//	addr 2
			6		:	spi_sdi_s5 = 1	;	//	addr 1
			7		:	spi_sdi_s5 = 0	;	//	addr 0
			//	DATA
			8		:	spi_sdi_s5 = 1	;	//	PWD_LVDS
			9		:	spi_sdi_s5 = 0	;	//	LSN
			10		:	spi_sdi_s5 = 0	;	//	HSN
			11		:	spi_sdi_s5 = 1	;	//	PWD_PLL
			12		:	spi_sdi_s5 = 1	;	//	SEL[1]
			13		:	spi_sdi_s5 = 1	;	//	SEL[0]
			14		:	spi_sdi_s5 = 0	;	//	NA
			15		:	spi_sdi_s5 = 0	;	//	NA
			default	:	spi_sdi_s5 = 0	;
		endcase
	else
		spi_sdi_s5 = 0;
end


//	--------------------------------------------------------------------------------------------
//	--------------------------------------------------------------------------------------------
//	--------------------------------------------------------------------------------------------
//	MUX
always@	(*)	begin
	case(spi_state)
		8'd0	:	spi_sdi = 1;
		8'd1	:	spi_sdi = spi_sdi_s1;
		8'd2	:	spi_sdi = spi_sdi_s2;
		8'd3	:	spi_sdi = spi_sdi_s3;
		8'd4	:	spi_sdi = spi_sdi_s4;
//		8'd5	:	spi_sdi = spi_sdi_s5;
		8'd5	:	spi_sdi = 1;
		default	:	spi_sdi = 1;
	endcase
end

//	spi ready signal
reg		spi_flag_1d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		spi_flag_1d <= 0;
	else
		spi_flag_1d <= spi_flag;
end

wire	spi_flag_neg = ~spi_flag && spi_flag_1d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		spi_rdy <= 0;
	else if(spi_flag_neg)
		spi_rdy <= 1;
end

endmodule
