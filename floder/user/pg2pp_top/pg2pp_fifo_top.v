/**
 * Filename     :       pg2pp_fifo_top.v
 * Date         :       2020-03-06
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-03-06 create basic Version
 */
module pg2pp_fifo_top # (
	parameter RGB_PORT	= 08'd01
	)(
	input 						wr_clk			,
	input 						rd_clk			,
	input 						rst				,
	input 						rst_n			,

	input 						Vsync			,
	input 						Hsync			,
	input 						DE				,
	input [RGB_PORT*24-1:0]		Din				,

	output 						rd_empty		,
	output 						Vs_out			,
	output 						Hs_out			,
	output 						De_out			,

	output 						valid_en			,
	output [RGB_PORT*24-1:0]	Dout

	);


wire wr_en, rd_en;
wire [RGB_PORT*24-1:0] din, dout;
wire full, almost_full;
wire wr_ack, overflow;
wire empty, almost_empty;
wire valid, underflow;
wire wr_rst_busy, rd_rst_busy;
wire [8:0] wr_data_count;

assign wr_en = (DE && !full);
assign din = (Din);

assign rd_en = (!empty);


fifo_p2pp		fifo_p2pp_inst(
    .rst 						(rst)			,		// clear signal, High_active
    .wr_clk 					(wr_clk)		,
    .rd_clk 					(rd_clk)		,
    .din 						(din)			,
    .wr_en 						(wr_en)			,
    .rd_en 						(rd_en)			,
    .dout 						(dout)			,
    .full 						(full)			,
    .almost_full 				(almost_full)	,
    .wr_ack 					(wr_ack)		,
    .overflow 					(overflow)		,
    .empty 						(empty)			,
    .almost_empty 				(almost_empty)	,
    .valid 						(valid)			,
    .underflow 					(underflow)		,
	.wr_data_count				(wr_data_count)	,
    .wr_rst_busy 				(wr_rst_busy)	,
    .rd_rst_busy 				(rd_rst_busy)
  );

assign rd_empty = (empty);
assign valid_en = (valid);

assign Dout = (dout);


/**
 * DE_delay
 */
parameter DELAY_CNT = 8'd6;
parameter DELAY_NUM = DELAY_CNT + 1'b1;
wire sig_in;
wire sig_out;
reg [DELAY_NUM-1:0] sig_shift;

always @ (posedge wr_clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		sig_shift <= {DELAY_NUM{1'b0}};
	end else begin
		sig_shift <= {sig_shift[DELAY_NUM-2:0], sig_in};
	end
end

assign sig_in = (DE);
assign sig_out = (sig_shift[DELAY_NUM-1]);

assign De_out = (sig_out);


endmodule // end of pg2pp_top
