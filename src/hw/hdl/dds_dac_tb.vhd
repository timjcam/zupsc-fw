--***********************************************************
-- Test Bench for DDS compiler
--
--  Fout​= PhaseInc / 2^^N  *​Fclk
--  PhaseInc = Fout / Fclk  * 2^^N
--
--  PhaseInc is 32 bits
--  Fclk = 100MHz

--
-- For 1MHz, PhaseInc=42,949,673





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dds_dac is
end entity;

architecture sim of tb_dds_dac is


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




  constant CLK_PERIOD : time := 10 ns; -- 100 MHz

  signal clk      : std_logic := '0';
  signal dds_freq : std_logic_vector(31 downto 0) := x"10000000";
  signal dds_out  : std_logic_vector(31 downto 0);
  signal dds_sine          : std_logic_vector(15 downto 0);
  signal dds_cos           : std_logic_vector(15 downto 0); 
  

begin

 

dds_sine <= dds_out(31 downto 16);
dds_cos  <= dds_out(15 downto 0);


  --------------------------------------------------------------------
  -- Clock
  --------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD / 2;

  --------------------------------------------------------------------
  -- DDS Compiler DUT
  --------------------------------------------------------------------
  dds_dac_sim : dds_dac
    port map (
      aclk                 => clk,
      s_axis_config_tvalid => '1',
      s_axis_config_tdata  => dds_freq,
      m_axis_data_tvalid   => open,
      m_axis_data_tdata    => dds_out,
      m_axis_phase_tvalid  => open,
      m_axis_phase_tdata   => open
    );

  --------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------
  process
  begin
    wait for 1 us;

    -- Change output frequency
    --1MHz
    dds_freq <= 32d"42949673";
    wait for 1 ms;

    --100KHz
    dds_freq <= 32d"4294967";
    wait for 1 ms;

    --10KHz
    dds_freq <= 32d"429497";
    wait for 1 ms;

    wait;
  end process;

end architecture;
