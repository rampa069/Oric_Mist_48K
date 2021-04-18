--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
		
-----------------------------------------------------
--
--  Multicore 2 keyboard adapter by Victor Trucco
--
-----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mist_Keyboard is
port (
  Clk          : in std_logic;
  KbdInt       : in std_logic;
  KbdScanCode  : in std_logic_vector(7 downto 0);
  Keyboarddata : out std_logic_vector(10 downto 0);
  osd_o			: out   std_logic_vector(7 downto 0)
);
end mist_Keyboard;

architecture Behavioral of mist_Keyboard is

signal IsReleased : std_logic;
signal osd_s : std_logic_vector(7 downto 0) := "11111111";
signal strobe : std_logic;
begin 

process(Clk)
begin
  if rising_edge(Clk) then
  
	osd_o <= osd_s;
	strobe <= '0';
  
    if KbdInt = '1' then
	 
			if KbdScanCode = "11110000" then IsReleased <= '1'; else IsReleased <= '0'; end if; 

			--[10] - toggles with every press/release, [9] - pressed, [8] - extended, [7:0] ps2 scan code
			
			Keyboarddata <= KbdInt & not IsReleased & '0' & KbdScanCode;
			
			
			if KbdScanCode = "01110101" then osd_s(0) <= (IsReleased); end if; -- up    arrow : 0x75
			if KbdScanCode = "01110010" then osd_s(1) <= (IsReleased); end if; -- down  arrow : 0x72
			if KbdScanCode = "01101011" then osd_s(2) <= (IsReleased); end if; -- left  arrow : 0x6B
			if KbdScanCode = "01110100" then osd_s(3) <= (IsReleased); end if; -- right arrow : 0x74	
			if KbdScanCode = x"5A" 	    then osd_s(4) <= (IsReleased); end if; -- ENTER	
			
			if KbdScanCode = x"07" then -- F12
				if IsReleased = '0' then 
					osd_s(7 downto 5) <= "001"; 
				else
					osd_s(7 downto 5) <= "111";
				end if; 
			end if;
				
				
	 
	 else
	 
			Keyboarddata <= (others=>'0');
    
	 end if;
 
  end if;
end process;

end Behavioral;


