module distortion (
    input wire clk,                               // 时钟信号
    input wire ce,                                // 低电平有效复位信号
    input wire [ADC_DATA_WIDTH - 1:0] iir_dout,   // 输入的IIR滤波后的音频数据
    input wire start,                             // 开始信号
    input wire [15:0] limit_value,                // 限制幅度的输入信号
    output wire [DAC_DATA_WIDTH - 1:0] Dist_Out,  // 输出带失真的音频
    output wire Dist_Done                         // 失真处理完成信号
);

    parameter SINGLE_ADC_WIDTH = 16;
    parameter SINGLE_DAC_WIDTH = 16;
    parameter ADC_DATA_WIDTH = 32;
    parameter DAC_DATA_WIDTH = 32;

    wire [SINGLE_ADC_WIDTH - 1:0] Dist_left_data;
    wire [SINGLE_ADC_WIDTH - 1:0] Dist_right_data;
    reg [SINGLE_DAC_WIDTH - 1:0] Dist_Out_left_data;
    reg [SINGLE_DAC_WIDTH - 1:0] Dist_Out_right_data;
    reg Dist_Done_left;
    reg Dist_Done_right;

    // 将 iir_dout 分割为左右声道数据
    assign Dist_left_data = iir_dout[ADC_DATA_WIDTH - 1 : SINGLE_ADC_WIDTH];
    assign Dist_right_data = iir_dout[SINGLE_ADC_WIDTH - 1 : 0];

    assign Dist_Out = {Dist_Out_left_data, Dist_Out_right_data};
    assign Dist_Done = Dist_Done_left && Dist_Done_right;

    // 左声道处理
    always @(posedge clk or negedge ce) begin
        if (~ce) begin
            Dist_Out_left_data <= 16'b0;
            Dist_Done_left <= 0;
        end else if (start) begin
            if (Dist_left_data > limit_value) begin
                Dist_Out_left_data <= limit_value;
                Dist_Done_left <= 1;
            end else if (Dist_left_data < -limit_value) begin
                Dist_Out_left_data <= -limit_value;
                Dist_Done_left <= 1;
            end else begin
                Dist_Out_left_data <= Dist_left_data;
                Dist_Done_left <= 0;
            end
        end
    end

    // 右声道处理
    always @(posedge clk or negedge ce) begin
        if (~ce) begin
            Dist_Out_right_data <= 16'b0;
            Dist_Done_right <= 0;
        end else if (start) begin
            if (Dist_right_data > limit_value) begin
                Dist_Out_right_data <= limit_value;
                Dist_Done_right <= 1;
            end else if (Dist_right_data < -limit_value) begin
                Dist_Out_right_data <= -limit_value;
                Dist_Done_right <= 1;
            end else begin
                Dist_Out_right_data <= Dist_right_data;
                Dist_Done_right <= 0;
            end
        end
    end

endmodule
