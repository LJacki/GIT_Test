/**
 * Filename     :       key_detect_top.v
 * Date         :       2019-03-04
 *
 * Version      :       V 0.1
 *
 * Modification history
 *
 */
module key_detect_top(
	input			clk,
	input			rst_n,
	input	[3:0]	key_in,
	
	output	[3:0]	key_out

	);
/**
 * key_up to change the pattern, detect the negedge of the key_up
 */
key_detect key_detect_up(
	.clk(clk),
	.rst_n(rst_n),

	.initial_status(1'b1),
	.key_in(key_in[0]),
	.key_out(key_out[0])
	);

/**
 * key_down to change the pattern, detect the negedge of key_down
 */
key_detect key_detect_down(
	.clk(clk),
	.rst_n(rst_n),

	.initial_status(1'b1),
	.key_in(key_in[1]),
	.key_out(key_out[1])
	);

/**
 * key_sel to change the pattern, detect the negedge of key_sel
 */
key_detect key_detect_sel(
	.clk(clk),
	.rst_n(rst_n),

	.initial_status(1'b1),
	.key_in(key_in[2]),
	.key_out(key_out[2])
	);

/**
 * key_auto to change the pattern, detect the negedge of key_auto
 */
key_detect key_detect_auto(
	.clk(clk),
	.rst_n(rst_n),

	.initial_status(1'b1),
	.key_in(key_in[3]),
	.key_out(key_out[3])
	);
	
endmodule