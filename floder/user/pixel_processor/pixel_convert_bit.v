`include "../defines.v"
module	pixel_convert_bit(
		//system signals
		input								clk			,
		input								rst_n		,
		//others signals
		input								din			,
		input								en			,
		output	reg	[`CACHE_WIDTH-1:0]		dout		,
		output	reg							oe
);

/**
 * stroe din cnt
 */
reg	[`CACHE_WIDTH-1:0]	cache;
reg	[`CNT_SIZE-1:0]	cnt;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		cnt <= 0;
	end else if( en ) begin
		if ( cnt == `CNT_WIDTH - 1'b1 ) begin
			cnt <= 0;
		end else begin
			cnt <= cnt + 1'b1;
		end
	end
end

reg oe_pre;
always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		oe_pre <= 0;
	end else if( en && cnt == `CNT_WIDTH - 1'b1) begin
		oe_pre <= 1;
	end else begin
		oe_pre <= 0;
	end
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		cache <= 0;
	end else if(en) begin
		// cache <= {din,cache[`CACHE_WIDTH-1:1]} ;
		cache <= {cache[`CACHE_WIDTH-2:0], din} ;
	end
end

/**
 * output oe and data
 */
always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		dout <= 0;
	end else if( oe_pre ) begin
		dout <= cache;
	end
end

always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		oe <= 1'b0;
	end else begin
		oe <= oe_pre;
	end
end


endmodule
