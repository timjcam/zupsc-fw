

# 24 16-bit ADC Channels (3 - ADS5868)



# Channel 0

# DCCT ADC's
set_property PACKAGE_PIN AF6 [get_ports {dcct_adc_cnv[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_cnv[0]}]
set_property PACKAGE_PIN AG6 [get_ports {dcct_adc_busy[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[0]}]
set_property PACKAGE_PIN AE8 [get_ports {dcct_adc_sck[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sck[0]}]
set_property PACKAGE_PIN AF8 [get_ports {dcct_adc_sdo[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[0]}]
set_property PACKAGE_PIN AE10 [get_ports {dcct_adc_sdo[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[1]}]

# SetPt DAC
set_property PACKAGE_PIN AH1 [get_ports {stpt_dac_sck[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sck[0]}]
set_property PACKAGE_PIN AH2 [get_ports {stpt_dac_sync[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[0]}]
set_property PACKAGE_PIN AJ1 [get_ports {stpt_dac_sdo[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[0]}]

# Monitor ADC
set_property PACKAGE_PIN F12 [get_ports {mon_adc_rst[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_rst[0]}]
set_property PACKAGE_PIN G14 [get_ports {mon_adc_cnv[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_cnv[0]}]
set_property PACKAGE_PIN H12 [get_ports {mon_adc_busy[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_busy[0]}]
set_property PACKAGE_PIN G11 [get_ports {mon_adc_fs[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_fs[0]}]
set_property PACKAGE_PIN E10 [get_ports {mon_adc_sdo[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sdo[0]}]
set_property PACKAGE_PIN H14 [get_ports {mon_adc_sck[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sck[0]}]


# Command digital outputs
set_property PACKAGE_PIN AH4 [get_ports {dig_out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[0]}]
set_property DRIVE 12 [get_ports {dig_out[0]}]
set_property SLEW SLOW [get_ports {dig_out[0]}]
set_property PACKAGE_PIN AJ4 [get_ports {dig_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[1]}]
set_property DRIVE 12 [get_ports {dig_out[1]}]
set_property SLEW SLOW [get_ports {dig_out[1]}]
set_property PACKAGE_PIN AJ6 [get_ports {dig_out[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[2]}]
set_property DRIVE 12 [get_ports {dig_out[2]}]
set_property SLEW SLOW [get_ports {dig_out[2]}]
set_property PACKAGE_PIN AJ5 [get_ports {dig_out[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[3]}]
set_property DRIVE 12 [get_ports {dig_out[3]}]
set_property SLEW SLOW [get_ports {dig_out[3]}]


# Command digital inputs
set_property PACKAGE_PIN AH7 [get_ports {dig_in[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[0]}]
set_property PACKAGE_PIN AH6 [get_ports {dig_in[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[1]}]
set_property PACKAGE_PIN AG10 [get_ports {dig_in[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[2]}]
set_property PACKAGE_PIN AG9 [get_ports {dig_in[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[3]}]




# Channel 1

# DCCT ADC's
set_property PACKAGE_PIN AE2 [get_ports {dcct_adc_cnv[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_cnv[1]}]
set_property PACKAGE_PIN AE1 [get_ports {dcct_adc_busy[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[1]}]
set_property PACKAGE_PIN AD2 [get_ports {dcct_adc_sck[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sck[1]}]
set_property PACKAGE_PIN AD1 [get_ports {dcct_adc_sdo[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[2]}]
set_property PACKAGE_PIN AE3 [get_ports {dcct_adc_sdo[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[3]}]

# SetPt DAC
set_property PACKAGE_PIN AD4 [get_ports {stpt_dac_sck[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sck[1]}]
set_property PACKAGE_PIN AD7 [get_ports {stpt_dac_sync[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[1]}]
set_property PACKAGE_PIN AE4 [get_ports {stpt_dac_sdo[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[1]}]

# Monitor ADC
set_property PACKAGE_PIN E13 [get_ports {mon_adc_rst[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_rst[1]}]
set_property PACKAGE_PIN H16 [get_ports {mon_adc_cnv[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_cnv[1]}]
set_property PACKAGE_PIN J15 [get_ports {mon_adc_busy[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_busy[1]}]
set_property PACKAGE_PIN G13 [get_ports {mon_adc_fs[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_fs[1]}]
set_property PACKAGE_PIN E12 [get_ports {mon_adc_sdo[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sdo[1]}]
set_property PACKAGE_PIN J16 [get_ports {mon_adc_sck[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sck[1]}]


# Command digital outputs
set_property PACKAGE_PIN AD10 [get_ports {dig_out[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[4]}]
set_property DRIVE 12 [get_ports {dig_out[4]}]
set_property SLEW SLOW [get_ports {dig_out[4]}]
set_property PACKAGE_PIN AE9 [get_ports {dig_out[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[5]}]
set_property DRIVE 12 [get_ports {dig_out[5]}]
set_property SLEW SLOW [get_ports {dig_out[5]}]
set_property PACKAGE_PIN AF2 [get_ports {dig_out[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[6]}]
set_property DRIVE 12 [get_ports {dig_out[6]}]
set_property SLEW SLOW [get_ports {dig_out[6]}]
set_property PACKAGE_PIN AF1 [get_ports {dig_out[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[7]}]
set_property DRIVE 12 [get_ports {dig_out[7]}]
set_property SLEW SLOW [get_ports {dig_out[7]}]


# Command digital inputs
set_property PACKAGE_PIN AE12 [get_ports {dig_in[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[4]}]
set_property PACKAGE_PIN AF12 [get_ports {dig_in[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[5]}]
set_property PACKAGE_PIN AE5 [get_ports {dig_in[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[6]}]
set_property PACKAGE_PIN AF5 [get_ports {dig_in[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[7]}]



# Channel 2

# DCCT ADC's
set_property PACKAGE_PIN Y8 [get_ports {dcct_adc_cnv[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_cnv[2]}]
set_property PACKAGE_PIN Y7 [get_ports {dcct_adc_busy[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[2]}]
set_property PACKAGE_PIN AB6 [get_ports {dcct_adc_sck[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sck[2]}]
set_property PACKAGE_PIN AB5 [get_ports {dcct_adc_sdo[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[4]}]
set_property PACKAGE_PIN AC12 [get_ports {dcct_adc_sdo[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[5]}]

# SetPt DAC
set_property PACKAGE_PIN AB4 [get_ports {stpt_dac_sck[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sck[2]}]
set_property PACKAGE_PIN W5 [get_ports {stpt_dac_sync[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[2]}]
set_property PACKAGE_PIN AC4 [get_ports {stpt_dac_sdo[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[2]}]

# Monitor ADC
set_property PACKAGE_PIN D14 [get_ports {mon_adc_rst[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_rst[2]}]
set_property PACKAGE_PIN C14 [get_ports {mon_adc_cnv[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_cnv[2]}]
set_property PACKAGE_PIN F13 [get_ports {mon_adc_busy[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_busy[2]}]
set_property PACKAGE_PIN D12 [get_ports {mon_adc_fs[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_fs[2]}]
set_property PACKAGE_PIN E14 [get_ports {mon_adc_sdo[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sdo[2]}]
set_property PACKAGE_PIN B12 [get_ports {mon_adc_sck[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sck[2]}]


# Command digital outputs
set_property PACKAGE_PIN AC2 [get_ports {dig_out[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[8]}]
set_property DRIVE 12 [get_ports {dig_out[8]}]
set_property SLEW SLOW [get_ports {dig_out[8]}]
set_property PACKAGE_PIN AC1 [get_ports {dig_out[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[9]}]
set_property DRIVE 12 [get_ports {dig_out[9]}]
set_property SLEW SLOW [get_ports {dig_out[9]}]
set_property PACKAGE_PIN Y2 [get_ports {dig_out[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[10]}]
set_property DRIVE 12 [get_ports {dig_out[10]}]
set_property SLEW SLOW [get_ports {dig_out[10]}]
set_property PACKAGE_PIN Y1 [get_ports {dig_out[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[11]}]
set_property DRIVE 12 [get_ports {dig_out[11]}]
set_property SLEW SLOW [get_ports {dig_out[11]}]


# Command digital inputs
set_property PACKAGE_PIN AC7 [get_ports {dig_in[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[8]}]
set_property PACKAGE_PIN AC6 [get_ports {dig_in[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[9]}]
set_property PACKAGE_PIN Y12 [get_ports {dig_in[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[10]}]
set_property PACKAGE_PIN AA12 [get_ports {dig_in[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[11]}]




# Channel 3

# DCCT ADC's
set_property PACKAGE_PIN U5 [get_ports {dcct_adc_cnv[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_cnv[3]}]
set_property PACKAGE_PIN U4 [get_ports {dcct_adc_busy[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_busy[3]}]
set_property PACKAGE_PIN V4 [get_ports {dcct_adc_sck[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sck[3]}]
set_property PACKAGE_PIN V3 [get_ports {dcct_adc_sdo[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[6]}]
set_property PACKAGE_PIN W2 [get_ports {dcct_adc_sdo[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dcct_adc_sdo[7]}]

# SetPt DAC
set_property PACKAGE_PIN V2 [get_ports {stpt_dac_sck[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sck[3]}]
set_property PACKAGE_PIN W7 [get_ports {stpt_dac_sync[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sync[3]}]
set_property PACKAGE_PIN V1 [get_ports {stpt_dac_sdo[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {stpt_dac_sdo[3]}]

# Monitor ADC
set_property PACKAGE_PIN A12 [get_ports {mon_adc_rst[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_rst[3]}]
set_property PACKAGE_PIN B16 [get_ports {mon_adc_cnv[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_cnv[3]}]
set_property PACKAGE_PIN G16 [get_ports {mon_adc_busy[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_busy[3]}]
set_property PACKAGE_PIN C13 [get_ports {mon_adc_fs[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_fs[3]}]
set_property PACKAGE_PIN D15 [get_ports {mon_adc_sdo[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sdo[3]}]
set_property PACKAGE_PIN B14 [get_ports {mon_adc_sck[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mon_adc_sck[3]}]


# Command digital outputs
set_property PACKAGE_PIN Y10 [get_ports {dig_out[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[12]}]
set_property DRIVE 12 [get_ports {dig_out[12]}]
set_property SLEW SLOW [get_ports {dig_out[12]}]
set_property PACKAGE_PIN Y9 [get_ports {dig_out[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[13]}]
set_property DRIVE 12 [get_ports {dig_out[13]}]
set_property SLEW SLOW [get_ports {dig_out[13]}]
set_property PACKAGE_PIN AA2 [get_ports {dig_out[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[14]}]
set_property DRIVE 12 [get_ports {dig_out[14]}]
set_property SLEW SLOW [get_ports {dig_out[14]}]
set_property PACKAGE_PIN AA1 [get_ports {dig_out[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_out[15]}]
set_property DRIVE 12 [get_ports {dig_out[15]}]
set_property SLEW SLOW [get_ports {dig_out[15]}]


# Command digital inputs
set_property PACKAGE_PIN AA11 [get_ports {dig_in[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[12]}]
set_property PACKAGE_PIN AA10 [get_ports {dig_in[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[13]}]
set_property PACKAGE_PIN Y4 [get_ports {dig_in[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[14]}]
set_property PACKAGE_PIN Y3 [get_ports {dig_in[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dig_in[15]}]




# DCCT Fault Bits
set_property PACKAGE_PIN A13 [get_ports {dcct_flt[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dcct_flt[0]}]
set_property PACKAGE_PIN B15 [get_ports {dcct_flt[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dcct_flt[1]}]
set_property PACKAGE_PIN A15 [get_ports {dcct_flt[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dcct_flt[2]}]
set_property PACKAGE_PIN A16 [get_ports {dcct_flt[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dcct_flt[3]}]


# afe enable
set_property PACKAGE_PIN H11 [get_ports afe_enb]
set_property IOSTANDARD LVCMOS33 [get_ports afe_enb]
set_property DRIVE 12 [get_ports afe_enb]
set_property SLEW SLOW [get_ports afe_enb]


