library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.psc_pkg.ALL;

entity axi4_write_adc is
  port (
    clk             : in std_logic;
    reset           : in std_logic;
    trigger         : in std_logic;  -- 10 kHz trigger

    s_axi4_m2s     : out t_pl_snapshot_axi4_m2s;
    s_axi4_s2m     : in t_pl_snapshot_axi4_s2m;
         
    dcct_adcs        : in t_dcct_adcs;
    mon_adcs         : in t_mon_adcs;
    dac_stat         : in t_dac_stat; 
    pid_stat         : in t_pid_stat;   

	ss_buf_stat      : out t_snapshot_stat        
    );
end entity axi4_write_adc;



architecture rtl of axi4_write_adc is

   -- Make sure AXI Bursts never cross a 4k cacheline boundary.  
   -- Made BURST_LEN 64, so always aligns with 4k cacheline boundary.
   constant BURST_LEN : integer := 64;
   constant DDR_BASE_ADDR   : std_logic_vector(31 downto 0) := x"1000_0000";
   --constant DDR_MAX_ADDR    : std_logic_vector(31 downto 0) := x"130D_4000";  --10KHz * 64beats*4bytes/beat * 20 sec 
   constant DDR_MAX_ADDR    : std_logic_vector(31 downto 0) := x"2E84_8000";  --100KHz * 64beats*4bytes/beat * 20 sec 
   
   type  state_type is (IDLE, ADDRESS, HDR, CNT, 
                        PS1_DCCT1, PS1_DCCT2, PS1_MON1, PS1_MON2, PS1_MON3, PS1_MON4, PS1_MON5, PS1_MON6, 
                        PS2_DCCT1, PS2_DCCT2, PS2_MON1, PS2_MON2, PS2_MON3, PS2_MON4, PS2_MON5, PS2_MON6,                
                        PS3_DCCT1, PS3_DCCT2, PS3_MON1, PS3_MON2, PS3_MON3, PS3_MON4, PS3_MON5, PS3_MON6,
                        PS4_DCCT1, PS4_DCCT2, PS4_MON1, PS4_MON2, PS4_MON3, PS4_MON4, PS4_MON5, PS4_MON6,              
                        WRD35, WRD36, WRD37, WRD38, WRD39, WRD40, WRD41, WRD42, WRD43, WRD44, WRD45, WRD46,
                        WRD47, WRD48, WRD49, WRD50, WRD51, WRD52, WRD53, WRD54, WRD55, WRD56, WRD57, WRD58,
                        WRD59, WRD60, WRD61, WRD62, WRD63, WRDLAST, AWAITRESP);  
--   type state_type is (IDLE, ADDRESS, DATA, WRDLAST, AWAITRESP);
   
   signal state :  state_type;


    signal wordnum : unsigned(31 downto 0);
    signal addr_base : std_logic_vector(31 downto 0) := DDR_BASE_ADDR;  -- Example DDR address
    
    signal datacnt : std_logic_vector(31 downto 0);
    signal prev_trigger : std_logic;
    
    signal axi_notrdy : std_logic;
    --signal dma_lencnt : unsigned(31 downto 0);
    
    
    --debug signals (connect to ila)
    attribute mark_debug                 : string;
    attribute mark_debug of trigger : signal is "true";
    attribute mark_debug of prev_trigger : signal is "true";   
    attribute mark_debug of s_axi4_m2s: signal is "true";
    attribute mark_debug of s_axi4_s2m: signal is "true";   
    attribute mark_debug of wordnum : signal is "true"; 
    attribute mark_debug of datacnt : signal is "true";  
    attribute mark_debug of state : signal is "true"; 
    attribute mark_debug of axi_notrdy : signal is "true"; 
    --attribute mark_debug of dma_rst : signal is "true";
    --attribute mark_debug of dma_enb : signal is "true"; 
    --attribute mark_debug of dma_len : signal is "true";     
    --attribute mark_debug of dma_lencnt : signal is "true";        
    attribute mark_debug of addr_base : signal is "true";    
   
procedure write_word (
    signal wdata   : out std_logic_vector(31 downto 0);
    signal wvalid  : out std_logic;
    signal next_state : out state_type;
    constant data  : std_logic_vector(31 downto 0);
    constant state : state_type
) is
begin

    if (s_axi4_s2m.wready = '1') then
        wvalid <= '1';
        wdata <= data;
        next_state <= state;
    end if;
