module eqa(
    input reset_n,
    input wire clk,                               // 时钟信号
    input wire [SINGLE_ADC_WIDTH -1:0] Eqa_in,                  // 32位宽的输入音频数据
    input wire eqa_start,                         // 开始信号

    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_a_1, coeff_a_2, coeff_a_3, coeff_a_4, coeff_a_5,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_b_1, coeff_b_2, coeff_b_3, coeff_b_4, coeff_b_5,
    input coeff_we_1, coeff_we_2, coeff_we_3, coeff_we_4, coeff_we_5,
    input coeff_set_1, coeff_set_2, coeff_set_3, coeff_set_4, coeff_set_5,

    output reg [SINGLE_ADC_WIDTH - 1:0] Eqa_Out,      // 输出带回声效果的音频
    output reg eqa_Done                          // 回声处理完成信号
);

//**********************************************************************
// --- Parameter
//**********************************************************************
  	parameter GAIN_WIDTH = 3;
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=16;
    parameter ADC_DATA_WIDTH=32;
    parameter DAC_DATA_WIDTH=32;
	parameter RAM_WIDTH         = 18;
    parameter COEFFICIENT_DATA_WIDTH = 18;

    // 状态定义
    parameter state_rx_idle        = 2'd0;   //空闲状态
    parameter state_rx_leftdata   = 2'd1;   //采集左通道数据
    parameter state_rx_rightdata  = 2'd2;   //采集右通道数据
    parameter state_rx_final  = 2'd3;   //采集完成道数据

    parameter state_tx_idle        = 3'd4;   //空闲状态
    parameter state_tx_leftdata   = 3'd5;   //采集左通道数据
    parameter state_tx_rightdata  = 3'd6;   //采集右通道数据
    parameter state_tx_final  = 3'd7;   //采集完成道数据


//**********************************************************************
//**********************************************************************

    wire [SINGLE_ADC_WIDTH-1:0] left_data;

    assign left_data = Eqa_in;

    // Define 5 registers for coeff_we and coeff_set
 

//**********************************************************************
// --- In/OUT Signal Declaration
//**********************************************************************
 reg [2:0] state_rx, state_tx, state_Coe;
//**********************************************************************
//**********************************************************************
    wire input_ready_1, input_ready_2, input_ready_3, input_ready_4, input_ready_5;

    reg inpvalid_1, inpvalid_2, inpvalid_3, inpvalid_4, inpvalid_5;

    reg [15:0] iir_din_1, iir_din_2, iir_din_3, iir_din_4, iir_din_5;

    always @(posedge clk or negedge reset_n)
    if (~reset_n)
    begin
        state_rx <= state_rx_idle;
        inpvalid_1 <= 0; iir_din_1 <= 0;
        inpvalid_2 <= 0; iir_din_2 <= 0;
        inpvalid_3 <= 0; iir_din_3 <= 0;
        inpvalid_4 <= 0; iir_din_4 <= 0;
        inpvalid_5 <= 0; iir_din_5 <= 0;
    end
    else begin
        case (state_rx)
            state_rx_idle:
            begin
                inpvalid_1 <= 0; inpvalid_2 <= 0; inpvalid_3 <= 0; inpvalid_4 <= 0; inpvalid_5 <= 0;
                if (eqa_start && input_ready_1 && input_ready_2 && input_ready_3 && input_ready_4 && input_ready_5)
                begin
                    iir_din_1 <= left_data;
                    iir_din_2 <= left_data;
                    iir_din_3 <= left_data;
                    iir_din_4 <= left_data;
                    iir_din_5 <= left_data;
                    state_rx <= state_rx_leftdata;
                end
            end

            state_rx_leftdata:
            begin
                inpvalid_1 <= 1;
                inpvalid_2 <= 1;
                inpvalid_3 <= 1;
                inpvalid_4 <= 1;
                inpvalid_5 <= 1;
                state_rx <= state_rx_final;
            end

            state_rx_final:
            begin
                inpvalid_1 <= 0; 
                inpvalid_2 <= 0; 
                inpvalid_3 <= 0;
                inpvalid_4 <= 0;
                inpvalid_5 <= 0;
                state_rx <= state_rx_idle;
            end

            default: state_rx <= state_rx_idle;
        endcase
    end

