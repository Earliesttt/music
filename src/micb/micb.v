module micb(
    Clk,
    Rst_n,

    MICB_up,
    up_Done,

    Go,
    MICB_Power,
    led_up
);

    input Clk;
    input Rst_n;
    input MICB_up;

    output up_Done;
    output reg MICB_Power;
    output reg Go;
    output reg led_up;


    reg [1:0] state, next_state;
    reg Go_ro;

    // 状态编码
    localparam IDLE = 2'd0,
               MICB_TURN = 2'd1,
               Go_ro_STATE = 2'd2;

    // 状态寄存器
    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 输出和寄存器更新逻辑
    always @(posedge Clk or negedge Rst_n) begin
        if (!Rst_n) begin
            MICB_Power <= 1'b0;
            led_up <= 1'b0;
            Go_ro <= 1'b0;
        end else begin
            case(state)
                IDLE: begin
                    Go_ro <= 1'b0;
                    if (up_Done)
                        next_state = MICB_TURN;
                    else
                        next_state = IDLE;
                end
                MICB_TURN: begin
                    Go_ro <= 1'b0;
                    MICB_Power <= ~MICB_Power;
                    led_up <= ~led_up;
                    next_state = Go_ro_STATE;
                end
                Go_ro_STATE: begin
                    Go_ro <= 1'b1;
                    next_state = IDLE;        
                end
                default: next_state = IDLE;
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
    key_filter MICB_key_filter(
        .clk(Clk),
        .reset_n(Rst_n),
        .key_in(MICB_up),
        .key_flag(),
        .key_state(),
        .led(),
        .adclrc_pose(up_Done)
    );

endmodule
