
--//////////////////////////////////////////////////////////////////////////////////
--// Company: 
--// Engineer: 
--// 
--// Create Date: 05/14/2015 02:56:06 PM
--// Design Name: 
--// Module Name: evr_top
--// Project Name: 
--// Target Devices: 
--// Tool Versions: 
--// Description: 
--// 
--// Dependencies: 
--// 
--// Revision:
--// Revision 0.01 - File Created
--// Additional Comments:
--//
--//
--//	SFP 5    - X0Y1
--//	SFP 6    - X0Y2   --- EVR Port
--//
--// 
--//////////////////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library work;
use work.psc_pkg.ALL;


entity fofb_top is
   port(
    sys_clk        : in std_logic;
    sys_rst        : in std_logic;
    gth_reset      : in std_logic_vector(7 downto 0);
    gth_refclk     : in std_logic;
    trig           : in std_logic;  
    tx_p           : out std_logic;
    tx_n           : out std_logic;
    rx_p           : in std_logic;
    rx_n           : in std_logic;
    fofb_data      : out t_fofb_data   
    --fofb_rcvd_clk  : out std_logic;
    --fofb_rcvd_data : out std_logic_vector(31 downto 0);
    --fofb_rcvd_val  : out std_logic;
    --fofb_txactive  : out std_logic;
    --fofb_txusr_clk : out std_logic

);
end fofb_top;
 
 
architecture behv of fofb_top is


component LocalDataCRC is
  port(
	clk            : in std_logic;
	rst            : in std_logic;		
	data_in        : in std_logic_vector(31 downto 0);
	crc_en         : in std_logic;
    CRCout         : out std_logic_vector(31 downto 0)
	);
end component;


component fofb_gth 
  port (
    gthrxn_in                            : in std_logic; 
    gthrxp_in                            : in std_logic;  
    gthtxn_out                           : out std_logic;  
    gthtxp_out                           : out std_logic;    
    gtwiz_reset_clk_freerun_in           : in std_logic;  
    gtwiz_reset_all_in                   : in std_logic;           
    drpclk_in                            : in std_logic; 
    gtrefclk0_in                         : in std_logic;  
    gtpowergood_out                      : out std_logic;  
    cpllfbclklost_out                    : out std_logic;  
    cplllock_out                         : out std_logic;  
    cpllrefclklost_out                   : out std_logic;       
     
    gtwiz_reset_tx_pll_and_datapath_in   : in std_logic;  
    gtwiz_reset_tx_datapath_in           : in std_logic;  
    gtwiz_reset_rx_pll_and_datapath_in   : in std_logic;  
    gtwiz_reset_rx_datapath_in           : in std_logic;  
    gtwiz_reset_rx_cdr_stable_out        : out std_logic;  
    gtwiz_reset_tx_done_out              : out std_logic;  
    gtwiz_reset_rx_done_out              : out std_logic;  
     
     gtwiz_userdata_tx_in                : in std_logic_vector(31 downto 0);  
     txctrl0_in                          : in std_logic_vector(15 downto 0);  
     txctrl1_in                          : in std_logic_vector(15 downto 0);   
     txctrl2_in                          : in std_logic_vector(7 downto 0);      
     tx8b10ben_in                        : in std_logic;  
     txoutclk_out                        : out std_logic;  
     txusrclk_in                         : in std_logic;  
     txusrclk2_in                        : in std_logic;  
     txpmaresetdone_out                  : out std_logic;       
     gtwiz_userclk_tx_reset_in           : in std_logic;  
     gtwiz_userclk_tx_active_in          : in std_logic; 

     gtwiz_userdata_rx_out               : out std_logic_vector(31 downto 0); 
     rxctrl0_out                         : out std_logic_vector(15 downto 0);     
     rxctrl1_out                         : out std_logic_vector(15 downto 0);  
     rxctrl2_out                         : out std_logic_vector(7 downto 0);  
     rxctrl3_out                         : out std_logic_vector(7 downto 0);   
     --rxpolarity_in                       : in std_logic;
     rx8b10ben_in                        : in std_logic; 
     rxcommadeten_in                     : in std_logic;  
     rxmcommaalignen_in                  : in std_logic;  
     rxpcommaalignen_in                  : in std_logic; 
     rxoutclk_out                        : out std_logic;        
     rxusrclk_in                         : in std_logic;  
     rxusrclk2_in                        : in std_logic;  
     rxbyteisaligned_out                 : out std_logic; 
     rxbyterealign_out                   : out std_logic;  
     rxcommadet_out                      : out std_logic;  
     rxpmaresetdone_out                  : out std_logic;  
     gtwiz_userclk_rx_active_in          : in std_logic

);
end component; 



	
    type state_type is (IDLE, CH1, CH2);
    type tx_state_type is (IDLE, WR_HEADER, WR_W0, WR_W1, WR_W2, WR_W3, WR_W4, WR_W5, WR_W6, WR_W7, WR_W8, WR_W9);                    
    signal   state   : state_type;
    signal tx_state  : tx_state_type;

