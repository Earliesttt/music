//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5A-LV25UG324C2/I1
//Device: GW5A-25
//Device Version: A
//Created Time: Tue Oct 29 16:42:24 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_RAM16SDP your_instance_name(
        .dout(dout_o), //output [17:0] dout
        .wre(wre_i), //input wre
        .wad(wad_i), //input [5:0] wad
        .di(di_i), //input [17:0] di
        .rad(rad_i), //input [5:0] rad
        .clk(clk_i) //input clk
    );

//--------Copy end-------------------