end procedure;    
    

begin


              
   
process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        wordnum <= 32d"0";
        s_axi4_m2s.awvalid <= '0';
        s_axi4_m2s.wvalid <= '0';
        s_axi4_m2s.bready <= '0';
        s_axi4_m2s.wdata <= 32d"0";
        state <= idle;
        datacnt <= 32d"0";
        axi_notrdy <= '0';
        addr_base <= DDR_BASE_ADDR;

        
      else
        case state is 
          when IDLE =>    
            axi_notrdy <= '0';            
            prev_trigger <= trigger;

            ss_buf_stat.addr_ptr <= addr_base;
            ss_buf_stat.tenkhzcnt <= datacnt;
            if (trigger = '1' and prev_trigger = '0') then 

              datacnt <= std_logic_vector(unsigned(datacnt) + 1);             
              wordnum <= 32d"0";
              s_axi4_m2s.awaddr <= "0000" & addr_base;
              s_axi4_m2s.awvalid <= '1';
              s_axi4_m2s.awburst <= "01";   -- Incrementing burst
              s_axi4_m2s.awcache <= "0011"; -- Normal non-cacheable bufferable
              s_axi4_m2s.awlen <= std_logic_vector(to_unsigned(BURST_LEN-1, 8));  -- beats per burst
              s_axi4_m2s.awlock <= "0";    
              s_axi4_m2s.awprot <= "000";  -- Unprivileged secure data
              s_axi4_m2s.awqos <= "0000";   
              s_axi4_m2s.awsize <= "010"; -- 4 bytes (32-bit)
              state <= address;
            end if;

          when ADDRESS =>
             -- Address handshake
             if (s_axi4_s2m.awready = '1') then
                 s_axi4_m2s.awvalid <= '0';  -- Address accepted
                 s_axi4_m2s.wdata <= 32d"0"; 
                 s_axi4_m2s.wstrb <= x"F";
                 state <= hdr; 
                 wordnum <= 32d"1";
             end if;
 
 
          when HDR => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, x"80000000", CNT);
          when CNT => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(unsigned(datacnt)), PS1_DCCT1); 
           
          when PS1_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct0), 32)), PS1_DCCT2); 
          when PS1_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct1), 32)), PS1_MON1); 
          when PS1_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.dacmon), 32)), PS1_MON2);          
          when PS1_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps1.setptin_f), 32)), PS1_MON3);  
          --when PS1_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.voltage), 32)), PS1_MON3);           
          when PS1_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps1.pterm_f), 32)), PS1_MON4);   
          when PS1_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps1.iterm_f), 32)), PS1_MON5);            
          --when PS1_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ignd), 32)), PS1_MON4);   
         -- when PS1_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.spare), 32)), PS1_MON5);            
          when PS1_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps1.sumterm_f), 32)), PS1_MON6);   
          when PS1_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps1.error_f), 32)), PS2_DCCT1);   

          when PS2_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct0), 32)), PS2_DCCT2); 
          when PS2_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct1), 32)), PS2_MON1); 
          when PS2_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.dacmon), 32)), PS2_MON2);          
          when PS2_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.voltage), 32)), PS2_MON3);   
          when PS2_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ignd), 32)), PS2_MON4);   
          when PS2_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.spare), 32)), PS2_MON5);            
          when PS2_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps2.sumterm_f), 32)), PS2_MON6);   
          when PS2_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps2.error_f), 32)), PS3_DCCT1);

          when PS3_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct0), 32)), PS3_DCCT2); 
          when PS3_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct1), 32)), PS3_MON1); 
          when PS3_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.dacmon), 32)), PS3_MON2);          
          when PS3_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.voltage), 32)), PS3_MON3);   
          when PS3_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ignd), 32)), PS3_MON4);   
          when PS3_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.spare), 32)), PS3_MON5);            
          when PS3_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps3.sumterm_f), 32)), PS3_MON6);   
          when PS3_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps3.error_f), 32)), PS4_DCCT1);   

          when PS4_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct0), 32)), PS4_DCCT2); 
          when PS4_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct1), 32)), PS4_MON1); 
          when PS4_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.dacmon), 32)), PS4_MON2);          
          when PS4_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.voltage), 32)), PS4_MON3);   
          when PS4_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ignd), 32)), PS4_MON4);   
          when PS4_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.spare), 32)), PS4_MON5);            
          when PS4_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps4.sumterm_f), 32)), PS4_MON6);   
          when PS4_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(pid_stat.ps4.error_f), 32)), WRD35);

          when WRD35 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"35", WRD36);
          when WRD36 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"36", WRD37);
          when WRD37 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"37", WRD38);
          when WRD38 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"38", WRD39); 
          when WRD39 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"39", WRD40);
          when WRD40 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"40", WRD41);
          when WRD41 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"41", WRD42);
          when WRD42 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"42", WRD43);         
          when WRD43 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"43", WRD44);
          when WRD44 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"44", WRD45);
          when WRD45 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"45", WRD46);
          when WRD46 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"46", WRD47); 
          when WRD47 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"47", WRD48);
          when WRD48 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"48", WRD49);
          when WRD49 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"49", WRD50);
          when WRD50 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"50", WRD51);           

          when WRD51 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"51", WRD52);
          when WRD52 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"52", WRD53); 
          when WRD53 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"53", WRD54);
          when WRD54 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"54", WRD55);
          when WRD55 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"55", WRD56);
          when WRD56 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"56", WRD57);         
          when WRD57 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"57", WRD58);
          when WRD58 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"58", WRD59);
          when WRD59 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"59", WRD60);
          when WRD60 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"60", WRD61); 
          when WRD61 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"61", WRD62);
          when WRD62 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"62", WRD63);
          when WRD63 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"63", WRDLAST);
      
                       
            --test case, to send counting pattern                                                   
