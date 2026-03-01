library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 10-point moving average (signed 20-bit input)
-- - Running-sum (subtract oldest, add newest)
-- - Reciprocal multiply instead of divide by 10
-- - Pipelined (friendly at 100 MHz)
-- - Small improvement: multiply uses the freshly computed next_sum (stage-0),
--   so the datapath is unambiguous and does not depend on sum0 timing.
entity moving_avg_10_signed is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        valid_in   : in  std_logic;
        din        : in  signed(19 downto 0);

        avg_out    : out signed(19 downto 0);
        valid_out  : out std_logic
    );
end entity;

architecture rtl of moving_avg_10_signed is

    -- samples(0) is newest, samples(9) is oldest
    type sample_array_t is array (9 downto 0) of signed(19 downto 0);
    signal samples : sample_array_t := (others => (others => '0'));

    -- Sum of 10 signed 20-bit values:
    -- magnitude up to ~10*(2^19) -> 24 bits signed is safe
    signal sum   : signed(23 downto 0) := (others => '0');
    signal count : unsigned(3 downto 0) := (others => '0');

    -- Reciprocal for /10 in Q19:
    -- 52429 = 0x0CCCD ≈ 2^19 / 10
    -- IMPORTANT: must be wide enough to stay positive (17-bit signed)
    constant RECIP10 : signed(16 downto 0) := to_signed(52429, 17);
    constant SHIFT10 : integer := 19;

    -- Pipeline valids:
    -- vld0: window full and a new sample accepted
    -- vld1: product available
    -- vld2: output valid
    signal vld0, vld1, vld2 : std_logic := '0';

    -- Pipeline regs
    signal sum0  : signed(23 downto 0) := (others => '0');  -- registered next_sum
    signal prod1 : signed(40 downto 0) := (others => '0');  -- 24+17 = 41 bits

begin

    process(clk)
        variable next_sum : signed(23 downto 0);
        variable avg_full : signed(40 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                samples   <= (others => (others => '0'));
                sum       <= (others => '0');
                count     <= (others => '0');

                sum0      <= (others => '0');
                prod1     <= (others => '0');

                avg_out   <= (others => '0');
                valid_out <= '0';

                vld0 <= '0';
                vld1 <= '0';
                vld2 <= '0';

            else
                -- defaults
                valid_out <= '0';

                -- advance valid pipeline
                vld2 <= vld1;
                vld1 <= vld0;
                vld0 <= '0';

                ------------------------------------------------------------
                -- Stage 0: accept input sample, update running sum, shift FIFO
                ------------------------------------------------------------
                if valid_in = '1' then
                    next_sum := sum
                                - resize(samples(9), 24)  -- subtract oldest
                                + resize(din, 24);         -- add newest

                    sum  <= next_sum;
                    sum0 <= next_sum;

                    -- shift (newest at 0)
                    samples(9 downto 1) <= samples(8 downto 0);
                    samples(0)          <= din;

                    -- window-full tracking
                    if count < 9 then
                        count <= count + 1;
                        vld0  <= '0';
                    else
                        vld0  <= '1';  -- window full; produce an output for this sample
                    end if;
                end if;

                ------------------------------------------------------------
                -- Stage 1: multiply by reciprocal
                -- Small improvement: use sum0 (registered next_sum) which is
                -- computed from the same sample that asserted vld0.
                ------------------------------------------------------------
                if vld0 = '1' then
                    prod1 <= sum0 * RECIP10; -- signed multiply
                end if;

                ------------------------------------------------------------
                -- Stage 2: arithmetic shift right and output
                ------------------------------------------------------------
                if vld1 = '1' then
                    avg_full := shift_right(prod1, SHIFT10); -- arithmetic for signed
                    avg_out  <= resize(avg_full, 20);
                end if;

                if vld2 = '1' then
                    valid_out <= '1';
                end if;

            end if;
        end if;
    end process;

end architecture;