/**
 * Filename     :       pg_timing.v
 * Date         :       2020-01-09
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-01-09 create basic Version
 */
module pg_timing #(
	// video parameter
	parameter V_ACT		= 12'd 2048		,
	parameter V_PW		= 12'd 2		,
	parameter V_BP		= 12'd 2		,
	parameter V_FP		= 12'd 192		,

	parameter H_ACT		= 12'd 2048		,
	parameter H_PW		= 12'd 42		,
	parameter H_BP		= 12'd 20		,
	parameter H_FP		= 12'd 90
	)(
    input               clk				,
    input               rst_n			,
	input 				en				,

    output              pg_frm_st		,
    output              DE_out			,
    output              Vsync_out		,
    output              Hsync_out

    );


/**
--        _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
-- PCLK  | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
--       __         ___________________________________________________________________________________________   _
-- Vsync   |_______|                                                                                           |_|
--            _____       ___________       ___________       ___________       ___________       ___________
-- Hsync ____|     |_____|           |_____|           |_____|           |_____|           |_____|           |_____
--                                            _______           _______           _______
-- DE    ____________________________________|       |_________|       |_________|       |_________________________
*/


/**
 * parameter setting should be transimit from lcdif_reg
 */

`ifdef Simulation
parameter 	H_act 			= 12'd	128;
parameter 	H_fp			= 12'd	1;
parameter 	H_bp 			= 12'd	1;
parameter	H_pw			= 12'd	1;
parameter   H_total         = H_act + H_fp + H_bp + H_pw;

parameter	V_act	 		= 12'd	8;
parameter	V_bp			= 12'd	1;
parameter	V_fp			= 12'd	1;
parameter	V_pw			= 12'd	1;
parameter   V_total 		= V_act + V_bp + V_fp + V_pw;

`else
parameter 	H_act 			= H_ACT;
parameter	H_pw			= H_PW;
parameter 	H_bp 			= H_BP;
parameter 	H_fp			= H_FP;
parameter   H_total         = H_act + H_fp + H_bp + H_pw;

parameter	V_act	 		= V_ACT;
parameter	V_pw			= V_PW;
parameter	V_bp			= V_BP;
parameter	V_fp			= V_FP;
parameter   V_total 		= V_act + V_bp + V_fp + V_pw;
`endif

/**
 * line and pixel cnt timing
 */
reg [11:0] pixel_cnt;
reg [11:0] line_cnt;
reg Hsync, Vsync, DE;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        pixel_cnt <= 12'b0;
        line_cnt <= 12'b0;
        Hsync <= 1'b0;
        Vsync <= 1'b0;
		DE <= 1'b0;
    end else if ( en ) begin
        // Hsync created
        if ( pixel_cnt == H_total - 1'b1 ) begin
            pixel_cnt <= 12'b0;
            Hsync <= 1'b0;
            // Vsync created
            if ( line_cnt == V_total - 1'b1 ) begin
                line_cnt <= 12'b0;
                Vsync <= 1'b0;
            end else if ( line_cnt < V_pw - 1'b1 ) begin
                line_cnt <= line_cnt + 1'b1;
                Vsync <= 1'b0;
            end else begin
                line_cnt <= line_cnt + 1'b1;
                Vsync <= 1'b1;
            end
        end else if ( pixel_cnt < H_pw - 1'b1 ) begin
            pixel_cnt <= pixel_cnt + 1'b1;
            Hsync <= 1'b0;

        end else begin
            pixel_cnt <= pixel_cnt + 1'b1;
            Hsync <= 1'b1;
        end

        // DE created
        if	((line_cnt >= (V_bp + V_pw)) && (line_cnt < (V_total - V_fp)) && (pixel_cnt >= (H_bp + H_pw - 1'b1)) && (pixel_cnt < (H_total - H_fp - 1'b1))) begin
            DE <= 1'b1;
        end else begin
            DE <= 1'b0;
        end

    end else begin
		pixel_cnt <= 12'b0;
        line_cnt <= 12'b0;
        Hsync <= 1'b0;
        Vsync <= 1'b0;
		DE <= 1'b0;
	end
end

/**
 * Delay of DE
 */
reg DE_delay0;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        DE_delay0 <= 1'b0;
    end else begin
        DE_delay0  <= DE;
    end
end

assign DE_out = (DE_delay0);

/**
 *	Delay of Vsync and Hsync
 */
reg Vsync_delay0, Hsync_delay0;
always @ (posedge clk or negedge rst_n )begin
	if ( !rst_n ) begin
		Vsync_delay0 <= 1'b0;
		Hsync_delay0 <= 1'b0;
	end else begin
		Vsync_delay0 <= Vsync;
		Hsync_delay0 <= Hsync;
	end
end
assign Vsync_out = (Vsync_delay0);
assign Hsync_out = (Hsync_delay0);

/**
 * the start of new frame
 */
reg frame_start;		// the new frame start flag
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		frame_start <= 1'b1;
	end else begin
		frame_start <= ( pixel_cnt == 12'd0 & line_cnt == 12'd0);
	end
end
assign pg_frm_st = (frame_start);

endmodule   // the end of pg_timing
