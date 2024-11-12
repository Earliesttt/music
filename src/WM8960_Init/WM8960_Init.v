/*============================================================================
*
*  LOGIC CORE:          WM8731 寄存器初始化模块顶层	
*  MODULE NAME:         WM8731_Init()
*  COMPANY:             武汉芯路恒科技有限公司
*                       http://xiaomeige.taobao.com
*	author:					小梅哥
*	Website:					www.corecourse.cn
*  REVISION HISTORY:  
*
*    Revision 1.0  04/10/2019     Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/


module WM8960_Init(
	Clk,
	Rst_n,

    MICB_Power,
    MICB_Go,

    vol_Go,
    volume_8,

    BCLK_ctrl,
    BCLK_Go,

	I2C_Init_Done,
	i2c_sdat,
	i2c_sclk
);

	input Clk;
	input Rst_n;

    input MICB_Power;
    input MICB_Go;

    input  [7:0] volume_8;
    input  vol_Go;

    input [3:0]BCLK_ctrl;
    input BCLK_Go;
	
	inout i2c_sdat;
	output i2c_sclk;
	output I2C_Init_Done;

	//产生初始化使能信号
	reg [15:0]Delay_Cnt;
	reg Init_en;
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			Delay_Cnt <= 16'd0;
		else if(Delay_Cnt < 16'd600)
			Delay_Cnt <= Delay_Cnt + 8'd1;
		else
			Delay_Cnt <= Delay_Cnt;
	end	
	
	always@(posedge Clk or negedge Rst_n)
	begin
		if(!Rst_n)
			Init_en <= 1'b0;
		else if(Delay_Cnt == 16'd599)
			Init_en <= 1'b1;
		else
			Init_en <= 1'b0;
	end

    reg adclrc_r0;
    reg adclrc_r1;
    reg adclrc_nege;
    reg adclrc_pose;

    always @(posedge Clk) begin
        adclrc_r0 <= Init_en;
        adclrc_r1 <= adclrc_r0;
    end

    always@(posedge Clk or negedge Rst_n)
    if(~Rst_n) begin
        adclrc_nege <= 1'd0;
        adclrc_pose <= 1'd0;
    end
    else begin
        adclrc_nege <= adclrc_r1 & (!adclrc_r0);
        adclrc_pose <= (!adclrc_r1) & adclrc_r0;
    end

	I2C_Init_Dev I2C_Init_Dev(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.Init_Go(adclrc_pose),
		.Init_Done(I2C_Init_Done),

        .MICB_Go(MICB_Go),
        .MICB_Power(MICB_Power),

        .vol_Go(vol_Go),
        .volume_8(volume_8),

        .BCLK_ctrl(BCLK_ctrl),
        .BCLK_Go(BCLK_Go),        

		.i2c_sclk(i2c_sclk),
		.i2c_sdat(i2c_sdat)
	);

endmodule