--   signal rxout_clk         : std_logic;
--   signal rxusr_clk         : std_logic;
--   signal rxdata            : std_logic_vector(31 downto 0);  
--   signal rxcharisk         : std_logic_vector(3 downto 0);   
--   signal rxresetdone       : std_logic;  
   
--   signal rxdisperr         : std_logic_vector(3 downto 0);
--   signal rxnotintable      : std_logic_vector(3 downto 0);

   
--   signal txdata            : std_logic_vector(31 downto 0);
--   signal txout_clk         : std_logic;
--   signal txusr_clk         : std_logic; 
--   signal txcharisk         : std_logic_vector(3 downto 0);
--   signal txresetdone       : std_logic;
   
   signal count             : unsigned(31 downto 0); 
   signal got_fofb_pkt      : std_logic;
   signal ps1_setpt         : std_logic_vector(19 downto 0);
   signal ps2_setpt         : std_logic_vector(19 downto 0);   
   
   signal tx_fsm_reset_done : std_logic;
   signal rx_fsm_reset_done : std_logic;
   
   signal cpllfbclklost     : std_logic;
   signal cplllock          : std_logic;
   
   signal data_rdy_s        : std_logic_vector(2 downto 0);
   
   signal crcdata           : std_logic_vector(31 downto 0);
   signal crc_en            : std_logic := '0';
   signal crc               : std_logic_vector(31 downto 0);
   signal crc_rst           : std_logic;
   
  signal gth_powergood   :  std_logic;
  signal gth_cpllfbclklost : std_logic;
  signal gth_cplllock      : std_logic;
  signal gth_cpllrefclklost  : std_logic;  
   
  signal gth_userclk_tx_srcclk : std_logic;
  signal gth_userclk_tx_usrclk : std_logic;
  signal gth_userclk_tx_usrclk2 : std_logic;
  signal gth_userclk_tx_active : std_logic; 
  signal gth_reset_tx_done     : std_logic;
  signal gth_txpmaresetdone    : std_logic;
  signal gth_txdata_in        : std_logic_vector(31 downto 0);
  signal gth_txcharisk_in      : std_logic_vector(7 downto 0);

  signal gth_userclk_rx_srcclk : std_logic;
  signal gth_userclk_rx_usrclk : std_logic;
  signal gth_userclk_rx_usrclk2 : std_logic;
  signal gth_userclk_rx_active : std_logic;
  signal gth_reset_rx_done     : std_logic;
  signal gth_rxpmaresetdone    : std_logic;
  signal gth_reset_rx_cdr_stable : std_logic;  
  signal gth_rxbyteisaligned   : std_logic;
  signal gth_rxbyterealign     : std_logic;
  signal gth_rxcommadet        : std_logic; 
  signal gth_rx_userdata       : std_logic_vector(31 downto 0);
  signal gth_rxctrl0           : std_logic_vector(15 downto 0);
  signal gth_rxctrl1           : std_logic_vector(15 downto 0);
  signal gth_rxctrl2           : std_logic_vector(7 downto 0);
  signal gth_rxctrl3           : std_logic_vector(7 downto 0);

  signal gth_rxusr_clk         : std_logic;
  signal gth_rxout_clk         : std_logic;
  signal gth_txusr_clk         : std_logic;
  signal gth_txout_clk         : std_logic;
  signal gth_rxusr_clk_i       : std_logic;
  
  signal ps1_history : std_logic_vector(399 downto 0) := (others => '0');
   
   
   
   
   
   attribute ASYNC_REG : string;
   attribute ASYNC_REG of data_rdy_s : signal is "true";

   
--   --debug signals (connect to ila)
   attribute mark_debug     : string;
  
   attribute mark_debug of gth_rx_userdata: signal is "true";
   attribute mark_debug of gth_rxctrl0: signal is "true";
   attribute mark_debug of gth_reset_rx_done: signal is "true";
   attribute mark_debug of gth_txdata_in: signal is "true";
   attribute mark_debug of gth_txcharisk_in: signal is "true";
   attribute mark_debug of gth_reset_tx_done: signal is "true";

   
   attribute mark_debug of count: signal is "true";
   attribute mark_debug of got_fofb_pkt: signal is "true";
   attribute mark_debug of ps1_setpt: signal is "true";
   attribute mark_debug of ps2_setpt: signal is "true";   
   attribute mark_debug of trig: signal is "true";
   attribute mark_debug of data_rdy_s: signal is "true";
   attribute mark_debug of ps1_history: signal is "true";



begin


