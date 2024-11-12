module RT_AudioPS(
		input clk,                    
		input reset_n,                                   
		inout iic_0_scl,              
		inout iic_0_sda, 
  
	    output led,
        output led_up,
        output led_down,
        output MICB_led_up,

        input volume_down,
        input volume_up,
        input MICB_up,

        input uart_rx,
        output uart_tx,		

		input I2S_ADCDAT,
		input I2S_ADCLRC,
		input I2S_BCLK,
		output I2S_DACDAT,
		input I2S_DACLRC,
		output I2S_MCLK,
        
        output PCM5102_BCLK,
        output PCM5102_DACLRC,
        output PCM5102_DACDAT
);
	

	parameter ADC_DATA_WIDTH        = 32;
	parameter DAC_DATA_WIDTH        = 32;
    parameter SINGLE_ADC_WIDTH=16;
    parameter SINGLE_DAC_WIDTH=16;
	parameter RAM_WIDTH         = 18;
    parameter ADDR_WIDTH        = 6;      
    parameter UART_RX_WIDTH     = 24;
    parameter UART_TX_WIDTH     = 24;
	parameter MSB_FIRST         = 1;	
	parameter RAM_USER          = 32;
	parameter IIR_SAMPLE_WIDTH = 6;
    parameter Baud_Set          = 3'd4;

    assign PCM5102_BCLK = I2S_BCLK;
