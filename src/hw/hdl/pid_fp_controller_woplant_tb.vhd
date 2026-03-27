library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use ieee.float_pkg.all;

library xil_defaultlib;
use xil_defaultlib.psc_pkg.ALL;


entity pid_fp_controller_tb is
end pid_fp_controller_tb;

architecture sim of pid_fp_controller_tb is

-- Component under test
component pid_fp_controller
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    start         : in std_logic;
    pid_cntrl     : in t_pid_cntrl_onech;
    pid_stat      : out t_pid_stat_onech;
    setpoint      : in  signed(19 downto 0);
    feedback      : in  signed(19 downto 0);
    control_out   : out signed(19 downto 0);
    done          : out std_logic
);
end component;


    -- Testbench signals
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '1';
    signal acq_trig      : std_logic := '0';
    signal done          : std_logic;
    signal setpoint      : signed(19 downto 0);
    signal feedback      : signed(19 downto 0);
    
    signal pid_cntrl     : t_pid_cntrl_onech;
    signal pid_stat      : t_pid_stat_onech;
    
    signal noise         : signed(19 downto 0);
    
    signal control_out   : signed(19 downto 0);

    constant clk_period : time := 10 ns;






begin
  -- Clock generation
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

 



-- PI Controller instantiation
uut: pid_fp_controller
    port map (
            clk           => clk,
            rst           => rst,
            start         => acq_trig,
            pid_cntrl     => pid_cntrl,
            pid_stat      => pid_stat,
            setpoint      => setpoint,
            feedback      => feedback,
            control_out   => control_out,
            done => done
        );


-- generate 100KHz acquistion triggers (PID Loop updates)
acq_clk: process
begin
  -- Generate 100khz_trig every 10 us (100 kHz)
  wait for 200 ns;
  for i in 0 to 10000 loop
    wait for 10 us;
    acq_trig <= '1';
    --feedback <= noise;
    wait for clk_period;
    acq_trig <= '0';
  end loop;  
  wait for 1000 ms;    
end process;



-- Stimulus process
stimulus: process
  begin
  
    -- Initialize inputs 
    setpoint  <= to_signed(0, 20);  
    feedback  <= to_signed(0, 20);   

    -- Set gains: Set in IEEE754 format, yes this is ugly
    pid_cntrl.kp <= x"3F800000";  -- 1
    pid_cntrl.ki <= x"3F800000";  -- 1    
    --pid_cntrl.ki <= x"3F000000";  -- 0.5
    pid_cntrl.kd <= x"3DCCCCCD";  -- 0.1

    -- Integral clamp: ±1.0
    pid_cntrl.ilimit_pos <= x"3F800000"; -- +1.0
    pid_cntrl.ilimit_neg <= x"BF800000"; -- -1.0
    
    --remove global reset
    wait for 100 ns;
    rst <= '0';
    
    

   -- reset integrator
   pid_cntrl.ireset <= '1';
   wait for 100 ns;
   pid_cntrl.ireset <= '0';
        
   -- Run simulation
   wait for 100 us;


   -- Change setpoint
   setpoint <= to_signed(500, 20);
   wait for 1000 ns;

   -- Finish
    wait;
        
        
 end process;





-- Simple pseudo-random noise generator
 noise_proc : process(rst,clk)
        variable seed : integer := 7;
        variable nval : integer;
    begin
        if (rst = '1') then
           noise <= to_signed(0,20);
        end if;
        if rising_edge(clk) then
           if acq_trig = '1' then
             -- Very basic LFSR-like noise
             seed := (seed * 17 + 3) mod 100;
             nval := seed - 50;  -- Range: -50 to +49
             noise <= to_signed(nval, 20);
           end if;
        end if;
    end process;







end sim;