--          when DATA =>
--              if (s_axi4_s2m.wready = '1') then
--                cnt_enable <= '1';
--                s_axi4_m2s.wvalid <= '1';
--                s_axi4_m2s.wdata <= std_logic_vector(wordnum);
--                wordnum <= wordnum + 1;
--                if wordnum = BURST_LEN-1 then
--                  state <= WRDLAST;
--                end if;
--              else 
--                axi_notrdy <= '1';
--              end if;

    
          when WRDLAST =>
            if (s_axi4_s2m.wready = '1') then
              s_axi4_m2s.wvalid <= '1';
              s_axi4_m2s.wlast <= '1';
              s_axi4_m2s.wdata <=  32d"64";  
              state <= awaitresp;  
            end if;
            
               
          when AWAITRESP =>
              s_axi4_m2s.wlast <= '0';
              s_axi4_m2s.wvalid <= '0';
              s_axi4_m2s.bready <= '1';
              -- Clear bready after response
              if s_axi4_s2m.bvalid = '1' then
                if (addr_base < DDR_MAX_ADDR) then
                   addr_base <= std_logic_vector(unsigned(addr_base) + 4*BURST_LEN);
                else
                   addr_base <= DDR_BASE_ADDR;
                end if;
                s_axi4_m2s.bready <= '0';
                state <= idle;
              end if;
              
          end case;
        end if;
      end if;
   end process;
end architecture;


          
             
--          when HDR => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 1, 32)), CNT);
--          when CNT => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 2, 32)), PS1_DCCT1);

--          when PS1_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 5, 32)), PS1_DCCT2);
--          when PS1_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 4, 32)), PS1_MON1);
--          when PS1_MON1  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 45, 32)), PS1_MON2);
--          when PS1_MON2  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 6, 32)), PS1_MON3);
--          when PS1_MON3  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 7, 32)), PS1_MON4);
--          when PS1_MON4  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 8, 32)), PS1_MON5);
--          when PS1_MON5  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned( 9, 32)), PS1_MON6);
--          when PS1_MON6  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(10, 32)), PS2_DCCT1);

--          when PS2_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(11, 32)), PS2_DCCT2);
--          when PS2_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(12, 32)), PS2_MON1);
--          when PS2_MON1  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(13, 32)), PS2_MON2);
--          when PS2_MON2  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(14, 32)), PS2_MON3);
--          when PS2_MON3  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(15, 32)), PS2_MON4);
--          when PS2_MON4  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(16, 32)), PS2_MON5);
--          when PS2_MON5  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(17, 32)), PS2_MON6);
--          when PS2_MON6  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(18, 32)), PS3_DCCT1);

