//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5A-LV25UG324C2/I1
//Device: GW5A-25
//Device Version: A
//Created Time: Sun Nov  3 18:04:07 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_CLKDIV_8 your_instance_name(
        .clkout(clkout_o), //output clkout
        .hclkin(hclkin_i), //input hclkin
        .resetn(resetn_i), //input resetn
        .calib(calib_i) //input calib
    );

//--------Copy end-------------------
