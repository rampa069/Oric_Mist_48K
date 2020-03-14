-- Microdisc CPLD Core 
-- Copyright 2010 Retromaster
-- Copyright 2020 rampa@encomix.org
--
--  This file was part of Cumulus CPLD Core. <http://miniserve.defence-force.org/svn/public/oric/hardware/cumulus/cpld/>
--  and was adapted to behave as a real microdisc controller (based on Slicebit and chema advice)
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
          
                                                            -- Oric Expansion Port Signals
          DI: in std_logic_vector(7 downto 0);               -- 6502 Data Bus
          DO: out std_logic_vector(7 downto 0);             -- 6502 Data Bus			 
          A: in std_logic_vector(15 downto 0);              -- 6502 Address Bus
          RnW: in std_logic;                                -- 6502 Read-/Write
          nIRQ: out std_logic;                              -- 6502 /IRQ
          PH2: in std_logic;                                -- 6502 PH2 
          nROMDIS: out std_logic;                           -- Oric ROM Disable
          nMAP: out std_logic;                              -- Oric MAP 
          IO: in std_logic;                                 -- Oric I/O 
          IOCTRL: out std_logic;                            -- Oric I/O Control           
          nHOSTRST: out std_logic;                          -- Oric RESET 

          nRESET: in std_logic;                             -- RESET from MCU

          DSEL: out std_logic_vector(1 downto 0);           -- Drive Select
          SSEL: out std_logic;                              -- Side Select
          
  		    u16k: buffer std_logic;                           -- signal when using overlay/rom
			 ENA:  in std_logic;                               -- Controller enable
                                                            -- EEPROM Control Lines.
          nECE: out std_logic;                               -- Chip Enable
			 -- WD
			 
			 fdc_nCS: inout std_logic;                            -- Chip Select
          fdc_nRE: inout std_logic;                            -- Read Enable
          fdc_nWE: inout std_logic;                            -- Write Enable
			 fdc_nOE: inout std_logic;
          fdc_CLK: out std_logic;                            
			 fdc_sel: inout std_logic;
			 fdc_DRQ: inout std_logic;
			 fdc_IRQ: inout std_logic;
          fdc_A:   out std_logic_vector(1 downto 0);         
          fdc_DALin: out std_logic_vector(7 downto 0);       
          fdc_DALout: in std_logic_vector(7 downto 0)         
      
         );
end Microdisc;

architecture Behavioral of microdisc is


    signal inECE: std_logic;
    signal inROMDIS: std_logic;
    
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

   

    -- Reset
    nHOSTRST <= '0' when nRESET = '0' else '1';

    -- Select signal (Address Range 031-)
    fdc_sel <= '1' when A(7 downto 4) = "0001" and IO = '0' and A(3 downto 2) /= "11"   else '0';

    -- WD1793 Signals
    fdc_A <= A(1 downto 0);
    fdc_nCS <= '0' when fdc_sel = '1' and A(3 downto 2) = "00" else '1';
	 fdc_nRE <= IO or not RnW;
    fdc_nWE <= IO or RnW;
    fdc_CLK <= not PH2_2;
	 
	 fdc_DALin <= DI; -- DO?
            
    -- ORIC Expansion Port Signals
    IOCTRL <= '0' when fdc_sel = '1' else '1';
    nROMDIS <= '0' when inROMDIS = '0' else '1';
    nIRQ <= '0' when fdc_IRQ = '1' and IRQEN = '1' else '1';
    
    -- EEPROM Control Signals
    u16k <= '1' when (inROMDIS = '0') and (A(14) = '1') and (A(15) = '1') else '0';
    inECE <= not (A(13) and u16k and not nROMEN);
    nECE <= inECE;
	 nMAP <= '0' when (PH2_2 and inECE and u16k) = '1' else '1'; 

    --nMCRQ <= inMCRQ;        
    
    -- Data Bus Control.
    process (RnW, fdc_DALout, fdc_DRQ, fdc_IRQ, fdc_nRE, fdc_nCS, A)
    begin 
        if RnW = '1' then      
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
--    
    fdc_nOE <= '0' when fdc_sel = '1' and PH2 = '1' else '1';
    
    -- Control Register.
    process (fdc_sel, A, RnW, DI,ENA,PH2_2,nRESET)
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
            if fdc_sel = '1' and A(3 downto 2) = "01" and RnW = '0' then
                nROMEN <= DI(7);
                DSEL <= DI(6 downto 5);
                SSEL <= DI(4);
                inROMDIS <= DI(1);
                IRQEN <= DI(0);
            end if;
        end if;
    end process;
    
    -- PH2 derived clocks.
    process (PH2, CLK, nRESET)
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
