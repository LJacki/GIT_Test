module fifo_ddr3_in (
    input           clk,
    input           rst_n,
    input [511:0]   din,
    input           wr_en,
    input           rd_en,

    output [511:0]  dout,
	output 			valid,
    output          full,
    output          almost_full,
	output 			prog_full,
    output          empty,
    output          almost_empty,
    output [7:0]    data_count
    );

infifo_ddr3		infifo_ddr3_u(
    .srst					(rst_n)						,	// clear signal, High_active
	.clk					(clk)						,
	.din					(din)						,
	.wr_en					(wr_en)						,
	.rd_en					(rd_en)						,
	.full					(full)						,
	.almost_full			(almost_full)				,
	.prog_full				(prog_full)					,
	.empty					(empty)						,
	.almost_empty			(almost_empty)				,
	.dout					(dout)						,
	.valid					(valid)						,
	.data_count 			(data_count)
	);

endmodule // the end of fifo_ddr3_in
