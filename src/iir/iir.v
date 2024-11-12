module iir(
    input clk,
    input reset_n,
    input pstart,
    input IIR_flag,

    input [ADC_DATA_WIDTH-1:0] din,

    input [SAMPLE_WIDTH -1 :0] downsamp,
    input [SAMPLE_WIDTH -1 :0] upsamp,

    output reg iir_Done,
    output reg [ADC_DATA_WIDTH-1:0] dout,

    input [RAM_WIDTH-1:0] cmd_en,  // Add coefficient inputs
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_a_0, 
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_a_1,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_a_2,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_b_0,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_b_1,
    input [COEFFICIENT_DATA_WIDTH-1:0] coeff_b_2
);

//**********************************************************************
// --- Parameter
//**********************************************************************
	parameter SAMPLE_WIDTH = 6;
	parameter RAM_WIDTH= 18;
    parameter ADDR_WIDTH= 6;   
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=19;
    parameter ADC_DATA_WIDTH=32;
    parameter DAC_DATA_WIDTH=38;
    parameter COEFFICIENT_DATA_WIDTH = 18;   
    localparam TAP_SIZES=2;
    localparam NUM_CHN = 2;

    parameter state_rx_idle        = 2'd0;   //空闲状态
    parameter state_rx_left   = 2'd1;   //采集左通道数据
    parameter state_rx_right  = 2'd2;   //采集右通道数据
    parameter state_rx_final  = 2'd3;   //采集完成道数据

    parameter state_tx_idle        = 2'd0;   //空闲状态
    parameter state_tx_left   = 2'd1;   //采集左通道数据
    parameter state_tx_right  = 2'd2;   //采集右通道数据
    parameter state_tx_final   = 2'd3;   //采集完成道数据

    parameter state_Coe_idle        = 3'd0;   //空闲状态
    parameter state_Coe_0   = 3'd1;   //采集左通道数据
    parameter state_Coe_1  = 3'd2;   //采集右通道数据
    parameter state_Coe_2  = 3'd3;   //采集右通道数据
    parameter state_Coe_final   = 3'd4;   //采集完成道数据
//**********************************************************************
// --- In/OUT Signal Declaration
//**********************************************************************	  
//**********************************************************************
    wire input_ready_right;
    wire input_ready_left;	
    wire outvalid_right;
    wire outvalid_left;	
    wire [SINGLE_ADC_WIDTH-1:0] left_data;
    wire [SINGLE_ADC_WIDTH-1:0] right_data;
    reg [1:0] state_rx; 
    reg [2:0] state_tx; 
    reg [2:0] state_Coe; 
	reg inpvalid_left;
	reg inpvalid_right;
    reg [SINGLE_ADC_WIDTH-1:0] iir_din_left;
    reg [SINGLE_ADC_WIDTH-1:0] iir_din_right;
    reg [SINGLE_ADC_WIDTH - 1:0] reg_left_data; 
    reg [SINGLE_ADC_WIDTH - 1:0] reg_right_data; 
    wire [SINGLE_ADC_WIDTH-1:0] iir_dout_left;
    wire [SINGLE_ADC_WIDTH-1:0] iir_dout_right;

//**********************************************************************
//**********************************************************************
    reg [3:0] insert_count;  // 升采样, 计数器，控制插入的零个数
    reg ZERO_start;
    wire upsamp_en; // 开启
    wire [SAMPLE_WIDTH -1 :0] upsamp;

    reg [3: 0]sample_count ; // 降采样
    wire downsamp_n;  // 关掉
    wire [SAMPLE_WIDTH -1 :0] downsamp;

    reg coeff_we;
    reg coeff_set;
    reg  [COEFFICIENT_DATA_WIDTH-1:0] coeff_a;
    reg  [COEFFICIENT_DATA_WIDTH-1:0] coeff_b;
//**********************************************************************
    assign upsamp_en = cmd_en[0];
    assign downsamp_n = ~cmd_en[1];

    assign left_data = din[31:16];
    assign right_data = din[15:0];

//**********************************************************************
//**********************************************************************
    always@(posedge clk or negedge reset_n)
    if(~reset_n)
    begin
        state_rx <= state_rx_idle;
        inpvalid_left <= 0;
        inpvalid_right <= 0;
        iir_din_left <= 0; 
        iir_din_right <= 0;
        insert_count <= 0;
        ZERO_start <= 0;
    end
    else begin
        case(state_rx)
            state_rx_idle:
            begin
                inpvalid_left <= 0;
                inpvalid_right <= 0;
                if(input_ready_left && input_ready_right)
                begin
                    if(pstart)
                    begin
                        iir_din_left <= left_data;
                        iir_din_right <= right_data;
                        state_rx <= state_rx_left;
                        ZERO_start <= 1'b1;
                        insert_count <= upsamp;
                    end
                    else if(ZERO_start && upsamp_en)
                    begin
                        iir_din_left <= 16'd0;
                        iir_din_right <= 16'd0;
                        state_rx <= state_rx_left; 
                        insert_count <= insert_count -1;            
                    end
                end
            end

            state_rx_left:
            begin
                    inpvalid_left <= 1;
                    inpvalid_right <= 1;
                    state_rx <= state_rx_final;
            end

            state_rx_final:
            begin
                    inpvalid_left <= 0;
                    inpvalid_right <= 0;
                    if(insert_count == 0)
                    begin
                        ZERO_start <= 0;     
                    end
                    state_rx <= state_rx_idle;
            end

            default: state_rx <= state_rx_idle;

        endcase
    end

