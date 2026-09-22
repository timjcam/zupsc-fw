library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- DDS DAC control
--
-- Function:
--
--   dac_out = dc_offset + (dds_sine * amplitude / 32768)
--
-- where:
--
--   32768 = 2^15
--
-- DDS output:
--   Uses dds_out(31 downto 16) as the signed 16-bit sine value.
--
--   DDS sine range:
--
--      -32768 to +32767
--
-- amplitude:
--   Unsigned 20-bit desired sine-wave peak amplitude in DAC counts.
--
--   For example:
--
--      amplitude = 100000
--
--   produces approximately:
--
--      -100000 to +99997
--
-- dc_offset:
--   Signed 20-bit DC offset in DAC counts.
--
-- dac_out:
--   Signed 20-bit output with saturation:
--
--      maximum = +524287
--      minimum = -524288
--
-- Notes:
--   1. DDS Compiler IP is named "dds_dac".
--   2. DDS configuration word is 32 bits.
--   3. DDS sine output is contained in dds_out(31 downto 16).
-- ============================================================================

entity dds_dac_control is
  port (
    clk       : in  std_logic;

    -- DDS frequency/configuration word
    dds_freq  : in  std_logic_vector(31 downto 0);

    -- Desired sine-wave peak amplitude in DAC counts
    amplitude : in  unsigned(19 downto 0);

    -- DC offset in signed 20-bit DAC counts
    dc_offset : in  signed(19 downto 0);

    -- Final signed 20-bit DAC value
    dac_out   : out signed(19 downto 0)
  );
end entity dds_dac_control;


architecture rtl of dds_dac_control is

  ---------------------------------------------------------------------------
  -- DDS signals
  ---------------------------------------------------------------------------

  signal dds_out  : std_logic_vector(31 downto 0);

  -- Sign-extended 16-bit DDS sine.
  -- Numeric range remains -32768 to +32767.
  signal dds_sine : signed(19 downto 0);


  ---------------------------------------------------------------------------
  -- Amplitude scaling
  ---------------------------------------------------------------------------

  -- amplitude is unsigned.
  -- Add a leading zero before treating it as signed.
  signal amplitude_ext : signed(20 downto 0);

  -- 20-bit signed x 21-bit signed = 41-bit signed product
  signal mult_result : signed(40 downto 0);

  -- After dividing by 2^15, the result may be almost +/- 2^20.
  -- Therefore 21 signed bits are required here.
  signal dds_scaled : signed(20 downto 0);


  ---------------------------------------------------------------------------
  -- Offset addition
  --
  -- dds_scaled can be nearly +/- 2^20
  -- dc_offset can be nearly +/- 2^19
  --
  -- Therefore use 22 bits for the sum before saturation.
  ---------------------------------------------------------------------------

  signal sum_result : signed(21 downto 0);


  ---------------------------------------------------------------------------
  -- Debug signals
  ---------------------------------------------------------------------------

  attribute mark_debug : string;

  attribute mark_debug of dds_freq   : signal is "true";
  attribute mark_debug of amplitude  : signal is "true";
  attribute mark_debug of dc_offset  : signal is "true";
  attribute mark_debug of dds_sine   : signal is "true";
  attribute mark_debug of dds_scaled : signal is "true";
  attribute mark_debug of sum_result : signal is "true";
  attribute mark_debug of dac_out    : signal is "true";


begin


  -- ==========================================================================
  -- Xilinx DDS Compiler IP
  -- ==========================================================================

  ddsmode : entity work.dds_dac
    port map (
      aclk                 => clk,

      s_axis_config_tvalid => '1',
      s_axis_config_tdata  => dds_freq,

      m_axis_data_tvalid   => open,
      m_axis_data_tdata    => dds_out,

      m_axis_phase_tvalid  => open,
      m_axis_phase_tdata   => open
    );


  -- ==========================================================================
  -- DDS sine
  --
  -- DDS output is signed 16-bit:
  --
  --      -32768 to +32767
  --
  -- Sign extend to 20 bits without changing the numeric value.
  -- ==========================================================================

  dds_sine <= resize(
                signed(dds_out(31 downto 16)),
                dds_sine'length
              );


  -- ==========================================================================
  -- Amplitude control
  --
  -- The DDS has a nominal full-scale magnitude of:
  --
  --      32768 = 2^15
  --
  -- amplitude represents the desired output peak in DAC counts.
  --
  -- Therefore:
  --
  --   dds_scaled = dds_sine * amplitude / 2^15
  --
  -- Examples:
  --
  --   amplitude =  50000  -> approximately +/-  50000 counts
  --   amplitude = 100000  -> approximately +/- 100000 counts
  --   amplitude = 262144  -> approximately +/- 262144 counts
  --   amplitude = 524287  -> approximately full DAC range
  --
  -- ==========================================================================

  amplitude_ext <= signed('0' & amplitude);

  mult_result <= dds_sine * amplitude_ext;

  dds_scaled <= resize(
                  shift_right(mult_result, 15),
                  dds_scaled'length
                );


  -- ==========================================================================
  -- Add programmable DC offset
  -- ==========================================================================

  sum_result <= resize(dds_scaled, sum_result'length) +
                resize(dc_offset, sum_result'length);


  -- ==========================================================================
  -- Saturate to signed 20-bit DAC limits
  --
  -- Output range:
  --
  --      +524287
  --      -524288
  --
  -- ==========================================================================

  saturation_proc : process(all)
  begin

    if sum_result > to_signed(524287, sum_result'length) then

      dac_out <= to_signed(524287, dac_out'length);

    elsif sum_result < to_signed(-524288, sum_result'length) then

      dac_out <= to_signed(-524288, dac_out'length);

    else

      dac_out <= resize(sum_result, dac_out'length);

    end if;

  end process saturation_proc;


end architecture rtl;
