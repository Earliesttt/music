module gw_gao(
    \Eqa3_A_0[17] ,
    \Eqa3_A_0[16] ,
    \Eqa3_A_0[15] ,
    \Eqa3_A_0[14] ,
    \Eqa3_A_0[13] ,
    \Eqa3_A_0[12] ,
    \Eqa3_A_0[11] ,
    \Eqa3_A_0[10] ,
    \Eqa3_A_0[9] ,
    \Eqa3_A_0[8] ,
    \Eqa3_A_0[7] ,
    \Eqa3_A_0[6] ,
    \Eqa3_A_0[5] ,
    \Eqa3_A_0[4] ,
    \Eqa3_A_0[3] ,
    \Eqa3_A_0[2] ,
    \Eqa3_A_0[1] ,
    \Eqa3_A_0[0] ,
    \Eqa3_A_1[17] ,
    \Eqa3_A_1[16] ,
    \Eqa3_A_1[15] ,
    \Eqa3_A_1[14] ,
    \Eqa3_A_1[13] ,
    \Eqa3_A_1[12] ,
    \Eqa3_A_1[11] ,
    \Eqa3_A_1[10] ,
    \Eqa3_A_1[9] ,
    \Eqa3_A_1[8] ,
    \Eqa3_A_1[7] ,
    \Eqa3_A_1[6] ,
    \Eqa3_A_1[5] ,
    \Eqa3_A_1[4] ,
    \Eqa3_A_1[3] ,
    \Eqa3_A_1[2] ,
    \Eqa3_A_1[1] ,
    \Eqa3_A_1[0] ,
    \Eqa3_A_2[17] ,
    \Eqa3_A_2[16] ,
    \Eqa3_A_2[15] ,
    \Eqa3_A_2[14] ,
    \Eqa3_A_2[13] ,
    \Eqa3_A_2[12] ,
    \Eqa3_A_2[11] ,
    \Eqa3_A_2[10] ,
    \Eqa3_A_2[9] ,
    \Eqa3_A_2[8] ,
    \Eqa3_A_2[7] ,
    \Eqa3_A_2[6] ,
    \Eqa3_A_2[5] ,
    \Eqa3_A_2[4] ,
    \Eqa3_A_2[3] ,
    \Eqa3_A_2[2] ,
    \Eqa3_A_2[1] ,
    \Eqa3_A_2[0] ,
    \Eqa3_B_0[17] ,
    \Eqa3_B_0[16] ,
    \Eqa3_B_0[15] ,
    \Eqa3_B_0[14] ,
    \Eqa3_B_0[13] ,
    \Eqa3_B_0[12] ,
    \Eqa3_B_0[11] ,
    \Eqa3_B_0[10] ,
    \Eqa3_B_0[9] ,
    \Eqa3_B_0[8] ,
    \Eqa3_B_0[7] ,
    \Eqa3_B_0[6] ,
    \Eqa3_B_0[5] ,
    \Eqa3_B_0[4] ,
    \Eqa3_B_0[3] ,
    \Eqa3_B_0[2] ,
    \Eqa3_B_0[1] ,
    \Eqa3_B_0[0] ,
    \Eqa3_B_1[17] ,
    \Eqa3_B_1[16] ,
    \Eqa3_B_1[15] ,
    \Eqa3_B_1[14] ,
    \Eqa3_B_1[13] ,
    \Eqa3_B_1[12] ,
    \Eqa3_B_1[11] ,
    \Eqa3_B_1[10] ,
    \Eqa3_B_1[9] ,
    \Eqa3_B_1[8] ,
    \Eqa3_B_1[7] ,
    \Eqa3_B_1[6] ,
    \Eqa3_B_1[5] ,
    \Eqa3_B_1[4] ,
    \Eqa3_B_1[3] ,
    \Eqa3_B_1[2] ,
    \Eqa3_B_1[1] ,
    \Eqa3_B_1[0] ,
    \Eqa3_B_2[17] ,
    \Eqa3_B_2[16] ,
    \Eqa3_B_2[15] ,
    \Eqa3_B_2[14] ,
    \Eqa3_B_2[13] ,
    \Eqa3_B_2[12] ,
    \Eqa3_B_2[11] ,
    \Eqa3_B_2[10] ,
    \Eqa3_B_2[9] ,
    \Eqa3_B_2[8] ,
    \Eqa3_B_2[7] ,
    \Eqa3_B_2[6] ,
    \Eqa3_B_2[5] ,
    \Eqa3_B_2[4] ,
    \Eqa3_B_2[3] ,
    \Eqa3_B_2[2] ,
    \Eqa3_B_2[1] ,
    \Eqa3_B_2[0] ,
    coeff_we_3,
    coeff_set_3,
    EQA_flag,
    clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \Eqa3_A_0[17] ;
input \Eqa3_A_0[16] ;
input \Eqa3_A_0[15] ;
input \Eqa3_A_0[14] ;
input \Eqa3_A_0[13] ;
input \Eqa3_A_0[12] ;
input \Eqa3_A_0[11] ;
input \Eqa3_A_0[10] ;
input \Eqa3_A_0[9] ;
input \Eqa3_A_0[8] ;
input \Eqa3_A_0[7] ;
input \Eqa3_A_0[6] ;
input \Eqa3_A_0[5] ;
input \Eqa3_A_0[4] ;
input \Eqa3_A_0[3] ;
input \Eqa3_A_0[2] ;
input \Eqa3_A_0[1] ;
input \Eqa3_A_0[0] ;
input \Eqa3_A_1[17] ;
input \Eqa3_A_1[16] ;
input \Eqa3_A_1[15] ;
input \Eqa3_A_1[14] ;
input \Eqa3_A_1[13] ;
input \Eqa3_A_1[12] ;
input \Eqa3_A_1[11] ;
input \Eqa3_A_1[10] ;
input \Eqa3_A_1[9] ;
input \Eqa3_A_1[8] ;
input \Eqa3_A_1[7] ;
input \Eqa3_A_1[6] ;
input \Eqa3_A_1[5] ;
input \Eqa3_A_1[4] ;
input \Eqa3_A_1[3] ;
input \Eqa3_A_1[2] ;
input \Eqa3_A_1[1] ;
input \Eqa3_A_1[0] ;
input \Eqa3_A_2[17] ;
input \Eqa3_A_2[16] ;
input \Eqa3_A_2[15] ;
input \Eqa3_A_2[14] ;
input \Eqa3_A_2[13] ;
input \Eqa3_A_2[12] ;
input \Eqa3_A_2[11] ;
input \Eqa3_A_2[10] ;
input \Eqa3_A_2[9] ;
input \Eqa3_A_2[8] ;
input \Eqa3_A_2[7] ;
input \Eqa3_A_2[6] ;
input \Eqa3_A_2[5] ;
input \Eqa3_A_2[4] ;
input \Eqa3_A_2[3] ;
input \Eqa3_A_2[2] ;
input \Eqa3_A_2[1] ;
input \Eqa3_A_2[0] ;
input \Eqa3_B_0[17] ;
input \Eqa3_B_0[16] ;
input \Eqa3_B_0[15] ;
input \Eqa3_B_0[14] ;
input \Eqa3_B_0[13] ;
input \Eqa3_B_0[12] ;
input \Eqa3_B_0[11] ;
input \Eqa3_B_0[10] ;
input \Eqa3_B_0[9] ;
input \Eqa3_B_0[8] ;
input \Eqa3_B_0[7] ;
input \Eqa3_B_0[6] ;
input \Eqa3_B_0[5] ;
input \Eqa3_B_0[4] ;
input \Eqa3_B_0[3] ;
input \Eqa3_B_0[2] ;
input \Eqa3_B_0[1] ;
input \Eqa3_B_0[0] ;
input \Eqa3_B_1[17] ;
input \Eqa3_B_1[16] ;
input \Eqa3_B_1[15] ;
input \Eqa3_B_1[14] ;
input \Eqa3_B_1[13] ;
input \Eqa3_B_1[12] ;
input \Eqa3_B_1[11] ;
input \Eqa3_B_1[10] ;
input \Eqa3_B_1[9] ;
input \Eqa3_B_1[8] ;
input \Eqa3_B_1[7] ;
input \Eqa3_B_1[6] ;
input \Eqa3_B_1[5] ;
input \Eqa3_B_1[4] ;
input \Eqa3_B_1[3] ;
input \Eqa3_B_1[2] ;
input \Eqa3_B_1[1] ;
input \Eqa3_B_1[0] ;
input \Eqa3_B_2[17] ;
input \Eqa3_B_2[16] ;
input \Eqa3_B_2[15] ;
input \Eqa3_B_2[14] ;
input \Eqa3_B_2[13] ;
input \Eqa3_B_2[12] ;
input \Eqa3_B_2[11] ;
input \Eqa3_B_2[10] ;
input \Eqa3_B_2[9] ;
input \Eqa3_B_2[8] ;
input \Eqa3_B_2[7] ;
input \Eqa3_B_2[6] ;
input \Eqa3_B_2[5] ;
input \Eqa3_B_2[4] ;
input \Eqa3_B_2[3] ;
input \Eqa3_B_2[2] ;
input \Eqa3_B_2[1] ;
input \Eqa3_B_2[0] ;
input coeff_we_3;
input coeff_set_3;
input EQA_flag;
input clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \Eqa3_A_0[17] ;
wire \Eqa3_A_0[16] ;
wire \Eqa3_A_0[15] ;
wire \Eqa3_A_0[14] ;
wire \Eqa3_A_0[13] ;
wire \Eqa3_A_0[12] ;
wire \Eqa3_A_0[11] ;
wire \Eqa3_A_0[10] ;
wire \Eqa3_A_0[9] ;
wire \Eqa3_A_0[8] ;
wire \Eqa3_A_0[7] ;
wire \Eqa3_A_0[6] ;
wire \Eqa3_A_0[5] ;
wire \Eqa3_A_0[4] ;
wire \Eqa3_A_0[3] ;
wire \Eqa3_A_0[2] ;
wire \Eqa3_A_0[1] ;
wire \Eqa3_A_0[0] ;
wire \Eqa3_A_1[17] ;
wire \Eqa3_A_1[16] ;
wire \Eqa3_A_1[15] ;
wire \Eqa3_A_1[14] ;
wire \Eqa3_A_1[13] ;
wire \Eqa3_A_1[12] ;
wire \Eqa3_A_1[11] ;
wire \Eqa3_A_1[10] ;
wire \Eqa3_A_1[9] ;
wire \Eqa3_A_1[8] ;
wire \Eqa3_A_1[7] ;
wire \Eqa3_A_1[6] ;
wire \Eqa3_A_1[5] ;
wire \Eqa3_A_1[4] ;
wire \Eqa3_A_1[3] ;
wire \Eqa3_A_1[2] ;
wire \Eqa3_A_1[1] ;
wire \Eqa3_A_1[0] ;
wire \Eqa3_A_2[17] ;
wire \Eqa3_A_2[16] ;
wire \Eqa3_A_2[15] ;
wire \Eqa3_A_2[14] ;
wire \Eqa3_A_2[13] ;
wire \Eqa3_A_2[12] ;
wire \Eqa3_A_2[11] ;
wire \Eqa3_A_2[10] ;
wire \Eqa3_A_2[9] ;
wire \Eqa3_A_2[8] ;
wire \Eqa3_A_2[7] ;
wire \Eqa3_A_2[6] ;
wire \Eqa3_A_2[5] ;
wire \Eqa3_A_2[4] ;
wire \Eqa3_A_2[3] ;
wire \Eqa3_A_2[2] ;
wire \Eqa3_A_2[1] ;
wire \Eqa3_A_2[0] ;
wire \Eqa3_B_0[17] ;
wire \Eqa3_B_0[16] ;
wire \Eqa3_B_0[15] ;
wire \Eqa3_B_0[14] ;
wire \Eqa3_B_0[13] ;
wire \Eqa3_B_0[12] ;
wire \Eqa3_B_0[11] ;
wire \Eqa3_B_0[10] ;
wire \Eqa3_B_0[9] ;
wire \Eqa3_B_0[8] ;
wire \Eqa3_B_0[7] ;
wire \Eqa3_B_0[6] ;
wire \Eqa3_B_0[5] ;
wire \Eqa3_B_0[4] ;
wire \Eqa3_B_0[3] ;
wire \Eqa3_B_0[2] ;
wire \Eqa3_B_0[1] ;
wire \Eqa3_B_0[0] ;
wire \Eqa3_B_1[17] ;
wire \Eqa3_B_1[16] ;
wire \Eqa3_B_1[15] ;
wire \Eqa3_B_1[14] ;
wire \Eqa3_B_1[13] ;
wire \Eqa3_B_1[12] ;
wire \Eqa3_B_1[11] ;
wire \Eqa3_B_1[10] ;
wire \Eqa3_B_1[9] ;
wire \Eqa3_B_1[8] ;
wire \Eqa3_B_1[7] ;
wire \Eqa3_B_1[6] ;
wire \Eqa3_B_1[5] ;
wire \Eqa3_B_1[4] ;
wire \Eqa3_B_1[3] ;
wire \Eqa3_B_1[2] ;
wire \Eqa3_B_1[1] ;
wire \Eqa3_B_1[0] ;
wire \Eqa3_B_2[17] ;
wire \Eqa3_B_2[16] ;
wire \Eqa3_B_2[15] ;
wire \Eqa3_B_2[14] ;
wire \Eqa3_B_2[13] ;
wire \Eqa3_B_2[12] ;
wire \Eqa3_B_2[11] ;
wire \Eqa3_B_2[10] ;
wire \Eqa3_B_2[9] ;
wire \Eqa3_B_2[8] ;
wire \Eqa3_B_2[7] ;
wire \Eqa3_B_2[6] ;
wire \Eqa3_B_2[5] ;
wire \Eqa3_B_2[4] ;
wire \Eqa3_B_2[3] ;
wire \Eqa3_B_2[2] ;
wire \Eqa3_B_2[1] ;
wire \Eqa3_B_2[0] ;
wire coeff_we_3;
wire coeff_set_3;
wire EQA_flag;
wire clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(EQA_flag),
    .data_i({\Eqa3_A_0[17] ,\Eqa3_A_0[16] ,\Eqa3_A_0[15] ,\Eqa3_A_0[14] ,\Eqa3_A_0[13] ,\Eqa3_A_0[12] ,\Eqa3_A_0[11] ,\Eqa3_A_0[10] ,\Eqa3_A_0[9] ,\Eqa3_A_0[8] ,\Eqa3_A_0[7] ,\Eqa3_A_0[6] ,\Eqa3_A_0[5] ,\Eqa3_A_0[4] ,\Eqa3_A_0[3] ,\Eqa3_A_0[2] ,\Eqa3_A_0[1] ,\Eqa3_A_0[0] ,\Eqa3_A_1[17] ,\Eqa3_A_1[16] ,\Eqa3_A_1[15] ,\Eqa3_A_1[14] ,\Eqa3_A_1[13] ,\Eqa3_A_1[12] ,\Eqa3_A_1[11] ,\Eqa3_A_1[10] ,\Eqa3_A_1[9] ,\Eqa3_A_1[8] ,\Eqa3_A_1[7] ,\Eqa3_A_1[6] ,\Eqa3_A_1[5] ,\Eqa3_A_1[4] ,\Eqa3_A_1[3] ,\Eqa3_A_1[2] ,\Eqa3_A_1[1] ,\Eqa3_A_1[0] ,\Eqa3_A_2[17] ,\Eqa3_A_2[16] ,\Eqa3_A_2[15] ,\Eqa3_A_2[14] ,\Eqa3_A_2[13] ,\Eqa3_A_2[12] ,\Eqa3_A_2[11] ,\Eqa3_A_2[10] ,\Eqa3_A_2[9] ,\Eqa3_A_2[8] ,\Eqa3_A_2[7] ,\Eqa3_A_2[6] ,\Eqa3_A_2[5] ,\Eqa3_A_2[4] ,\Eqa3_A_2[3] ,\Eqa3_A_2[2] ,\Eqa3_A_2[1] ,\Eqa3_A_2[0] ,\Eqa3_B_0[17] ,\Eqa3_B_0[16] ,\Eqa3_B_0[15] ,\Eqa3_B_0[14] ,\Eqa3_B_0[13] ,\Eqa3_B_0[12] ,\Eqa3_B_0[11] ,\Eqa3_B_0[10] ,\Eqa3_B_0[9] ,\Eqa3_B_0[8] ,\Eqa3_B_0[7] ,\Eqa3_B_0[6] ,\Eqa3_B_0[5] ,\Eqa3_B_0[4] ,\Eqa3_B_0[3] ,\Eqa3_B_0[2] ,\Eqa3_B_0[1] ,\Eqa3_B_0[0] ,\Eqa3_B_1[17] ,\Eqa3_B_1[16] ,\Eqa3_B_1[15] ,\Eqa3_B_1[14] ,\Eqa3_B_1[13] ,\Eqa3_B_1[12] ,\Eqa3_B_1[11] ,\Eqa3_B_1[10] ,\Eqa3_B_1[9] ,\Eqa3_B_1[8] ,\Eqa3_B_1[7] ,\Eqa3_B_1[6] ,\Eqa3_B_1[5] ,\Eqa3_B_1[4] ,\Eqa3_B_1[3] ,\Eqa3_B_1[2] ,\Eqa3_B_1[1] ,\Eqa3_B_1[0] ,\Eqa3_B_2[17] ,\Eqa3_B_2[16] ,\Eqa3_B_2[15] ,\Eqa3_B_2[14] ,\Eqa3_B_2[13] ,\Eqa3_B_2[12] ,\Eqa3_B_2[11] ,\Eqa3_B_2[10] ,\Eqa3_B_2[9] ,\Eqa3_B_2[8] ,\Eqa3_B_2[7] ,\Eqa3_B_2[6] ,\Eqa3_B_2[5] ,\Eqa3_B_2[4] ,\Eqa3_B_2[3] ,\Eqa3_B_2[2] ,\Eqa3_B_2[1] ,\Eqa3_B_2[0] ,coeff_we_3,coeff_set_3}),
    .clk_i(clk)
);

endmodule
