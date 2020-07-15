/**
 * Filename     :       ff_divider.v
 * Date         :       2020-01-09
 *
 * Version      :       V 0.1
 * Author       :       liujunkai@lumicore.com.cn
 * Modification history
 *
 */
module ff_divider (
    input               clk,
    input               rst_n,
    input               reset,
    input       [11:0]  dividend,   // dividend
    input       [11:0]  divisor,    // divisor

    output  reg [11:0]  ff_cnt
    );

reg     [11:0]      cmp_tmp;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ff_cnt  <= 12'b0;
        cmp_tmp <= 12'b0;
    end else if ( reset ) begin
        ff_cnt  <= 12'b0;
        cmp_tmp <= divisor;
    end else if ( dividend == cmp_tmp ) begin
        cmp_tmp <= cmp_tmp + divisor;
        ff_cnt  <= ff_cnt + 12'b1;
    end
end
endmodule // ff_divider
