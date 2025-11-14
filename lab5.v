`timescale 1ns / 1ns

module lab5(
    input wire sys_clk, sys_rst_n,
    input wire btn_left, btn_right,  // 木块控制
    output wire hsync, vsync,
    output wire [15:0] rgb,
    output wire game_over
);

    // 参数定义（像素单位）
    parameter PADDLE_Y   = 420;    // 木块 Y（底部）
    parameter PADDLE_W   = 40;     // 木块宽
    parameter PADDLE_H   = 100;    // 木块高
    parameter BALL_SIZE  = 16;     // 弹球大小
    localparam SCREEN_W  = 640;
    localparam SCREEN_H  = 480;

    // 内部信号
    wire vga_clk;
    wire [9:0] pix_x, pix_y;
    wire [15:0] pix_data_paddle, pix_data_ball, pix_data_bg;
    reg [15:0] pix_data;
    reg [9:0] paddle_x;            // 木块 X（中心）
    reg [9:0] ball_x, ball_y;      // 弹球位置
    reg [3:0] ball_dx, ball_dy;    // 弹球速度（有符号，2~4）
    reg [9:0] ball_x_next, ball_y_next;
    wire frame_start;              // 帧开始（vsync 边沿，用于更新位置）
    reg game_over_reg;

    // 时钟分频 50MHz -> 25MHz
    reg [1:0] clk_div;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            clk_div <= 2'b00;
            vga_clk <= 0;
        end else begin
            clk_div <= clk_div + 1;
            vga_clk <= clk_div[0];
        end
    end

    // VGA 控制器（复用原有）
    vga_ctrl vga_ctrl_inst (
        .vga_clk(vga_clk),
        .sys_rst_n(sys_rst_n),
        .pix_data(pix_data),
        .pix_x(pix_x),
        .pix_y(pix_y),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    // 渲染模块实例化
    pong_paddle pong_paddle_inst (
        .vga_clk(vga_clk), .sys_rst_n(sys_rst_n),
        .pix_x(pix_x), .pix_y(pix_y),
        .paddle_x(paddle_x),
        .pix_data(pix_data_paddle)
    );

    pong_ball pong_ball_inst (
        .vga_clk(vga_clk), .sys_rst_n(sys_rst_n),
        .pix_x(pix_x), .pix_y(pix_y),
        .ball_x(ball_x), .ball_y(ball_y),
        .pix_data(pix_data_ball)
    );

    pong_bg pong_bg_inst (
        .vga_clk(vga_clk), .sys_rst_n(sys_rst_n),
        .pix_x(pix_x), .pix_y(pix_y),
        .game_over(game_over_reg),
        .pix_data(pix_data_bg)
    );

    // 像素选择（优先级：paddle > ball > bg）
    always @(*) begin
        if (pix_data_paddle != 0) pix_data = pix_data_paddle;
        else if (pix_data_ball != 0) pix_data = pix_data_ball;
        else pix_data = pix_data_bg;
    end

    // 帧开始检测（垂直同步上升沿，每帧更新一次位置）
    reg vsync_prev;
    always @(posedge vga_clk) vsync_prev <= vsync;
    assign frame_start = vsync && !vsync_prev;

    // 木块移动（按键边沿检测 + 边界限制）
    reg left_prev, right_prev;
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            paddle_x <= (SCREEN_W / 2);
            left_prev <= 0;
            right_prev <= 0;
        end else begin
            left_prev <= btn_left;
            right_prev <= btn_right;
            if (btn_left && !left_prev) paddle_x <= (paddle_x > 20) ? paddle_x - 20 : 20;
            if (btn_right && !right_prev) paddle_x <= (paddle_x < SCREEN_W - 20) ? paddle_x + 20 : SCREEN_W - 20;
        end
    end

    // 弹球物理更新（每帧）
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            ball_x <= SCREEN_W / 2;
            ball_y <= SCREEN_H / 2;
            ball_dx <= 3;  // 右上初始
            ball_dy <= -2;
            game_over_reg <= 0;
        end else if (frame_start && !game_over_reg) begin
            ball_x <= ball_x_next;
            ball_y <= ball_y_next;

            // 碰撞检测 & 反弹
            // 左右墙
            if (ball_x_next <= 0 || ball_x_next >= SCREEN_W - BALL_SIZE) begin
                ball_dx <= -ball_dx;
            end
            // 上下墙
            if (ball_y_next <= 0) begin
                ball_dy <= -ball_dy;
            end
            // 底部（游戏结束）
            if (ball_y_next >= SCREEN_H - BALL_SIZE) begin
                game_over_reg <= 1;
            end
            // 木块碰撞（简单：X 重叠 + Y 在木块范围内，反弹 Y）
            if (ball_x_next + BALL_SIZE >= paddle_x - PADDLE_W/2 &&
                ball_x_next <= paddle_x + PADDLE_W/2 &&
                ball_y_next + BALL_SIZE >= PADDLE_Y) begin
                ball_dy <= -ball_dy;
                ball_dx <= ball_dx + (ball_x_next > paddle_x ? 1 : -1);  // 角度变化
            end
        end else if (!sys_rst_n) begin
            game_over_reg <= 0;
        end
    end

    // 下一位置计算（组合逻辑）
    always @(*) begin
        ball_x_next = ball_x + ball_dx;
        ball_y_next = ball_y + ball_dy;
    end

    assign game_over = game_over_reg;

endmodule
