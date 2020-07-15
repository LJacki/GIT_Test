`include "../defines.v"
module ctrl_ddr3_top (
	// DDR3 physical interface
	// Single-ended system clock
	input 						sys_clk_i,
	// Single-ended iodelayctrl clk (reference clock)
//	input 						clk_ref_i,
	// System rst_n Ports
	input 						sys_rst,

	// Outputs
	output [14:0]				ddr3_addr,
	output [2:0]				ddr3_ba,
	output 						ddr3_cas_n,
	output [0:0]				ddr3_ck_n,
	output [0:0]				ddr3_ck_p,
	output [0:0]				ddr3_cke,
	output 						ddr3_ras_n,
	output 						ddr3_we_n,

	inout [63:0]				ddr3_dq,
	inout [7:0]					ddr3_dqs_n,
	inout [7:0]					ddr3_dqs_p,

	output 						init_calib_complete,// (o)

	output 						ddr3_reset_n,

	output [0:0]        		ddr3_cs_n,
	output [7:0]				ddr3_dm,
	output [0:0]				ddr3_odt,

	output 						app_rdy,
	output 						ui_clk,
	output 						ui_clk_sync_rst,
	// DDR3 user interface

	output 						app_writing,
	output 						fifo_ddr3_in_rd_en,
	// input 						wr_st,
	input 						wr_en_i,
	input [511:0] 				wr_data_i,
	input [`MEM_ADDR_SIZE-1:0]	wr_addr_i,


	output 						fifo_ddr3_rd_addr_rd_en,
	// input 						rd_st,
	input 						rd_en_i,
	input [`MEM_ADDR_SIZE-1:0]	rd_addr_i,
	output [511:0]				rd_data_o,
	output 						rd_data_o_valid

	);


// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************
// wire init_calib_complete;
(*mark_debug = "true"*) wire [`MEM_ADDR_SIZE-1:0] app_addr;
(*mark_debug = "true"*) wire [2:0] app_cmd;
(*mark_debug = "true"*) wire app_en;

(*mark_debug = "true"*) wire [511:0] app_wdf_data;
(*mark_debug = "true"*) wire app_wdf_end;
(*mark_debug = "true"*) wire app_wdf_wren;

(*mark_debug = "true"*) wire [511:0] app_rd_data;
(*mark_debug = "true"*) wire app_rd_data_end;
(*mark_debug = "true"*) wire app_rd_data_valid;

// wire app_rdy;
(*mark_debug = "true"*) wire app_wdf_rdy;

wire app_sr_active;
wire app_ref_ack;
wire app_zq_ack;

// wire ui_clk;
// wire ui_clk_sync_rst;

wire [11:0] device_temp;
wire [63:0] app_wdf_mask = 63'b0;


