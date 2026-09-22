-------------------------------------------------------------------------------
-- Title         : DAC Controller
-------------------------------------------------------------------------------
-- File          : DAC_ctrlr.vhd
-- Author        : Thomas Chiesa tchiesa@bnl.gov
-- Created       : 07/19/2020
-------------------------------------------------------------------------------
-- Description:
-- This program is the DAC controller for the PSC.  It controls all
-- four DACs on the PSC. 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Modification history:
-- 07/19/2020: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.psc_pkg.all;



entity dac_chan is
  port(
    clk                  : in std_logic; 
    reset                : in std_logic; 
    tenkhz_trig          : in std_logic;
    fofb_dac_setpt       : in signed(19 downto 0);
    dcct_adcs            : in t_dcct_adcs_onech;
    pid_cntrl            : in t_pid_cntrl_onech;
    pid_stat             : out t_pid_stat_onech;
    dac_numbits_sel      : in std_logic;
    dac_cntrl            : in t_dac_cntrl_onech;
    dac_stat             : out t_dac_stat_onech;
    n_sync1234		     : out std_logic; 
	sclk1234   		     : out std_logic; 
	sdo                  : out std_logic	
    );
end entity;

architecture arch of dac_chan is


component dds_dac IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_phase_tvalid : OUT STD_LOGIC;
    m_axis_phase_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;



 
  signal dac_data          : std_logic_vector(19 downto 0);
  signal dac_rdaddr        : std_logic_vector(15 downto 0);
  signal dac_rddata        : std_logic_vector(19 downto 0);
  signal dac_rden          : std_logic;
  signal ramp_dac_setpt    : signed(19 downto 0);
  signal smooth_dac_setpt  : signed(19 downto 0);
  --signal fofb_dac_setpt   : signed(19 downto 0);
  signal dac_setpt_raw     : signed(19 downto 0);
  signal dac_setpt_rawordds: signed(19 downto 0);
  signal dac_setpt         : signed(19 downto 0);
  signal ramp_active       : std_logic;
  signal smooth_active     : std_logic;
  signal dac_trig          : std_logic;
  signal gainoff_done      : std_logic;

  signal dac_setpt_gainoff : signed(19 downto 0); 
  signal dac_setpt_digital : signed(19 downto 0);  
  
  signal dds_out           : std_logic_vector(31 downto 0);
  signal dds_sine          : signed(19 downto 0);




   --debug signals (connect to ila)
   attribute mark_debug                 : string;
   attribute mark_debug of dds_sine: signal is "true";
   attribute mark_debug of dac_data: signal is "true";
--   attribute mark_debug of ramp_dac_setpt: signal is "true";
--   attribute mark_debug of smooth_dac_setpt: signal is "true";
--   attribute mark_debug of dac_setpt_raw: signal is "true";   
--   attribute mark_debug of dac_setpt: signal is "true";
--   attribute mark_debug of ramp_active: signal is "true";  
--   attribute mark_debug of smooth_active: signal is "true";  
--   attribute mark_debug of fofb_dac_setpt: signal is "true"; 
   attribute mark_debug of dac_cntrl: signal is "true";


begin

--status readbacks
dac_stat.dac_setpt <= dac_setpt;
dac_stat.active <= ramp_active or smooth_active;




--Source of DAC data depends on Mode
--Because DAC sync's are tied together, must always update every DAC
--  0=smooth ramp, 1=ramp table, 2=FOFB, 3=Jump Mode
process(clk) 
begin 
    if rising_edge(clk) then 
      if (reset = '1') then
        dac_setpt_raw <= (others => '0');
      else
        if (tenkhz_trig = '1') then 
          case dac_cntrl.mode is 
            when "00" =>  
               dac_setpt_raw <= smooth_dac_setpt;
            when "01" =>
               dac_setpt_raw <= ramp_dac_setpt;
            when "10" =>
               dac_setpt_raw <= fofb_dac_setpt;
            when "11" =>
               dac_setpt_raw <= dac_cntrl.setpoint;
            when others =>
               dac_setpt_raw <= dac_cntrl.setpoint; 
          end case;   
        end if;
      end if;
    end if; 
end process; 







-- forward dac_setpt or if in DDS mode write the DDS output
dac_setpt_rawordds <= dac_setpt_raw when dac_cntrl.dds_enb = '0' else dds_sine; 


--process(clk)
--begin
--  if rising_edge(clk) then
--    if tenkhz_trig = '1' then
--       dds_sine <= resize(signed(dds_out(31 downto 16)), 20) sll 2;
--    end if;
--  end if;
--end process;

--ddsmode: dds_dac 
--  port map (
--    aclk => clk,
--    s_axis_config_tvalid => '1', 
--    s_axis_config_tdata => dac_cntrl.dds_freq, 
--    m_axis_data_tvalid => open, 
--    m_axis_data_tdata => dds_out, 
--    m_axis_phase_tvalid => open, 
--    m_axis_phase_tdata => open
--  );


dds : entity work.dds_dac_control
  port map (
    clk       => clk,
    dds_freq  => dac_cntrl.dds_freq,
    amplitude => unsigned(dac_cntrl.dds_amplitude),
    dc_offset => signed(dac_cntrl.dds_offset),
    dac_out   => dds_sine
  );







-- In rampmode, DAC setpoint comes from table in block ram
rampmode: entity work.ramptable_ramp
  port map (
    clk => clk,  
    reset => reset,  
    tenkhz_trig => tenkhz_trig, 
    mode => dac_cntrl.mode,    
    dac_cntrl => dac_cntrl, 
    ramp_active => ramp_active,
    ramp_dac_setpt => ramp_dac_setpt
    );


-- In smoothmode, DAC setpoint comes from raised cosine calculation done in fabric
smoothmode: entity work.smooth_ramp
  port map (
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    mode => dac_cntrl.mode,
    cur_setpt => dac_setpt, 
    new_setpt => dac_cntrl.setpoint, 
    phase_inc => dac_cntrl.smooth_phaseinc, 
    smooth_active => smooth_active,
    rampout => smooth_dac_setpt
);
 
  
  
 
-- apply gain and offsets 
gainoff_dac : entity work.dac_gainoffset
  port map (
    clk => clk,
    reset => reset,
    tenkhz_trig => tenkhz_trig,
    numbits_sel => dac_numbits_sel,
    dac_setpt_raw => dac_setpt_rawordds,
    dac_cntrl => dac_cntrl,
    dac_setpt => dac_setpt_gainoff,
    done => gainoff_done
);
  
 
--Digital Control Loop
dig_loop : entity work.pid_fp_controller
port map(
    clk => clk, 
    rst => reset, 
    start => gainoff_done, 
    pid_cntrl => pid_cntrl,
	pid_stat => pid_stat,   
    setpoint => dac_setpt_gainoff,
    feedback => dcct_adcs.dcct1, 
    control_out => dac_setpt_digital,
    done => open
);  
  
  
-- mux to bypass digital PID  
dac_setpt <= dac_setpt_gainoff when pid_cntrl.digpid_enb = '0' else dac_setpt_digital;    
  

dac_data <= std_logic_vector(dac_setpt);



-- write the SPI DAC
spi_dac:  entity work.dac_ad5781 
  generic map
    (SPI_CLK_DIV => 5) --10MHz sclk
  port map(
    clk => clk,
    reset => dac_cntrl.reset, 
	start => gainoff_done,       
    dac_data => dac_data, 
    dac_ctrl_bits => dac_cntrl.cntrl(4 downto 0),       
    n_sync => n_sync1234, 
    sclk => sclk1234,
    sdo => sdo, 
    done => open
);




end arch;
