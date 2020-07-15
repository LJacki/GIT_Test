//	_width	定义数据位宽
//	_size	定义width的大小

// chip
// `define DRIVER_5020
`define DRIVER_8030

`ifdef DRIVER_8030
	`define		CHIP_RES_COL	12'd1280
	`define		CHIP_RES_ROW	12'd720 // 720 // 2048
	`define		DATA_WIDTH		8'd32
	`define		DATA_SIZE		8'd5

	`define		RGB_PORT		8'd1
	`define		RGB_DATA_WIDTH	5'd24
	`define     CACHE_WIDTH     9'd320// `DATA_WIDTH*3
	`define     CNT_WIDTH       9'd320
	`define     CNT_SIZE        8'd9

	`define 	LINE_TRANS_NUM  8'd4  // every line trans data number 1280 / 320

`else
	`define		CHIP_RES_COL	12'd2048
	`define		CHIP_RES_ROW	12'd2048 // 2048
	`define		DATA_WIDTH		8'd128
	`define		DATA_SIZE		8'd7

	`define		RGB_PORT		8'd2
	`define		RGB_DATA_WIDTH	5'd24
	`define     CACHE_WIDTH     `DATA_WIDTH*3
	`define     CNT_WIDTH       `DATA_WIDTH/2
	`define     CNT_SIZE        `DATA_SIZE - 1

	`define 	LINE_TRANS_NUM  8'd16  // every line trans data number 2048*3/384


`endif



`define CHIP_RES_ROW_HALF	`CHIP_RES_ROW / 2


`define	PWM_NUM				19
`define	PWM_NUM_SIZE		5

`define	MEM_BL				40
`define	RAM_ADDR_SIZE		10	//	19*40=760 10bit addr

`define	MEM_BL_NUM_PER_ROW	4	//	40bl*4=160
`define	MEM_ROW_PER_BIT		180	//	720/4=180

`define	MEM_CMD_SIZE		5
`define	MEM_BA_SIZE			2

`define	MEM_ADDR_SIZE		29   // used
`define MEM_ADDR_ST         29'b0
`define BURST_LENGTH        8   // ddr3 burst length is 8


`define	MEM_DQM_SIZE		4

`define	XFRAME				2



//

`define 	REQ_ROW			8'd6 // 32
`define 	STA2_TIMES		`CHIP_RES_ROW / `REQ_ROW * `PWM_NUM


// `define 	PG_SIMULATION
`ifdef PG_SIMULATION
	`define		V_ACT			12'd8
	`define		V_PW			12'd1					//	12'd10
	`define		V_BP			12'd1					//	12'd68
	`define		V_FP			12'd1					//	12'd124

	`define		H_ACT			12'd1280
	`define		H_PW			12'd40
	`define		H_BP			12'd110
	`define		H_FP			12'd220
`else
// for pg_top display
	`define		V_ACT			12'd720
	`define		V_PW			12'd10					//	12'd10
	`define		V_BP			12'd10					//	12'd68
	`define		V_FP			12'd10					//	12'd124

	`define		H_ACT			12'd1280
	`define		H_PW			12'd40
	`define		H_BP			12'd110
	`define		H_FP			12'd220
`endif
// pg_timing parameter list
// `define Simulation

/**
 * parameter of picture number
 */
// parameter COLORFRAME    = 5'd0;
// parameter BLACK			= 5'd1;
// parameter WHITE         = 5'd2;
// parameter RED			= 5'd3;
// parameter GREEN			= 5'd4;
// parameter BLUE			= 5'd5;
// parameter CHESSBOARD    = 5'd6;
// parameter GRAY64		= 5'd7;
// parameter GRAYBARH      = 5'd8;
// parameter GRAYBARV      = 5'd9;
// parameter COLORBARH     = 5'd10;
// parameter COLORBARV     = 5'd11;
// parameter FLICKER       = 5'd12;
// parameter ETCOLORSCALE  = 5'd13;
// parameter COLORBAR3     = 5'd14;
// parameter CROSSTALK     = 5'd15;
// parameter GRAY192		= 5'd16;
// parameter GRAY127		= 5'd17;
// parameter GRAY32		= 5'd18;
// parameter PURECOLOR     = 5'd30;
//
// parameter CHESSBOARDN   = 5'd19;
// parameter GRAYBARHN     = 5'd20;
// parameter GRAYBARVN     = 5'd21;
// parameter COLORBARHN    = 5'd22;
// parameter COLORBARVN    = 5'd23;
//
// parameter FIRSTPIC		= 5'd00;
// parameter LASTPIC		= 5'd23;
//
// parameter DEBUG_PIC		= COLORFRAME;
// parameter DEFAULTPIC	= DEBUG_PIC;
//
// parameter	AUTO_TIMER		=	30'd150000000;
