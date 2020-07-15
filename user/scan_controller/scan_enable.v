`include "../defines.v"
module	scan_enable(
		//system signals
		input							clk			,
		input							rst_n		,
		//others signals
		input				[ 6:0]		rdusedw		,
		input							rdempty		,
		output							ctrl_ena
);

//	=================================================================	\
//	************** Define Paramters	and Interal signals**************
//	=================================================================	/
localparam	WATER_LINE	=	100;

reg									ena						;
reg				[1:0]				delay					;

//	=================================================================	\
//	************** Define Paramters	and Interal signals**************
//	=================================================================	/
always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			ena <= 0;
		else if(rdusedw > WATER_LINE)
			ena <= 1;
		else if(rdempty)
			ena <= 0;
		else
			ena <= ena;
end

always@	(posedge clk or negedge rst_n)	begin
		if(!rst_n)
			delay <= 0;
		else
			delay <= {delay[0],ena};
end

assign	ctrl_ena = |delay;

endmodule
