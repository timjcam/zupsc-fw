-------------------------------------------------------------------------------
-- Title         : ADC 8 Channel module
-------------------------------------------------------------------------------
-- File          : ADC_8CH_module.vhd
-- Author        : Thomas Chiesa tchiesa@bnl.gov
-- Created       : 07/19/2020
-------------------------------------------------------------------------------
-- Description:
-- This is the controller for the 4 8 Channel ADS8568 ADCs. Gains
-- and offsets are applied
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.psc_pkg.all;


entity adc_8ch_module is
	port(
		 clk           : in std_logic;
		 reset         : in std_logic;
		 start         : in std_logic;
		 mon_adcs      : out t_mon_adcs;
		 mon_params    : in t_mon_adcs_params;
		 sdo           : in std_logic_vector(3 downto 0);
		 rst           : out std_logic_vector(3 downto 0);
		 cnv           : out std_logic_vector(3 downto 0);
		 fs            : out std_logic_vector(3 downto 0);
		 sck           : out std_logic_vector(3 downto 0);
		 done          : out std_logic
	);
end entity;


architecture arch of adc_8ch_module is
signal ch0_adcdata      : std_logic_vector(127 downto 0);
signal ch1_adcdata      : std_logic_vector(127 downto 0);
signal ch2_adcdata      : std_logic_vector(127 downto 0);
signal ch3_adcdata      : std_logic_vector(127 downto 0);
signal adc0             : signed(15 downto 0);
signal adc1             : signed(15 downto 0);
signal adc2             : signed(15 downto 0);
signal adc3             : signed(15 downto 0);
signal adc4             : signed(15 downto 0);
signal adc5             : signed(15 downto 0);
signal adc6             : signed(15 downto 0);
signal adc7             : signed(15 downto 0);

signal conv_done        : std_logic;
signal done_pipe        : std_logic;
signal mon_adcs_in      : t_mon_adcs;


   --debug signals (connect to ila)
   attribute mark_debug                 : string;
--   attribute mark_debug of ADC8C_CONV123: signal is "true";
--   attribute mark_debug of ADC8C_FS123: signal is "true";
--   attribute mark_debug of ADC8C_SCK123: signal is "true";
--   attribute mark_debug of ADC8C_SDO: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC1: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC2: signal is "true";
--   attribute mark_debug of ADC_8CH_ADC3: signal is "true";       
   --attribute mark_debug of mon_adcs_in: signal is "true";
   attribute mark_debug of adc0 : signal is "true";
   attribute mark_debug of adc1 : signal is "true";
   attribute mark_debug of adc2 : signal is "true";
   attribute mark_debug of adc3 : signal is "true";      
   attribute mark_debug of adc4 : signal is "true";
   attribute mark_debug of adc5 : signal is "true";
   attribute mark_debug of adc6 : signal is "true";
   attribute mark_debug of adc7 : signal is "true";  


begin


rst <= "0000";


ch0_adc_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128,	SPI_CLK_DIV => 5)
  port map(
	clk => clk,
	reset => reset,
	start => start,
	busy => '0',
	sdi => sdo(0), --ADC8C_MISO1,
	cnv => cnv(0),
	n_fs => fs(0),
	sclk => sck(0),
	sdo => open,
	data_out => ch0_adcdata,
	data_rdy => conv_done
);


ch1_adc_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128,	SPI_CLK_DIV => 5)
  port map(
	clk => clk,
	reset => reset,
	start => start,
	busy => '0',
	sdi => sdo(1), --ADC8C_MISO1,
	cnv => cnv(1),
	n_fs => fs(1),
	sclk => sck(1),
	sdo => open,
	data_out => ch1_adcdata,
	data_rdy => open
);


ch2_adc_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128,	SPI_CLK_DIV => 5)
  port map(
	clk => clk,
	reset => reset,
	start => start,
	busy => '0',
	sdi => sdo(2), --ADC8C_MISO1,
	cnv => cnv(2),
	n_fs => fs(2),
	sclk => sck(2),
	sdo => open,
	data_out => ch2_adcdata,
	data_rdy => open
);

