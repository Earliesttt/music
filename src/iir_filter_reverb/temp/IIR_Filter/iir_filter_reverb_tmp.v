//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5A-LV25UG324C2/I1
//Device: GW5A-25
//Device Version: A
//Created Time: Sat Nov  9 12:05:04 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	IIR_Filter__reverb your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.ce(ce_i), //input ce
		.coeff_we(coeff_we_i), //input coeff_we
		.coeff_set(coeff_set_i), //input coeff_set
		.coeff_a(coeff_a_i), //input [31:0] coeff_a
		.coeff_b(coeff_b_i), //input [31:0] coeff_b
		.input_ready(input_ready_o), //output input_ready
		.inpvalid(inpvalid_i), //input inpvalid
		.din(din_i), //input [15:0] din
		.outvalid(outvalid_o), //output outvalid
		.dout(dout_o) //output [15:0] dout
	);

//--------Copy end-------------------
