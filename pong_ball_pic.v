`timescale 1ns / 1ns
module pong_ball (
    input wire vga_clk, sys_rst_n,
    input wire [9:0] pix_x, pix_y,
    input wire [9:0] ball_x, ball_y,
    output reg [15:0] pix_data
);
    localparam BALL_SIZE = 16;
    localparam WHITE = 16'hFFFF;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) pix_data <= 0;
        else begin
            if (pix_x >= ball_x && pix_x < ball_x + BALL_SIZE &&
                pix_y >= ball_y && pix_y < ball_y + BALL_SIZE)
                pix_data <= WHITE;
            else pix_data <= 0;
        end
    end
endmodule
