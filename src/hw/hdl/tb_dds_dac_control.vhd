library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ============================================================================
-- Testbench for dds_dac_control
--
-- This testbench assumes the Xilinx/Vivado generated DDS IP entity "dds_dac"
-- is compiled into the work library along with dds_dac_control.vhd.
--
-- Tests:
--   1. 0% amplitude, 0 offset
--   2. 0% amplitude, positive offset
--   3. 25% amplitude
--   4. 50% amplitude
--   5. ~100% amplitude
--   6. ~100% amplitude + positive offset
--   7. Positive saturation
--   8. Negative saturation
--
-- The testbench is intended primarily for waveform inspection.
-- It also includes assertions for the cases where amplitude = 0.
-- ============================================================================

entity tb_dds_dac_control is
end entity tb_dds_dac_control;


architecture sim of tb_dds_dac_control is

  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

  signal clk : std_logic := '0';


  ---------------------------------------------------------------------------
  -- DUT inputs
  ---------------------------------------------------------------------------
  signal dds_freq  : std_logic_vector(31 downto 0) := (others => '0');

  -- Q0.16:
  --   x"0000" =   0%
  --   x"4000" =  25%
  --   x"8000" =  50%
  --   x"C000" =  75%
  --   x"FFFF" = ~100%
  signal amplitude : unsigned(15 downto 0) := (others => '0');

  -- Signed 20-bit offset in DAC counts
  signal dc_offset : signed(19 downto 0) := (others => '0');


  ---------------------------------------------------------------------------
  -- DUT output
  ---------------------------------------------------------------------------
  signal dac_out : signed(19 downto 0);


begin

  ---------------------------------------------------------------------------
  -- 100 MHz clock
  ---------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD / 2;


  ---------------------------------------------------------------------------
  -- Device Under Test
  ---------------------------------------------------------------------------
  dut : entity work.dds_dac_control
    port map (
      clk       => clk,
      dds_freq  => dds_freq,
      amplitude => amplitude,
      dc_offset => dc_offset,
      dac_out   => dac_out
    );


  ---------------------------------------------------------------------------
  -- Stimulus
  ---------------------------------------------------------------------------
  stimulus_proc : process
  begin

    -------------------------------------------------------------------------
    -- DDS frequency word
    --
    -- Replace this with whatever tuning word gives a convenient sine-wave
    -- frequency for your DDS configuration.
    --
    -- This value is intentionally non-zero so the DDS output changes during
    -- the simulation.
    -------------------------------------------------------------------------
    dds_freq <= x"01000000";

    -------------------------------------------------------------------------
    -- Allow DDS IP to start producing valid output.
    --
    -- The exact DDS latency depends on how the Vivado IP was configured.
    -------------------------------------------------------------------------
    amplitude <= x"0000";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 1 us;


    -------------------------------------------------------------------------
    -- TEST 1:
    -- 0% amplitude, zero offset.
    --
    -- Output should remain exactly zero regardless of the DDS waveform.
    -------------------------------------------------------------------------
    report "TEST 1: amplitude = 0%, offset = 0";

    amplitude <= x"0000";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 1 us;

    assert dac_out = to_signed(0, dac_out'length)
      report "TEST 1 FAILED: dac_out should be 0"
      severity error;


    -------------------------------------------------------------------------
    -- TEST 2:
    -- 0% amplitude, +100000 count DC offset.
    --
    -- Since amplitude is zero, the DDS is completely removed and the output
    -- must equal the DC offset.
    -------------------------------------------------------------------------
    report "TEST 2: amplitude = 0%, offset = +100000";

    amplitude <= x"0000";
    dc_offset <= to_signed(100000, dc_offset'length);

    wait for 1 us;

    assert dac_out = to_signed(100000, dac_out'length)
      report "TEST 2 FAILED: dac_out should equal +100000"
      severity error;


    -------------------------------------------------------------------------
    -- TEST 3:
    -- 25% amplitude, no DC offset.
    --
    -- The DDS sine amplitude should be approximately one quarter of the
    -- original dds_sine amplitude.
    -------------------------------------------------------------------------
    report "TEST 3: amplitude = 25%, offset = 0";

    amplitude <= x"4000";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 4:
    -- 50% amplitude, no DC offset.
    -------------------------------------------------------------------------
    report "TEST 4: amplitude = 50%, offset = 0";

    amplitude <= x"8000";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 5:
    -- Approximately 100% amplitude, no DC offset.
    --
    -- x"FFFF" corresponds to 65535/65536 = 0.9999847.
    -------------------------------------------------------------------------
    report "TEST 5: amplitude ~= 100%, offset = 0";

    amplitude <= x"FFFF";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 6:
    -- Approximately 100% amplitude with +100000 count DC offset.
    --
    -- You should see the entire sine wave move upward by 100000 counts.
    -------------------------------------------------------------------------
    report "TEST 6: amplitude ~= 100%, offset = +100000";

    amplitude <= x"FFFF";
    dc_offset <= to_signed(100000, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 7:
    -- Positive saturation.
    --
    -- dds_sine can reach approximately +131068 counts. Adding +500000 should
    -- cause the positive peaks to clamp at +524287 rather than wrap around.
    -------------------------------------------------------------------------
    report "TEST 7: positive saturation";

    amplitude <= x"FFFF";
    dc_offset <= to_signed(500000, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 8:
    -- Negative saturation.
    --
    -- dds_sine can reach approximately -131072 counts. Adding -500000 should
    -- cause the negative peaks to clamp at -524288 rather than wrap around.
    -------------------------------------------------------------------------
    report "TEST 8: negative saturation";

    amplitude <= x"FFFF";
    dc_offset <= to_signed(-500000, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- TEST 9:
    -- 25% amplitude with a negative offset.
    -------------------------------------------------------------------------
    report "TEST 9: amplitude = 25%, offset = -50000";

    amplitude <= x"4000";
    dc_offset <= to_signed(-50000, dc_offset'length);

    wait for 5 us;


    -------------------------------------------------------------------------
    -- Return output to zero.
    -------------------------------------------------------------------------
    report "Returning output to zero";

    amplitude <= x"0000";
    dc_offset <= to_signed(0, dc_offset'length);

    wait for 1 us;

    assert dac_out = to_signed(0, dac_out'length)
      report "FINAL TEST FAILED: dac_out should return to zero"
      severity error;


    -------------------------------------------------------------------------
    -- End simulation
    -------------------------------------------------------------------------
    report "DDS DAC CONTROL TESTBENCH COMPLETED";

    wait;

  end process stimulus_proc;


end architecture sim;