fofb_data.ps1_setpt <= signed(ps1_setpt);
fofb_data.ps2_setpt <= signed(ps2_setpt);
fofb_data.ps3_setpt <= 20d"0";
fofb_data.ps4_setpt <= 20d"0";

--fofb_txusr_clk <= txusr_clk;
--fofb_txactive <= txcharisk(0);

-- received FOFB data (for remote mode)
--fofb_rcvd_clk <= rxusr_clk;
--fofb_rcvd_data <= rxdata;
--fofb_rcvd_val <= NOT rxcharisk(0);



--sync the data_rdy signal to the txusr_clk domain
process (gth_txusr_clk)
begin
  if (rising_edge(gth_txusr_clk)) then
    data_rdy_s(2) <= trig; --fa_data.data_rdy;
    data_rdy_s(1) <= data_rdy_s(2);
    data_rdy_s(0) <= data_rdy_s(1);
  end if;
end process;


BUFG_GT_rx : BUFG_GT
   port map (
      O => gth_rxusr_clk,             -- 1-bit output: Buffer
      CE => '1',           -- 1-bit input: Buffer enable
      CEMASK => '0',   -- 1-bit input: CE Mask
      CLR => gth_reset(0),  --gth_reset(0),         -- 1-bit input: Asynchronous clear
      CLRMASK => '0', -- 1-bit input: CLR Mask
      DIV => "000",         -- 3-bit input: Dynamic divide Value
      I => gth_rxout_clk              -- 1-bit input: Buffer
   );

BUFG_GT_tx : BUFG_GT
   port map (
      O => gth_txusr_clk,             -- 1-bit output: Buffer
      CE => '1',           -- 1-bit input: Buffer enable
      CEMASK => '0',   -- 1-bit input: CE Mask
      CLR => gth_reset(0), --reg_o.reset, --gth_reset(0),         -- 1-bit input: Asynchronous clear
      CLRMASK => '0', -- 1-bit input: CLR Mask
      DIV => "000",         -- 3-bit input: Dynamic divide Value
      I => gth_txout_clk              -- 1-bit input: Buffer
   );



--write samples to transceiver
process(sys_rst, gth_txusr_clk)
  begin
    if (rising_edge(gth_txusr_clk)) then
      if (sys_rst = '1') then
        tx_state <= idle;
        crcdata <= 32d"0";
        gth_txdata_in <= x"5051523C";
        crc_en <= '0';
        crc_rst <= '1';
        gth_txcharisk_in <= x"01";              
      else
        case tx_state is
          when IDLE => 
            gth_txdata_in <= x"5051523C";
            gth_txcharisk_in <= x"01";  
            crcdata <= 32d"0";
            crc_rst <= '1';    
            if (data_rdy_s(0) = '0') and (data_rdy_s(1) = '1') then
              crc_rst <= '0';
              tx_state <= wr_header;
            end if;
             
          when WR_HEADER =>
            crc_en <= '1';
            crcdata <= x"00A0005C";
            tx_state <= wr_w0;   
             
          when WR_W0 =>
            crcdata <= x"00001000"; --fa_data.cha_mag;
            gth_txdata_in  <= x"00A0005C";
            gth_txcharisk_in <= x"00";
            tx_state <= wr_w1;

          when WR_W1 =>
            crcdata <= x"00001001"; --fa_data.chb_mag;         
            gth_txdata_in  <= x"00001000"; --fa_data.cha_mag;
            tx_state <= wr_w2;
              
         when WR_W2 =>
            crcdata <= x"00001002"; --fa_data.chc_mag;
            gth_txdata_in  <= x"00001001"; --fa_data.chb_mag;
            tx_state <= wr_w3;

          when WR_W3 =>
            crcdata <= x"00001003"; --fa_data.chd_mag;
            gth_txdata_in  <= x"00001002"; --fa_data.chc_mag;
            tx_state <= wr_w4;
 
          when WR_W4 =>
            crcdata <= x"00002000"; --fa_data.xpos;
            gth_txdata_in  <= x"00001003"; --fa_data.chd_mag;
            tx_state <= wr_w5;                                      
 
         when WR_W5 =>
            crcdata <= x"00002001"; --fa_data.ypos;
            gth_txdata_in  <= x"00002000"; --fa_data.xpos;
            tx_state <= wr_w6;

          when WR_W6 =>
            crcdata <= x"00003333"; --fa_data.sum;
            gth_txdata_in  <= x"00002001"; --fa_data.ypos;
            tx_state <= wr_w7;
 
          when WR_W7 =>
            crcdata <= 32d"0";
            gth_txdata_in <= x"00003333"; --fa_data.sum;         
            tx_state <= wr_w8;  
            
         when WR_W8 =>
            crc_en <= '0';
            gth_txdata_in <= 32d"0"; --status;
            tx_state <= wr_w9;             
            
          when WR_W9 =>
            gth_txdata_in <= crc;
            tx_state <= idle;   

          when OTHERS => 
              tx_state <= idle;    
              
         end case;
       end if;
     end if;
