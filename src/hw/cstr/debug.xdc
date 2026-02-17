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
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {mon_adc_sdo_IBUF[0]} {mon_adc_sdo_IBUF[1]} {mon_adc_sdo_IBUF[2]} {mon_adc_sdo_IBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {mon_adc_sck_OBUF[0]} {mon_adc_sck_OBUF[1]} {mon_adc_sck_OBUF[2]} {mon_adc_sck_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {mon_adc_fs_OBUF[0]} {mon_adc_fs_OBUF[1]} {mon_adc_fs_OBUF[2]} {mon_adc_fs_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {mon_adc_cnv_OBUF[0]} {mon_adc_cnv_OBUF[1]} {mon_adc_cnv_OBUF[2]} {mon_adc_cnv_OBUF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {read_mon_adcs/adc7[0]} {read_mon_adcs/adc7[1]} {read_mon_adcs/adc7[2]} {read_mon_adcs/adc7[3]} {read_mon_adcs/adc7[4]} {read_mon_adcs/adc7[5]} {read_mon_adcs/adc7[6]} {read_mon_adcs/adc7[7]} {read_mon_adcs/adc7[8]} {read_mon_adcs/adc7[9]} {read_mon_adcs/adc7[10]} {read_mon_adcs/adc7[11]} {read_mon_adcs/adc7[12]} {read_mon_adcs/adc7[13]} {read_mon_adcs/adc7[14]} {read_mon_adcs/adc7[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {read_mon_adcs/adc5[0]} {read_mon_adcs/adc5[1]} {read_mon_adcs/adc5[2]} {read_mon_adcs/adc5[3]} {read_mon_adcs/adc5[4]} {read_mon_adcs/adc5[5]} {read_mon_adcs/adc5[6]} {read_mon_adcs/adc5[7]} {read_mon_adcs/adc5[8]} {read_mon_adcs/adc5[9]} {read_mon_adcs/adc5[10]} {read_mon_adcs/adc5[11]} {read_mon_adcs/adc5[12]} {read_mon_adcs/adc5[13]} {read_mon_adcs/adc5[14]} {read_mon_adcs/adc5[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {read_mon_adcs/adc6[0]} {read_mon_adcs/adc6[1]} {read_mon_adcs/adc6[2]} {read_mon_adcs/adc6[3]} {read_mon_adcs/adc6[4]} {read_mon_adcs/adc6[5]} {read_mon_adcs/adc6[6]} {read_mon_adcs/adc6[7]} {read_mon_adcs/adc6[8]} {read_mon_adcs/adc6[9]} {read_mon_adcs/adc6[10]} {read_mon_adcs/adc6[11]} {read_mon_adcs/adc6[12]} {read_mon_adcs/adc6[13]} {read_mon_adcs/adc6[14]} {read_mon_adcs/adc6[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {read_mon_adcs/adc0[0]} {read_mon_adcs/adc0[1]} {read_mon_adcs/adc0[2]} {read_mon_adcs/adc0[3]} {read_mon_adcs/adc0[4]} {read_mon_adcs/adc0[5]} {read_mon_adcs/adc0[6]} {read_mon_adcs/adc0[7]} {read_mon_adcs/adc0[8]} {read_mon_adcs/adc0[9]} {read_mon_adcs/adc0[10]} {read_mon_adcs/adc0[11]} {read_mon_adcs/adc0[12]} {read_mon_adcs/adc0[13]} {read_mon_adcs/adc0[14]} {read_mon_adcs/adc0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {read_mon_adcs/adc1[0]} {read_mon_adcs/adc1[1]} {read_mon_adcs/adc1[2]} {read_mon_adcs/adc1[3]} {read_mon_adcs/adc1[4]} {read_mon_adcs/adc1[5]} {read_mon_adcs/adc1[6]} {read_mon_adcs/adc1[7]} {read_mon_adcs/adc1[8]} {read_mon_adcs/adc1[9]} {read_mon_adcs/adc1[10]} {read_mon_adcs/adc1[11]} {read_mon_adcs/adc1[12]} {read_mon_adcs/adc1[13]} {read_mon_adcs/adc1[14]} {read_mon_adcs/adc1[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {read_mon_adcs/adc4[0]} {read_mon_adcs/adc4[1]} {read_mon_adcs/adc4[2]} {read_mon_adcs/adc4[3]} {read_mon_adcs/adc4[4]} {read_mon_adcs/adc4[5]} {read_mon_adcs/adc4[6]} {read_mon_adcs/adc4[7]} {read_mon_adcs/adc4[8]} {read_mon_adcs/adc4[9]} {read_mon_adcs/adc4[10]} {read_mon_adcs/adc4[11]} {read_mon_adcs/adc4[12]} {read_mon_adcs/adc4[13]} {read_mon_adcs/adc4[14]} {read_mon_adcs/adc4[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {read_mon_adcs/adc2[0]} {read_mon_adcs/adc2[1]} {read_mon_adcs/adc2[2]} {read_mon_adcs/adc2[3]} {read_mon_adcs/adc2[4]} {read_mon_adcs/adc2[5]} {read_mon_adcs/adc2[6]} {read_mon_adcs/adc2[7]} {read_mon_adcs/adc2[8]} {read_mon_adcs/adc2[9]} {read_mon_adcs/adc2[10]} {read_mon_adcs/adc2[11]} {read_mon_adcs/adc2[12]} {read_mon_adcs/adc2[13]} {read_mon_adcs/adc2[14]} {read_mon_adcs/adc2[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {read_mon_adcs/adc3[0]} {read_mon_adcs/adc3[1]} {read_mon_adcs/adc3[2]} {read_mon_adcs/adc3[3]} {read_mon_adcs/adc3[4]} {read_mon_adcs/adc3[5]} {read_mon_adcs/adc3[6]} {read_mon_adcs/adc3[7]} {read_mon_adcs/adc3[8]} {read_mon_adcs/adc3[9]} {read_mon_adcs/adc3[10]} {read_mon_adcs/adc3[11]} {read_mon_adcs/adc3[12]} {read_mon_adcs/adc3[13]} {read_mon_adcs/adc3[14]} {read_mon_adcs/adc3[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list tenkhz_trig]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0]
