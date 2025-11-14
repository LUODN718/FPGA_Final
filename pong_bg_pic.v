`timescale 1ns / 1ns
module pong_bg (
    input wire vga_clk, sys_rst_n,
    input wire [9:0] pix_x, pix_y,
    input wire game_over,
    output reg [15:0] pix_data
);
    localparam WHITE = 16'hFFFF, BLACK = 16'h0000;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) pix_data <= BLACK;
        else if (game_over) pix_data <= BLACK;  // 结束：全黑
        else begin
            // 边框（细线）
            if ((pix_x < 10 || pix_x > 630 || pix_y < 10 || pix_y > 470))
                pix_data <= WHITE;
            else pix_data <= BLACK;  // 背景黑
        end
    end
endmodule
