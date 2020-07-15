/**
 * Filename :   led_signal.v
 * Function :   Setting for led blink as flag
 * Drafter  :   junkai_liu
 * Version  :   0.1
 * Date     :   2019-08-06
 * Modification history  :
 *              2019-08-06  Create the demon, design for 1 ouput pin
 */
module led_signal
#(  parameter sys_clock = 8'd150, led_type = 1'b0 ) (
    input               clk,
    input               rst_n,
    input               led_en,         // High :enable;
    input [3:0]         blink_type,

    output              led_signal
    );

/**
 * Caculate the 1 second depends on the sys_clock
 * The sys_clock of this design is 150M
 * create sec ms us 1 clk pluse
 */
localparam count_sec = sys_clock * 32'd100_0000;
localparam count_ms  = count_sec / 32'd1000;
localparam count_us  = count_sec / 32'd100_0000;

reg [31:0] counter_sec;
reg second;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        counter_sec <= 32'b0;
        second <= 1'b0;
    end else if ( counter_sec == count_sec && led_en ) begin
        second <= 1'b1;
        counter_sec <= 32'b0;
    end else begin
        second <= 1'b0;
        counter_sec <= counter_sec + 1'b1;
    end
end

reg [31:0] counter_ms;
reg million_sec;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        counter_ms <= 32'b0;
        million_sec <= 1'b0;
    end else if ( counter_ms == count_ms && led_en ) begin
        million_sec <= 1'b1;
        counter_ms <= 32'b0;
    end else begin
        million_sec <= 1'b0;
        counter_ms <= counter_ms + 1'b1;
    end
end

// reg [31:0] counter_us;
// reg micro_sec;
// always @ (posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         counter_us <= 32'b0;
//         micro_sec <= 1'b0;
//     end else if ( counter_us == count_us && led_en ) begin
//         micro_sec <= 1'b1;
//         counter_us <= 32'b0;
//     end else begin
//         micro_sec <= 1'b0;
//         counter_us <= counter_us + 1'b1;
//     end
// end

/**
 * led blink type 0000
 * 1s light 1s black
 */
reg q_a;
always @ (posedge second or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_a <= ~led_type;
    end else begin
        q_a <= ~q_a;
    end
end

/**
 * led blink type 0001
 * 500ms light 500ms black
 */
localparam   STOP_B = 16'd500;
reg q_b;
reg [31:0] q_b_count;
always @ (posedge million_sec or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_b <= ~led_type;
        q_b_count <= 32'b0;
    end else if ( q_b_count == STOP_B ) begin
        q_b <= ~q_b;
        q_b_count <= 32'b0;
    end else begin
        q_b_count <= q_b_count + 1'b1;
    end
end

/**
 * led blink type 0010
 * 200ms light 200ms black
 */
localparam   STOP_C = 16'd200;
reg q_c;
reg [31:0] q_c_count;
always @ (posedge million_sec or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_c <= ~led_type;
        q_c_count <= 32'b0;
    end else if ( q_c_count == STOP_C ) begin
        q_c <= ~q_c;
        q_c_count <= 32'b0;
    end else begin
        q_c_count <= q_c_count + 1'b1;
    end
end

/**
 * led blink type 0011
 * 3s black 200ms light 200ms black 200ms light
 */
localparam  black_timel = 16'd3,
            black_times = 16'd200,
            light_timel = 16'd200,
            light_times = 16'd200;
reg q_d_en;
reg [31:0]  q_d_count;
always @ (posedge second or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_d_en <= 1'b0;
        q_d_count <= 32'b0;
    end else if ( q_d_count == black_timel ) begin
        q_d_en <= 1'b1;
        q_d_count <= 32'b0;
    end else begin
        q_d_en <= 1'b0;
        q_d_count <= q_d_count + 1'b1;
    end
end

reg q_d;
reg [31:0] q_d_count0;
always @ (posedge million_sec or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_d <= ~led_type;
        q_d_count0 <= 32'b0;
    end else if ( q_d_en && q_d_count0 <= light_timel ) begin
        q_d <= led_type;
        q_d_count0 <= q_d_count0 + 1'b1;
    end else if (q_d_en && q_d_count0 <= light_timel + light_times) begin
        q_d <= ~led_type;
        q_d_count0 <= q_d_count0 + 1'b1;
    end else if (q_d_en && q_d_count0 <= light_timel * 2'b10 + light_times) begin
        q_d <= led_type;
        q_d_count0 <= q_d_count0 + 1'b1;
    end else if (!q_d_en) begin
        q_d <= ~led_type;
        q_d_count0 <= 32'b0;
    end else begin
        q_d <= ~led_type;
    end
end


/**
 * [led_signal type output ]
 */
reg q_out;
always @ (posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        q_out <= ~led_type;
    end else begin
        case ( blink_type )
            4'h0    : q_out <= q_a;
            4'h1    : q_out <= q_b;
            4'h2    : q_out <= q_c;
            4'h3    : q_out <= q_d;
            default : q_out <= q_d;
        endcase
    end
end

assign led_signal = (q_out);




endmodule // led_signal
