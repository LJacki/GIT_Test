/**
 * Filename     :       line_divide.v
 * Date         :       2020-05-25
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *				:		2020-05-25 create basic Version
 */
`include "../defines.v"
module line_divide (
	input 					clk,
	input 					rst_n,

	input 					rd_en,		// 1 clk before pix_valid;
	input 					pix_valid,
	input [`DATA_WIDTH-1:0]	pix_data,

	output 					pix_valid_o,
	output [`DATA_WIDTH-1:0]pix_data_o

	);

localparam  LINE_CNT = 8'd48;
localparam  WE_CNT = LINE_CNT * 2;
localparam  HALF_CNT = LINE_CNT /2;

localparam  IDLE = 4'b0000;
localparam  INIT = 4'b0001;
localparam  STA1 = 4'b0010;
localparam  STA2 = 4'b0100;
// localparam  KEEP = 4'b1000;

(*mark_debug = "true"*) reg [3:0] curr_state;
(*mark_debug = "true"*) reg [3:0] next_state;
// state to ASCII
(*mark_debug = "true"*) reg [79:0] state_curr;
always @ ( curr_state ) begin
	case (curr_state)
		IDLE	:	state_curr = "IDLE";
		INIT	:	state_curr = "INIT";
		STA1	:	state_curr = "STA1";
		STA2	:	state_curr = "STA2";
		// KEEP	:	state_curr = "KEEP";
		default	: 	state_curr = "DEFAULT";
	endcase
end

(*mark_debug = "true"*) reg [79:0] state_next;
always @ ( next_state ) begin
	case (next_state)
		IDLE	:	state_next = "IDLE";
		INIT	:	state_next = "INIT";
		STA1	:	state_next = "STA1";
		STA2	:	state_next = "STA2";
		// KEEP	:	state_next = "KEEP";
		default	: 	state_next = "DEFAULT";
	endcase
end

// first part : state transition
always @ ( posedge clk or posedge rst_n ) begin
	if ( !rst_n ) begin
		curr_state <= IDLE;
	end else begin
		curr_state <= next_state;
	end
end

// second part : transition condition
localparam  INIT_CNT = 8'd48;
localparam  STA1_CNT = 8'd48;
localparam  STA2_CNT = 8'd48;

(*mark_debug = "true"*) reg [7:0] init_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		init_cnt <= 8'b0;
	end else if ( next_state == INIT ) begin
		init_cnt <= init_cnt + 1'b1;
	end else begin
		init_cnt <= 8'b0;
	end
end


(*mark_debug = "true"*) reg [7:0] sta1_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		sta1_cnt <= 8'b0;
	end else if ( next_state == STA1 ) begin
		sta1_cnt <= sta1_cnt + 1'b1;
	end else begin
		sta1_cnt <= 8'b0;
	end
end


(*mark_debug = "true"*) reg [7:0] sta2_cnt;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		sta2_cnt <= 8'b0;
	end else if ( next_state == STA2 ) begin
		sta2_cnt <= sta2_cnt + 1'b1;
	end else begin
		sta2_cnt <= 8'b0;
	end
end




always @ ( curr_state or rd_en or init_cnt or sta1_cnt or sta2_cnt or pix_valid ) begin
	case ( curr_state )
		IDLE	: 	if ( rd_en ) begin
			next_state = INIT;
		end else begin
			next_state = IDLE;
		end
		INIT	: 	if ( init_cnt == INIT_CNT ) begin
			next_state = STA1;
		end else begin
			next_state = INIT;
		end
		STA1 	:	if ( sta1_cnt == STA1_CNT ) begin
			next_state = STA2;
		end else begin
			next_state = STA1;
		end
		STA2	:	if ( sta2_cnt == STA2_CNT ) begin
			if ( !pix_valid ) begin
				next_state = IDLE;
			end else begin
				next_state = STA1;
			end
		end else begin
			next_state = STA2;
		end
		// KEEP	:	if ( 0 ) begin
		//
		// end else begin
		//
		// end
		default	: 	next_state = IDLE;
	endcase
end


/**
 * RAM
 */

(*mark_debug = "true"*) wire clka_left, ena_left, wea_left;
(*mark_debug = "true"*) wire [6:0] addra_left;
(*mark_debug = "true"*) wire [127:0] dina_left;
(*mark_debug = "true"*) wire [63:0] douta_left;

(*mark_debug = "true"*) wire clkb_left, enb_left, web_left;
(*mark_debug = "true"*) wire [6:0] addrb_left;
(*mark_debug = "true"*) wire [127:0] dinb_left;
(*mark_debug = "true"*) wire [63:0] doutb_left;

(*mark_debug = "true"*) wire clka_right, ena_right, wea_right;
(*mark_debug = "true"*) wire [6:0] addra_right;
(*mark_debug = "true"*) wire [127:0] dina_right;
(*mark_debug = "true"*) wire [63:0] douta_right;

(*mark_debug = "true"*) wire clkb_right, enb_right, web_right;
(*mark_debug = "true"*) wire [6:0] addrb_right;
(*mark_debug = "true"*) wire [127:0] dinb_right;
(*mark_debug = "true"*) wire [63:0] doutb_right;

assign clka_left = (clk);
assign clkb_left = (clk);
assign clka_right = (clk);
assign clkb_right = (clk);

assign ena_left = (1'b1);
assign enb_left = (1'b1);
assign ena_right = (1'b1);
assign enb_right = (1'b1);


/*
██      ███████ ███████ ████████      █████
██      ██      ██         ██        ██   ██
██      █████   █████      ██        ███████
██      ██      ██         ██        ██   ██
███████ ███████ ██         ██        ██   ██
*/

(*mark_debug = "true"*) reg wea_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wea_left_tmp <= 1'b0;
	end else if ( (curr_state == INIT && init_cnt <= HALF_CNT) || (curr_state == STA2 && sta2_cnt <= HALF_CNT) ) begin
		wea_left_tmp <= pix_valid;
	end else begin
		wea_left_tmp <= 1'b0;
	end
end
assign wea_left = (wea_left_tmp);

(*mark_debug = "true"*) reg [6:0] addra_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		addra_left_tmp <= 7'b0;
	end else if ( (curr_state == INIT && init_cnt <= HALF_CNT) || (curr_state == STA2 && sta2_cnt <= HALF_CNT) ) begin
		if ( init_cnt == 7'd1 || sta2_cnt == 7'd1 ) begin
			addra_left_tmp <= 7'b0;
		end else begin
			addra_left_tmp <= addra_left_tmp + 2'b10;
		end
	end else if ( curr_state == STA1) begin
		addra_left_tmp <= STA1_CNT - sta1_cnt;
	end else begin
		addra_left_tmp <= 7'b0;
	end
end
assign addra_left = (addra_left_tmp);


(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] dina_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dina_left_tmp <= {`DATA_WIDTH{1'b0}};
	end else if ( (curr_state == INIT && init_cnt <= HALF_CNT) || (curr_state == STA2 && sta2_cnt <= HALF_CNT) ) begin
		dina_left_tmp <= {pix_data[63:0],pix_data[127:64]};
	end else begin
		dina_left_tmp <= {`DATA_WIDTH{1'b0}};
	end
end
assign dina_left = (dina_left_tmp);


/*
██████  ██  ██████  ██   ██ ████████      █████
██   ██ ██ ██       ██   ██    ██        ██   ██
██████  ██ ██   ███ ███████    ██        ███████
██   ██ ██ ██    ██ ██   ██    ██        ██   ██
██   ██ ██  ██████  ██   ██    ██        ██   ██
*/

(*mark_debug = "true"*) reg wea_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		wea_right_tmp <= 1'b0;
	end else if ( (curr_state == INIT && init_cnt > HALF_CNT) || (curr_state == STA2 && sta2_cnt > HALF_CNT) ) begin
		wea_right_tmp <= pix_valid;
	end else begin
		wea_right_tmp <= 1'b0;
	end
end
assign wea_right = (wea_right_tmp);

(*mark_debug = "true"*) reg [6:0] addra_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		addra_right_tmp <= 7'b0 - 2'b10;
	end else if ( (curr_state == INIT && init_cnt > HALF_CNT) || (curr_state == STA2 && sta2_cnt > HALF_CNT) ) begin
		addra_right_tmp <= addra_right_tmp + 2'b10;
	end else if ( curr_state == STA1) begin
		addra_right_tmp <= sta1_cnt - 1'b1;
	end else begin
		addra_right_tmp <= 7'b0 - 2'b10;
	end
end
assign addra_right = (addra_right_tmp);


(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] dina_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dina_right_tmp <= {`DATA_WIDTH{1'b0}};
	end else if ( (curr_state == INIT && init_cnt > HALF_CNT) || (curr_state == STA2 && sta2_cnt > HALF_CNT) ) begin
		dina_right_tmp <= {pix_data[63:0],pix_data[127:64]};
	end else begin
		dina_right_tmp <= {`DATA_WIDTH{1'b0}};
	end
end
assign dina_right = (dina_right_tmp);


/*
██      ███████ ███████ ████████     ██████
██      ██      ██         ██        ██   ██
██      █████   █████      ██        ██████
██      ██      ██         ██        ██   ██
███████ ███████ ██         ██        ██████
*/

(*mark_debug = "true"*) reg web_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		web_left_tmp <= 1'b0;
	end else if ( curr_state == STA1 && sta1_cnt <= HALF_CNT) begin
		web_left_tmp <= pix_valid;
	end else begin
		web_left_tmp <= 1'b0;
	end
end
assign web_left = (web_left_tmp);

(*mark_debug = "true"*) reg [6:0] addrb_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		addrb_left_tmp <= LINE_CNT - 2'b10;
	end else if ( curr_state == STA1 && sta1_cnt <= HALF_CNT) begin
		if ( sta1_cnt == 7'd1 ) begin
			addrb_left_tmp <= LINE_CNT;
		end else begin
			addrb_left_tmp <= addrb_left_tmp + 2'b10;
		end
	end else if ( curr_state == STA2) begin
		addrb_left_tmp <= STA2_CNT * 2 - sta2_cnt;
	end else begin
		addrb_left_tmp <= LINE_CNT - 2'b10;
	end
end
assign addrb_left = (addrb_left_tmp);


(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] dinb_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dinb_left_tmp <= {`DATA_WIDTH{1'b0}};
	end else if ( curr_state == STA1 && sta1_cnt <= HALF_CNT) begin
		dinb_left_tmp <= {pix_data[63:0],pix_data[127:64]};
	end else begin
		dinb_left_tmp <= {`DATA_WIDTH{1'b0}};
	end
end
assign dinb_left = (dinb_left_tmp);




/*
██████  ██  ██████  ██   ██ ████████     ██████
██   ██ ██ ██       ██   ██    ██        ██   ██
██████  ██ ██   ███ ███████    ██        ██████
██   ██ ██ ██    ██ ██   ██    ██        ██   ██
██   ██ ██  ██████  ██   ██    ██        ██████
*/

(*mark_debug = "true"*) reg web_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		web_right_tmp <= 1'b0;
	end else if ( curr_state == STA1 && sta1_cnt > HALF_CNT) begin
		web_right_tmp <= pix_valid;
	end else begin
		web_right_tmp <= 1'b0;
	end
end
assign web_right = (web_right_tmp);

(*mark_debug = "true"*) reg [6:0] addrb_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		addrb_right_tmp <= LINE_CNT - 2'b10;
	end else if ( curr_state == STA1 && sta1_cnt > HALF_CNT) begin
		addrb_right_tmp <= addrb_right_tmp + 2'b10;
	end else if ( curr_state == STA2) begin
		addrb_right_tmp <= STA2_CNT + sta2_cnt - 1'b1;
	end else begin
		addrb_right_tmp <= LINE_CNT - 2'b10;
	end
end
assign addrb_right = (addrb_right_tmp);


(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] dinb_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		dinb_right_tmp <= {`DATA_WIDTH{1'b0}};
	end else if ( curr_state == STA1 && sta1_cnt > HALF_CNT) begin
		dinb_right_tmp <= {pix_data[63:0],pix_data[127:64]};
	end else begin
		dinb_right_tmp <= {`DATA_WIDTH{1'b0}};
	end
end
assign dinb_right = (dinb_right_tmp);







//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
line_ram line_ram_left (
  .clka(clka_left),    // input wire clka
  .ena(ena_left),      // input wire ena
  .wea(wea_left),      // input wire [0 : 0] wea
  .addra(addra_left),  // input wire [6 : 0] addra
  .dina(dina_left),    // input wire [127 : 0] dina
  .douta(douta_left),  // output wire [63 : 0] douta
  .clkb(clkb_left),    // input wire clkb
  .enb(enb_left),      // input wire enb
  .web(web_left),      // input wire [0 : 0] web
  .addrb(addrb_left),  // input wire [6 : 0] addrb
  .dinb(dinb_left),    // input wire [127 : 0] dinb
  .doutb(doutb_left)  // output wire [63 : 0] doutb
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
line_ram line_ram_right (
  .clka(clka_right),    // input wire clka
  .ena(ena_right),      // input wire ena
  .wea(wea_right),      // input wire [0 : 0] wea
  .addra(addra_right),  // input wire [6 : 0] addra
  .dina(dina_right),    // input wire [127 : 0] dina
  .douta(douta_right),  // output wire [63 : 0] douta
  .clkb(clkb_right),    // input wire clkb
  .enb(enb_right),      // input wire enb
  .web(web_right),      // input wire [0 : 0] web
  .addrb(addrb_right),  // input wire [6 : 0] addrb
  .dinb(dinb_right),    // input wire [127 : 0] dinb
  .doutb(doutb_right)  // output wire [63 : 0] doutb
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

/**
 * ouput a
 */
(*mark_debug = "true"*) reg valid_a_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_a_left_tmp <= 1'b0;
	end else if ( curr_state == STA1 ) begin
		valid_a_left_tmp <= 1'b1;
	end else begin
		valid_a_left_tmp <= 1'b0;
	end
end

(*mark_debug = "true"*) reg valid_a_left_tmp_d0, valid_a_left_tmp_d1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_a_left_tmp_d0 <= 1'b0;
		valid_a_left_tmp_d1 <= 1'b0;
	end else begin
		valid_a_left_tmp_d0 <= valid_a_left_tmp;
		valid_a_left_tmp_d1 <= valid_a_left_tmp_d0;
	end
end


(*mark_debug = "true"*) reg valid_a_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_a_right_tmp <= 1'b0;
	end else if ( curr_state == STA1 ) begin
		valid_a_right_tmp <= 1'b1;
	end else begin
		valid_a_right_tmp <= 1'b0;
	end
end

(*mark_debug = "true"*) reg valid_a_right_tmp_d0, valid_a_right_tmp_d1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_a_right_tmp_d0 <= 1'b0;
		valid_a_right_tmp_d1 <= 1'b0;
	end else begin
		valid_a_right_tmp_d0 <= valid_a_right_tmp;
		valid_a_right_tmp_d1 <= valid_a_right_tmp_d0;
	end
end

/**
 * output b
 */
(*mark_debug = "true"*) reg valid_b_left_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_b_left_tmp <= 1'b0;
	end else if ( curr_state == STA2 ) begin
		valid_b_left_tmp <= 1'b1;
	end else begin
		valid_b_left_tmp <= 1'b0;
	end
end

(*mark_debug = "true"*) reg valid_b_left_tmp_d0, valid_b_left_tmp_d1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_b_left_tmp_d0 <= 1'b0;
		valid_b_left_tmp_d1 <= 1'b0;
	end else begin
		valid_b_left_tmp_d0 <= valid_b_left_tmp;
		valid_b_left_tmp_d1 <= valid_b_left_tmp_d0;
	end
end


(*mark_debug = "true"*) reg valid_b_right_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_b_right_tmp <= 1'b0;
	end else if ( curr_state == STA2 ) begin
		valid_b_right_tmp <= 1'b1;
	end else begin
		valid_b_right_tmp <= 1'b0;
	end
end

(*mark_debug = "true"*) reg valid_b_right_tmp_d0, valid_b_right_tmp_d1;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		valid_b_right_tmp_d0 <= 1'b0;
		valid_b_right_tmp_d1 <= 1'b0;
	end else begin
		valid_b_right_tmp_d0 <= valid_b_right_tmp;
		valid_b_right_tmp_d1 <= valid_b_right_tmp_d0;
	end
end





/**
 * pix_valid_o
 */
(*mark_debug = "true"*) reg pix_valid_o_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		pix_valid_o_tmp <= 1'b0;
	end else if ( valid_a_right_tmp_d1 ) begin
		pix_valid_o_tmp <= 1'b1;
	end else if ( valid_b_right_tmp_d1 ) begin
		pix_valid_o_tmp <= 1'b1;
	end	else begin
		pix_valid_o_tmp <= 1'b0;
	end
end
assign pix_valid_o = (pix_valid_o_tmp);




(*mark_debug = "true"*) reg [`DATA_WIDTH-1:0] pix_data_o_tmp;
always @ (posedge clk or negedge rst_n ) begin
	if ( !rst_n ) begin
		pix_data_o_tmp <= {`DATA_WIDTH{1'b0}};
	end else if ( valid_a_right_tmp_d1 ) begin
		pix_data_o_tmp <= {douta_left, douta_right};
	end else if ( valid_b_right_tmp_d1 ) begin
		pix_data_o_tmp <= {doutb_left, doutb_right};
	end	else begin
		pix_data_o_tmp <= {`DATA_WIDTH{1'b0}};
	end
end
assign pix_data_o = (pix_data_o_tmp);






endmodule // the end of line_divide_top
