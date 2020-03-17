-- Cumulus CPLD Core 
-- Top Level Entity
-- Copyright 2010 Retromaster
--
--  This file is part of Cumulus CPLD Core.
--
--  Cumulus CPLD Core is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License,
--  or any later version.
--
--  Cumulus CPLD Core is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with Cumulus CPLD Core.  If not, see <http://www.gnu.org/licenses/>.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Microdisc is
    port( 
          CLK: in std_logic;                                -- 32 Mhz input clock
          CLK_SYS: in std_logic;                            -- 24 Mhz input clock
                                                            -- Oric Expansion Port Signals
          DI: in std_logic_vector(7 downto 0);            -- 6502 Data Bus
          DO: out std_logic_vector(7 downto 0);            -- 6502 Data Bus
			 
          A: in std_logic_vector(15 downto 0);              -- 6502 Address Bus
          RnW: in std_logic;                                -- 6502 Read-/Write
          nIRQ: out std_logic;                              -- 6502 /IRQ
          PH2: in std_logic;                                -- 6502 PH2 
          nROMDIS: out std_logic;                           -- Oric ROM Disable
          nMAP: out std_logic;                              -- Oric MAP 
          IO: in std_logic;                                 -- Oric I/O 
          IOCTRL: out std_logic;                            -- Oric I/O Control           
          nHOSTRST: out std_logic;                          -- Oric RESET 
                  
                                                            -- Data Bus Buffer Control Signals
          nOE: out std_logic;                               -- Output Enable
          DIR: out std_logic;                               -- Direction
          

                                                            -- Additional MCU Interface Lines
 			 nRESET: in std_logic;                             -- RESET from MCU
          DSEL: buffer std_logic_vector(1 downto 0);           -- Drive Select
          SSEL: buffer std_logic;                              -- Side Select
          
                                                            -- EEPROM Control Lines.
          nECE: out std_logic;                              -- Chip Enable
          nEOE: out std_logic;                              -- Output Enable
          ENA:  in std_logic;
			 
			 img_mounted:     in std_logic;
			 img_wp:          in std_logic_vector (1 downto 0);
			 img_size:        in std_logic_vector (31 downto 0);
			 sd_lba:          out std_logic_vector (31 downto 0);
			 sd_rd:           out std_logic_vector (1 downto 0);
			 sd_wr:           out std_logic_vector (1 downto 0);
			 sd_ack:          in std_logic;
			 sd_buff_addr:    in std_logic_vector (8 downto 0);
			 sd_dout:         in std_logic_vector (7 downto 0);
			 sd_din:          out std_logic_vector (7 downto 0);
			 sd_dout_strobe:  in std_logic;
			 sd_din_strobe:   in std_logic;
			 
			 fdd_ready:       in std_logic;
			 fd_led:          out std_logic
         );
end Microdisc;

architecture Behavioral of Microdisc is
    component wd1793 
        port(                                               
              clk_sys:          in std_logic;
				  ce:               in std_logic;
				  
				  reset:            in std_logic;
				  io_en:            in std_logic;
				  rd:               in std_logic;
				  wr:               in std_logic;
				  addr:             in std_logic_vector (1 downto 0);
				  din:              in  std_logic_vector (7 downto 0);
				  dout:             out std_logic_vector (7 downto 0);
				  
				  intrq:            out std_logic;
              drq:              out std_logic;
				  
				  busy:             out std_logic;
				  ready:            in std_logic;
				  layout:          in std_logic;
				  side:            in std_logic;
				  
				  img_mounted:     in std_logic;
				  wp:              in std_logic;
				  img_size:        in std_logic_vector (19 downto 0);
				  sd_lba:          out std_logic_vector (31 downto 0);
				  sd_rd:           out std_logic;
				  sd_wr:           out std_logic;
				  sd_ack:          in std_logic;
				  sd_buff_addr:    in std_logic_vector (8 downto 0);
				  sd_buff_dout:    in std_logic_vector (7 downto 0);
				  sd_buff_din:     out std_logic_vector (7 downto 0);
				  
				  size_code:       in std_logic_vector (2 downto 0)
				  --sd_dout_strobe:  in std_logic;
				  --sd_din_strobe:   in std_logic
				  
             );
    end component;
	 
    signal data: std_logic_vector(7 downto 0);
    signal track: std_logic_vector(6 downto 0);
    signal sector: std_logic_vector(7 downto 0);
    signal command: std_logic_vector(7 downto 0);
    signal status: std_logic_vector(7 downto 0);
    signal MST: std_logic_vector(6 downto 0);

    -- Status
    signal busy: std_logic;
    signal lostData: std_logic;
    signal dataRequest: std_logic;
    signal commandRequest: std_logic;


    
    signal fdc_nCS: std_logic;                                  
    signal fdc_nRE: std_logic;                              
    signal fdc_nWE: std_logic;                                  
    signal fdc_CLK: std_logic;                                  
    signal fdc_A: std_logic_vector(1 downto 0);         
    signal fdc_DALin: std_logic_vector(7 downto 0); 
    signal fdc_DALout: std_logic_vector(7 downto 0);        
    signal fdc_DRQ: std_logic;                              
    signal fdc_IRQ: std_logic;                                                                                                              
                    
    signal sel: std_logic;                  
    signal u16k: std_logic; 
    signal inECE: std_logic;
    signal inROMDIS: std_logic;
    signal iDIR: std_logic;
    
    -- Control Register 
    signal nROMEN: std_logic;               -- ROM Enable
    signal IRQEN: std_logic;                -- IRQ Enable
    
    signal inMCRQ: std_logic;
    
    signal DBG_cntr: std_logic_vector(1 downto 0);
    signal DBG_signal: std_logic;
    
    signal PH2_1: std_logic;                                
    signal PH2_2: std_logic;                                
    signal PH2_3: std_logic;                                
    signal PH2_old: std_logic_vector(3 downto 0);   
    signal PH2_cntr: std_logic_vector(4 downto 0);
                        
