`include "../defines.v"
module	pixel_convert_sel(
		input							clk				,
		input							rst_n			,
		input							en				,
		input		[`CACHE_WIDTH-1:0]	din_b18			,
		input		[`CACHE_WIDTH-1:0]	din_b17			,
		input		[`CACHE_WIDTH-1:0]	din_b16			,
		input		[`CACHE_WIDTH-1:0]	din_b15			,
		input		[`CACHE_WIDTH-1:0]	din_b14			,
		input		[`CACHE_WIDTH-1:0]	din_b13			,
		input		[`CACHE_WIDTH-1:0]	din_b12			,
		input		[`CACHE_WIDTH-1:0]	din_b11			,
		input		[`CACHE_WIDTH-1:0]	din_b10			,
		input		[`CACHE_WIDTH-1:0]	din_b9			,
		input		[`CACHE_WIDTH-1:0]	din_b8			,
		input		[`CACHE_WIDTH-1:0]	din_b7			,
		input		[`CACHE_WIDTH-1:0]	din_b6			,
		input		[`CACHE_WIDTH-1:0]	din_b5			,
		input		[`CACHE_WIDTH-1:0]	din_b4			,
		input		[`CACHE_WIDTH-1:0]	din_b3			,
		input		[`CACHE_WIDTH-1:0]	din_b2			,
		input		[`CACHE_WIDTH-1:0]	din_b1			,
		input		[`CACHE_WIDTH-1:0]	din_b0			,
		output	reg	[`CACHE_WIDTH-1:0]	dout			,
		output	reg						oe
);

reg en_ff1 ;
reg en_ff2 ;
reg en_ff3 ;
reg en_ff4 ;
reg en_ff5 ;
reg en_ff6 ;
reg en_ff7 ;
reg en_ff8 ;
reg en_ff9 ;
reg en_ff10;
reg en_ff11;
reg en_ff12;
reg en_ff13;
reg en_ff14;
reg en_ff15;
reg en_ff16;
reg en_ff17;
reg en_ff18;
reg en_ff19;
reg en_ff20;
reg en_ff21;
reg en_ff22;
reg en_ff23;
reg en_ff24;
reg en_ff25;
reg en_ff26;
reg en_ff27;
reg en_ff28;
reg en_ff29;
reg en_ff30;
reg en_ff31;
reg en_ff32;
reg en_ff33;
reg en_ff34;

always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff1  <= 0; else en_ff1  <= en;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff2  <= 0; else en_ff2  <= en_ff1 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff3  <= 0; else en_ff3  <= en_ff2 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff4  <= 0; else en_ff4  <= en_ff3 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff5  <= 0; else en_ff5  <= en_ff4 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff6  <= 0; else en_ff6  <= en_ff5 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff7  <= 0; else en_ff7  <= en_ff6 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff8  <= 0; else en_ff8  <= en_ff7 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff9  <= 0; else en_ff9  <= en_ff8 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff10 <= 0; else en_ff10 <= en_ff9 ;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff11 <= 0; else en_ff11 <= en_ff10;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff12 <= 0; else en_ff12 <= en_ff11;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff13 <= 0; else en_ff13 <= en_ff12;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff14 <= 0; else en_ff14 <= en_ff13;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff15 <= 0; else en_ff15 <= en_ff14;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff16 <= 0; else en_ff16 <= en_ff15;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff17 <= 0; else en_ff17 <= en_ff16;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff18 <= 0; else en_ff18 <= en_ff17;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff19 <= 0; else en_ff19 <= en_ff18;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff20 <= 0; else en_ff20 <= en_ff19;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff21 <= 0; else en_ff21 <= en_ff20;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff22 <= 0; else en_ff22 <= en_ff21;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff23 <= 0; else en_ff23 <= en_ff22;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff24 <= 0; else en_ff24 <= en_ff23;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff25 <= 0; else en_ff25 <= en_ff24;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff26 <= 0; else en_ff26 <= en_ff25;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff27 <= 0; else en_ff27 <= en_ff26;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff28 <= 0; else en_ff28 <= en_ff27;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff29 <= 0; else en_ff29 <= en_ff28;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff30 <= 0; else en_ff30 <= en_ff29;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff31 <= 0; else en_ff31 <= en_ff30;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff32 <= 0; else en_ff32 <= en_ff31;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff33 <= 0; else en_ff33 <= en_ff32;
always@ (posedge clk or negedge rst_n) if(!rst_n) en_ff34 <= 0; else en_ff34 <= en_ff33;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		oe <= 0;
	else if(en|en_ff1|en_ff2|en_ff3|en_ff4|en_ff5|en_ff6|en_ff7|en_ff8|en_ff9|en_ff10|en_ff11|en_ff12|en_ff13
				 |en_ff14|en_ff15|en_ff16|en_ff17|en_ff18)
		oe <= 1;
	else
		oe <= 0;
end

//	output BIT0 first
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)				dout <= 0;
		else if(en)	dout <= din_b0;
		else if(en_ff1 )	dout <= din_b1;
		else if(en_ff2 )	dout <= din_b2;
		else if(en_ff3 )	dout <= din_b3;
		else if(en_ff4 )	dout <= din_b4;
		else if(en_ff5 )	dout <= din_b5;
		else if(en_ff6 )	dout <= din_b6;
		else if(en_ff7 )	dout <= din_b7;
		else if(en_ff8 )	dout <= din_b8;
		else if(en_ff9 )	dout <= din_b9;
		else if(en_ff10)	dout <= din_b10;
		else if(en_ff11)	dout <= din_b11;
		else if(en_ff12)	dout <= din_b12;
		else if(en_ff13)	dout <= din_b13;
		else if(en_ff14)	dout <= din_b14;
		else if(en_ff15)	dout <= din_b15;
		else if(en_ff16)	dout <= din_b16;
		else if(en_ff17)	dout <= din_b17;
		else if(en_ff18)	dout <= din_b18;
		else					dout <= 0;
end

endmodule
