`include "../defines.v"
module ctrl_ddr3_addr_test (
    input                       clk     ,
    input                       rst_n   ,

    input                       Vsync   ,
    input                       Hsync   ,
    input                       DE      ,

    input                       ddr3_din_en  ,
    input [`CACHE_WIDTH-1:0]    ddr3_din,

    output                      ddr3_wr_en,
    output [`MEM_ADDR_SIZE-1:0] ddr3_wr_addr,
    output [`CACHE_WIDTH-1:0]   ddr3_wr_data,

	input 						ddr3_dout_req_i,
	output 						ddr3_dout_req_o,
	output [`MEM_ADDR_SIZE-1:0] ddr3_rd_addr

    );

/*
██     ██ ██████           █████  ██████  ██████  ██████
██     ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██  █  ██ ██████          ███████ ██   ██ ██   ██ ██████
██ ███ ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
 ███ ███  ██   ██ ███████ ██   ██ ██████  ██████  ██   ██
*/

reg [`MEM_ADDR_SIZE:0] wr_addr_real;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        wr_addr_real <= 28'h000_0100;// {`MEM_ADDR_SIZE{1'b0}};
    end else if (ddr3_din_en) begin
        wr_addr_real <= wr_addr_real + `BURST_LENGTH;
    end else begin
		wr_addr_real <= wr_addr_real;
	end
end

assign ddr3_wr_addr = (wr_addr_real);	// ddr3_din_en_d1 ? wr_addr_real : {`MEM_ADDR_SIZE{1'b0}};

/**
 * for output sync to ddr3_wr_addr
 */
reg ddr3_din_en_d0, ddr3_din_en_d1;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_din_en_d0 <= 1'b0;
        ddr3_din_en_d1 <= 1'b0;
    end else begin
        ddr3_din_en_d0 <= ddr3_din_en;
        ddr3_din_en_d1 <= ddr3_din_en_d0;
    end
end
assign ddr3_wr_en = (ddr3_din_en_d0);


reg [`CACHE_WIDTH-1:0] ddr3_din_d0, ddr3_din_d1;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_din_d0 <= {`CACHE_WIDTH{1'b0}};
        ddr3_din_d1 <= {`CACHE_WIDTH{1'b0}};
    end else begin
        ddr3_din_d0 <= ddr3_din;
        ddr3_din_d1 <= ddr3_din_d0;
    end
end

assign ddr3_wr_data = (ddr3_din_d0);



/*
██████  ██████           █████  ██████  ██████  ██████
██   ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██████  ██   ██         ███████ ██   ██ ██   ██ ██████
██   ██ ██   ██         ██   ██ ██   ██ ██   ██ ██   ██
██   ██ ██████  ███████ ██   ██ ██████  ██████  ██   ██
*/

reg [`MEM_ADDR_SIZE-1:0] rd_addr_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		rd_addr_tmp <= 28'h000_0100;// {`MEM_ADDR_SIZE{1'b0}};
	end else if ( ddr3_dout_req_i ) begin
		rd_addr_tmp <= rd_addr_tmp + `BURST_LENGTH; // 28'h000_0010;
	end else begin
		rd_addr_tmp <= rd_addr_tmp;	// pay more attention here;
	end
end

assign ddr3_rd_addr = rd_addr_tmp;

/**
 * for output sync to ddr3_rd_addr
 */
reg ddr3_dout_req0, ddr3_dout_req1;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ddr3_dout_req0 <= 1'b0;
        ddr3_dout_req1 <= 1'b0;
    end else begin
        ddr3_dout_req0 <= ddr3_dout_req_i;
        ddr3_dout_req1 <= ddr3_dout_req0;
    end
end
assign ddr3_dout_req_o = (ddr3_dout_req0);

endmodule // the end of ctrl_ddr3_addr