//    assign PCM5102_DACLRC = I2S_DACLRC;
    assign PCM5102_DACLRC = I2S_DACLRC_8;
    assign PCM5102_DACDAT = I2S_DACDAT;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    wire I2S_DACLRC_4;
    wire I2S_DACLRC_8;

    Gowin_PLL Gowin_PLL(
        .clkout0(I2S_MCLK), //output clkout0
        .clkin(clk) //input clkin
    );

    Gowin_CLKDIV_4 Gowin_CLKDIV_4(
        .clkout(I2S_DACLRC_4), //output clkout
        .hclkin(I2S_BCLK), //input hclkin
        .resetn(reset_n) //input resetn
    );

    Gowin_CLKDIV_8 Gowin_CLKDIV_8(
        .clkout(I2S_DACLRC_8), //output clkout
        .hclkin(I2S_DACLRC_4), //input hclkin
        .calib(4'd2), //input calib
        .resetn(reset_n) //input resetn
    );

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    reg [3:0] prev_BCLK_ctrl;  // 用于存储 BCLK_ctrl 的前一个值
    reg [3:0] BCLK_ctrl;
    reg BCLK_Go;                    // 使能脉冲信号

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            BCLK_ctrl <= 0;
            prev_BCLK_ctrl <= 0;
            BCLK_Go <= 0;
        end else begin
            case (cmd_en)
                2'b00: BCLK_ctrl <= 4'd7;
                2'b01: BCLK_ctrl <= reg_upsamp[3:0];
                2'b10: BCLK_ctrl <= reg_downsamp[3:0];
                default: BCLK_ctrl <= 0;  // 处理未定义的组合
            endcase

            // 检查 BCLK_ctrl 是否变化
            if (BCLK_ctrl != prev_BCLK_ctrl) begin
                BCLK_Go <= 1;                   // 如果变化，则产生一个脉冲
            end else begin
                BCLK_Go <= 0;                   // 否则保持低电平
            end

            prev_BCLK_ctrl <= BCLK_ctrl;    // 更新前一个值
        end
    end

 	wire Init_Done;
	WM8960_Init WM8960_Init(
		.Clk(clk),
		.Rst_n(reset_n),
		.I2C_Init_Done(Init_Done),

        .vol_Go(vol_Go),
        .volume_8(volume_8),

        .BCLK_ctrl(BCLK_ctrl),
        .BCLK_Go(BCLK_Go),

        .MICB_Power(MICB_Power),
        .MICB_Go(MICB_Go),

		.i2c_sclk(iic_0_scl),
		.i2c_sdat(iic_0_sda)
	);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
	
	assign led = Init_Done;
	
	reg adcfifo_read;
	wire [ADC_DATA_WIDTH - 1:0] adcfifo_readdata;
	wire adcfifo_empty;

	reg dacfifo_write;
	reg [DAC_DATA_WIDTH - 1:0] dacfifo_writedata;
	wire dacfifo_full;

    reg [ADC_DATA_WIDTH - 1:0] din;
	wire [ADC_DATA_WIDTH - 1:0] iir_dout;
    reg pstart;
    wire iir_Done;

    reg [RAM_WIDTH-1 :0] cmd_en, cmd_en1, cmd_en2;
    reg [RAM_WIDTH-1 :0] coeff_a_0;    
    reg [RAM_WIDTH-1 :0] coeff_a_1;
    reg [RAM_WIDTH-1 :0] coeff_a_2;
    reg [RAM_WIDTH-1 :0] coeff_b_0;    
    reg [RAM_WIDTH-1 :0] coeff_b_1;
    reg [RAM_WIDTH-1 :0] coeff_b_2;


    //回声
    reg [RAM_WIDTH-1 :0] reg_delay_Echo;
    //采样
    reg [RAM_WIDTH-1 :0] reg_upsamp;
    reg [RAM_WIDTH-1 :0] reg_downsamp;
    //混响
    reg [RAM_WIDTH-1 :0] reg_delay_Reverb;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    reg adclrc_nege;
    reg adclrc_pose;	
    reg adclrc_r0;
    reg adclrc_r1;

    always @(posedge clk) begin
        adclrc_r0 <= ~adcfifo_empty;
        adclrc_r1 <= adclrc_r0;
    end

    always@(posedge clk or negedge reset_n)
    if(~reset_n) begin
        adclrc_nege <= 1'd0;
        adclrc_pose <= 1'd0;
    end
    else begin
        adclrc_nege <= adclrc_r1 & (!adclrc_r0);
        adclrc_pose <= (!adclrc_r1) & adclrc_r0;
    end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
	always @ (posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			adcfifo_read <= 1'b0;
		end
		else if (~adcfifo_empty)
		begin
			adcfifo_read <= 1'b1;
		end
		else
		begin
			adcfifo_read <= 1'b0;
		end
	end

	always @ (posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			din <= 32'b0;
            pstart <= 1'b0;
		end
		else if (adclrc_pose)
		begin
			pstart <= 1'b1;
            din <= adcfifo_readdata;
		end
		else
		begin
			pstart <= 1'b0;
		end
	end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
	always @ (posedge clk or negedge reset_n)
	begin
		if(~reset_n)
			dacfifo_write <= 1'd0;
        else if(~dacfifo_full)
            begin
                if(Reverb_ce && reverb_Done) 
                begin
                    dacfifo_write <= 1'd1;
                    dacfifo_writedata <= Reverb_Out;
                end
                else if(Echo_ce && echo_Done) 
                begin
                    dacfifo_write <= 1'd1;
                    dacfifo_writedata <= Echo_Out;
                end  
                else if(Eqa_ce && eqa_Done) 
                begin
                    dacfifo_write <= 1'd1;
                    dacfifo_writedata <= Eqa_Out;
                end  

                else if(Dist_ce && Dist_Done)
                begin
                    dacfifo_write <= 1'd1;
                    dacfifo_writedata <= Dist_Out;
                end 

                else if(~Reverb_ce && ~Echo_ce && ~Eqa_ce && ~Dist_ce && iir_Done) 
                begin
                    dacfifo_write <= 1'd1;
                    dacfifo_writedata <= iir_dout;
                end   
                else begin
                    dacfifo_write <= 1'd0;
                end
            end
	end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
always @ (posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        cmd_en <= 0;
        cmd_en1 <= 0;
        cmd_en2 <= 0;
        coeff_a_0 <= 0;    
        coeff_a_1 <= 0;
        coeff_a_2 <= 0;
        coeff_b_0 <= 0;    
        coeff_b_1 <= 0;
        coeff_b_2 <= 0;
        // 回声
        reg_delay_Echo <= 0;
        // 采样
        reg_upsamp <= 0;
        reg_downsamp <= 0;
        // 混响 
        reg_delay_Reverb <= 0;
        //失真
        limit_value <= 0;

        Eqa1_A_0 <= 0; Eqa1_A_1 <= 0; Eqa1_A_2 <= 0; 
        Eqa1_B_0 <= 0; Eqa1_B_1 <= 0; Eqa1_B_2 <= 0; 

        Eqa2_A_0 <= 0; Eqa2_A_1 <= 0; Eqa2_A_2 <= 0; 
        Eqa2_B_0 <= 0; Eqa2_B_1 <= 0; Eqa2_B_2 <= 0;

        Eqa3_A_0 <= 0; Eqa3_A_1 <= 0; Eqa3_A_2 <= 0; 
        Eqa4_A_0 <= 0; Eqa4_A_1 <= 0; Eqa4_A_2 <= 0;

        Eqa3_B_0 <= 0; Eqa3_B_1 <= 0; Eqa3_B_2 <= 0; 
        Eqa4_B_0 <= 0; Eqa4_B_1 <= 0; Eqa4_B_2 <= 0; 

        Eqa5_A_0 <= 0; Eqa5_A_1 <= 0; Eqa5_A_2 <= 0;  
        Eqa5_B_0 <= 0; Eqa5_B_1 <= 0; Eqa5_B_2 <= 0; 

    end else begin
        case (read_addr)
            6'd0: begin
                cmd_en <= cmd_data; // Update cmd_en for addr 0
            end
            6'd1: begin
                coeff_a_0 <= cmd_data; // Update coeff_a_0 for addr 1
            end
            6'd2: begin
                coeff_a_1 <= cmd_data; // Update coeff_a_1 for addr 2
            end
            6'd3: begin
                coeff_a_2 <= cmd_data; // Update coeff_a_2 for addr 3
            end
            6'd4: begin
                coeff_b_0 <= cmd_data; // Update coeff_b_0 for addr 4
            end
            6'd5: begin
                coeff_b_1 <= cmd_data; // Update coeff_b_1 for addr 5
            end
            6'd6: begin
                coeff_b_2 <= cmd_data; // Update coeff_b_2 for addr 6
            end

            // Update delay settings (Echo, Sampling, Reverb)
            6'd7: begin
                reg_delay_Echo <= cmd_data; // Update reg_delay_Echo for addr 7
            end
            6'd8: begin
                reg_downsamp <= cmd_data; // Update reg_downsamp for addr 8
            end
            6'd9: begin
                reg_upsamp <= cmd_data; // Update reg_upsamp for addr 9
            end
            6'd10: begin
                reg_delay_Reverb <= cmd_data; // Update reg_delay_Reverb for addr 10
            end

            6'd15: begin
                Eqa1_A_0 <= cmd_data; // Update Eqa1_A_0 for addr 11
            end
            6'd16: begin
                Eqa1_A_1 <= cmd_data; // Update Eqa1_A_1 for addr 12
            end
            6'd17: begin
                Eqa1_A_2 <= cmd_data; // Update Eqa1_A_2 for addr 13
            end

            6'd18: begin
                Eqa1_B_0 <= cmd_data; // Update Eqa1_B_0 for addr 16
            end
            6'd19: begin
                Eqa1_B_1 <= cmd_data; // Update Eqa1_B_1 for addr 17
            end
            6'd20: begin
                Eqa1_B_2 <= cmd_data; // Update Eqa1_B_2 for addr 18
            end
            // Continue with similar pattern for Eqa2, Eqa3, Eqa4, Eqa5
            6'd21: begin
                Eqa2_A_0 <= cmd_data; // Update Eqa2_A_0 for addr 21
            end
            6'd22: begin
                Eqa2_A_1 <= cmd_data; // Update Eqa2_A_1 for addr 22
            end
            6'd23: begin
                Eqa2_A_2 <= cmd_data; // Update Eqa2_A_2 for addr 23
            end
            6'd24: begin
                Eqa2_B_0 <= cmd_data; // Update Eqa2_B_0 for addr 26
            end
            6'd25: begin
                Eqa2_B_1 <= cmd_data; // Update Eqa2_B_1 for addr 27
            end
            6'd26: begin
                Eqa2_B_2 <= cmd_data; // Update Eqa2_B_2 for addr 28
            end

                6'd27: begin
                    Eqa3_A_0 <= cmd_data; // Update Eqa3_A_0 for addr 31
                end
                6'd28: begin
                    Eqa3_A_1 <= cmd_data; // Update Eqa3_A_1 for addr 32
                end
                6'd29: begin
                    Eqa3_A_2 <= cmd_data; // Update Eqa3_A_2 for addr 33
                end
                6'd30: begin
                    Eqa3_B_0 <= cmd_data; // Update Eqa3_B_0 for addr 36
                end
                6'd31: begin
                    Eqa3_B_1 <= cmd_data; // Update Eqa3_B_1 for addr 37
                end
                6'd32: begin
                    Eqa3_B_2 <= cmd_data; // Update Eqa3_B_2 for addr 38
                end

                6'd33: begin
                    Eqa4_A_0 <= cmd_data; // Update Eqa4_A_0 for addr 41
                end
                6'd34: begin
                    Eqa4_A_1 <= cmd_data; // Update Eqa4_A_1 for addr 42
                end
                6'd35: begin
                    Eqa4_A_2 <= cmd_data; // Update Eqa4_A_2 for addr 43
                end
                6'd36: begin
                    Eqa4_B_0 <= cmd_data; // Update Eqa4_B_0 for addr 46
                end
                6'd37: begin
                    Eqa4_B_1 <= cmd_data; // Update Eqa4_B_1 for addr 47
                end
                6'd38: begin
                    Eqa4_B_2 <= cmd_data; // Update Eqa4_B_2 for addr 48
                end

                6'd39: begin
                    Eqa5_A_0 <= cmd_data; // Update Eqa5_A_0 for addr 51
                end
                6'd40: begin
                    Eqa5_A_1 <= cmd_data; // Update Eqa5_A_1 for addr 52
                end
                6'd41: begin
                    Eqa5_A_2 <= cmd_data; // Update Eqa5_A_2 for addr 53
                end
                6'd42: begin
                    Eqa5_B_0 <= cmd_data; // Update Eqa5_B_0 for addr 56
                end
                6'd43: begin
                    Eqa5_B_1 <= cmd_data; // Update Eqa5_B_1 for addr 57
                end
                6'd44: begin
                    Eqa5_B_2 <= cmd_data; // Update Eqa5_B_2 for addr 58
                end

                6'd45: begin
                    limit_value <= cmd_data; // Update Eqa5_B_2 for addr 58
                end                

            6'd61: begin
                cmd_en1 <= cmd_data; // Update Eqa5_B_4 for addr 60
            end
            6'd62: begin
                cmd_en2 <= cmd_data; // Update Eqa5_B_4 for addr 60
             end
            // Repeat the same for Eqa3, Eqa4, and Eqa5 similarly
            // Similar blocks for Eqa3, Eqa4, and Eqa5 can be added here

            default: begin
                // Optional: Handle other addresses if needed
            end
        endcase
    end
end



///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    reg IIR_flag;
    reg IIR_flag_next;    

    // Update IIR_flag based on IIR_flag_next
    always @ (posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            IIR_flag <= 0; // Initialize IIR_flag to 0
            IIR_flag_next <= 0;
        end 
        else if(Addr_Done && read_addr == 6'd6) begin    
            IIR_flag_next <= 1;    
        end
        else begin
            IIR_flag <= IIR_flag_next; // Update IIR_flag based on IIR_flag_next
            IIR_flag_next <= 0; // Reset IIR_flag_next for the next clock cycle
        end
    end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    // 定义 EQA_flag 和 EQA_flag_next
    reg EQA_flag;
    reg EQA_flag_next;

    // 使用 EQA_flag_next 更新 EQA_flag
    always @ (posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            EQA_flag <= 0;           // 初始化 EQA_flag 为 0
            EQA_flag_next <= 0;
        end 
        else if (Addr_Done && (read_addr == 6'd44 || read_addr == 6'd38 || read_addr == 6'd32 || read_addr == 6'd26 || read_addr == 6'd20 ) )
        begin    
            EQA_flag_next <= 1;      // 当 Addr_Done 为高，且地址为 6'd7 时，设置 EQA_flag_next
        end
        else begin
            EQA_flag <= EQA_flag_next; // 使用 EQA_flag_next 更新 EQA_flag
            EQA_flag_next <= 0;       // 重置 EQA_flag_next，为下一个时钟周期做准备
        end
    end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
 
	i2s_rx 
	#(
		.DATA_WIDTH(ADC_DATA_WIDTH) 
	)i2s_rx
	(
		.reset_n(reset_n),
		.bclk(I2S_BCLK),
		.adclrc(I2S_ADCLRC),
		.adcdat(I2S_ADCDAT),
		.adcfifo_rdclk(clk),
		.adcfifo_read(adcfifo_read),
		.adcfifo_empty(adcfifo_empty),
		.adcfifo_readdata(adcfifo_readdata)
	);
	
	i2s_tx
	#(
		 .DATA_WIDTH(DAC_DATA_WIDTH)
	)i2s_tx
	(
		 .reset_n(reset_n),
		 .dacfifo_wrclk(clk),
		 .dacfifo_wren(dacfifo_write),
		 .dacfifo_wrdata(dacfifo_writedata),
		 .dacfifo_full(dacfifo_full),
		 .bclk(I2S_BCLK),
		 .daclrc(I2S_DACLRC_8),
		 .dacdat(I2S_DACDAT)
	);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    wire up_Done;
    wire down_Done;
    wire vol_Go;
	wire [7:0]volume_8;
    wire led_up;
    wire led_down;
 
     volume_control volume_control(
        .Clk(clk),
        .Rst_n(reset_n),

        .volume_up(volume_up),
        .up_Done(up_Done),
        
        .volume_down(volume_down),
        .down_Done(down_Done),
        
        .Go(vol_Go),
        .volume(volume_8),
        .led_up(led_up),
        .led_down(led_down)
    );

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    wire MICB_Go;
	wire MICB_Power;
    wire MICB_led_up;
 
     micb micb_inst(
        .Clk(clk),
        .Rst_n(reset_n),

        .MICB_up(MICB_up),
        .up_Done(),
        
        .Go(MICB_Go),
        .MICB_Power(MICB_Power),
        .led_up(MICB_led_up)
    );

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
    parameter ECHO_SAMPLE_WIDTH        = 13;

    wire Echo_ce;
    wire [DAC_DATA_WIDTH - 1:0] Echo_Out;
    wire echo_Done;
    wire [ECHO_SAMPLE_WIDTH -1:0] delay_Echo;

    assign Echo_ce = cmd_en1[2]; // 第二位是使能
    assign delay_Echo = reg_delay_Echo[ECHO_SAMPLE_WIDTH-1 :0];

    echo_top #(
    .SAMPLE_WIDTH(ECHO_SAMPLE_WIDTH),
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .ADC_DATA_WIDTH(ADC_DATA_WIDTH),
    .DAC_DATA_WIDTH(DAC_DATA_WIDTH)
    )
    echo_top_inst(
        .clk(clk),                // 时钟信号
        .ce(Echo_ce),              // 复位信号
        .iir_dout(iir_dout),        // 16位宽的输入音频数据
        .echo_start(iir_Done),                // 开始
        .delay_samples(delay_Echo),            // 延迟时间
        .Echo_Out(Echo_Out),      // 输出带回声效果的音频
        .echo_Done(echo_Done)  
    );

///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 
    parameter REVERB_SAMPLE_WIDTH        = 13;

    wire Reverb_ce;
    wire [DAC_DATA_WIDTH - 1:0] Reverb_Out;
    wire reverb_Done;
    wire [REVERB_SAMPLE_WIDTH -1:0] delay_Reverb;

    assign Reverb_ce = cmd_en1[3]; // 第二位是使能
    assign delay_Reverb = reg_delay_Reverb[REVERB_SAMPLE_WIDTH-1 :0];

    reverb_top #(
    .SAMPLE_WIDTH(REVERB_SAMPLE_WIDTH),
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .ADC_DATA_WIDTH(ADC_DATA_WIDTH),
    .DAC_DATA_WIDTH(DAC_DATA_WIDTH)
    )
    reverb_top_inst(
        .clk(clk),                // 时钟信号
        .ce(Reverb_ce),              // 复位信号
        .iir_dout(iir_dout),        // 32位宽的输入音频数据
        .reverb_start(iir_Done),                // 开始
        .delay_samples(delay_Reverb),
        .Reverb_Out(Reverb_Out),      // 输出带回声效果的音频
        .reverb_Done(reverb_Done)  
    );

///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 
    wire Eqa_ce;

    assign Eqa_ce = cmd_en2[4]; // 第二位是使能

    wire [DAC_DATA_WIDTH - 1:0] Eqa_Out;
    wire eqa_Done;

    

    eqa_top #(
        .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
        .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
        .ADC_DATA_WIDTH(ADC_DATA_WIDTH),
        .DAC_DATA_WIDTH(DAC_DATA_WIDTH)
    ) eqa_top_inst (
        .ce(Eqa_ce),                          // Active-low reset signal
        .clk(clk),                                 // Clock signal
        .iir_dout(iir_dout),                       // 32-bit wide input audio data
        .eqa_start(iir_Done),                     // Start signal for processing
        . coeff_a_1(coeff_A_1),
        . coeff_b_1(coeff_B_1),
        .coeff_we_1(coeff_we_1),
        .coeff_set_1(coeff_set_1),

        . coeff_a_2(coeff_A_2),
        . coeff_b_2(coeff_B_2),
        .coeff_we_2(coeff_we_2),
        .coeff_set_2(coeff_set_2),

        .coeff_a_3(coeff_A_3),
        .coeff_b_3(coeff_B_3),
        .coeff_we_3(coeff_we_3),
        .coeff_set_3(coeff_set_3),

        .coeff_a_4(coeff_A_4),
        .coeff_b_4(coeff_B_4),
        .coeff_we_4(coeff_we_4),
        .coeff_set_4(coeff_set_4),

        .coeff_a_5(coeff_A_5),
        .coeff_b_5(coeff_B_5),
        .coeff_we_5(coeff_we_5),
        .coeff_set_5(coeff_set_5),

        .Eqa_Out(Eqa_Out),                         // Output audio data with echo effect
        .eqa_Done(eqa_Done)                        // Processing completion signal
    );

     reg [RAM_WIDTH-1:0] Eqa1_A_0, Eqa1_A_1, Eqa1_A_2;
     reg [RAM_WIDTH-1:0] Eqa1_B_0, Eqa1_B_1, Eqa1_B_2;

     reg [RAM_WIDTH-1:0] Eqa2_A_0, Eqa2_A_1, Eqa2_A_2;
     reg [RAM_WIDTH-1:0] Eqa2_B_0, Eqa2_B_1, Eqa2_B_2;

     reg [RAM_WIDTH-1:0] Eqa3_A_0, Eqa3_A_1, Eqa3_A_2;
     reg [RAM_WIDTH-1:0] Eqa3_B_0, Eqa3_B_1, Eqa3_B_2;

     reg [RAM_WIDTH-1:0] Eqa4_A_0, Eqa4_A_1, Eqa4_A_2;
     reg [RAM_WIDTH-1:0] Eqa4_B_0, Eqa4_B_1, Eqa4_B_2;

     reg [RAM_WIDTH-1:0] Eqa5_A_0, Eqa5_A_1, Eqa5_A_2;
     reg [RAM_WIDTH-1:0] Eqa5_B_0, Eqa5_B_1, Eqa5_B_2;


    parameter state_Coe_idle        = 3'd0;   //空闲状态
    parameter state_Coe_0   = 3'd1;   //采集左通道数据
    parameter state_Coe_1  = 3'd2;   //采集右通道数据
    parameter state_Coe_2  = 3'd3;   //采集右通道数据
    parameter state_Coe_final   = 3'd4;   //采集完成道数据

    reg coeff_we_1, coeff_set_1;
    reg coeff_we_2, coeff_set_2;

    reg coeff_we_3, coeff_set_3;
    reg coeff_we_4, coeff_set_4;

    reg coeff_we_5, coeff_set_5;

    reg [RAM_WIDTH-1 :0] coeff_A_1, coeff_B_1;
    reg [RAM_WIDTH-1 :0] coeff_A_2, coeff_B_2;

    reg [RAM_WIDTH-1 :0] coeff_A_3, coeff_B_3;
    reg [RAM_WIDTH-1 :0] coeff_A_4, coeff_B_4;

    reg [RAM_WIDTH-1 :0] coeff_A_5, coeff_B_5;

    reg [2:0] state_Coe; 

    always @(posedge clk or negedge reset_n)
        if (~reset_n) begin
            coeff_A_1 <= 0;
            coeff_B_1 <= 0;
            coeff_we_1 <= 0;
            coeff_set_1 <= 0;

            coeff_A_2 <= 0;
            coeff_B_2 <= 0;
            coeff_we_2 <= 0;
            coeff_set_2 <= 0;

            coeff_A_3 <= 0;
            coeff_B_3 <= 0;
            coeff_we_3 <= 0;
            coeff_set_3 <= 0;

            coeff_A_4 <= 0;
            coeff_B_4 <= 0;
            coeff_we_4 <= 0;
            coeff_set_4 <= 0;

            coeff_A_5 <= 0;
            coeff_B_5 <= 0;
            coeff_we_5 <= 0;
            coeff_set_5 <= 0;
        end
        else begin
            case (state_Coe)
                state_Coe_idle: begin
                    coeff_A_1 <= 0;
                    coeff_B_1 <= 0;
                    coeff_set_1 <= 0;
                    coeff_we_1 <= 0;

                    coeff_A_2 <= 0;
                    coeff_B_2 <= 0;
                    coeff_set_2 <= 0;
                    coeff_we_2 <= 0;

                    coeff_A_3 <= 0;
                    coeff_B_3 <= 0;
                    coeff_set_3 <= 0;
                    coeff_we_3 <= 0;

                    coeff_A_4 <= 0;
                    coeff_B_4 <= 0;
                    coeff_set_4 <= 0;
                    coeff_we_4 <= 0;

                    coeff_A_5 <= 0;
                    coeff_B_5 <= 0;
                    coeff_set_5 <= 0;
                    coeff_we_5 <= 0;

                    if (EQA_flag) begin
                        state_Coe <= state_Coe_0;
                    end
                end

                state_Coe_0: begin
                    coeff_we_1 <= 1'b1;
                    coeff_A_1 <= Eqa1_A_0;
                    coeff_B_1 <= Eqa1_B_0;

                    coeff_we_2 <= 1'b1;
                    coeff_A_2 <= Eqa2_A_0;
                    coeff_B_2 <= Eqa2_B_0;

                    coeff_we_3 <= 1'b1;
                    coeff_A_3 <= Eqa3_A_0;
                    coeff_B_3 <= Eqa3_B_0;

                    coeff_we_4 <= 1'b1;
                    coeff_A_4 <= Eqa4_A_0;
                    coeff_B_4 <= Eqa4_B_0;

                    coeff_we_5 <= 1'b1;
                    coeff_A_5 <= Eqa5_A_0;
                    coeff_B_5 <= Eqa5_B_0;

                    state_Coe <= state_Coe_1;
                end

                state_Coe_1: begin
                    coeff_A_1 <= Eqa1_A_1;
                    coeff_B_1 <= Eqa1_B_1;

                    coeff_A_2 <= Eqa2_A_1;
                    coeff_B_2 <= Eqa2_B_1;

                    coeff_A_3 <= Eqa3_A_1;
                    coeff_B_3 <= Eqa3_B_1;

                    coeff_A_4 <= Eqa4_A_1;
                    coeff_B_4 <= Eqa4_B_1;

                    coeff_A_5 <= Eqa5_A_1;
                    coeff_B_5 <= Eqa5_B_1;

                    state_Coe <= state_Coe_2;
                end

                state_Coe_2: begin
                    coeff_A_1 <= Eqa1_A_2;
                    coeff_B_1 <= Eqa1_B_2;

                    coeff_A_2 <= Eqa2_A_2;
                    coeff_B_2 <= Eqa2_B_2;

                    coeff_A_3 <= Eqa3_A_2;
                    coeff_B_3 <= Eqa3_B_2;

                    coeff_A_4 <= Eqa4_A_2;
                    coeff_B_4 <= Eqa4_B_2;

                    coeff_A_5 <= Eqa5_A_2;
                    coeff_B_5 <= Eqa5_B_2;

                    state_Coe <= state_Coe_final;
                end

                state_Coe_final: begin
                    coeff_set_1 <= 1'b1;
                    coeff_we_1 <= 1'b0;

                    coeff_set_2 <= 1'b1;
                    coeff_we_2 <= 1'b0;

                    coeff_set_3 <= 1'b1;
                    coeff_we_3 <= 1'b0;

                    coeff_set_4 <= 1'b1;
                    coeff_we_4 <= 1'b0;

                    coeff_set_5 <= 1'b1;
                    coeff_we_5 <= 1'b0;

                    state_Coe <= state_Coe_idle;
                end

                default: state_Coe <= state_Coe_idle;
            endcase
        end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
 
    wire Dist_ce;
    wire [DAC_DATA_WIDTH - 1:0] Dist_Out;
    wire Dist_Done;
    reg [15:0] limit_value;    

    assign Dist_ce = cmd_en1[0]; // 第二位是使能

    // 实例化 distortion 模块
    distortion #(
        .ADC_DATA_WIDTH(ADC_DATA_WIDTH),
        .DAC_DATA_WIDTH(DAC_DATA_WIDTH)
    ) distortion_inst (
        .clk(clk),                          // 连接时钟信号
        .ce(Dist_ce),                            // 连接复位信号
        .iir_dout(iir_dout),                    // 输入音频数据
        .start(iir_Done),                      // 开始信号
        .limit_value(limit_value),
        .Dist_Out(Dist_Out),               // 输出音频数据
        .Dist_Done(Dist_Done)               // 输出完成信号
    );


///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 
    wire [IIR_SAMPLE_WIDTH -1 :0] upsamp;    
    wire [IIR_SAMPLE_WIDTH -1 :0] downsamp;

    assign upsamp = reg_upsamp[7 :4];
    assign downsamp = reg_downsamp[7 :4];

    iir #(
    .SINGLE_ADC_WIDTH(SINGLE_ADC_WIDTH),
    .SINGLE_DAC_WIDTH(SINGLE_DAC_WIDTH),
    .ADC_DATA_WIDTH(ADC_DATA_WIDTH),
    .DAC_DATA_WIDTH(DAC_DATA_WIDTH),
    .RAM_WIDTH(RAM_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .SAMPLE_WIDTH(IIR_SAMPLE_WIDTH)
    )
    iir_inst(
        .clk(clk),
        .reset_n(reset_n),
        .din(din),
        .pstart(pstart),
        .iir_Done(iir_Done),
        .dout(iir_dout),
        .downsamp(downsamp),
        .upsamp(upsamp),
        .IIR_flag(IIR_flag),
        .cmd_en(cmd_en),
        .coeff_a_0(coeff_a_0), // Add coefficient inputs
        .coeff_a_1(coeff_a_1),
        .coeff_a_2(coeff_a_2),
        .coeff_b_0(coeff_b_0),
        .coeff_b_1(coeff_b_1),
        .coeff_b_2(coeff_b_2)
    );


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////    
    wire [UART_RX_WIDTH-1:0]rx_data;
    wire Rx_Done;
    wire Tx_Done;
    wire send_en;

    uart_data_rx 
    #(
		.DATA_WIDTH(UART_RX_WIDTH),
		.MSB_FIRST(MSB_FIRST)		
	)
	uart_data_rx(
        .Clk(clk),
        .Rst_n(reset_n),
        .uart_rx(uart_rx),
        
        .data(rx_data),
        .Rx_Done(Rx_Done),
        .timeout_flag(),
        
        .Baud_Set(Baud_Set)
     );

    uart_data_tx 
    #(
		.DATA_WIDTH(UART_TX_WIDTH),
		.MSB_FIRST(MSB_FIRST)
	)uart_data_tx(
        .Clk(clk),
        .Rst_n(reset_n),
      
        .data(rx_data),
        .send_en(send_en),   
        .Baud_Set(Baud_Set),  
        
        .uart_tx(uart_tx),  
        .Tx_Done(Tx_Done),   
        .uart_state()
    );

///////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////// 
    wire [RAM_WIDTH-1 :0] ram_data;
    wire [RAM_WIDTH-1 :0] cmd_data;
    wire [ADDR_WIDTH-1 :0] write_addr;
    wire [ADDR_WIDTH-1 :0] read_addr; 
    wire Addr_Done;
    wire write_en;

    assign ram_data = rx_data[RAM_WIDTH-1 :0];
    assign write_addr = rx_data[UART_RX_WIDTH-1 :RAM_WIDTH];
	assign write_en = Rx_Done;   


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////   
 
	cmd_ctrl 
    #(
		.RAM_WIDTH(RAM_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
        .RAM_USER(RAM_USER)
	)cmd_ctrl_inst(
		.clk(clk),                //时钟输入50M    
		.reset_n(reset_n),        //模块复位，低有效
        .Rx_Done(Rx_Done),
        .Addr_Done(Addr_Done),
        .write_addr(write_addr),
		.read_addr(read_addr)           //dpram读地址   
 	);  

    Gowin_RAM16SDP Gowin_RAM16SDP(
        .dout(cmd_data), //output [7:0] iir_dout
        .wre(write_en),               //dpram写使能
        .wad(write_addr), //input [7:0] wad
        .di(ram_data), //input [7:0] di
        .rad(read_addr), //input [7:0] rad
        .clk(clk) //input clk
    );
	 
endmodule
