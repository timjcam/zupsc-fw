library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_moving_avg_10_signed is
end entity;

architecture tb of tb_moving_avg_10_signed is

    constant CLK_PERIOD  : time := 10 ns; -- 100 MHz
    constant DUT_LATENCY : integer := 2;  -- matches pipelined module above
    constant TOL_LSB     : integer := 1;  -- reciprocal rounding tolerance

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal valid_in  : std_logic := '0';
    signal din       : signed(19 downto 0) := (others => '0');
    signal avg_out   : signed(19 downto 0);
    signal valid_out : std_logic;

    type samp_arr_t is array (0 to 9) of signed(19 downto 0);
    signal hist : samp_arr_t := (others => (others => '0'));
    signal sum  : integer := 0;
    signal fill : integer range 0 to 10 := 0;

    type exp_arr_t is array (0 to 255) of integer;
    signal exp_q : exp_arr_t := (others => 0);
    signal q_wr  : integer range 0 to 255 := 0;
    signal q_rd  : integer range 0 to 255 := 0;

    function iabs(x : integer) return integer is
    begin
        if x < 0 then return -x; else return x; end if;
    end function;

begin

    -- DUT
    dut : entity work.moving_avg_10_signed
        port map (
            clk       => clk,
            reset     => reset,
            valid_in  => valid_in,
            din       => din,
            avg_out   => avg_out,
            valid_out => valid_out
        );

    -- clock
    clk <= not clk after CLK_PERIOD/2;

    -- stimulus helper
    stim : process
        procedure send_sample(x : integer) is
        begin
            valid_in <= '1';
            din      <= to_signed(x, 20);
            wait until rising_edge(clk);
            valid_in <= '0';
            din      <= (others => '0');
            wait for 50 ns;
        end procedure;
 
 
 
    begin
        -- reset
        reset <= '1';
        wait for 10*CLK_PERIOD;
        wait until rising_edge(clk);
        reset <= '0';

        -- ramp positive
        for i in 0 to 19 loop
            send_sample(-520000 + i);
            wait until rising_edge(clk);
        end loop;
        
        wait for 10 us;

        -- ramp negative
        for i in 0 to 19 loop
            send_sample(-500 - i);
            wait until rising_edge(clk);
        end loop;

        wait for 10 us;
        
        -- alternating sign
        for i in 0 to 29 loop
            if (i mod 2) = 0 then
                send_sample(20000);
            else
                send_sample(-20000);
            end if;
            wait until rising_edge(clk);
        end loop;

        wait for 200*CLK_PERIOD;
        report "TB finished" severity note;
        std.env.stop;
        wait;
    end process;



end architecture;
