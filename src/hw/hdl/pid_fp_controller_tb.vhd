library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- This is the core floating point package
use ieee.float_pkg.all;
use ieee.math_real.all; -- Required for cos and MATH_PI

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
      start         : in  std_logic;
      pid_cntrl     : in  t_pid_cntrl_onech;
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

  constant clk_period  : time := 10 ns;

  --------------------------------------------------------------------------
  -- Plant parameters
  --------------------------------------------------------------------------
  constant R_OHM       : real := 0.01;
  constant L_H         : real := 10.0e-6;
  constant TS_S        : real := 10.0e-6;   -- 100 kHz loop update

  constant A_PLANT     : real := exp(-(R_OHM * TS_S) / L_H);
  constant B_PLANT     : real := (1.0 - A_PLANT) / R_OHM;

  --------------------------------------------------------------------------
  -- Scaling between DUT counts and physical units
  --
  -- Adjust these to match your real design.
  -- Here:
  --   control_out full scale  -> +/-10 V
  --   feedback/setpoint full scale -> +/-100 A
  --------------------------------------------------------------------------
  constant CTRL_FS_V   : real := 10.0;
  constant FB_FS_A     : real := 100.0;
  constant S20_MAX     : integer := 2**19 - 1;  -- 524287
  constant S20_MIN     : integer := -(2**19);   -- -524288

  --------------------------------------------------------------------------
  -- Plant state
  --------------------------------------------------------------------------
  signal plant_current_a : real := 0.0;
  signal plant_voltage_v : real := 0.0;
  
  signal v_curr_val :   real := 0.0;
  signal setpoint_start:   real := 0.0; 
  signal setpoint_end: real := 0.0;
  signal setpoint_start_prev : real := 0.0;  
  
    -- Internal Counters
  signal tick_count    : integer := 0;
  signal time_ns       : real := 0.0;
  signal ramp_active   : boolean := true;


  --------------------------------------------------------------------------
  -- Helper functions
  --------------------------------------------------------------------------
  function clamp_int(x, lo, hi : integer) return integer is
  begin
    if x < lo then
      return lo;
    elsif x > hi then
      return hi;
    else
      return x;
    end if;
  end function;

  function s20_to_real(x : signed(19 downto 0); full_scale : real) return real is
  begin
    return real(to_integer(x)) * full_scale / real(S20_MAX);
  end function;

  function real_to_s20(x : real; full_scale : real) return signed is
    variable xi : integer;
  begin
    xi := integer(x * real(S20_MAX) / full_scale);

    xi := clamp_int(xi, S20_MIN, S20_MAX);
    return to_signed(xi, 20);
  end function;


-- Inside your architecture or a package
function generate_cosine_ramp (
    start_lvl : real;
    end_lvl   : real;
    current_t : real;  -- Current time in the ramp (0 to duration)
    duration  : real   -- Total time for the ramp to complete
) return real is
    variable normalized_t : real;
    variable ramp_val     : real;
begin
    -- Clamp time to the duration limits
    if current_t <= 0.0 then
        return start_lvl;
    elsif current_t >= duration then
        return end_lvl;
    end if;

    -- Normalized time goes from 0.0 to 1.0
    normalized_t := current_t / duration;
    
    -- Half-cosine interpolation formula
    ramp_val := start_lvl + (end_lvl - start_lvl) * (1.0 - cos(MATH_PI * normalized_t)) / 2.0;
    
    return ramp_val;
end function;

begin

  --------------------------------------------------------------------------
  -- Clock generation
  --------------------------------------------------------------------------
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  --------------------------------------------------------------------------
  -- PID Controller instantiation
  --------------------------------------------------------------------------
  uut: pid_fp_controller
    port map (
      clk         => clk,
      rst         => rst,
      start       => acq_trig,
      pid_cntrl   => pid_cntrl,
      pid_stat    => pid_stat,
      setpoint    => setpoint,
      feedback    => feedback,
      control_out => control_out,
      done        => done
    );

  --------------------------------------------------------------------------
  -- Generate 100 kHz acquisition triggers (10 us period)
  --------------------------------------------------------------------------
  acq_clk: process
  begin
    wait for 200 ns;
    for i in 0 to 10000 loop
      wait for 10 us;
      acq_trig <= '1';
      wait for clk_period;
      acq_trig <= '0';
    end loop;
    wait;
  end process;

  --------------------------------------------------------------------------
  -- Stimulus process
  --------------------------------------------------------------------------
  stimulus: process
  begin
    -- Initialize inputs
    --setpoint <= to_signed(0, 20);

    -- Set gains: IEEE754 single-precision
    --pid_cntrl.kp <= x"3F800000";  -- 1.0
  --  pid_cntrl.kp <= std_logic_vector(to_float(0.000002,8,23)); 
  pid_cntrl.kp <= std_logic_vector(to_float(0.4,8,23)); 
    --x"3DCCCCCD";  -- 0.1
    --pid_cntrl.ki <= x"3C23D70A";  -- 0.01
    pid_cntrl.ki <= std_logic_vector(to_float(0.7,8,23)); 
    --x"3DCCCCCD";  -- 0.1
    --pid_cntrl.kd <= x"3DCCCCCD";  -- 0.1

    -- Integral clamp: +/-1.0
    pid_cntrl.ilimit_pos <= std_logic_vector(to_float(10,8,23)); 
    pid_cntrl.ilimit_neg <= std_logic_vector(to_float(-10,8,23)); 

    -- remove global reset
    wait for 100 ns;
    rst <= '0';

    -- reset integrator
    pid_cntrl.ireset <= '1';
    wait for 100 ns;
    pid_cntrl.ireset <= '0';

    -- let it run at zero
    wait for 100 us;

    -- ramp setpoint
    setpoint_start <= 0.0; 
    setpoint_end <= 2.5; 
    
    wait for 7 ms; 
    
    -- ramp setpoint again...
    setpoint_start <= 2.5;
    setpoint_end <= 1.2;  
    
    wait for 7 ms; 
    
    -- ramp setpoint again...
    setpoint_start <= 1.2;
    setpoint_end <= 3.5;  


    wait;
  end process;
  