ch3_adc_8ch: entity work.adc_ads8568_intf
  generic map(DATA_BITS   => 128,	SPI_CLK_DIV => 5)
  port map(
	clk => clk,
	reset => reset,
	start => start,
	busy => '0',
	sdi => sdo(3), --ADC8C_MISO1,
	cnv => cnv(3),
	n_fs => fs(3),
	sclk => sck(3),
	sdo => open,
	data_out => ch3_adcdata,
	data_rdy => open
);


process(clk) 
  begin 
	if rising_edge(clk) then 

        mon_adcs_in.ps1.dacmon_raw  <= signed(ch0_adcdata(127 downto 112));  -- A0
        mon_adcs_in.ps1.ignd_raw    <= signed(ch0_adcdata(95 downto 80));    -- B0
        mon_adcs_in.ps1.spare_raw   <= signed(ch0_adcdata(63 downto 48));    -- C0
        mon_adcs_in.ps1.voltage_raw <= signed(ch0_adcdata(31 downto 16));    -- D0
        adc0 <= signed(ch0_adcdata(127 downto 112));
        adc1 <= signed(ch0_adcdata(111 downto 96));
        adc2 <= signed(ch0_adcdata(95 downto 80));
        adc3 <= signed(ch0_adcdata(79 downto 64));                
        adc4 <= signed(ch0_adcdata(63 downto 48));
        adc5 <= signed(ch0_adcdata(47 downto 32));
        adc6 <= signed(ch0_adcdata(31 downto 16));
        adc7 <= signed(ch0_adcdata(15 downto 0));          


        mon_adcs_in.ps2.dacmon_raw  <= signed(ch1_adcdata(127 downto 112));  -- A0
        mon_adcs_in.ps2.ignd_raw    <= signed(ch1_adcdata(95 downto 80));    -- B0
        mon_adcs_in.ps2.spare_raw   <= signed(ch1_adcdata(63 downto 48));    -- C0
        mon_adcs_in.ps2.voltage_raw <= signed(ch1_adcdata(31 downto 16));    -- D0

        mon_adcs_in.ps3.dacmon_raw  <= signed(ch2_adcdata(127 downto 112));  -- A0
        mon_adcs_in.ps3.ignd_raw    <= signed(ch2_adcdata(95 downto 80));    -- B0
        mon_adcs_in.ps3.spare_raw   <= signed(ch2_adcdata(63 downto 48));    -- C0
        mon_adcs_in.ps3.voltage_raw <= signed(ch2_adcdata(31 downto 16));    -- D0

        mon_adcs_in.ps4.dacmon_raw  <= signed(ch3_adcdata(127 downto 112));  -- A0
        mon_adcs_in.ps4.ignd_raw    <= signed(ch3_adcdata(95 downto 80));    -- B0
        mon_adcs_in.ps4.spare_raw   <= signed(ch3_adcdata(63 downto 48));    -- C0
        mon_adcs_in.ps4.voltage_raw <= signed(ch3_adcdata(31 downto 16));    -- D0 

  end if;
end process;
 
    


-- apply gains and offsets
gainoff_ps1: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps1,
    mon_params => mon_params.ps1,
    mon_out => mon_adcs.ps1,
    done => done
);

-- apply gains and offsets
gainoff_ps2: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps2,
    mon_params => mon_params.ps2,
    mon_out => mon_adcs.ps2,
    done => done
);

-- apply gains and offsets
gainoff_ps3: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps3,
    mon_params => mon_params.ps3,
    mon_out => mon_adcs.ps3,
    done => done
);

-- apply gains and offsets
gainoff_ps4: entity work.mon_gainoffset
  port map(
    clk => clk,
    reset => reset,
    conv_done => conv_done,
    mon_adc => mon_adcs_in.ps4,
    mon_params => mon_params.ps4,
    mon_out => mon_adcs.ps4,
    done => done
);




end architecture;
