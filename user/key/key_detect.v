/**
 * Filename     :       key_detect.v
 * Date         :       2019-02-03
 *
 * Version      :       V 0.1
 *
 * Modification history
 *
 * 						key detect time 20ms.
 */

module key_detect(
	input	clk,
	input	rst_n,

	input	initial_status,
	input	key_in,
	output	key_out
	);

reg	[15:0]	detect_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		detect_cnt <= 16'b0;
	end else begin
		detect_cnt <= detect_cnt + 1'b1;
	end
end

reg key_status;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		key_status <= initial_status;
	end else if ( detect_cnt == 16'h0fff ) begin
		key_status <= key_in;
	end
end

reg key_status_delay0;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		key_status_delay0 <= initial_status;
	end else begin
		key_status_delay0 <= key_status;
	end
end
assign key_out = (~key_status) & (key_status_delay0);

endmodule