--------------------------------------------------------------------------
-- Smooth Ramp Generator Simulation
--------------------------------------------------------------------------
  
-------------------------------------------------------------------------- 
-- Clocked Smooth Ramp Generator (10 kHz Update Rate)
-------------------------------------------------------------------------- 
process(clk)
    -- Constants for the ramp profile
    constant RAMP_DURATION_NS : real :=15000000.0; -- 
    constant CLK_PERIOD_NS    : real := 100.0;     -- Assuming a 10MHz clock for example
    constant UPDATE_TICKS     : integer := 1000;   -- Steps every 100us (10kHz)
    

begin
    if rising_edge(clk) then
        if ramp_active then
            setpoint_start_prev <= setpoint_start;          
            -- Trigger calculation every 100us (10 kHz)
            if tick_count >= UPDATE_TICKS then
                tick_count <= 0;
                -- 1. Calculate the smooth cosine ramp value (Real)
                v_curr_val <= generate_cosine_ramp(setpoint_start, setpoint_end, time_ns, RAMP_DURATION_NS);
                
                -- 2. Scale and Convert to 20-bit Signed
                -- Multiply by 524287 to avoid +1 overflow on 20-bit signed (max 524287)
                setpoint <= to_signed(integer((v_curr_val / 100.0) * 524287.0), 20);
                
                -- 3. Update the tracking time
                time_ns <= time_ns + 100000.0; -- Advance by 100us
                
                -- 4. Stop when we hit the end of the ramp
                if time_ns > RAMP_DURATION_NS then
                    ramp_active <= false;
                    time_ns <= 0.0; 
                    tick_count <= 0; 
                end if; 
            else
                tick_count <= tick_count + 1;
            end if;          
        end if;
        
         if setpoint_start /= setpoint_start_prev then 
             ramp_active <= true; 
         end if; 
         
    end if;
end process;

  --------------------------------------------------------------------------
  -- Simple pseudo-random noise generator
  --------------------------------------------------------------------------
  noise_proc : process(rst, clk)
    variable seed : integer := 7;
    variable nval : integer;
  begin
    if rst = '1' then
      noise <= to_signed(0, 20);
    elsif rising_edge(clk) then
      if acq_trig = '1' then
        seed := (seed * 17 + 3) mod 100;
        nval := seed - 50;  -- Range: -50 to +49 counts
        noise <= to_signed(nval, 20);
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- RL plant model
  --
  -- control_out -> commanded voltage
  -- plant current updated once per acq_trig
  -- feedback = plant current + noise
  
  --  i[n+1] = ai[n] + bv[n]
  --  a = e^(-RTs/L),  b = (1-a)/R​
  --------------------------------------------------------------------------
  plant_proc : process(rst, clk)
    variable v_cmd   : real;
    variable i_next  : real;
  begin
    if rst = '1' then
      plant_current_a <= 0.0;
      plant_voltage_v <= 0.0;
      feedback        <= (others => '0');

    elsif rising_edge(clk) then
      if acq_trig = '1' then

        -- Convert PID output counts to volts
        v_cmd := s20_to_real(control_out, CTRL_FS_V);

        -- Optional voltage clamp
        if v_cmd > CTRL_FS_V then
          v_cmd := CTRL_FS_V;
        elsif v_cmd < -CTRL_FS_V then
          v_cmd := -CTRL_FS_V;
        end if;

        plant_voltage_v <= v_cmd;

        -- Exact discrete-time RL plant update
        i_next := A_PLANT * plant_current_a + B_PLANT * v_cmd;

        plant_current_a <= i_next;

        -- Convert plant current back to feedback counts and add noise
        feedback <= real_to_s20(i_next, FB_FS_A); -- + noise;
      end if;
    end if;
  end process;

end architecture;

