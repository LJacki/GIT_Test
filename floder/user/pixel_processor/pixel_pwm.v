module	pixel_pwm(
	input					clk		,
	input					rst_n	,
	input	[ 7:0]			din		,
	input					en		,
	output	[`PWM_NUM-1:0]	dout	,
	output					oe
);

reg	[14:0]	pwm_reg;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n) begin
		pwm_reg <= 0;
	end else begin
		case(din[7:4])
			0		:	pwm_reg	<= 15'b000_0000_0000_0000;
			1		:	pwm_reg	<= 15'b000_0000_0000_0001;
			2		:	pwm_reg	<= 15'b000_0000_0000_0011;
			3		:	pwm_reg	<= 15'b000_0000_0000_0111;
			4		:	pwm_reg	<= 15'b000_0000_0000_1111;
			5		:	pwm_reg	<= 15'b000_0000_0001_1111;
			6		:	pwm_reg	<= 15'b000_0000_0011_1111;
			7		:	pwm_reg	<= 15'b000_0000_0111_1111;
			8		:	pwm_reg	<= 15'b000_0000_1111_1111;
			9		:	pwm_reg	<= 15'b000_0001_1111_1111;
			10		:	pwm_reg	<= 15'b000_0011_1111_1111;
			11		:	pwm_reg	<= 15'b000_0111_1111_1111;
			12		:	pwm_reg	<= 15'b000_1111_1111_1111;
			13		:	pwm_reg	<= 15'b001_1111_1111_1111;
			14		:	pwm_reg	<= 15'b011_1111_1111_1111;
			15		:	pwm_reg	<= 15'b111_1111_1111_1111;
			default	:	pwm_reg <= pwm_reg;
		endcase
	end
end


reg				en_1d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		en_1d <= 0;
	else
		en_1d <= en;
end

reg		[ 7:0]	din_1d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		din_1d <= 0;
	else
		din_1d <= din;
end

assign oe = en_1d;
assign dout = {pwm_reg,din_1d[3:0]};

endmodule
