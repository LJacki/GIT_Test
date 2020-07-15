/**
 * Filename     :       delay_top.v
 * Date         :       2019-02-20
 *
 * Version      :       V 0.1
 *
 * Modification history
 *
 */
module delay_top(
	input			clk,
	input			rst_n,
	input 			signal_in,
	input	[4:0]	delay_num,

	output			signal_out
	);
//
//reg signal_in;
//reg [7:0] delay_num;
//
//wire signal_out;

/**
 *	use shift to delay the singal in
 */
reg [31:0] signal_shift;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		signal_shift <= 32'b00;
	end else begin
		signal_shift <= {signal_shift[30:0], signal_in};
	end
end

/**
 *	use delay_num to output the singal
 */
reg signal_out_tmp;
always @ ( posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		signal_out_tmp <= 1'b0;
	end else begin
		signal_out_tmp <= signal_shift[delay_num - 1'b1];
	end
end

assign signal_out = (delay_num == 4'b0) ? signal_in : signal_out_tmp;

endmodule //	delay_top