end process; 


fofb: LocalDataCRC 
  port map(
	clk => gth_txusr_clk,
	rst => crc_rst, 		
	data_in => crcdata,
	crc_en => crc_en, 
    CRCout => crc
	);


--process
--begin
--   txout_clk <= '0';
--   wait for 4 ns;
--   txout_clk <= '1';
--   wait for 4 ns;
--end process;


process (gth_rxusr_clk)
begin
  if (rising_edge(gth_rxusr_clk)) then
    if (sys_rst = '1') then
      count <= 32d"0";
      got_fofb_pkt <= '0';
      ps1_setpt <= 20d"0";
    else
      case state is
        when IDLE => 
          if (gth_rx_userdata = x"0800005C") and (gth_rxctrl0(3 downto 0) = x"1") then
            count <= 32d"0";
            got_fofb_pkt <= '1';
            count <= 32d"0";
            state <= CH1;
          else
            count <= count + 1;
            got_fofb_pkt <= '0';
          end if;
            
        when CH1 => 
          ps1_setpt <= gth_rx_userdata(19 downto 0) xor x"80000";  --convert offset binary to 2's complement
          -- Shift older samples upward and insert newest sample at the bottom.
         ps1_history <= ps1_history(379 downto 0) & (gth_rx_userdata(19 downto 0) xor x"80000");
          
          state <= ch2;
          
            
        when CH2 => 
          ps2_setpt <= gth_rx_userdata(19 downto 0) xor x"80000";  --convert offset binary to 2's complement
          state <= idle;
        
        when others => 
          state <= idle;
      end case;              

    end if;
  end if;
end process;
    

gth : fofb_gth 
    port map(
     gthrxn_in => rx_n,
     gthrxp_in => rx_p, 
     gthtxn_out => tx_n, 
     gthtxp_out => tx_p,   
     gtwiz_reset_clk_freerun_in => sys_clk, 
     gtwiz_reset_all_in => gth_reset(0),  --gth_reset(0),          
     drpclk_in => sys_clk,
     gtrefclk0_in => gth_refclk, 
     gtpowergood_out => gth_powergood, 
     cpllfbclklost_out => gth_cpllfbclklost, 
     cplllock_out => gth_cplllock, 
     cpllrefclklost_out => gth_cpllrefclklost,      
     
     gtwiz_reset_tx_pll_and_datapath_in => gth_reset(0),
     gtwiz_reset_tx_datapath_in => gth_reset(0),
     gtwiz_reset_rx_pll_and_datapath_in => gth_reset(0), 
     gtwiz_reset_rx_datapath_in => gth_reset(0),
     gtwiz_reset_rx_cdr_stable_out => gth_reset_rx_cdr_stable, 
     gtwiz_reset_tx_done_out => gth_reset_tx_done, 
     gtwiz_reset_rx_done_out => gth_reset_rx_done, 
     
     gtwiz_userdata_tx_in => gth_txdata_in, 
     txctrl0_in  => x"0000",
     txctrl1_in => x"0000", 
     txctrl2_in => gth_txcharisk_in,      
     tx8b10ben_in => '1', 
     txoutclk_out => gth_txout_clk, 
     txusrclk_in => gth_txusr_clk, 
     txusrclk2_in => gth_txusr_clk, 
     txpmaresetdone_out => gth_txpmaresetdone,      
     gtwiz_userclk_tx_reset_in => gth_reset(0),
     gtwiz_userclk_tx_active_in => not gth_reset(0),

     gtwiz_userdata_rx_out => gth_rx_userdata,
     rxctrl0_out => gth_rxctrl0, 
     rxctrl1_out => gth_rxctrl1, 
     rxctrl2_out => gth_rxctrl2, 
     rxctrl3_out => gth_rxctrl3,  
     --rxpolarity_in => '0',   -- '1' for Rev3 board
     rx8b10ben_in  => '1',
     rxcommadeten_in => '1', 
     rxmcommaalignen_in => '1', 
     rxpcommaalignen_in => '1',
     rxoutclk_out => gth_rxout_clk,       
     rxusrclk_in => gth_rxusr_clk, 
     rxusrclk2_in => gth_rxusr_clk, 
     rxbyteisaligned_out => gth_rxbyteisaligned, 
     rxbyterealign_out => gth_rxbyterealign, 
     rxcommadet_out => gth_rxcommadet, 
     rxpmaresetdone_out => gth_rxpmaresetdone, 
     gtwiz_userclk_rx_active_in  => not gth_reset(0)

);




		

			 
end behv;
