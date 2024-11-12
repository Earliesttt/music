module volume_control(
    Clk,
    Rst_n,

    volume_up,
    up_Done,

    volume_down,
    down_Done,

    Go,
    volume,
    led_up,
    led_down
);

    input Clk;
    input Rst_n;
    input volume_up;
    input volume_down;

    output up_Done;
    output down_Done;
    output reg [7:0] volume;
    output reg Go;
    output led_up;
    output led_down;

    reg [1:0] state, next_state;
    reg [3:0] cnt;
    reg Go_ro;

    // 状态编码
    localparam IDLE = 2'd0,
               VOLUME_UP = 2'd1,
               VOLUME_DOWN = 2'd2,
               Go_ro_STATE = 2'd3;

    // 状态寄存器
    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 下一个状态逻辑
    always @(posedge Clk) begin
        case(state)
            IDLE: begin
                if (up_Done)
                    next_state = VOLUME_UP;
                else if (down_Done)
                    next_state = VOLUME_DOWN;
                else
                    next_state = IDLE;
            end
            VOLUME_UP: begin
                next_state = Go_ro_STATE;
            end
            VOLUME_DOWN: begin
                next_state = Go_ro_STATE;
            end
            Go_ro_STATE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // 输出和寄存器更新逻辑
    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            Go_ro <= 1'b0;
            cnt <= 4'd0;
        end else begin
            case(state)
                IDLE: begin
                    Go_ro <= 1'b0;
                    // 在IDLE状态下，volume保持不变
                end
                VOLUME_UP: begin
                    if (cnt != 4'd7) begin
                        cnt <= cnt + 1;
                    end
                    Go_ro <= 1'b0;
                end
                VOLUME_DOWN: begin
                    if (cnt != 4'd0) begin
                        cnt <= cnt - 1;
                    end
                    Go_ro <= 1'b0;
                end
                Go_ro_STATE: begin
                    Go_ro <= 1'b1;
                    // 在Go_ro_STATE状态下，volume保持不变
                end
                default: begin
                    cnt <= 4'd4;
                    Go_ro <= 1'b0;
                end
            endcase
        end
    end

    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            volume <= 8'b1100_0011;  // 默认复位后的音量为 0 dB
        end else begin
            case(cnt)
                4'd0:  volume <= 8'b0000_0000;   // 静音
                4'd1:  volume <= 8'b1011_0010;   // -6 dB
                4'd2:  volume <= 8'b1011_0110;   // -4 dB
                4'd3:  volume <= 8'b1011_1011;   // -2 dB
                4'd4:  volume <= 8'b1100_0011;   // 0 dB
                4'd5:  volume <= 8'b1100_0100;   // 2 dB (推算值)
                4'd6:  volume <= 8'b1100_1100;   // 4 dB (推算值)
                4'd7:  volume <= 8'b1111_0000;   // 6 dB (推算值)
                default: volume <= 8'b1100_0011; // 默认值为 0 dB
            endcase
        end
    end


    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            Go <= 1'b0;
        end else begin
            Go <= Go_ro;
        end
    end

    // 键盘滤波模块实例化
    key_filter volume_up_key_filter(
        .clk(Clk),
        .reset_n(Rst_n),
        .key_in(volume_up),
        .key_flag(),
        .key_state(),
        .led(led_up),
        .adclrc_pose(up_Done)
    );

    key_filter volume_down_key_filter(
        .clk(Clk),
        .reset_n(Rst_n),
        .key_in(volume_down),
        .key_flag(),
        .key_state(),
        .led(led_down),
        .adclrc_pose(down_Done)
    );

endmodule
