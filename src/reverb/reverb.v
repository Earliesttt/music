module reverb (
    input wire clk,                 // 时钟信号
    input wire ce,               // 复位信号（低电平有效）
    input wire [SINGLE_ADC_WIDTH-1:0] Data,     // 输入音频信号（16-bit）
    input wire start,                             // 开始信号
    input wire [SAMPLE_WIDTH-1:0] delay_samples,  // 延迟的采样点数
    input wire [4:0] feedback_gain, // 反馈系数（调整参数）
    input wire [4:0] wet_dry_mix,    // 干湿比例（调整参数）
    output reg Reverb_Done,                    // 处理完成信号
    output reg [SINGLE_DAC_WIDTH-1:0]  Reverb_Out
);

    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=16;
    parameter SAMPLE_WIDTH = 10;                   // 采样点宽度

    parameter state_idle        = 2'd0;   //空闲状态
    parameter state_leftdata   = 2'd1;   //采集左通道数据
    parameter state_final  = 2'd2;   //采集完成道数据

    wire [SINGLE_ADC_WIDTH-1:0] fifo_out;               // FIFO的输出数据
    wire fifo_empty;                // FIFO空标志
    wire fifo_full;                 // FIFO满标志
    wire Reset;
    reg WrEn, RdEn;                               // 写入和读取使能信号
    reg [SAMPLE_WIDTH-1:0] count;                 // 计数器用于延迟控制
    reg flag;
    reg flag_1;
    reg [SINGLE_ADC_WIDTH-1:0] Data_in;
    // 干湿信号混合
    wire [31:0] wet_signal;
    wire [31:0] dry_signal;
    wire [31:0] mixed_signal;
    wire [15:0] feedback_signal;
    // 复位信号
    assign Reset = ~ce;   

    // FIFO实例化
    fifo_sc_top_v2 fifo_sc_top_v2_inst (
        .Data(Data_in), // 反馈信号与当前输入相加
        .Reset(Reset),              // 复位信号，低电平有效
        .Clk(clk),                   // 时钟
        .WrEn(WrEn),                 // 写入使能
        .RdEn(RdEn),                 // 读取使能
        .Almost_Empty(),             // FIFO快空
        .Almost_Full(),              // FIFO快满
        .Q(fifo_out),                // FIFO输出数据
        .Empty(fifo_empty),          // FIFO空标志
        .Full(fifo_full)             // FIFO满标志
    );

    always @(posedge clk or negedge ce) 
    begin
        if (~ce) 
        begin
            Reverb_Done <= 1'b0;      // 重置处理完成标志
            RdEn <= 1'b0;           // 停止读取FIFO
            WrEn <= 1'b0;           // 停止写入FIFO
            count <= 0;             // 重置计数器
            Reverb_Out <= 0;
            flag <= 0;
            flag_1 <= 0;
        end 
        else if (start && count == delay_samples) 
        begin
                WrEn <= 1'b0;        // 停止写入FIFO
                RdEn <= 1'b1;        // 启用读取FIFO
                Reverb_Done <= 1'b1;   // 标记处理完成
                count <= count - 1;  // 增加计数器
                Reverb_Out = Data + fifo_out ;  // 取低16位作为输出
                flag <= 1;
                flag_1 <= 1;
        end
        else if (count < delay_samples && ~flag_1) 
        begin
                flag <= 0;
                Reverb_Done <= 1'b0;   // 处理未完成
                RdEn <= 1'b0;        // 暂不读取FIFO
                WrEn <= 1'b1;        // 继续写入FIFO
                count <= count + 1;  // 增加计数器
                Data_in <= Data;
        end
        else if (count < delay_samples && outvalid && flag_1) 
        begin
                flag <= 0;
                Reverb_Done <= 1'b0;   // 处理未完成
                RdEn <= 1'b0;        // 暂不读取FIFO
                WrEn <= 1'b1;        // 继续写入FIFO
                count <= count + 1;  // 增加计数器
                Data_in <= dout;
        end
        else
        begin
            Reverb_Done <= 1'b0;      // 重置处理完成标志
            RdEn <= 1'b0;           // 停止读取FIFO 
            WrEn <= 1'b0;           // 停止写入FIFO
            flag <= 1'b0;
        end 
    end

    always@(posedge clk or negedge ce)
    if(~ce)
    begin
        state <= state_idle;
        inpvalid <= 0;
        din <= 0; 
    end
    else begin
        case(state)
            state_idle:
            begin
                inpvalid <= 0;
                if(flag && input_ready)
                begin
                    din <= Reverb_Out;
                    state <= state_leftdata;
                end
            end

            state_leftdata:
            begin
                    inpvalid <= 1;
                    state <= state_final;
            end

            state_final:
            begin
                inpvalid <= 0;
                state <= state_idle;
            end

            default: state <= state_idle;

        endcase
    end

    wire [SINGLE_ADC_WIDTH-1:0] dout;
    reg inpvalid;
    wire input_ready;
    wire outvalid;        
    reg [SINGLE_ADC_WIDTH-1:0] din;
    reg [1:0] state;

    IIR_Filter__reverb IIR_Filter__reverb(
            .clk(clk), //input clk
            .rstn(ce), //input rstn
            .ce(1'b1), //input ce
            .coeff_we(1'b0), //input coeff_we
            .coeff_set(1'b0), //input coeff_set
            .coeff_a(18'b0), //input [18:0] coeff_a
            .coeff_b(18'b0), //input [18:0] coeff_b
            .input_ready(input_ready), //output input_ready_left
            .inpvalid(inpvalid), //input inpvalid_left
            .din(din), //input  din
            .outvalid(outvalid), //output outvalid_left
            .dout(dout) //output  dout
        );

endmodule
