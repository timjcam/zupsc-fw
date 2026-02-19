create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys/zynq_ultra_ps_e_0/U0/pl_clk0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 9 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {read_dcct_adcs/dcct_ch0/bit_count[0]} {read_dcct_adcs/dcct_ch0/bit_count[1]} {read_dcct_adcs/dcct_ch0/bit_count[2]} {read_dcct_adcs/dcct_ch0/bit_count[3]} {read_dcct_adcs/dcct_ch0/bit_count[4]} {read_dcct_adcs/dcct_ch0/bit_count[5]} {read_dcct_adcs/dcct_ch0/bit_count[6]} {read_dcct_adcs/dcct_ch0/bit_count[7]} {read_dcct_adcs/dcct_ch0/bit_count[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {mon_adc_cnv_OBUF[0]} {mon_adc_cnv_OBUF[1]} {mon_adc_cnv_OBUF[2]} {mon_adc_cnv_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {mon_adc_sdo_IBUF[0]} {mon_adc_sdo_IBUF[1]} {mon_adc_sdo_IBUF[2]} {mon_adc_sdo_IBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {mon_adc_sck_OBUF[0]} {mon_adc_sck_OBUF[1]} {mon_adc_sck_OBUF[2]} {mon_adc_sck_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {mon_adc_fs_OBUF[0]} {mon_adc_fs_OBUF[1]} {mon_adc_fs_OBUF[2]} {mon_adc_fs_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {read_mon_adcs/adc0[0]} {read_mon_adcs/adc0[1]} {read_mon_adcs/adc0[2]} {read_mon_adcs/adc0[3]} {read_mon_adcs/adc0[4]} {read_mon_adcs/adc0[5]} {read_mon_adcs/adc0[6]} {read_mon_adcs/adc0[7]} {read_mon_adcs/adc0[8]} {read_mon_adcs/adc0[9]} {read_mon_adcs/adc0[10]} {read_mon_adcs/adc0[11]} {read_mon_adcs/adc0[12]} {read_mon_adcs/adc0[13]} {read_mon_adcs/adc0[14]} {read_mon_adcs/adc0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {read_mon_adcs/adc1[0]} {read_mon_adcs/adc1[1]} {read_mon_adcs/adc1[2]} {read_mon_adcs/adc1[3]} {read_mon_adcs/adc1[4]} {read_mon_adcs/adc1[5]} {read_mon_adcs/adc1[6]} {read_mon_adcs/adc1[7]} {read_mon_adcs/adc1[8]} {read_mon_adcs/adc1[9]} {read_mon_adcs/adc1[10]} {read_mon_adcs/adc1[11]} {read_mon_adcs/adc1[12]} {read_mon_adcs/adc1[13]} {read_mon_adcs/adc1[14]} {read_mon_adcs/adc1[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {read_mon_adcs/adc4[0]} {read_mon_adcs/adc4[1]} {read_mon_adcs/adc4[2]} {read_mon_adcs/adc4[3]} {read_mon_adcs/adc4[4]} {read_mon_adcs/adc4[5]} {read_mon_adcs/adc4[6]} {read_mon_adcs/adc4[7]} {read_mon_adcs/adc4[8]} {read_mon_adcs/adc4[9]} {read_mon_adcs/adc4[10]} {read_mon_adcs/adc4[11]} {read_mon_adcs/adc4[12]} {read_mon_adcs/adc4[13]} {read_mon_adcs/adc4[14]} {read_mon_adcs/adc4[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {read_mon_adcs/adc2[0]} {read_mon_adcs/adc2[1]} {read_mon_adcs/adc2[2]} {read_mon_adcs/adc2[3]} {read_mon_adcs/adc2[4]} {read_mon_adcs/adc2[5]} {read_mon_adcs/adc2[6]} {read_mon_adcs/adc2[7]} {read_mon_adcs/adc2[8]} {read_mon_adcs/adc2[9]} {read_mon_adcs/adc2[10]} {read_mon_adcs/adc2[11]} {read_mon_adcs/adc2[12]} {read_mon_adcs/adc2[13]} {read_mon_adcs/adc2[14]} {read_mon_adcs/adc2[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {read_mon_adcs/adc3[0]} {read_mon_adcs/adc3[1]} {read_mon_adcs/adc3[2]} {read_mon_adcs/adc3[3]} {read_mon_adcs/adc3[4]} {read_mon_adcs/adc3[5]} {read_mon_adcs/adc3[6]} {read_mon_adcs/adc3[7]} {read_mon_adcs/adc3[8]} {read_mon_adcs/adc3[9]} {read_mon_adcs/adc3[10]} {read_mon_adcs/adc3[11]} {read_mon_adcs/adc3[12]} {read_mon_adcs/adc3[13]} {read_mon_adcs/adc3[14]} {read_mon_adcs/adc3[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {read_mon_adcs/adc7[0]} {read_mon_adcs/adc7[1]} {read_mon_adcs/adc7[2]} {read_mon_adcs/adc7[3]} {read_mon_adcs/adc7[4]} {read_mon_adcs/adc7[5]} {read_mon_adcs/adc7[6]} {read_mon_adcs/adc7[7]} {read_mon_adcs/adc7[8]} {read_mon_adcs/adc7[9]} {read_mon_adcs/adc7[10]} {read_mon_adcs/adc7[11]} {read_mon_adcs/adc7[12]} {read_mon_adcs/adc7[13]} {read_mon_adcs/adc7[14]} {read_mon_adcs/adc7[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {read_mon_adcs/adc5[0]} {read_mon_adcs/adc5[1]} {read_mon_adcs/adc5[2]} {read_mon_adcs/adc5[3]} {read_mon_adcs/adc5[4]} {read_mon_adcs/adc5[5]} {read_mon_adcs/adc5[6]} {read_mon_adcs/adc5[7]} {read_mon_adcs/adc5[8]} {read_mon_adcs/adc5[9]} {read_mon_adcs/adc5[10]} {read_mon_adcs/adc5[11]} {read_mon_adcs/adc5[12]} {read_mon_adcs/adc5[13]} {read_mon_adcs/adc5[14]} {read_mon_adcs/adc5[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {read_mon_adcs/adc6[0]} {read_mon_adcs/adc6[1]} {read_mon_adcs/adc6[2]} {read_mon_adcs/adc6[3]} {read_mon_adcs/adc6[4]} {read_mon_adcs/adc6[5]} {read_mon_adcs/adc6[6]} {read_mon_adcs/adc6[7]} {read_mon_adcs/adc6[8]} {read_mon_adcs/adc6[9]} {read_mon_adcs/adc6[10]} {read_mon_adcs/adc6[11]} {read_mon_adcs/adc6[12]} {read_mon_adcs/adc6[13]} {read_mon_adcs/adc6[14]} {read_mon_adcs/adc6[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 20 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {read_dcct_adcs/dcct_ch0/dcct0[0]} {read_dcct_adcs/dcct_ch0/dcct0[1]} {read_dcct_adcs/dcct_ch0/dcct0[2]} {read_dcct_adcs/dcct_ch0/dcct0[3]} {read_dcct_adcs/dcct_ch0/dcct0[4]} {read_dcct_adcs/dcct_ch0/dcct0[5]} {read_dcct_adcs/dcct_ch0/dcct0[6]} {read_dcct_adcs/dcct_ch0/dcct0[7]} {read_dcct_adcs/dcct_ch0/dcct0[8]} {read_dcct_adcs/dcct_ch0/dcct0[9]} {read_dcct_adcs/dcct_ch0/dcct0[10]} {read_dcct_adcs/dcct_ch0/dcct0[11]} {read_dcct_adcs/dcct_ch0/dcct0[12]} {read_dcct_adcs/dcct_ch0/dcct0[13]} {read_dcct_adcs/dcct_ch0/dcct0[14]} {read_dcct_adcs/dcct_ch0/dcct0[15]} {read_dcct_adcs/dcct_ch0/dcct0[16]} {read_dcct_adcs/dcct_ch0/dcct0[17]} {read_dcct_adcs/dcct_ch0/dcct0[18]} {read_dcct_adcs/dcct_ch0/dcct0[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 20 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {read_dcct_adcs/dcct_ch0/dcct1[0]} {read_dcct_adcs/dcct_ch0/dcct1[1]} {read_dcct_adcs/dcct_ch0/dcct1[2]} {read_dcct_adcs/dcct_ch0/dcct1[3]} {read_dcct_adcs/dcct_ch0/dcct1[4]} {read_dcct_adcs/dcct_ch0/dcct1[5]} {read_dcct_adcs/dcct_ch0/dcct1[6]} {read_dcct_adcs/dcct_ch0/dcct1[7]} {read_dcct_adcs/dcct_ch0/dcct1[8]} {read_dcct_adcs/dcct_ch0/dcct1[9]} {read_dcct_adcs/dcct_ch0/dcct1[10]} {read_dcct_adcs/dcct_ch0/dcct1[11]} {read_dcct_adcs/dcct_ch0/dcct1[12]} {read_dcct_adcs/dcct_ch0/dcct1[13]} {read_dcct_adcs/dcct_ch0/dcct1[14]} {read_dcct_adcs/dcct_ch0/dcct1[15]} {read_dcct_adcs/dcct_ch0/dcct1[16]} {read_dcct_adcs/dcct_ch0/dcct1[17]} {read_dcct_adcs/dcct_ch0/dcct1[18]} {read_dcct_adcs/dcct_ch0/dcct1[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 6 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {read_dcct_adcs/dcct_ch0/num_bits[0]} {read_dcct_adcs/dcct_ch0/num_bits[1]} {read_dcct_adcs/dcct_ch0/num_bits[2]} {read_dcct_adcs/dcct_ch0/num_bits[3]} {read_dcct_adcs/dcct_ch0/num_bits[4]} {read_dcct_adcs/dcct_ch0/num_bits[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 2 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {read_dcct_adcs/dcct_ch0/sdi[0]} {read_dcct_adcs/dcct_ch0/sdi[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 20 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {read_dcct_adcs/dcct_ch0/shift_reg0[0]} {read_dcct_adcs/dcct_ch0/shift_reg0[1]} {read_dcct_adcs/dcct_ch0/shift_reg0[2]} {read_dcct_adcs/dcct_ch0/shift_reg0[3]} {read_dcct_adcs/dcct_ch0/shift_reg0[4]} {read_dcct_adcs/dcct_ch0/shift_reg0[5]} {read_dcct_adcs/dcct_ch0/shift_reg0[6]} {read_dcct_adcs/dcct_ch0/shift_reg0[7]} {read_dcct_adcs/dcct_ch0/shift_reg0[8]} {read_dcct_adcs/dcct_ch0/shift_reg0[9]} {read_dcct_adcs/dcct_ch0/shift_reg0[10]} {read_dcct_adcs/dcct_ch0/shift_reg0[11]} {read_dcct_adcs/dcct_ch0/shift_reg0[12]} {read_dcct_adcs/dcct_ch0/shift_reg0[13]} {read_dcct_adcs/dcct_ch0/shift_reg0[14]} {read_dcct_adcs/dcct_ch0/shift_reg0[15]} {read_dcct_adcs/dcct_ch0/shift_reg0[16]} {read_dcct_adcs/dcct_ch0/shift_reg0[17]} {read_dcct_adcs/dcct_ch0/shift_reg0[18]} {read_dcct_adcs/dcct_ch0/shift_reg0[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 20 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {read_dcct_adcs/dcct_ch0/shift_reg1[0]} {read_dcct_adcs/dcct_ch0/shift_reg1[1]} {read_dcct_adcs/dcct_ch0/shift_reg1[2]} {read_dcct_adcs/dcct_ch0/shift_reg1[3]} {read_dcct_adcs/dcct_ch0/shift_reg1[4]} {read_dcct_adcs/dcct_ch0/shift_reg1[5]} {read_dcct_adcs/dcct_ch0/shift_reg1[6]} {read_dcct_adcs/dcct_ch0/shift_reg1[7]} {read_dcct_adcs/dcct_ch0/shift_reg1[8]} {read_dcct_adcs/dcct_ch0/shift_reg1[9]} {read_dcct_adcs/dcct_ch0/shift_reg1[10]} {read_dcct_adcs/dcct_ch0/shift_reg1[11]} {read_dcct_adcs/dcct_ch0/shift_reg1[12]} {read_dcct_adcs/dcct_ch0/shift_reg1[13]} {read_dcct_adcs/dcct_ch0/shift_reg1[14]} {read_dcct_adcs/dcct_ch0/shift_reg1[15]} {read_dcct_adcs/dcct_ch0/shift_reg1[16]} {read_dcct_adcs/dcct_ch0/shift_reg1[17]} {read_dcct_adcs/dcct_ch0/shift_reg1[18]} {read_dcct_adcs/dcct_ch0/shift_reg1[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 3 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {read_dcct_adcs/dcct_ch0/state[0]} {read_dcct_adcs/dcct_ch0/state[1]} {read_dcct_adcs/dcct_ch0/state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 4 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {read_dcct_adcs/sclk[0]} {read_dcct_adcs/sclk[1]} {read_dcct_adcs/sclk[2]} {read_dcct_adcs/sclk[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 8 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {read_dcct_adcs/sdi[0]} {read_dcct_adcs/sdi[1]} {read_dcct_adcs/sdi[2]} {read_dcct_adcs/sdi[3]} {read_dcct_adcs/sdi[4]} {read_dcct_adcs/sdi[5]} {read_dcct_adcs/sdi[6]} {read_dcct_adcs/sdi[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 8 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {dcct_adc_sdo_IBUF[0]} {dcct_adc_sdo_IBUF[1]} {dcct_adc_sdo_IBUF[2]} {dcct_adc_sdo_IBUF[3]} {dcct_adc_sdo_IBUF[4]} {dcct_adc_sdo_IBUF[5]} {dcct_adc_sdo_IBUF[6]} {dcct_adc_sdo_IBUF[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 4 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {dcct_adc_sck_OBUF[0]} {dcct_adc_sck_OBUF[1]} {dcct_adc_sck_OBUF[2]} {dcct_adc_sck_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 4 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {dcct_adc_cnv_OBUF[0]} {dcct_adc_cnv_OBUF[1]} {dcct_adc_cnv_OBUF[2]} {dcct_adc_cnv_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list read_dcct_adcs/dcct_ch0/cnv]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list read_dcct_adcs/dcct_ch0/clk_enb]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list read_dcct_adcs/dcct_ch0/data_rdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list tenkhz_trig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list read_dcct_adcs/dcct_ch0/sclk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list read_dcct_adcs/dcct_ch0/start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list read_dcct_adcs/dcct_ch0/start_lat]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