--          when PS3_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(19, 32)), PS3_DCCT2);
--          when PS3_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(20, 32)), PS3_MON1);
--          when PS3_MON1  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(21, 32)), PS3_MON2);
--          when PS3_MON2  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(22, 32)), PS3_MON3);
--          when PS3_MON3  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(23, 32)), PS3_MON4);
--          when PS3_MON4  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(24, 32)), PS3_MON5);
--          when PS3_MON5  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(25, 32)), PS3_MON6);
--          when PS3_MON6  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(26, 32)), PS4_DCCT1);

--          when PS4_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(27, 32)), PS4_DCCT2);
--          when PS4_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(28, 32)), PS4_MON1);
--          when PS4_MON1  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(29, 32)), PS4_MON2);
--          when PS4_MON2  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(30, 32)), PS4_MON3);
--          when PS4_MON3  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(31, 32)), PS4_MON4);
--          when PS4_MON4  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(32, 32)), PS4_MON5);
--          when PS4_MON5  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(33, 32)), PS4_MON6);
--          when PS4_MON6  => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(34, 32)), WRD35);

--          when WRD35 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(35, 32)), WRD36);
--          when WRD36 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(36, 32)), WRD37);
--          when WRD37 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(37, 32)), WRD38);
--          when WRD38 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(38, 32)), WRD39);
--          when WRD39 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(to_unsigned(39, 32)), WRDLAST);
          
          
                      
--          when HDR => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, x"80000000", CNT);
--          when CNT => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(unsigned(datacnt)), PS1_DCCT1); 
           
--          when PS1_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct0), 32)), PS1_DCCT2); 
--          when PS1_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps1.dcct1), 32)), PS1_MON1); 
--          when PS1_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.dacmon), 32)), PS1_MON2);          
--          when PS1_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.voltage), 32)), PS1_MON3);   
--          when PS1_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ignd), 32)), PS1_MON4);   
--          when PS1_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.spare), 32)), PS1_MON5);            
--          when PS1_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ps_reg), 32)), PS1_MON6);   
--          when PS1_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps1.ps_error), 32)), PS2_DCCT1);   

--          when PS2_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct0), 32)), PS2_DCCT2); 
--          when PS2_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps2.dcct1), 32)), PS2_MON1); 
--          when PS2_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.dacmon), 32)), PS2_MON2);          
--          when PS2_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.voltage), 32)), PS2_MON3);   
--          when PS2_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ignd), 32)), PS2_MON4);   
--          when PS2_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.spare), 32)), PS2_MON5);            
--          when PS2_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ps_reg), 32)), PS2_MON6);   
--          when PS2_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps2.ps_error), 32)), PS3_DCCT1);

--          when PS3_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct0), 32)), PS3_DCCT2); 
--          when PS3_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps3.dcct1), 32)), PS3_MON1); 
--          when PS3_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.dacmon), 32)), PS3_MON2);          
--          when PS3_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.voltage), 32)), PS3_MON3);   
--          when PS3_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ignd), 32)), PS3_MON4);   
--          when PS3_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.spare), 32)), PS3_MON5);            
--          when PS3_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ps_reg), 32)), PS3_MON6);   
--          when PS3_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps3.ps_error), 32)), PS4_DCCT1);   

--          when PS4_DCCT1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct0), 32)), PS4_DCCT2); 
--          when PS4_DCCT2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(dcct_adcs.ps4.dcct1), 32)), PS4_MON1); 
--          when PS4_MON1 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.dacmon), 32)), PS4_MON2);          
--          when PS4_MON2 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.voltage), 32)), PS4_MON3);   
--          when PS4_MON3 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ignd), 32)), PS4_MON4);   
--          when PS4_MON4 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.spare), 32)), PS4_MON5);            
--          when PS4_MON5 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ps_reg), 32)), PS4_MON6);   
--          when PS4_MON6 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, std_logic_vector(resize(signed(mon_adcs.ps4.ps_error), 32)), WRD35);

--          when WRD35 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"35", WRD36);
--          when WRD36 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"36", WRD37);
--          when WRD37 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"37", WRD38);
--          when WRD38 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"38", WRD39);         
--          when WRD39 => write_word(s_axi4_m2s.wdata, s_axi4_m2s.wvalid, state, 32d"39", WRDLAST);   
