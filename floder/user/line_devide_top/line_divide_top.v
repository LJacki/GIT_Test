/**
 * Filename     :       line_divide_top.v
 * Date         :       2020-05-25
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-05-25 create basic Version
 */
`include "../defines.v"
module line_divide_top (
	input 						clk,
	input 						rst_n,
	input 						srst,

	output 						rd_en_up,		// 1 clk before pix_valid;
	input 						empty_up,
	input 						pix_valid_up,
	input [`DATA_WIDTH-1:0]		pix_data_up,
	input [9:0]					data_count_up,

	output 						rd_en_down,		// 1 clk before pix_valid;
	input 						empty_down,
	input 						pix_valid_down,
	input [`DATA_WIDTH-1:0]		pix_data_down,
	input [9:0]					data_count_down,

	input 						rd_en4scan_up,
	output 						empty2scan_up,
	output 						pix_valid2scan_up,
	output [`DATA_WIDTH-1:0]	pix_data2scan_up,
	output [6:0]				data_count2scan_up,

	input 						rd_en4scan_down,
	output 						empty2scan_down,
	output 						pix_valid2scan_down,
	output [`DATA_WIDTH-1:0]	pix_data2scan_down,
	output [6:0]				data_count2scan_down

	);


assign rd_en_up = (!empty_up);
assign rd_en_down = (!empty_down);



line_divide 		line_divide_up (
	.clk							(clk),
	.rst_n							(rst_n),
	.rd_en							(rd_en_up),
	.pix_valid						(pix_valid_up),
	.pix_data						(pix_data_up),

	.pix_valid_o					(pix_valid_o_up),
	.pix_data_o						(pix_data_o_up)

	);


line_divide 		line_divide_down (
	.clk							(clk),
	.rst_n							(rst_n),
	.rd_en							(rd_en_down),
	.pix_valid						(pix_valid_down),
	.pix_data						(pix_data_down),

	.pix_valid_o					(pix_valid_o_down),
	.pix_data_o						(pix_data_o_down)

	);


wire [`DATA_WIDTH-1:0] fifo_ld2scan_up_din, fifo_ld2scan_up_dout;
wire fifo_ld2scan_up_wr_en, fifo_ld2scan_up_rd_en;
wire fifo_ld2scan_up_full, fifo_ld2scan_up_almost_full;
wire fifo_ld2scan_up_wr_ack, fifo_ld2scan_up_overflow;
wire fifo_ld2scan_up_empty, fifo_ld2scan_up_almost_empty;
wire fifo_ld2scan_up_valid,	fifo_ld2scan_up_underflow;
wire [6:0] fifo_ld2scan_up_data_count;

assign fifo_ld2scan_up_wr_en = (pix_valid_o_up);
assign fifo_ld2scan_up_din = (pix_data_o_up);

assign fifo_ld2scan_up_rd_en = (rd_en4scan_up);
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_ld2scan fifo_ld2scan_up (
	.clk(clk),                    					// input wire clk
	.srst(srst),                  					// input wire srst
	.din(fifo_ld2scan_up_din),                    	// input wire [127 : 0] din
	.wr_en(fifo_ld2scan_up_dout),                	// input wire wr_en
	.rd_en(fifo_ld2scan_up_rd_en),                	// input wire rd_en
	.dout(fifo_ld2scan_up_dout),                  	// output wire [127 : 0] dout
	.full(fifo_ld2scan_up_full),                  	// output wire full
	.almost_full(fifo_ld2scan_up_almost_full),    	// output wire almost_full
	.wr_ack(fifo_ld2scan_up_wr_ack),              	// output wire wr_ack
	.overflow(fifo_ld2scan_up_overflow),          	// output wire overflow
	.empty(fifo_ld2scan_up_empty),                	// output wire empty
	.almost_empty(fifo_ld2scan_up_almost_empty),  	// output wire almost_empty
	.valid(fifo_ld2scan_up_valid),                	// output wire valid
	.underflow(fifo_ld2scan_up_underflow),			// output wire underflow
	.data_count(fifo_ld2scan_up_data_count)			// output wire [6 : 0] data_count
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

assign pix_valid2scan_up = (fifo_ld2scan_up_valid);
assign pix_data2scan_up = (fifo_ld2scan_up_dout);
assign empty2scan_up = (fifo_ld2scan_up_empty);
assign data_count2scan_up = (fifo_ld2scan_up_data_count);




wire [`DATA_WIDTH-1:0] fifo_ld2scan_down_din, fifo_ld2scan_down_dout;
wire fifo_ld2scan_down_wr_en, fifo_ld2scan_down_rd_en;
wire fifo_ld2scan_down_full, fifo_ld2scan_down_almost_full;
wire fifo_ld2scan_down_wr_ack, fifo_ld2scan_down_overflow;
wire fifo_ld2scan_down_empty, fifo_ld2scan_down_almost_empty;
wire fifo_ld2scan_down_valid,	fifo_ld2scan_down_underflow;
wire [6:0] fifo_ld2scan_down_data_count;

assign fifo_ld2scan_down_wr_en = (pix_valid_o_down);
assign fifo_ld2scan_down_din = (pix_data_o_down);

assign fifo_ld2scan_down_rd_en = (rd_en4scan_down);
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_ld2scan fifo_ld2scan_down (
	.clk(clk),                    					// input wire clk
	.srst(srst),                  					// input wire srst
	.din(fifo_ld2scan_down_din),                    	// input wire [127 : 0] din
	.wr_en(fifo_ld2scan_down_dout),                	// input wire wr_en
	.rd_en(fifo_ld2scan_down_rd_en),                	// input wire rd_en
	.dout(fifo_ld2scan_down_dout),                  	// output wire [127 : 0] dout
	.full(fifo_ld2scan_down_full),                  	// output wire full
	.almost_full(fifo_ld2scan_down_almost_full),    	// output wire almost_full
	.wr_ack(fifo_ld2scan_down_wr_ack),              	// output wire wr_ack
	.overflow(fifo_ld2scan_down_overflow),          	// output wire overflow
	.empty(fifo_ld2scan_down_empty),                	// output wire empty
	.almost_empty(fifo_ld2scan_down_almost_empty),  	// output wire almost_empty
	.valid(fifo_ld2scan_down_valid),                	// output wire valid
	.underflow(fifo_ld2scan_down_underflow),			// output wire underflow
	.data_count(fifo_ld2scan_down_data_count)			// output wire [6 : 0] data_count
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

assign pix_valid2scan_down = (fifo_ld2scan_down_valid);
assign pix_data2scan_down = (fifo_ld2scan_down_dout);
assign empty2scan_down = (fifo_ld2scan_down_empty);
assign data_count2scan_down = (fifo_ld2scan_down_data_count);






endmodule // the end of line_divide_top