mig_7series_0 u_mig_7series_0 (
	// Memory interface ports
	// System Clock Ports, maybe 400Mhz
	.sys_clk_i						(sys_clk_i),		// input
	// Reference Clock Ports, maybe same to 400Mhz
//	.clk_ref_i                      (clk_ref_i),		// input

	// System rst_n Ports
	.sys_rst						(sys_rst),			// input

	// DDR3 physical pin connected
	.ddr3_addr						(ddr3_addr),		// output [14:0]
	.ddr3_ba                        (ddr3_ba),			// output [2:0]
	.ddr3_cas_n                     (ddr3_cas_n),		// output
	.ddr3_ck_n                      (ddr3_ck_n),		// output [0:0]
	.ddr3_ck_p                      (ddr3_ck_p),		// output [0:0]
	.ddr3_cke                       (ddr3_cke),			// output [0:0]
	.ddr3_ras_n                     (ddr3_ras_n),		// output
	.ddr3_we_n                      (ddr3_we_n),		// output

	.ddr3_dq                        (ddr3_dq),			// inout [63:0]
	.ddr3_dqs_n                     (ddr3_dqs_n),		// inout [7:0]
	.ddr3_dqs_p                     (ddr3_dqs_p),		// inout [7:0]

	.ddr3_reset_n                   (ddr3_reset_n),		// output

	// DDR3 initial complete signal, pay more attention
	.init_calib_complete            (init_calib_complete), // output

	// DDR3 physical pin connected
	.ddr3_cs_n                      (ddr3_cs_n),		// output [0:0]
	.ddr3_dm                        (ddr3_dm),			// output [7:0]
	.ddr3_odt                       (ddr3_odt),			// output [0:0]

	// Application interface ports, pay more attention
	.app_addr                       (app_addr),			// input [28:0]
	.app_cmd                        (app_cmd),			// input [2:0]
	.app_en                         (app_en),			// input
	.app_wdf_data                   (app_wdf_data),		// input [511:0]
	.app_wdf_end                    (app_wdf_end),		// input
	.app_wdf_wren                   (app_wdf_wren),		// input

	.app_rd_data                    (app_rd_data),		// output [511:0]
	.app_rd_data_end                (app_rd_data_end),	// output
	.app_rd_data_valid              (app_rd_data_valid),// output
	.app_rdy                        (app_rdy),			// output
	.app_wdf_rdy                    (app_wdf_rdy),		// output

	// Just send 0 to this three pin under
	.app_sr_req                     (1'b0),				// input
	.app_ref_req                    (1'b0),				// input
	.app_zq_req                     (1'b0),				// input

	// output to wire
	.app_sr_active                  (app_sr_active),	// output
	.app_ref_ack                    (app_ref_ack),		// output
	.app_zq_ack                     (app_zq_ack),		// output

	// ui_clk : MIG output for user clock, maybe 200Mhz
	.ui_clk                         (ui_clk),			// output

	// ui_clk_sync_rst : MIG output rst, connect to wire
	.ui_clk_sync_rst                (ui_clk_sync_rst),	// output, active high

	// mask singal, send 0 here
	.app_wdf_mask                   (app_wdf_mask),		// input [63:0]

	.device_temp            		(device_temp)
    );
// End of User Design top instance

// Controller state machine
(*mark_debug = "true"*) reg [3:0] curr_state;	// (* syn_encoding = "safe" *)
(*mark_debug = "true"*) reg [3:0] next_state;	// (* syn_encoding = "safe" *)

// state statement
parameter IDLE 		= 4'b0000;
parameter WAIT		= 4'b0001;
parameter WRITE		= 4'b0010;
parameter READ		= 4'b0100;
parameter FINISH	= 4'b1000;

parameter CMD_WR	= 3'b000;
parameter CMD_RD	= 3'b001;

// state to ASCII
reg [79:0] state_curr;
always @ ( * ) begin
	case (curr_state)
		IDLE	:	state_curr = "IDLE";
		WAIT	:	state_curr = "WAIT";
		WRITE	:	state_curr = "WRITE";
		READ	:	state_curr = "READ";
		FINISH	:	state_curr = "FINISH";
		default: ;
	endcase
end

reg [79:0] state_next;
always @ ( * ) begin
	case (next_state)
		IDLE	:	state_next = "IDLE";
		WAIT	:	state_next = "WAIT";
		WRITE	:	state_next = "WRITE";
		READ	:	state_next = "READ";
		FINISH	:	state_next = "FINISH";
		default: ;
	endcase
end

// first part : state transition
always @ ( posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		curr_state <= IDLE;
	end else begin
		curr_state <= next_state;
	end
end

// second part : transition condition
(*mark_debug = "true"*) wire wr_en;
(*mark_debug = "true"*) wire rd_en;
(*mark_debug = "true"*) reg [15:0] wr_en_in_cnt;
(*mark_debug = "true"*) reg [15:0] app_rdy_cnt;
(*mark_debug = "true"*) reg [15:0] rd_en_in_cnt;
(*mark_debug = "true"*) reg [15:0] app_rdy_rd_cnt;

always @ ( curr_state or wr_en or rd_en or app_rdy_cnt or wr_en_in_cnt or app_rdy_rd_cnt or rd_en_in_cnt or app_rdy or init_calib_complete ) begin
	case (curr_state)
		IDLE	:	if ( init_calib_complete ) begin
			next_state = WAIT;
		end else begin
			next_state = IDLE;
		end
		WAIT	:	if ( wr_en ) begin	// app_rdy keep high, app_en keep high, app_addr valid
			next_state = WRITE;
		end else if ( rd_en ) begin
			next_state = READ;
		end else begin
			next_state = WAIT;
		end
		WRITE	:	if ( app_rdy_cnt >= wr_en_in_cnt && app_rdy ) begin
			next_state = FINISH;
		end else begin
			next_state = WRITE;
		end
		READ	:	if ( (wr_en || app_rdy_rd_cnt >= rd_en_in_cnt ) && app_rdy ) begin
			next_state = FINISH;
		end else begin
			next_state = READ;
		end
		FINISH	:	if ( wr_en ) begin
			next_state = WRITE;
		end else if ( rd_en || (app_rdy_rd_cnt < rd_en_in_cnt)) begin
			next_state = READ;
		end else begin
			next_state = WAIT;
		end
		default :	next_state = IDLE;
	endcase
end


// third part : state output
// app_en
(*mark_debug = "true"*) wire app_rdy_sig;
assign app_rdy_sig = (app_rdy);

reg app_en_tmp;
reg [2:0] app_cmd_tmp;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		app_en_tmp <= 1'b0;
		app_cmd_tmp <= 3'b000;
	end else if ( curr_state == WRITE ) begin
		app_cmd_tmp <= CMD_WR;
		if ( app_rdy ) begin
			if ( app_rdy_cnt < wr_en_in_cnt ) begin
				app_en_tmp <= 1'b1;
			end else begin
				app_en_tmp <= 1'b0;
			end
		end else begin
			app_en_tmp <= app_en_tmp;
		end
	end else if ( curr_state == READ ) begin
		app_cmd_tmp <= CMD_RD;
		if ( app_rdy ) begin
			if ( app_rdy_rd_cnt < rd_en_in_cnt && (next_state != FINISH) ) begin
				app_en_tmp <= 1'b1;
			end else begin
				app_en_tmp <= 1'b0;
			end
		end else begin
			app_en_tmp <= app_en_tmp;
		end
	end else begin
		app_en_tmp <= 1'b0;
		app_cmd_tmp <= 3'b000;
	end
end
assign app_en = app_en_tmp;
// assign app_en = (curr_state == WRITE) ? (app_rdy && app_wdf_rdy) : ((curr_state == READ)&&app_rdy);

// app_cmd
assign app_cmd = app_cmd_tmp;

// app_addr
// app_addr_wr_en & app_addr_rd_en
(*mark_debug = "true"*) wire app_addr_wr_en;
assign app_addr_wr_en = (curr_state == WRITE);
(*mark_debug = "true"*) wire app_addr_rd_en;
assign app_addr_rd_en = (curr_state == READ);

assign app_addr = app_addr_wr_en ? wr_addr_i : app_addr_rd_en ? rd_addr_i : {`MEM_ADDR_SIZE{1'b0}};

assign fifo_ddr3_rd_addr_rd_en = (curr_state == READ) && (next_state == READ) && (app_rdy);
assign fifo_ddr3_in_rd_en = (curr_state == WRITE) && (next_state == WRITE) && (app_rdy);


// app_wdf_wren, app_wdf_end
reg app_wdf_wren_tmp;
always @ (posedge ui_clk or posedge ui_clk_sync_rst) begin
	if ( ui_clk_sync_rst ) begin
		app_wdf_wren_tmp <= 1'b0;
	end else if ( curr_state == WRITE ) begin
		if ( app_rdy ) begin
			if ( app_rdy_cnt < wr_en_in_cnt ) begin
				app_wdf_wren_tmp <= 1'b1;
			end else begin
				app_wdf_wren_tmp <= 1'b0;
			end
		end else begin
			app_wdf_wren_tmp <= 1'b0;
		end
	end else begin
		app_wdf_wren_tmp <= 1'b0;
	end
end
// app_wdf_wren need to be follow by the app_wdf_data
assign app_wdf_wren = (curr_state == WRITE) && ( app_en_tmp && app_rdy );
assign app_wdf_end = (app_wdf_wren);
// assign app_wdf_wren = (curr_state == WRITE) ? (app_rdy && app_wdf_rdy) : 1'b0;
// assign app_wdf_end = (app_wdf_wren);


// app_wdf_data
assign app_wdf_data = app_wdf_rdy ? (wr_data_i) : 512'b0;

assign wr_en = (wr_en_i);

// count for wr_en_in	// attention to reset
// reg [15:0] wr_en_in_cnt;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		wr_en_in_cnt <= 16'b0;
	end else if ( wr_en ) begin				// wr_en_in
		wr_en_in_cnt <= wr_en_in_cnt + 1'b1;
	end else if ( next_state == WRITE ) begin
		wr_en_in_cnt <= wr_en_in_cnt;
	end else begin
		wr_en_in_cnt <= 16'b0;
	end
end


// count for app_rdy
// reg [15:0] app_rdy_cnt;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		app_rdy_cnt <= 16'b0;
	end else if ( curr_state == WRITE && next_state != FINISH ) begin
	 	if ( app_rdy ) begin
			app_rdy_cnt <= app_rdy_cnt + 1'b1;
		end else begin
			app_rdy_cnt <= app_rdy_cnt;
		end
	end else begin
		app_rdy_cnt <= 16'b0;
	end
end


/*
██████  ██████
██   ██ ██   ██
██████  ██   ██
██   ██ ██   ██
██   ██ ██████
*/
assign rd_en = (rd_en_i);

// count for rd_en_in
// reg [15:0] rd_en_in_cnt;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		rd_en_in_cnt <= 16'b0;
	end else if ( rd_en ) begin				// rd_en_in
		rd_en_in_cnt <= rd_en_in_cnt + 1'b1;
	end else if ( next_state == READ || app_rdy_rd_cnt < rd_en_in_cnt ) begin
		rd_en_in_cnt <= rd_en_in_cnt;
	end else begin
		rd_en_in_cnt <= 16'b0;
	end
end


always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		app_rdy_rd_cnt <= 16'b0;
	end else if ( curr_state == READ && next_state != FINISH ) begin
		if ( app_rdy ) begin
			app_rdy_rd_cnt <= app_rdy_rd_cnt + 1'b1;
		end else begin
			app_rdy_rd_cnt <= app_rdy_rd_cnt;
		end
	end else if ( app_rdy_rd_cnt < rd_en_in_cnt ) begin
		app_rdy_rd_cnt <= app_rdy_rd_cnt;
	end else begin
		app_rdy_rd_cnt <= 16'b0;
	end
end

// recieve rd data valid
reg app_rd_data_valid_d0;
reg app_rd_data_valid_d1;
always @ (posedge ui_clk or posedge ui_clk_sync_rst ) begin
	if ( ui_clk_sync_rst ) begin
		app_rd_data_valid_d0 <= 1'b0;
		app_rd_data_valid_d1 <= 1'b0;
	end else begin
		app_rd_data_valid_d0 <= app_rd_data_valid;
		app_rd_data_valid_d1 <= app_rd_data_valid_d0;
	end
end

assign rd_data_o_valid = (app_rd_data_valid_d0);

// recieve rd data
reg [511:0] app_rd_data_tmp;
always @ (posedge ui_clk or posedge ui_clk_sync_rst) begin
	if ( ui_clk_sync_rst ) begin
		app_rd_data_tmp <= 512'b0;
	end else if ( app_rd_data_valid ) begin
		app_rd_data_tmp <= app_rd_data;
	end else begin
		app_rd_data_tmp <= 512'b0;
	end
end

assign rd_data_o = (app_rd_data_tmp);

assign app_writing = (app_addr_wr_en);


endmodule // the end of ctrl_ddr3_top
