`timescale 1ns / 1ns

module DevelopmentBoard(
    input wire clk,      // 50MHz
    input wire reset,    // 复位
    input wire B2, B3,   // B2:左移, B3:右移 (B4,B5 未用)
    output wire h_sync, v_sync,
    output wire [15:0] rgb,
    output wire led1, led2, led3, led4, led5
);

    wire game_over;      // 来自 lab4 的游戏结束信号

    lab4 lab4_inst (
        .sys_clk(clk),
        .sys_rst_n(~reset),  // 低有效复位
        .btn_left(B2),       // 左移
        .btn_right(B3),      // 右移
        .hsync(h_sync),
        .vsync(v_sync),
        .rgb(rgb),
        .game_over(game_over)
    );

    // LED 逻辑
    assign led1 = reset;           // 复位指示
    assign led2 = B2;              // 左键指示
    assign led3 = B3;       // 游戏结束
    assign led4 = game_over;            // 未用（可接木块位置）
    assign led5 = 1'b0;

endmodule