//**********************************************************************	
//**********************************************************************
    wire [15:0] iir_dout_1, iir_dout_2, iir_dout_3, iir_dout_4, iir_dout_5;

    wire outvalid_1, outvalid_2, outvalid_3, outvalid_4, outvalid_5;

    reg [15:0] reg_left_data_1, reg_left_data_2, reg_left_data_3, reg_left_data_4, reg_left_data_5;

    always@(posedge clk or negedge reset_n)
    if(~reset_n)
    begin
        state_tx <= state_tx_idle;
        reg_left_data_1 <= 0;
        reg_left_data_2 <= 0;
        reg_left_data_3 <= 0;
        reg_left_data_4 <= 0;
        reg_left_data_5 <= 0;
        eqa_Done <= 0;
    end
    else begin
        case(state_tx)
            state_tx_idle:
            begin
                eqa_Done <= 0;
                if(outvalid_1 && outvalid_2 && outvalid_3 && outvalid_4 && outvalid_5)
                begin
                    reg_left_data_1 <= iir_dout_1;
                    reg_left_data_2 <= iir_dout_2;
                    reg_left_data_3 <= iir_dout_3;
                    reg_left_data_4 <= iir_dout_4;
                    reg_left_data_5 <= iir_dout_5;
                    state_tx <= state_tx_rightdata;
                end
            end

            state_tx_rightdata:
            begin
                Eqa_Out <= reg_left_data_1 + reg_left_data_2 + reg_left_data_3 + reg_left_data_4 + reg_left_data_5;
                state_tx <= state_tx_final;
            end

            state_tx_final:
            begin
                eqa_Done <= 1;
                state_tx <= state_tx_idle;
            end

            default: state_tx <= state_tx_idle;
        endcase
    end






//**********************************************************************	
// --- Initial Block
//**********************************************************************

    IIR_Filter_Top_eqa1 IIR_Filter_Top_eqa1 (
        .clk(clk), //input clk
        .rstn(reset_n), //input rstn
        .ce(1'b1), //input ce
        .coeff_we(coeff_we_1), //input coeff_we
        .coeff_set(coeff_set_1), //input coeff_set
        .coeff_a(coeff_a_1), //input [18:0] coeff_a
        .coeff_b(coeff_b_1), //input [18:0] coeff_b
        .input_ready(input_ready_1), //output input_ready_left
        .inpvalid(inpvalid_1), //input inpvalid_left
        .din(iir_din_1), //input din
        .outvalid(outvalid_1), //output outvalid_left
        .dout(iir_dout_1) //output dout
    );

        IIR_Filter_Top_eqa2 IIR_Filter_Top_eqa2 (
        .clk(clk),
        .rstn(reset_n),
        .ce(1'b1),
        .coeff_we(coeff_we_2),
        .coeff_set(coeff_set_2),
        .coeff_a(coeff_a_2),
        .coeff_b(coeff_b_2),
        .input_ready(input_ready_2),
        .inpvalid(inpvalid_2),
        .din(iir_din_2),
        .outvalid(outvalid_2),
        .dout(iir_dout_2)
    );

    IIR_Filter_Top_eqa3 IIR_Filter_Top_eqa3 (
        .clk(clk),
        .rstn(reset_n),
        .ce(1'b1),
        .coeff_we(coeff_we_3),
        .coeff_set(coeff_set_3),
        .coeff_a(coeff_a_3),
        .coeff_b(coeff_b_3),
        .input_ready(input_ready_3),
        .inpvalid(inpvalid_3),
        .din(iir_din_3),
        .outvalid(outvalid_3),
        .dout(iir_dout_3)
    );

    IIR_Filter_Top_eqa4 IIR_Filter_Top_eqa4 (
        .clk(clk),
        .rstn(reset_n),
        .ce(1'b1),
        .coeff_we(coeff_we_4),
        .coeff_set(coeff_set_4),
        .coeff_a(coeff_a_4),
        .coeff_b(coeff_b_4),
        .input_ready(input_ready_4),
        .inpvalid(inpvalid_4),
        .din(iir_din_4),
        .outvalid(outvalid_4),
        .dout(iir_dout_4)
    );

    IIR_Filter_Top_eqa5 IIR_Filter_Top_eqa5 (
        .clk(clk),
        .rstn(reset_n),
        .ce(1'b1),
        .coeff_we(coeff_we_5),
        .coeff_set(coeff_set_5),
        .coeff_a(coeff_a_5),
        .coeff_b(coeff_b_5),
        .input_ready(input_ready_5),
        .inpvalid(inpvalid_5),
        .din(iir_din_5),
        .outvalid(outvalid_5),
        .dout(iir_dout_5)
    );

endmodule