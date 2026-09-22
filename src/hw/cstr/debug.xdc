create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys/zynq_ultra_ps_e_0/U0/pl_clk0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 20 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {write_dacs/dac0/dac_cntrl[dds_offset][0]} {write_dacs/dac0/dac_cntrl[dds_offset][1]} {write_dacs/dac0/dac_cntrl[dds_offset][2]} {write_dacs/dac0/dac_cntrl[dds_offset][3]} {write_dacs/dac0/dac_cntrl[dds_offset][4]} {write_dacs/dac0/dac_cntrl[dds_offset][5]} {write_dacs/dac0/dac_cntrl[dds_offset][6]} {write_dacs/dac0/dac_cntrl[dds_offset][7]} {write_dacs/dac0/dac_cntrl[dds_offset][8]} {write_dacs/dac0/dac_cntrl[dds_offset][9]} {write_dacs/dac0/dac_cntrl[dds_offset][10]} {write_dacs/dac0/dac_cntrl[dds_offset][11]} {write_dacs/dac0/dac_cntrl[dds_offset][12]} {write_dacs/dac0/dac_cntrl[dds_offset][13]} {write_dacs/dac0/dac_cntrl[dds_offset][14]} {write_dacs/dac0/dac_cntrl[dds_offset][15]} {write_dacs/dac0/dac_cntrl[dds_offset][16]} {write_dacs/dac0/dac_cntrl[dds_offset][17]} {write_dacs/dac0/dac_cntrl[dds_offset][18]} {write_dacs/dac0/dac_cntrl[dds_offset][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {write_dacs/dac0/dac_cntrl[dds_freq][0]} {write_dacs/dac0/dac_cntrl[dds_freq][1]} {write_dacs/dac0/dac_cntrl[dds_freq][2]} {write_dacs/dac0/dac_cntrl[dds_freq][3]} {write_dacs/dac0/dac_cntrl[dds_freq][4]} {write_dacs/dac0/dac_cntrl[dds_freq][5]} {write_dacs/dac0/dac_cntrl[dds_freq][6]} {write_dacs/dac0/dac_cntrl[dds_freq][7]} {write_dacs/dac0/dac_cntrl[dds_freq][8]} {write_dacs/dac0/dac_cntrl[dds_freq][9]} {write_dacs/dac0/dac_cntrl[dds_freq][10]} {write_dacs/dac0/dac_cntrl[dds_freq][11]} {write_dacs/dac0/dac_cntrl[dds_freq][12]} {write_dacs/dac0/dac_cntrl[dds_freq][13]} {write_dacs/dac0/dac_cntrl[dds_freq][14]} {write_dacs/dac0/dac_cntrl[dds_freq][15]} {write_dacs/dac0/dac_cntrl[dds_freq][16]} {write_dacs/dac0/dac_cntrl[dds_freq][17]} {write_dacs/dac0/dac_cntrl[dds_freq][18]} {write_dacs/dac0/dac_cntrl[dds_freq][19]} {write_dacs/dac0/dac_cntrl[dds_freq][20]} {write_dacs/dac0/dac_cntrl[dds_freq][21]} {write_dacs/dac0/dac_cntrl[dds_freq][22]} {write_dacs/dac0/dac_cntrl[dds_freq][23]} {write_dacs/dac0/dac_cntrl[dds_freq][24]} {write_dacs/dac0/dac_cntrl[dds_freq][25]} {write_dacs/dac0/dac_cntrl[dds_freq][26]} {write_dacs/dac0/dac_cntrl[dds_freq][27]} {write_dacs/dac0/dac_cntrl[dds_freq][28]} {write_dacs/dac0/dac_cntrl[dds_freq][29]} {write_dacs/dac0/dac_cntrl[dds_freq][30]} {write_dacs/dac0/dac_cntrl[dds_freq][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 20 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {write_dacs/dac0/dac_cntrl[dds_amplitude][0]} {write_dacs/dac0/dac_cntrl[dds_amplitude][1]} {write_dacs/dac0/dac_cntrl[dds_amplitude][2]} {write_dacs/dac0/dac_cntrl[dds_amplitude][3]} {write_dacs/dac0/dac_cntrl[dds_amplitude][4]} {write_dacs/dac0/dac_cntrl[dds_amplitude][5]} {write_dacs/dac0/dac_cntrl[dds_amplitude][6]} {write_dacs/dac0/dac_cntrl[dds_amplitude][7]} {write_dacs/dac0/dac_cntrl[dds_amplitude][8]} {write_dacs/dac0/dac_cntrl[dds_amplitude][9]} {write_dacs/dac0/dac_cntrl[dds_amplitude][10]} {write_dacs/dac0/dac_cntrl[dds_amplitude][11]} {write_dacs/dac0/dac_cntrl[dds_amplitude][12]} {write_dacs/dac0/dac_cntrl[dds_amplitude][13]} {write_dacs/dac0/dac_cntrl[dds_amplitude][14]} {write_dacs/dac0/dac_cntrl[dds_amplitude][15]} {write_dacs/dac0/dac_cntrl[dds_amplitude][16]} {write_dacs/dac0/dac_cntrl[dds_amplitude][17]} {write_dacs/dac0/dac_cntrl[dds_amplitude][18]} {write_dacs/dac0/dac_cntrl[dds_amplitude][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {write_dacs/dac0/dac_cntrl[cntrl][0]} {write_dacs/dac0/dac_cntrl[cntrl][1]} {write_dacs/dac0/dac_cntrl[cntrl][2]} {write_dacs/dac0/dac_cntrl[cntrl][3]} {write_dacs/dac0/dac_cntrl[cntrl][4]} {write_dacs/dac0/dac_cntrl[cntrl][5]} {write_dacs/dac0/dac_cntrl[cntrl][6]} {write_dacs/dac0/dac_cntrl[cntrl][7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {write_dacs/dac0/dac_cntrl[mode][0]} {write_dacs/dac0/dac_cntrl[mode][1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {write_dacs/dac0/dac_cntrl[dpram_addr][0]} {write_dacs/dac0/dac_cntrl[dpram_addr][1]} {write_dacs/dac0/dac_cntrl[dpram_addr][2]} {write_dacs/dac0/dac_cntrl[dpram_addr][3]} {write_dacs/dac0/dac_cntrl[dpram_addr][4]} {write_dacs/dac0/dac_cntrl[dpram_addr][5]} {write_dacs/dac0/dac_cntrl[dpram_addr][6]} {write_dacs/dac0/dac_cntrl[dpram_addr][7]} {write_dacs/dac0/dac_cntrl[dpram_addr][8]} {write_dacs/dac0/dac_cntrl[dpram_addr][9]} {write_dacs/dac0/dac_cntrl[dpram_addr][10]} {write_dacs/dac0/dac_cntrl[dpram_addr][11]} {write_dacs/dac0/dac_cntrl[dpram_addr][12]} {write_dacs/dac0/dac_cntrl[dpram_addr][13]} {write_dacs/dac0/dac_cntrl[dpram_addr][14]} {write_dacs/dac0/dac_cntrl[dpram_addr][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 20 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {write_dacs/dac0/dds_sine[0]} {write_dacs/dac0/dds_sine[1]} {write_dacs/dac0/dds_sine[2]} {write_dacs/dac0/dds_sine[3]} {write_dacs/dac0/dds_sine[4]} {write_dacs/dac0/dds_sine[5]} {write_dacs/dac0/dds_sine[6]} {write_dacs/dac0/dds_sine[7]} {write_dacs/dac0/dds_sine[8]} {write_dacs/dac0/dds_sine[9]} {write_dacs/dac0/dds_sine[10]} {write_dacs/dac0/dds_sine[11]} {write_dacs/dac0/dds_sine[12]} {write_dacs/dac0/dds_sine[13]} {write_dacs/dac0/dds_sine[14]} {write_dacs/dac0/dds_sine[15]} {write_dacs/dac0/dds_sine[16]} {write_dacs/dac0/dds_sine[17]} {write_dacs/dac0/dds_sine[18]} {write_dacs/dac0/dds_sine[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 20 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {write_dacs/dac0/dds/amplitude[0]} {write_dacs/dac0/dds/amplitude[1]} {write_dacs/dac0/dds/amplitude[2]} {write_dacs/dac0/dds/amplitude[3]} {write_dacs/dac0/dds/amplitude[4]} {write_dacs/dac0/dds/amplitude[5]} {write_dacs/dac0/dds/amplitude[6]} {write_dacs/dac0/dds/amplitude[7]} {write_dacs/dac0/dds/amplitude[8]} {write_dacs/dac0/dds/amplitude[9]} {write_dacs/dac0/dds/amplitude[10]} {write_dacs/dac0/dds/amplitude[11]} {write_dacs/dac0/dds/amplitude[12]} {write_dacs/dac0/dds/amplitude[13]} {write_dacs/dac0/dds/amplitude[14]} {write_dacs/dac0/dds/amplitude[15]} {write_dacs/dac0/dds/amplitude[16]} {write_dacs/dac0/dds/amplitude[17]} {write_dacs/dac0/dds/amplitude[18]} {write_dacs/dac0/dds/amplitude[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 20 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {write_dacs/dac0/dds/dac_out[0]} {write_dacs/dac0/dds/dac_out[1]} {write_dacs/dac0/dds/dac_out[2]} {write_dacs/dac0/dds/dac_out[3]} {write_dacs/dac0/dds/dac_out[4]} {write_dacs/dac0/dds/dac_out[5]} {write_dacs/dac0/dds/dac_out[6]} {write_dacs/dac0/dds/dac_out[7]} {write_dacs/dac0/dds/dac_out[8]} {write_dacs/dac0/dds/dac_out[9]} {write_dacs/dac0/dds/dac_out[10]} {write_dacs/dac0/dds/dac_out[11]} {write_dacs/dac0/dds/dac_out[12]} {write_dacs/dac0/dds/dac_out[13]} {write_dacs/dac0/dds/dac_out[14]} {write_dacs/dac0/dds/dac_out[15]} {write_dacs/dac0/dds/dac_out[16]} {write_dacs/dac0/dds/dac_out[17]} {write_dacs/dac0/dds/dac_out[18]} {write_dacs/dac0/dds/dac_out[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 20 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {write_dacs/dac0/dds/dc_offset[0]} {write_dacs/dac0/dds/dc_offset[1]} {write_dacs/dac0/dds/dc_offset[2]} {write_dacs/dac0/dds/dc_offset[3]} {write_dacs/dac0/dds/dc_offset[4]} {write_dacs/dac0/dds/dc_offset[5]} {write_dacs/dac0/dds/dc_offset[6]} {write_dacs/dac0/dds/dc_offset[7]} {write_dacs/dac0/dds/dc_offset[8]} {write_dacs/dac0/dds/dc_offset[9]} {write_dacs/dac0/dds/dc_offset[10]} {write_dacs/dac0/dds/dc_offset[11]} {write_dacs/dac0/dds/dc_offset[12]} {write_dacs/dac0/dds/dc_offset[13]} {write_dacs/dac0/dds/dc_offset[14]} {write_dacs/dac0/dds/dc_offset[15]} {write_dacs/dac0/dds/dc_offset[16]} {write_dacs/dac0/dds/dc_offset[17]} {write_dacs/dac0/dds/dc_offset[18]} {write_dacs/dac0/dds/dc_offset[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {write_dacs/dac0/dds/dds_freq[0]} {write_dacs/dac0/dds/dds_freq[1]} {write_dacs/dac0/dds/dds_freq[2]} {write_dacs/dac0/dds/dds_freq[3]} {write_dacs/dac0/dds/dds_freq[4]} {write_dacs/dac0/dds/dds_freq[5]} {write_dacs/dac0/dds/dds_freq[6]} {write_dacs/dac0/dds/dds_freq[7]} {write_dacs/dac0/dds/dds_freq[8]} {write_dacs/dac0/dds/dds_freq[9]} {write_dacs/dac0/dds/dds_freq[10]} {write_dacs/dac0/dds/dds_freq[11]} {write_dacs/dac0/dds/dds_freq[12]} {write_dacs/dac0/dds/dds_freq[13]} {write_dacs/dac0/dds/dds_freq[14]} {write_dacs/dac0/dds/dds_freq[15]} {write_dacs/dac0/dds/dds_freq[16]} {write_dacs/dac0/dds/dds_freq[17]} {write_dacs/dac0/dds/dds_freq[18]} {write_dacs/dac0/dds/dds_freq[19]} {write_dacs/dac0/dds/dds_freq[20]} {write_dacs/dac0/dds/dds_freq[21]} {write_dacs/dac0/dds/dds_freq[22]} {write_dacs/dac0/dds/dds_freq[23]} {write_dacs/dac0/dds/dds_freq[24]} {write_dacs/dac0/dds/dds_freq[25]} {write_dacs/dac0/dds/dds_freq[26]} {write_dacs/dac0/dds/dds_freq[27]} {write_dacs/dac0/dds/dds_freq[28]} {write_dacs/dac0/dds/dds_freq[29]} {write_dacs/dac0/dds/dds_freq[30]} {write_dacs/dac0/dds/dds_freq[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 21 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {write_dacs/dac0/dds/dds_scaled[0]} {write_dacs/dac0/dds/dds_scaled[1]} {write_dacs/dac0/dds/dds_scaled[2]} {write_dacs/dac0/dds/dds_scaled[3]} {write_dacs/dac0/dds/dds_scaled[4]} {write_dacs/dac0/dds/dds_scaled[5]} {write_dacs/dac0/dds/dds_scaled[6]} {write_dacs/dac0/dds/dds_scaled[7]} {write_dacs/dac0/dds/dds_scaled[8]} {write_dacs/dac0/dds/dds_scaled[9]} {write_dacs/dac0/dds/dds_scaled[10]} {write_dacs/dac0/dds/dds_scaled[11]} {write_dacs/dac0/dds/dds_scaled[12]} {write_dacs/dac0/dds/dds_scaled[13]} {write_dacs/dac0/dds/dds_scaled[14]} {write_dacs/dac0/dds/dds_scaled[15]} {write_dacs/dac0/dds/dds_scaled[16]} {write_dacs/dac0/dds/dds_scaled[17]} {write_dacs/dac0/dds/dds_scaled[18]} {write_dacs/dac0/dds/dds_scaled[19]} {write_dacs/dac0/dds/dds_scaled[20]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 22 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {write_dacs/dac0/dds/sum_result[0]} {write_dacs/dac0/dds/sum_result[1]} {write_dacs/dac0/dds/sum_result[2]} {write_dacs/dac0/dds/sum_result[3]} {write_dacs/dac0/dds/sum_result[4]} {write_dacs/dac0/dds/sum_result[5]} {write_dacs/dac0/dds/sum_result[6]} {write_dacs/dac0/dds/sum_result[7]} {write_dacs/dac0/dds/sum_result[8]} {write_dacs/dac0/dds/sum_result[9]} {write_dacs/dac0/dds/sum_result[10]} {write_dacs/dac0/dds/sum_result[11]} {write_dacs/dac0/dds/sum_result[12]} {write_dacs/dac0/dds/sum_result[13]} {write_dacs/dac0/dds/sum_result[14]} {write_dacs/dac0/dds/sum_result[15]} {write_dacs/dac0/dds/sum_result[16]} {write_dacs/dac0/dds/sum_result[17]} {write_dacs/dac0/dds/sum_result[18]} {write_dacs/dac0/dds/sum_result[19]} {write_dacs/dac0/dds/sum_result[20]} {write_dacs/dac0/dds/sum_result[21]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 20 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {write_dacs/dac0/dds/dds_sine[0]} {write_dacs/dac0/dds/dds_sine[1]} {write_dacs/dac0/dds/dds_sine[2]} {write_dacs/dac0/dds/dds_sine[3]} {write_dacs/dac0/dds/dds_sine[4]} {write_dacs/dac0/dds/dds_sine[5]} {write_dacs/dac0/dds/dds_sine[6]} {write_dacs/dac0/dds/dds_sine[7]} {write_dacs/dac0/dds/dds_sine[8]} {write_dacs/dac0/dds/dds_sine[9]} {write_dacs/dac0/dds/dds_sine[10]} {write_dacs/dac0/dds/dds_sine[11]} {write_dacs/dac0/dds/dds_sine[12]} {write_dacs/dac0/dds/dds_sine[13]} {write_dacs/dac0/dds/dds_sine[14]} {write_dacs/dac0/dds/dds_sine[15]} {write_dacs/dac0/dds/dds_sine[16]} {write_dacs/dac0/dds/dds_sine[17]} {write_dacs/dac0/dds/dds_sine[18]} {write_dacs/dac0/dds/dds_sine[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 16 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {write_dacs/dac0/dac_cntrl[ramplen][0]} {write_dacs/dac0/dac_cntrl[ramplen][1]} {write_dacs/dac0/dac_cntrl[ramplen][2]} {write_dacs/dac0/dac_cntrl[ramplen][3]} {write_dacs/dac0/dac_cntrl[ramplen][4]} {write_dacs/dac0/dac_cntrl[ramplen][5]} {write_dacs/dac0/dac_cntrl[ramplen][6]} {write_dacs/dac0/dac_cntrl[ramplen][7]} {write_dacs/dac0/dac_cntrl[ramplen][8]} {write_dacs/dac0/dac_cntrl[ramplen][9]} {write_dacs/dac0/dac_cntrl[ramplen][10]} {write_dacs/dac0/dac_cntrl[ramplen][11]} {write_dacs/dac0/dac_cntrl[ramplen][12]} {write_dacs/dac0/dac_cntrl[ramplen][13]} {write_dacs/dac0/dac_cntrl[ramplen][14]} {write_dacs/dac0/dac_cntrl[ramplen][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 20 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {write_dacs/dac0/dac_cntrl[setpoint_last][0]} {write_dacs/dac0/dac_cntrl[setpoint_last][1]} {write_dacs/dac0/dac_cntrl[setpoint_last][2]} {write_dacs/dac0/dac_cntrl[setpoint_last][3]} {write_dacs/dac0/dac_cntrl[setpoint_last][4]} {write_dacs/dac0/dac_cntrl[setpoint_last][5]} {write_dacs/dac0/dac_cntrl[setpoint_last][6]} {write_dacs/dac0/dac_cntrl[setpoint_last][7]} {write_dacs/dac0/dac_cntrl[setpoint_last][8]} {write_dacs/dac0/dac_cntrl[setpoint_last][9]} {write_dacs/dac0/dac_cntrl[setpoint_last][10]} {write_dacs/dac0/dac_cntrl[setpoint_last][11]} {write_dacs/dac0/dac_cntrl[setpoint_last][12]} {write_dacs/dac0/dac_cntrl[setpoint_last][13]} {write_dacs/dac0/dac_cntrl[setpoint_last][14]} {write_dacs/dac0/dac_cntrl[setpoint_last][15]} {write_dacs/dac0/dac_cntrl[setpoint_last][16]} {write_dacs/dac0/dac_cntrl[setpoint_last][17]} {write_dacs/dac0/dac_cntrl[setpoint_last][18]} {write_dacs/dac0/dac_cntrl[setpoint_last][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 20 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {write_dacs/dac0/dac_data[0]} {write_dacs/dac0/dac_data[1]} {write_dacs/dac0/dac_data[2]} {write_dacs/dac0/dac_data[3]} {write_dacs/dac0/dac_data[4]} {write_dacs/dac0/dac_data[5]} {write_dacs/dac0/dac_data[6]} {write_dacs/dac0/dac_data[7]} {write_dacs/dac0/dac_data[8]} {write_dacs/dac0/dac_data[9]} {write_dacs/dac0/dac_data[10]} {write_dacs/dac0/dac_data[11]} {write_dacs/dac0/dac_data[12]} {write_dacs/dac0/dac_data[13]} {write_dacs/dac0/dac_data[14]} {write_dacs/dac0/dac_data[15]} {write_dacs/dac0/dac_data[16]} {write_dacs/dac0/dac_data[17]} {write_dacs/dac0/dac_data[18]} {write_dacs/dac0/dac_data[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 24 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {write_dacs/dac0/dac_cntrl[gain][0]} {write_dacs/dac0/dac_cntrl[gain][1]} {write_dacs/dac0/dac_cntrl[gain][2]} {write_dacs/dac0/dac_cntrl[gain][3]} {write_dacs/dac0/dac_cntrl[gain][4]} {write_dacs/dac0/dac_cntrl[gain][5]} {write_dacs/dac0/dac_cntrl[gain][6]} {write_dacs/dac0/dac_cntrl[gain][7]} {write_dacs/dac0/dac_cntrl[gain][8]} {write_dacs/dac0/dac_cntrl[gain][9]} {write_dacs/dac0/dac_cntrl[gain][10]} {write_dacs/dac0/dac_cntrl[gain][11]} {write_dacs/dac0/dac_cntrl[gain][12]} {write_dacs/dac0/dac_cntrl[gain][13]} {write_dacs/dac0/dac_cntrl[gain][14]} {write_dacs/dac0/dac_cntrl[gain][15]} {write_dacs/dac0/dac_cntrl[gain][16]} {write_dacs/dac0/dac_cntrl[gain][17]} {write_dacs/dac0/dac_cntrl[gain][18]} {write_dacs/dac0/dac_cntrl[gain][19]} {write_dacs/dac0/dac_cntrl[gain][20]} {write_dacs/dac0/dac_cntrl[gain][21]} {write_dacs/dac0/dac_cntrl[gain][22]} {write_dacs/dac0/dac_cntrl[gain][23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 20 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {write_dacs/dac0/dac_cntrl[dpram_data][0]} {write_dacs/dac0/dac_cntrl[dpram_data][1]} {write_dacs/dac0/dac_cntrl[dpram_data][2]} {write_dacs/dac0/dac_cntrl[dpram_data][3]} {write_dacs/dac0/dac_cntrl[dpram_data][4]} {write_dacs/dac0/dac_cntrl[dpram_data][5]} {write_dacs/dac0/dac_cntrl[dpram_data][6]} {write_dacs/dac0/dac_cntrl[dpram_data][7]} {write_dacs/dac0/dac_cntrl[dpram_data][8]} {write_dacs/dac0/dac_cntrl[dpram_data][9]} {write_dacs/dac0/dac_cntrl[dpram_data][10]} {write_dacs/dac0/dac_cntrl[dpram_data][11]} {write_dacs/dac0/dac_cntrl[dpram_data][12]} {write_dacs/dac0/dac_cntrl[dpram_data][13]} {write_dacs/dac0/dac_cntrl[dpram_data][14]} {write_dacs/dac0/dac_cntrl[dpram_data][15]} {write_dacs/dac0/dac_cntrl[dpram_data][16]} {write_dacs/dac0/dac_cntrl[dpram_data][17]} {write_dacs/dac0/dac_cntrl[dpram_data][18]} {write_dacs/dac0/dac_cntrl[dpram_data][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 20 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {write_dacs/dac0/dac_cntrl[setpoint][0]} {write_dacs/dac0/dac_cntrl[setpoint][1]} {write_dacs/dac0/dac_cntrl[setpoint][2]} {write_dacs/dac0/dac_cntrl[setpoint][3]} {write_dacs/dac0/dac_cntrl[setpoint][4]} {write_dacs/dac0/dac_cntrl[setpoint][5]} {write_dacs/dac0/dac_cntrl[setpoint][6]} {write_dacs/dac0/dac_cntrl[setpoint][7]} {write_dacs/dac0/dac_cntrl[setpoint][8]} {write_dacs/dac0/dac_cntrl[setpoint][9]} {write_dacs/dac0/dac_cntrl[setpoint][10]} {write_dacs/dac0/dac_cntrl[setpoint][11]} {write_dacs/dac0/dac_cntrl[setpoint][12]} {write_dacs/dac0/dac_cntrl[setpoint][13]} {write_dacs/dac0/dac_cntrl[setpoint][14]} {write_dacs/dac0/dac_cntrl[setpoint][15]} {write_dacs/dac0/dac_cntrl[setpoint][16]} {write_dacs/dac0/dac_cntrl[setpoint][17]} {write_dacs/dac0/dac_cntrl[setpoint][18]} {write_dacs/dac0/dac_cntrl[setpoint][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 32 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {write_dacs/dac0/dac_cntrl[smooth_phaseinc][0]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][1]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][2]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][3]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][4]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][5]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][6]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][7]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][8]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][9]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][10]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][11]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][12]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][13]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][14]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][15]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][16]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][17]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][18]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][19]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][20]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][21]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][22]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][23]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][24]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][25]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][26]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][27]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][28]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][29]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][30]} {write_dacs/dac0/dac_cntrl[smooth_phaseinc][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 20 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {write_dacs/dac0/dac_cntrl[offset][0]} {write_dacs/dac0/dac_cntrl[offset][1]} {write_dacs/dac0/dac_cntrl[offset][2]} {write_dacs/dac0/dac_cntrl[offset][3]} {write_dacs/dac0/dac_cntrl[offset][4]} {write_dacs/dac0/dac_cntrl[offset][5]} {write_dacs/dac0/dac_cntrl[offset][6]} {write_dacs/dac0/dac_cntrl[offset][7]} {write_dacs/dac0/dac_cntrl[offset][8]} {write_dacs/dac0/dac_cntrl[offset][9]} {write_dacs/dac0/dac_cntrl[offset][10]} {write_dacs/dac0/dac_cntrl[offset][11]} {write_dacs/dac0/dac_cntrl[offset][12]} {write_dacs/dac0/dac_cntrl[offset][13]} {write_dacs/dac0/dac_cntrl[offset][14]} {write_dacs/dac0/dac_cntrl[offset][15]} {write_dacs/dac0/dac_cntrl[offset][16]} {write_dacs/dac0/dac_cntrl[offset][17]} {write_dacs/dac0/dac_cntrl[offset][18]} {write_dacs/dac0/dac_cntrl[offset][19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {write_dacs/dac0/dac_cntrl[setpoint_changed]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {write_dacs/dac0/dac_cntrl[dpram_we]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {write_dacs/dac0/dac_cntrl[dds_enb]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {write_dacs/dac0/dac_cntrl[reset]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {write_dacs/dac0/dac_cntrl[ramprun]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets dbg_OBUF[4]]
