//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9
//Part Number: GW5A-LV25UG324C2/I1
//Device: GW5A-25
//Device Version: A
//Created Time: Sat Nov  9 11:25:36 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Equalizer_Top your_instance_name(
		.clk(clk_i), //input clk
		.rstn(rstn_i), //input rstn
		.ce(ce_i), //input ce
		.in_valid(in_valid_i), //input in_valid
		.din(din_i), //input [15:0] din
		.gainwe(gainwe_i), //input gainwe
		.gainset(gainset_i), //input gainset
		.gain(gain_i), //input [2:0] gain
		.in_ready(in_ready_o), //output in_ready
		.out_valid(out_valid_o), //output out_valid
		.dout(dout_o) //output [18:0] dout
	);

//--------Copy end-------------------
