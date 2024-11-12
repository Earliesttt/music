//////////////////////////////////////////////////////////////////////////////////
// Company: 武汉芯路恒科技有限公司
// Engineer: 小梅哥团队
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: ram_ip
// Module Name: ctrl
// Project Name: ram_ip
// Description: ram_ip控制程序
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cmd_ctrl(
	clk,
	reset_n,
	read_addr,
    write_addr,
    Rx_Done,
    Addr_Done	
);

	parameter RAM_WIDTH         = 18;
    parameter ADDR_WIDTH        = 6;   
	parameter RAM_USER          = 32;

    input Rx_Done; 
	input clk;     //时钟输入50M
	input reset_n;    //模块复位，低有效
	output reg [ADDR_WIDTH-1 :0]read_addr;      //dpram读地址
    input [ADDR_WIDTH-1 :0] write_addr;         //dpram写地址
    output reg Addr_Done;

	wire reset;
    assign reset = ~reset_n;    

	always@(posedge clk or posedge reset)
	if(reset)
    begin
		read_addr <= 8'd0;
        Addr_Done <= 0;
    end
	else if(Rx_Done)
    begin
        read_addr <= write_addr; 
        Addr_Done <= 1;  
    end
	else begin
		read_addr <= read_addr;
        Addr_Done <= 0; 
    end
endmodule