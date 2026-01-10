-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright (c) 2020 DESY
-------------------------------------------------------------------------------
--! @brief   Basic Example for FWK Module
--! @created 2020-01-30
-------------------------------------------------------------------------------
--! Description:
--! Simple Entity that creates a 32 bit counter with active high reset
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FWK adds app_demo's Config parameters as VHDL packages in 'work' library.
-- This package contains the C_RESET_TYPE constant declaration
use work.pkg_app_demo_config.all;

entity app_demo_top is
port(
  pi_clock : in std_logic;
  pi_reset : in std_logic;
  po_counter : out std_logic_vector(31 downto 0)
);
end app_demo_top;

architecture behavioral of app_demo_top is
  signal counter : unsigned(31 downto 0);
begin

  po_counter <= std_logic_vector(counter);

  gen_sync_reset : if C_RESET_TYPE = "SYNC" generate
    process(pi_clock) begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          counter <= (others => '0');
        else
          counter <= counter + 1;
        end if;
      end if;
    end process;

  end generate;

  gen_async_reset : if C_RESET_TYPE = "ASYNC" generate
    process(pi_clock, pi_reset) begin
      if pi_reset = '0' then
        counter <= (others => '0');
      elsif rising_edge(pi_clock) then
        counter <= counter + 1;
      end if;
    end process;
  end generate;

end behavioral;