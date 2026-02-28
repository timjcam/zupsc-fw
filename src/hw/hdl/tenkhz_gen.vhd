library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.psc_pkg.ALL;


entity tenkhz_gen is
  port(
    clk    	    	: in std_logic; 
    reset      		: in std_logic; 
		  				
    evr_trigs       : in t_evr_trigs;
    evr_params      : in t_evr_params;

    flt_10kHz       : out std_logic; 
    acq_freq        : out std_logic_vector(31 downto 0);	
    acq_trig        : out std_logic;	
    tenkhz_trig     : out std_logic        
    ); 

end entity; 
    
architecture arch of tenkhz_gen is 

    signal acq_trig_prev     : std_logic;
	signal acq_rate_cnt      : std_logic_vector(31 downto 0);    
    
	signal evr_onehz_trig    : std_logic;
	signal tenkhz_rate_cnt   : std_logic_vector(31 downto 0);
    signal tenkhz_trig_prev  : std_logic;
    signal trig_cnt          : unsigned(3 downto 0) := 4d"0"; -- counts 0 to 9

   --debug signals (connect to ila)
   attribute mark_debug                 : string;
   attribute mark_debug of tenkhz_rate_cnt : signal is "true";
   attribute mark_debug of tenkhz_trig : signal is "true";
   attribute mark_debug of tenkhz_trig_prev : signal is "true";
   attribute mark_debug of acq_freq : signal is "true";   
	
	
	
begin 

--Fault Signal 
flt_10kHz <= '0';  



---- 1Hz event from EVR resync's our Storage Ring Orbit Clock (SROC) (10KHz)
--sync_1Hz_trig: entity work.pulse_sync
--  port map(
--    clk => clk,
--    pulse_in => evr_trigs.onehz_trig,
--    pulse_out => evr_onehz_trig
--);



 -- generate acquisition triggers with nco,
uut: entity work.nco_srocgen
  port map (
    clk => clk,
    reset  => reset,
    step_size => unsigned(evr_params.nco_stepsize),
    resync_pulse => '0', --evr_trigs.onehz_trig, --evr_onehz_trig,
    pulse_out => acq_trig
    );



--measure 10KHz event frequency
process(clk)
  begin
    if rising_edge(clk) then
      acq_rate_cnt <= std_logic_vector(unsigned(acq_rate_cnt) + 1);
      acq_trig_prev <= acq_trig;
      if (acq_trig_prev = '0' and acq_trig = '1') then
           acq_freq <= acq_rate_cnt;
           tenkhz_rate_cnt <= 32d"0";
      end if;
    end if;
end process;   



process(clk)
begin
 
  if rising_edge(clk) then      
    -- default: no pulse
    tenkhz_trig <= '0';
    tenkhz_trig_prev <= tenkhz_trig;
    if (acq_trig = '1' and acq_trig_prev = '0') then  -- rising edge detected    
      if trig_cnt = 9 then
        trig_cnt  <= (others => '0');
        tenkhz_trig  <= '1';  -- generate 1-cycle pulse
      else
        trig_cnt <= trig_cnt + 1;
      end if;

        end if;

    end if;
end process;





end architecture; 
