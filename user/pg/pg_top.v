/**
 * Filename     :       pg_top.v
 * Function     :       pattern generate module
 * Date         :       2020-01-09
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-01-09 create basic Version
 */
 `include "../defines.v"
module pg_top #(
	// video parameter
	parameter V_ACT		= 12'd 2048		,
	parameter V_PW		= 12'd 2		,
	parameter V_BP		= 12'd 2		,
	parameter V_FP		= 12'd 192		,

	parameter H_ACT		= 12'd 2048		,
	parameter H_PW		= 12'd 42		,
	parameter H_BP		= 12'd 20		,
	parameter H_FP		= 12'd 90		,

	// data width setting
	parameter RGB_PORT	= 08'd01

	)(
    input 						clk			,  // (i) block clock
    input 						rst_n		,  // (i) block reset, Low_active
    input                   	en          ,   // (i) block enable, High_active
    // key
    input						key_up		,
	input						key_down	,
	input						key_sel		,
	input						key_auto	,

	output 						pg_frm_st	,
    output          			DE			,
    output         				Vsync		,
    output          			Hsync		,
    output  [RGB_PORT*24-1:0]  	data_rgb
    );

// wire pg_frm_st;
wire DE_tmp;
wire Vsync_tmp;
wire Hsync_tmp;

pg_timing #(
	// video parameter
	.V_ACT				(V_ACT)			,
	.V_PW				(V_PW)			,
	.V_BP				(V_BP)			,
	.V_FP				(V_FP)			,

	.H_ACT				(H_ACT)			,
	.H_PW				(H_PW)			,
	.H_BP				(H_BP)			,
	.H_FP				(H_FP)
	) pg_timing_inst(
    .clk				(clk)			,	// (i) block clock
    .rst_n				(rst_n)			,	// (i) block reset, Low_active
    .en                 (en)            ,   // (i) block enable

    .pg_frm_st			(pg_frm_st)		,	// (o) frame_start signal,
    .DE_out				(DE_tmp)		,	// (o)
    .Vsync_out			(Vsync_tmp)		,	// (o)
    .Hsync_out			(Hsync_tmp)			// (o)
    );



wire [RGB_PORT*24-1:0] data_rgb_tmp;
genvar port_num;
generate
	for(port_num = 0; port_num < RGB_PORT; port_num = port_num + 1'b1) begin : rgb_port
		pg_data #(
			.V_ACT					(V_ACT),
			.H_ACT					(H_ACT),
			.RGB_PORT				(RGB_PORT),
			.PORT_NUM				(port_num)
			) pg_data_inst(
    		.clk					(clk)			,	// (i) block clock
    		.rst_n					(rst_n)			,	// (i) block reset, Low_active
    		.pg_frm_st				(pg_frm_st)		,	// (i) frame_start signal, High_active

    		.normalpic_fifo_rd		(DE_tmp)		,	// (i) fifo read enable
    		.normalpic_fifo_empty	()				,	// (o) fifo read empty signal
    		.normalpic_fifo_rddata	(data_rgb_tmp[(24*(port_num+1)-1):(24*port_num)])	,	// ()

    		.raw_data_test			()				,	// ()
    		.key_up					(key_up)		,	// ()
    		.key_down				(key_down)		,	// ()
    		.key_sel				()				,	// ()
    		.key_auto				(key_auto)
    		);
	end
endgenerate


reg DE_tmp_delay0, DE_tmp_delay1, DE_tmp_delay2, DE_tmp_delay3;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DE_tmp_delay0 <= 1'b0;
        DE_tmp_delay1 <= 1'b0;
        DE_tmp_delay2 <= 1'b0;
        DE_tmp_delay3 <= 1'b0;
    end else begin
        DE_tmp_delay0 <= DE_tmp;
        DE_tmp_delay1 <= DE_tmp_delay0;
        DE_tmp_delay2 <= DE_tmp_delay1;
        DE_tmp_delay3 <= DE_tmp_delay2;

    end
end

reg Vsync_tmp_delay0, Vsync_tmp_delay1, Vsync_tmp_delay2, Vsync_tmp_delay3;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Vsync_tmp_delay0 <= 1'b0;
        Vsync_tmp_delay1 <= 1'b0;
        Vsync_tmp_delay2 <= 1'b0;
        Vsync_tmp_delay3 <= 1'b0;
    end else begin
        Vsync_tmp_delay0 <= Vsync_tmp;
        Vsync_tmp_delay1 <= Vsync_tmp_delay0;
        Vsync_tmp_delay2 <= Vsync_tmp_delay1;
        Vsync_tmp_delay3 <= Vsync_tmp_delay2;
    end
end

reg Hsync_tmp_delay0, Hsync_tmp_delay1, Hsync_tmp_delay2, Hsync_tmp_delay3;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Hsync_tmp_delay0 <= 1'b0;
        Hsync_tmp_delay1 <= 1'b0;
        Hsync_tmp_delay2 <= 1'b0;
        Hsync_tmp_delay3 <= 1'b0;
    end else begin
        Hsync_tmp_delay0 <= Hsync_tmp;
        Hsync_tmp_delay1 <= Hsync_tmp_delay0;
        Hsync_tmp_delay2 <= Hsync_tmp_delay1;
        Hsync_tmp_delay3 <= Hsync_tmp_delay2;
    end
end

assign DE = (DE_tmp_delay1);
assign Vsync = (Vsync_tmp_delay1);
assign Hsync = (Hsync_tmp_delay1);
assign data_rgb = data_rgb_tmp;

endmodule // pg_top