begin

fdd1: wd1793
 port map
  (
              clk_sys         => CLK_SYS,
				  ce              => fdc_CLK,
				  
				  reset           => not nRESET,
				  io_en           => not fdc_nCS,
				  rd              => not fdc_nRE,
				  wr              => not fdc_nWE,
				  addr            => fdc_A,
				  din             => fdc_DALin,
				  dout            => fdc_DALout,
				  
				  intrq          => fdc_IRQ,
              drq            => fdc_DRQ,
				  
				  ready          => fdd_ready, --img_mounted,
				  --busy           => 
				  
				  layout         => '1',
				  size_code      => "001",
				  side           => SSEL,
				  --prepare        => 
				  img_mounted    => img_mounted,
				  wp             => img_wp(0),
				  img_size       => img_size (19 downto 0),
				  sd_lba         => sd_lba,
				  sd_rd          => sd_rd(0),
				  sd_wr          => sd_wr(0),
				  sd_ack         => sd_ack,
				  sd_buff_addr   => sd_buff_addr,
				  sd_buff_dout   => sd_dout,
				  sd_buff_din    => sd_din
				  --sd_dout_strobe => sd_dout_strobe,
				  --sd_din_strobe  => sd_din_strobe
  );
    
  

    -- Reset
    nHOSTRST <= '0' when nRESET = '0' else '1';

    -- Select signal (Address Range 031-)
    sel <= '1' when A(7 downto 4) = "0001" and IO = '0' and A(3 downto 2) /= "11"   else '0';

    -- WD1793 Signals
    fdc_A <= A(1 downto 0);
    fdc_nCS <= '0' when sel = '1' and A(3 downto 2) = "00" else '1';
    fdc_nRE <= IO or not RnW;
    fdc_nWE <= IO or RnW;
    fdc_CLK <= not PH2_2;
    fdc_DALin <= DI;
    -- DEBUG led
    fd_led <= not fdc_DRQ;
	 
    -- ORIC Expansion Port Signals
    IOCTRL <= '0' when sel = '1' else '1';
    nROMDIS <= '0' when inROMDIS = '0' else '1';
    nIRQ <= '0' when fdc_IRQ = '1' and IRQEN = '1' else '1';
    
    -- EEPROM Control Signals
    nEOE <= PH2_1 or not RnW;
    u16k <= '1' when (inROMDIS = '0') and (A(14) = '1') and (A(15) = '1') else '0';
    inECE <= not (A(13) and u16k and not nROMEN);
    nECE <= inECE;
    nMAP <= '0' when (PH2_2 and inECE and u16k) = '1' else '1'; 
    
    
    --nMCRQ <= inMCRQ;        
    
    DIR <= iDIR;
    iDIR <= RnW;    
    
    -- Data Bus Control.
    process (iDIR, fdc_DALout, fdc_DRQ, fdc_IRQ, fdc_nRE, A)
    begin 
        if iDIR = '1' then      
            if A(3 downto 2) = "10" then 
                DO <= (not fdc_DRQ) & "-------";
            elsif A(3 downto 2) = "01" then 
                DO <= (not fdc_IRQ) & "-------"; 
            elsif fdc_nRE = '0' and fdc_nCS = '0' then
                DO <= fdc_DALout;            
            else 
                DO <= "--------";    
            end if;
        else 
            DO <= "ZZZZZZZZ";    
        end if;
    end process;    
    
    nOE <= '0' when sel = '1' and PH2 = '1' else '1';
    
    -- Control Register.
    process (sel, A, RnW, DI)
    begin
        if nRESET = '0' then
            nROMEN <= '0';
            DSEL <= "00";
            SSEL <= '0';
				if ENA = '0' then
				     inROMDIS <= '0';
				else inROMDIS <= '1';
				end if;
				IRQEN <= '0';       
        elsif falling_edge(PH2_2) then 
            if sel = '1' and A(3 downto 2) = "01" and RnW = '0' then
                nROMEN <= DI(7);
                DSEL <= DI(6 downto 5);
                SSEL <= DI(4);
					 inROMDIS <= DI(1);
                IRQEN <= DI(0);
            end if;
        end if;
    end process;
    
    -- PH2 derived clocks.
    process (PH2, CLK)
    begin
        if nRESET = '0' then
            PH2_cntr <= "00000";
        elsif falling_edge(CLK) then 
            PH2_old <= PH2_old(2 downto 0) & PH2;
            if (PH2_old = "1111") and (PH2 = '0') then 
                PH2_cntr <= "00000";
                PH2_1 <= '1';
            else
                PH2_cntr <= PH2_cntr + 1;               
                if (PH2_cntr = "10000") then 
                    PH2_1 <= '0';
                    PH2_2 <= '1';
                elsif (PH2_cntr = "10111") then 
                    PH2_3 <= '1';
                elsif (PH2_cntr = "11100") then 
                    PH2_2 <= '0';                   
                elsif (PH2_cntr = "11101") then 
                    PH2_3 <= '0';
                end if;
            end if;
        end if;
    end process;        
        
end Behavioral;

