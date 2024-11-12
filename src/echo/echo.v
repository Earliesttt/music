module echo (
    input wire clk,                               // 时钟信号
    input wire ce,                           // 低电平有效复位信号
    input wire [SINGLE_ADC_WIDTH-1:0] Data,             // 16位宽的输入音频数据
    input wire [SAMPLE_WIDTH-1:0] delay_samples,  // 延迟的采样点数
    input wire start,                             // 开始信号
    output reg [SINGLE_DAC_WIDTH -1:0] Echo_Out,                   // 输出带回声效果的音频
    output reg echo_Done                          // 回声处理完成信号
);

    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=19;
    parameter SAMPLE_WIDTH = 13;                   // 采样点宽度

    // FIFO接口信号
    wire [SINGLE_ADC_WIDTH-1:0] fifo_out;               // FIFO的输出数据
    wire fifo_empty, fifo_full;                   // FIFO状态信号
    reg WrEn, RdEn;                               // 写入和读取使能信号
    reg [SAMPLE_WIDTH-1:0] count;                 // 计数器用于延迟控制
    wire Reset;

    // 复位信号
    assign Reset = ~ce ;

    // FIFO实例化
    fifo_sc_top fifo_sc_top_inst (
        .Data(Data),               // 输入数据
        .Reset(Reset),             // 复位信号
        .Clk(clk),                 // 时钟
        .WrEn(WrEn),               // 写入使能
        .RdEn(RdEn),               // 读取使能
        .Almost_Empty(),
        .Almost_Full(),
        .Q(fifo_out),              // 输出数据
        .Empty(fifo_empty),        // 空标志
        .Full(fifo_full)           // 满标志
    );

    // 写入计数器和回声处理逻辑
    always @(posedge clk or negedge ce) 
    begin
        if (~ce) 
        begin
            echo_Done <= 1'b0;      // 重置处理完成标志
            Echo_Out <= 16'b0;      // 清空输出
            count <= 0;             // 重置计数器
            WrEn <= 1'b0;           // 停止写入FIFO
            RdEn <= 1'b0;        // 不读取FIFO
        end 
        else 
        begin
            if (start && count == delay_samples) 
            begin
                    WrEn <= 1'b0;        // 停止写入FIFO
                    RdEn <= 1'b1;        // 启用读取FIFO
                    Echo_Out <= Data + fifo_out;  // 输出带回声的音频
                    echo_Done <= 1'b1;   // 标记处理完成
                    count <= count - 1;  // 增加计数器
            end
            else if (count < delay_samples) 
            begin
                    echo_Done <= 1'b0;   // 处理未完成
                    RdEn <= 1'b0;        // 暂不读取FIFO
                    WrEn <= 1'b1;        // 继续写入FIFO
                    count <= count + 1;  // 增加计数器
            end
            else
            begin
                echo_Done <= 1'b0;      // 重置处理完成标志
                RdEn <= 1'b0;           // 停止读取FIFO 
                WrEn <= 1'b0;           // 停止写入FIFO
            end 
        end
    end
endmodule
