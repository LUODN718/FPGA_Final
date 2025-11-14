`timescale 1ns / 1ns
module pong_paddle (
    input wire vga_clk, sys_rst_n,
    input wire [9:0] pix_x, pix_y,
    input wire [9:0] paddle_x,
    output reg [15:0] pix_data
);
    localparam PADDLE_W = 40, PADDLE_H = 100, PADDLE_Y = 420;
    localparam WHITE = 16'hFFFF;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) pix_data <= 0;
        else begin
            if (pix_y >= PADDLE_Y && pix_y < PADDLE_Y + PADDLE_H &&
                pix_x >= paddle_x - PADDLE_W/2 && pix_x < paddle_x + PADDLE_W/2)
                pix_data <= WHITE;
            else pix_data <= 0;
        end
    end
endmodule