//**********************************************************************	
//**********************************************************************	
    always@(posedge clk or negedge reset_n)
    if(~reset_n)
    begin
        state_tx <= state_tx_idle;
        reg_left_data <= 0;
        reg_right_data <= 0;
        iir_Done <= 0;
        sample_count <= 0; 
    end
    else begin
        case(state_tx)
            state_tx_idle:
            begin
                iir_Done <= 0;
                if(outvalid_left && outvalid_right)
                begin
                    reg_left_data <= iir_dout_left;
                    reg_right_data <= iir_dout_right;
                    sample_count <= sample_count + 1;
                    state_tx <= state_tx_left;
                end
            end

            state_tx_left:
            begin
                if(downsamp_n || sample_count == downsamp)
                begin 
                    state_tx <= state_tx_right;
                end
                else
                    state_tx <= state_tx_idle;
            end

            state_tx_right:
            begin
                dout <= {reg_left_data,reg_right_data};
                state_tx <= state_tx_final;
            end

            state_tx_final:
            begin
                sample_count <= 0; 
                iir_Done <= 1;
                state_tx <= state_tx_idle;
            end

            default: state_tx <= state_tx_idle;

        endcase
    end

//**********************************************************************	
//**********************************************************************
    always@(posedge clk or negedge reset_n)
    if(~reset_n)
    begin
        coeff_a <= 0;
        coeff_b <= 0;
        coeff_set <= 0;
        coeff_we <= 0;
    end
    else begin
        case(state_Coe)
            state_Coe_idle:
            begin
                coeff_a <= 0;
                coeff_b <= 0;
                coeff_set <= 0;
                coeff_we <= 0;
                if(IIR_flag)
                begin
                    state_Coe <= state_Coe_0;
                end
            end

            state_Coe_0:
            begin
                coeff_we = 1'b1;  
                coeff_a <= coeff_a_0; 
                coeff_b <= coeff_b_0;        
                state_Coe <= state_Coe_1;
              
            end

            state_Coe_1:
            begin
                coeff_a <= coeff_a_1; 
                coeff_b <= coeff_b_1;        
                state_Coe <= state_Coe_2;
              
            end

            state_Coe_2:
            begin 
                coeff_a <= coeff_a_2; 
                coeff_b <= coeff_b_2;        
                state_Coe <= state_Coe_final;
              
            end

            state_Coe_final:
            begin
                coeff_set <= 1'b1; 
                coeff_we = 1'b0;
                state_Coe <= state_Coe_idle;
            end

            default: state_Coe <= state_Coe_idle;
        endcase
    end

//**********************************************************************	
// --- Initial Block
//**********************************************************************

IIR_Filter_Top IIR_Filter_Top_left(
		.clk(clk), //input clk
		.rstn(reset_n), //input rstn
		.ce(1'b1), //input ce
		.coeff_we(coeff_we), //input coeff_we
		.coeff_set(coeff_set), //input coeff_set
		.coeff_a(coeff_a), //input [18:0] coeff_a
		.coeff_b(coeff_b), //input [18:0] coeff_b
		.input_ready(input_ready_left), //output input_ready_left
		.inpvalid(inpvalid_left), //input inpvalid_left
		.din(iir_din_left), //input  din
		.outvalid(outvalid_left), //output outvalid_left
		.dout(iir_dout_left) //output  dout
	);

IIR_Filter_Top IIR_Filter_Top_right(
		.clk(clk), //input clk
		.rstn(reset_n), //input rstn
		.ce(1'b1), //input ce
		.coeff_we(coeff_we), //input coeff_we
		.coeff_set(coeff_set), //input coeff_set
		.coeff_a(coeff_a), //input [18:0] coeff_a
		.coeff_b(coeff_b), //input [18:0] coeff_b
		.input_ready(input_ready_right), //output input_ready_left
		.inpvalid(inpvalid_right), //input inpvalid_left
		.din(iir_din_right), //input  din
		.outvalid(outvalid_right), //output outvalid_left
		.dout(iir_dout_right) //output  dout
	);

endmodule
