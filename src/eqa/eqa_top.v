module eqa_top (
    input wire clk,                               // 时钟信号
    input wire ce,                           // 高电平使能
    input wire [ADC_DATA_WIDTH -1:0] iir_dout,             // 16位宽的输入音频数据
    input wire eqa_start,                             // 开始信号

    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_a_1, coeff_a_2, coeff_a_3, coeff_a_4, coeff_a_5,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_b_1, coeff_b_2, coeff_b_3, coeff_b_4, coeff_b_5,
    input coeff_we_1, coeff_we_2, coeff_we_3, coeff_we_4, coeff_we_5,
    input coeff_set_1, coeff_set_2, coeff_set_3, coeff_set_4, coeff_set_5,

    output wire [DAC_DATA_WIDTH -1:0] Eqa_Out,                   // 输出带回声效果的音频
    output wire eqa_Done                          // 回声处理完成信号
);

	parameter SAMPLE_WIDTH= 13;
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=19;
    parameter ADC_DATA_WIDTH=32;
    parameter DAC_DATA_WIDTH=38;
	parameter RAM_WIDTH         = 18;
    parameter COEFFICIENT_DATA_WIDTH = 18;


    wire [SINGLE_ADC_WIDTH -1:0] eqa_left_data;
    wire [SINGLE_ADC_WIDTH -1:0] eqa_right_data;
    wire [SINGLE_DAC_WIDTH -1:0] eqa_Out_left_data;
    wire [SINGLE_DAC_WIDTH -1:0] eqa_Out_right_data;

    assign eqa_left_data = iir_dout[ADC_DATA_WIDTH -1 :SINGLE_ADC_WIDTH];
    assign eqa_right_data = iir_dout[SINGLE_ADC_WIDTH -1 :0];

    assign Eqa_Out = {eqa_Out_left_data, eqa_Out_right_data};
    assign eqa_Done = eqa_Done_left && eqa_Done_right;

    eqa #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH)
    )
    eqa_left(
        .clk(clk),                // 时钟信号
        .reset_n(ce),              // 复位信号
        .Eqa_in(eqa_left_data),        // 16位宽的输入音频数据
        .eqa_start(eqa_start),                // 开始
        .coeff_a_1(coeff_a_1),
        .coeff_b_1(coeff_b_1),
        .coeff_we_1(coeff_we_1),
        .coeff_set_1(coeff_set_1),

        .coeff_a_2(coeff_a_2),
        .coeff_b_2(coeff_b_2),
        .coeff_we_2(coeff_we_2),
        .coeff_set_2(coeff_set_2),

        .coeff_a_3(coeff_a_3),
        .coeff_b_3(coeff_b_3),
        .coeff_we_3(coeff_we_3),
        .coeff_set_3(coeff_set_3),

        .coeff_a_4(coeff_a_4),
        .coeff_b_4(coeff_b_4),
        .coeff_we_4(coeff_we_4),
        .coeff_set_4(coeff_set_4),

        .coeff_a_5(coeff_a_5),
        .coeff_b_5(coeff_b_5),
        .coeff_we_5(coeff_we_5),
        .coeff_set_5(coeff_set_5),

        .Eqa_Out(eqa_Out_left_data),      // 输出带回声效果的音频
        .eqa_Done(eqa_Done_left)  
    );

    eqa #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH)
    )
    eqa_right(
        .clk(clk),                // 时钟信号
        .reset_n(ce),              // 复位信号
        .Eqa_in(eqa_right_data),        // 16位宽的输入音频数据
        .eqa_start(eqa_start),                // 开始
        .coeff_a_1(coeff_a_1),
        .coeff_b_1(coeff_b_1),
        .coeff_we_1(coeff_we_1),
        .coeff_set_1(coeff_set_1),

        .coeff_a_2(coeff_a_2),
        .coeff_b_2(coeff_b_2),
        .coeff_we_2(coeff_we_2),
        .coeff_set_2(coeff_set_2),

        .coeff_a_3(coeff_a_3),
        .coeff_b_3(coeff_b_3),
        .coeff_we_3(coeff_we_3),
        .coeff_set_3(coeff_set_3),

        .coeff_a_4(coeff_a_4),
        .coeff_b_4(coeff_b_4),
        .coeff_we_4(coeff_we_4),
        .coeff_set_4(coeff_set_4),

        .coeff_a_5(coeff_a_5),
        .coeff_b_5(coeff_b_5),
        .coeff_we_5(coeff_we_5),
        .coeff_set_5(coeff_set_5),

        .Eqa_Out(eqa_Out_right_data),      // 输出带回声效果的音频
        .eqa_Done(eqa_Done_right)  
    );


endmodule