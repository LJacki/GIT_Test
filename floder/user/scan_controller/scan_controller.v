`include "../defines.v"
module	scan_controller(
		//system signals
		input							clk			,
		input							rst_n		,
		//others signals
		input				[ 6:0]		rdusedw		,
		input							rdempty		,
		input	[`DATA_WIDTH-1:0]		pixel_data	,
		output				[ 7:0]		ctrl		,
		output	[`DATA_WIDTH-1:0]		d63_0		,
		output							edff
);

//	===============================================================================	\
//	***************	Interal signals and Interface	*******************************
//	===============================================================================	/
wire						ctrl_ena			;
wire						edff_en				;
wire						edff_un				;
wire						col_start			;
wire						g1					;
wire						lrn					;
wire						col_shift_en		;
wire						g2					;
wire						ren					;
wire						woe					;
wire						row_data			;

wire						clr_op					;
wire						clr_col_start			;
wire						clr_g1					;
wire						clr_lrn					;
wire						clr_col_shift			;
wire						clr_g2					;
wire						clr_ren					;
wire						clr_woe					;
wire						clr_row_data			;

//	============================================================================================
//	***************	Module INST	************************************************************
//	============================================================================================
scan_enable		scan_enable_inst(
		.clk					(clk)			,
		.rst_n					(rst_n)			,
		.rdusedw				(rdusedw)		,
		.rdempty				(rdempty)		,
		.ctrl_ena				(ctrl_ena)
);

scan_ctrl		scan_ctrl_inst(
		.clk					(clk)			,
		.rst_n					(rst_n)			,
		.ctrl_ena				(ctrl_ena)		,
		.edff					(edff)			,
		.edff_un				(edff_un)		,
		.col_start				(col_start)		,
		.g1						(g1)			,
		.lrn					(lrn)			,
		.col_shift_en			(col_shift_en)	,
		.g2						(g2)			,
		.ren					(ren)			,
		.woe					(woe)			,
		.row_data				(row_data)
);

scan_init_clr		scan_init_clr_inst(
	.clk			(clk)	,
	.rst_n			(rst_n)	,
	.clr_op			(clr_op)	,
	.col_start		(clr_col_start)	,
	.col_shift		(clr_col_shift)	,
	.lrn			(clr_lrn)	,
	.g1				(clr_g1)	,
	.g2				(clr_g2)	,
	.ren			(clr_ren)	,
	.woe			(clr_woe)	,
	.row_data       (clr_row_data)
);


wire [7:0] clr_ctrl_reg = {clr_row_data,clr_woe,clr_ren,clr_g2,clr_col_shift,clr_lrn,clr_g1,clr_col_start};

wire [7:0] ctrl_reg = {row_data,woe,ren,g2,col_shift_en,~lrn,g1,col_start};

reg [7:0] ctrl_reg_1d,ctrl_reg_2d;

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ctrl_reg_1d <= 0;
	else
		ctrl_reg_1d <= ctrl_reg;
end

always@	(posedge clk or negedge rst_n)	begin
	if(!rst_n)
		ctrl_reg_2d <= 0;
	else
		ctrl_reg_2d <= ctrl_reg_1d;
end

assign ctrl = clr_op ? clr_ctrl_reg : ctrl_reg_2d;

scan_data_path	scan_data_path_inst(
		.clk					(clk)			,
		.rst_n					(rst_n)			,
		.edff					(edff)			,
		.edff_un				(edff_un)		,
		.pixel_data				(pixel_data)	,
		.d63_0					(d63_0)
);

endmodule
