
// =================================================================================================
// File Name      : oserdes_if.v
// Module         : oserdes_if
// Function       : oserdes_if Interface
// Type           : RTL
// -------------------------------------------------------------------------------------------------
// Update History :
// -------------------------------------------------------------------------------------------------
// Rev.Level  Date         Coded by        Contents
// 0.1.0      2014/12/26   TEDWX)zhang.m   Create new
//
//
// =================================================================================================
// End Revision
// =================================================================================================

// =============================================================================
// Timescale Define
// =============================================================================
`timescale 1 ns / 1 ps

// =============================================================================
// RTL Header
// =============================================================================
module oserdes_if #(
	parameter					DB_W 	= 16					// data bus width
	)
	(
	// clk&rst
	input						XRST        				, 	// (i) System reset signal low active
	input						CLK_DIV	       				, 	// (i) clock input div4
	input						CLK	       					, 	// (i) clock input
	// io signals
	output						OSERDES_CLK_P				, 	// (o) OSERDES clock P
	output						OSERDES_CLK_N				, 	// (o) OSERDES clock N
	output		[DB_W-1  :0]	OSERDES_DAT_P				, 	// (o) OSERDES data P
	output		[DB_W-1  :0]	OSERDES_DAT_N				, 	// (o) OSERDES data P
	// fabric signals to tx_bitslice
	input						TX_DVLD						, 	// (i) user txdata valid
	input		[DB_W*8-1:0]	TX_DATA			  				// (i) user txdata
) ;


//---------------------------------------------------------------------
// Defination of Parameters
//---------------------------------------------------------------------

// parameter					P_IDLE			=	3'b001	; 	// fsm idel state
// parameter					P_CALIB			=	3'b010	; 	// fsm calibrating state
// parameter					P_CALIB_DONE	=	3'b100	; 	// fsm calibrate done state
parameter 					clk_pattern		=	8'b0101_0101;

//---------------------------------------------------------------------
// Defination of Internal Signals
//---------------------------------------------------------------------
wire		[DB_W-1  :0]	s_OSERDES_DAT				;	// tx io data
wire						s_OSERDES_CLK				;	// tx io clk

// =============================================================================
// RTL Body
// =============================================================================

//---------------------------------------------------------------------
// serdes instance
//---------------------------------------------------------------------

//---------------------------------------------------------------------
// Clock Output control
//---------------------------------------------------------------------
OSERDESE2 #(
	.DATA_RATE_OQ		( "SDR"				),	// DDR, SDR
	.DATA_RATE_TQ		( "SDR"				),	// DDR, BUF, SDR
	.DATA_WIDTH			( 8					),	// Parallel data width (2-8,10,14)
	.INIT_OQ			( 1'b0				),	// Initial value of OQ output (1'b0,1'b1)
	.INIT_TQ			( 1'b0				),	// Initial value of TQ output (1'b0,1'b1)
	.SERDES_MODE		( "MASTER"			),	// MASTER, SLAVE
	.SRVAL_OQ			( 1'b0				),	// OQ output value when SR is used (1'b0,1'b1)
	.SRVAL_TQ			( 1'b0				),	// TQ output value when SR is used (1'b0,1'b1)
	.TBYTE_CTL			( "FALSE"			),	// Enable tristate byte operation (FALSE, TRUE)
	.TBYTE_SRC			( "FALSE"			),	// Tristate byte source (FALSE, TRUE)
	.TRISTATE_WIDTH		( 1					)	// 3-state converter width (1,4)
)
U_OSERDESE2_CLK0 (
	.OFB				( 					),	// 1-bit output: Feedback path for data
	.OQ					( s_OSERDES_CLK		),	// 1-bit output: Data path output
	// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
	.SHIFTOUT1			( 					),
	.SHIFTOUT2			( 					),
	.TBYTEOUT			( 					),	// 1-bit output: Byte group tristate
	.TFB				( 					),	// 1-bit output: 3-state control
	.TQ					( 					),	// 1-bit output: 3-state control
	.CLK				( CLK				),	// 1-bit input: High speed clock
	.CLKDIV				( CLK_DIV			),	// 1-bit input: Divided clock
	// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
	.D1					( clk_pattern[0]				),
	.D2					( clk_pattern[1]				),
	.D3					( clk_pattern[2]				),
	.D4					( clk_pattern[3]				),
	.D5					( clk_pattern[4]				),
	.D6					( clk_pattern[5]				),
	.D7					( clk_pattern[6]				),
	.D8					( clk_pattern[7]				),
	.OCE				( 1'b1				),	// 1-bit input: Output data clock enable
	.RST				( ~XRST				),	// 1-bit input: Reset
	// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
	.SHIFTIN1			( 1'b0				),
	.SHIFTIN2			( 1'b0				),
	// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
	.T1					( 1'b0				),
	.T2					( 1'b0				),
	.T3					( 1'b0				),
	.T4					( 1'b0				),
	.TBYTEIN			( 1'b0				),	// 1-bit input: Byte group tristate
	.TCE				( 1'b0				)	// 1-bit input: 3-state clock enable
);

OBUFDS #(
	.SLEW				( "FAST"			)   // Specify the output slew rate
)
U_OBUFDS_CLK0 (
	.O					( OSERDES_CLK_P	),	// Diff_p output (connect directly to top-level port)
	.OB					( OSERDES_CLK_N	),	// Diff_n output (connect directly to top-level port)
	.I					( s_OSERDES_CLK	) 	// Buffer input
);


//---------------------------------------------------------------------
// Data Output control CHANNEL1
//---------------------------------------------------------------------
genvar i;
generate
	for (i=0; i<DB_W; i=i+1) begin: data_txout

		OSERDESE2 #(
			.DATA_RATE_OQ		( "SDR"							),	// DDR, SDR
			.DATA_RATE_TQ		( "SDR"							),	// DDR, BUF, SDR
			.DATA_WIDTH			( 8								),	// Parallel data width (2-8,10,14)
			.INIT_OQ			( 1'b0							),	// Initial value of OQ output (1'b0,1'b1)
			.INIT_TQ			( 1'b0							),	// Initial value of TQ output (1'b0,1'b1)
			.SERDES_MODE		( "MASTER"						),	// MASTER, SLAVE
			.SRVAL_OQ			( 1'b0							),	// OQ output value when SR is used (1'b0,1'b1)
			.SRVAL_TQ			( 1'b0							),	// TQ output value when SR is used (1'b0,1'b1)
			.TBYTE_CTL			( "FALSE"						),	// Enable tristate byte operation (FALSE, TRUE)
			.TBYTE_SRC			( "FALSE"						),	// Tristate byte source (FALSE, TRUE)
			.TRISTATE_WIDTH		( 1								)	// 3-state converter width (1,4)
		)
		U_OSERDESE2_TLA0 (
			.OFB				( 								),	// 1-bit output: Feedback path for data
			.OQ					( s_OSERDES_DAT[i] 				),	// 1-bit output: Data path output
			// SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
			.SHIFTOUT1			( 				 				),
			.SHIFTOUT2			(  								),
			.TBYTEOUT			( 								),	// 1-bit output: Byte group tristate
			.TFB				( 								),	// 1-bit output: 3-state control
			.TQ					( 								),	// 1-bit output: 3-state control
			.CLK				( CLK							),	// 1-bit input: High speed clock
			.CLKDIV				( CLK_DIV						),	// 1-bit input: Divided clock
			// D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
			.D1					( TX_DATA[i*8+7]				),
			.D2					( TX_DATA[i*8+6]				),
			.D3					( TX_DATA[i*8+5]				),
			.D4					( TX_DATA[i*8+4]				),
			.D5					( TX_DATA[i*8+3]				),
			.D6					( TX_DATA[i*8+2]				),
			.D7					( TX_DATA[i*8+1]				),
			.D8					( TX_DATA[i*8+0]				),
			.OCE				( 1'b1							),	// 1-bit input: Output data clock enable
			.RST				( ~XRST							),	// 1-bit input: Reset
			// SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
			.SHIFTIN1			( 1'b0							),
			.SHIFTIN2			( 1'b0							),
			// T1 - T4: 1-bit (each) input: Parallel 3-state inputs
			.T1					( 1'b0							),
			.T2					( 1'b0							),
			.T3					( 1'b0							),
			.T4					( 1'b0							),
			.TBYTEIN			( 1'b0							),	// 1-bit input: Byte group tristate
			.TCE				( 1'b0							)	// 1-bit input: 3-state clock enable
		);

		OBUFDS #(
			.SLEW			( "FAST"						)   // Specify the output slew rate
		)
		U_OBUFDS_TLA0 (
			.O				( OSERDES_DAT_P[i]				),	// Diff_p output (connect directly to top-level port)
			.OB				( OSERDES_DAT_N[i]				),	// Diff_n output (connect directly to top-level port)
			.I				( s_OSERDES_DAT[i]				) 	// Buffer input
		);

	end
endgenerate


endmodule
