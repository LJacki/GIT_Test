`include "../defines.v"
module	scan_data_path(
		//system signals
		input						clk				,
		input						rst_n			,
		//others signals
		input						edff			,
		input						edff_un			,
		input	[`DATA_WIDTH-1:0]	pixel_data		,
		output	[`DATA_WIDTH-1:0]	d63_0
);

//	=================================================================	\
//	************** Define Paramters	and Interal signals**************
//	=================================================================	/
reg							edff_1d			;
reg							edff_2d			;
reg		[`DATA_WIDTH-1:0]	pixel_data_1d	;

//	=================================================================	\
//	************** Define Paramters	and Interal signals**************
//	=================================================================	/
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)	begin
			edff_1d <= 0;
			edff_2d <= 0;
		end
		else begin
			edff_1d <= edff;
			edff_2d <= edff_1d;
		end
end

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			pixel_data_1d <= 0;
		else
			pixel_data_1d <= pixel_data;
end

assign d63_0 = edff_2d ? pixel_data_1d : 'd0;

endmodule
