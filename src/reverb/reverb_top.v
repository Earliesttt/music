module reverb_top (
    input wire clk,                               // 时钟信号
    input wire ce,                           // 高电平使能
    input wire [ADC_DATA_WIDTH-1:0] iir_dout,             // 16位宽的输入音频数据
    input wire reverb_start,                             // 开始信号
    input [SAMPLE_WIDTH -1:0] delay_samples,         // 采样数
    output wire [DAC_DATA_WIDTH -1:0] Reverb_Out,                   // 输出带回声效果的音频
    output wire reverb_Done                          // 回声处理完成信号
);

    parameter SAMPLE_WIDTH = 10;                   // 采样点宽度
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=19;
    parameter ADC_DATA_WIDTH=32;
    parameter DAC_DATA_WIDTH=38;
	parameter wet_dry_mix        = 0; 
	parameter feedback_gain        = 1; 

    wire [SINGLE_ADC_WIDTH -1:0] Reverb_left_data;
    wire [SINGLE_ADC_WIDTH -1:0] Reverb_right_data;
    wire [SINGLE_DAC_WIDTH -1:0] Reverb_Out_left_data;
    wire [SINGLE_DAC_WIDTH -1:0] Reverb_Out_right_data;



    assign Reverb_left_data = iir_dout[ADC_DATA_WIDTH -1 : SINGLE_ADC_WIDTH];
    assign Reverb_right_data = iir_dout[SINGLE_ADC_WIDTH -1:0];

    assign Reverb_Out = {Reverb_Out_left_data, Reverb_Out_right_data};
    assign reverb_Done = Reverb_Done_left && Reverb_Done_right;


    reverb #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
    )
    reverb_left(
        .clk(clk),                // 时钟信号
        .ce(ce),              // 复位信号
        .Data(Reverb_left_data),        // 16位宽的输入音频数据
        .delay_samples(delay_samples), // 延迟的采样点数
        .start(reverb_start),                             // 开始信号
        .feedback_gain(feedback_gain), // 反馈系数（调整参数）
        .wet_dry_mix(wet_dry_mix),    // 干湿比例（调整参数）
        .Reverb_Done(Reverb_Done_left),                    // 处理完成信号
        .Reverb_Out(Reverb_Out_left_data)
    );

    reverb #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
    )
    reverb_right(
        .clk(clk),                // 时钟信号
        .ce(ce),              // 复位信号
        .Data(Reverb_right_data),        // 16位宽的输入音频数据
        .delay_samples(delay_samples), // 延迟的采样点数
        .start(reverb_start),                             // 开始信号
        .feedback_gain(feedback_gain), // 反馈系数（调整参数）
        .wet_dry_mix(wet_dry_mix),    // 干湿比例（调整参数）
        .Reverb_Done(Reverb_Done_right),                    // 处理完成信号
        .Reverb_Out(Reverb_Out_right_data)
    );

endmodule