module echo_top (
    input wire clk,                               // 时钟信号
    input wire ce,                           // 高电平使能
    input wire [ADC_DATA_WIDTH -1:0] iir_dout,             // 16位宽的输入音频数据
    input wire echo_start,                             // 开始信号
    input [SAMPLE_WIDTH -1:0] delay_samples,         // 采样数
    output wire [DAC_DATA_WIDTH -1:0] Echo_Out,                   // 输出带回声效果的音频
    output wire echo_Done                          // 回声处理完成信号
);

	parameter SAMPLE_WIDTH= 13;
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=19;
    parameter ADC_DATA_WIDTH=32;
    parameter DAC_DATA_WIDTH=38;

    wire [SINGLE_ADC_WIDTH -1:0] Echo_left_data;
    wire [SINGLE_ADC_WIDTH -1:0] Echo_right_data;
    wire [SINGLE_DAC_WIDTH -1:0] Echo_Out_left_data;
    wire [SINGLE_DAC_WIDTH -1:0] Echo_Out_right_data;

    assign Echo_left_data = iir_dout[ADC_DATA_WIDTH -1 :SINGLE_ADC_WIDTH];
    assign Echo_right_data = iir_dout[SINGLE_ADC_WIDTH -1 :0];

    assign Echo_Out = {Echo_Out_left_data, Echo_Out_right_data};
    assign echo_Done = echo_Done_left && echo_Done_right;

    echo #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
    )
    echo_left(
        .clk(clk),                // 时钟信号
        .ce(ce),              // 复位信号
        .Data(Echo_left_data),        // 16位宽的输入音频数据
        .delay_samples(delay_samples), // 延迟的采样点数
        .start(echo_start),                // 开始
        .Echo_Out(Echo_Out_left_data),      // 输出带回声效果的音频
        .echo_Done(echo_Done_left)  
    );

    echo #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .SAMPLE_WIDTH(SAMPLE_WIDTH)
    )
    echo_right(
        .clk(clk),                // 时钟信号
        .ce(ce),              // 复位信号
        .Data(Echo_right_data),        // 16位宽的输入音频数据
        .delay_samples(delay_samples), // 延迟的采样点数
        .start(echo_start),                // 开始
        .Echo_Out(Echo_Out_right_data),      // 输出带回声效果的音频
        .echo_Done(echo_Done_right)  
    );


endmodule