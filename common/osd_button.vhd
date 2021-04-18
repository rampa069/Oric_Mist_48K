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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

entity osd_button is
generic
(
        OSD_CMD         : in std_logic_vector(2 downto 0) := "001";
        CLK_SPEED       : in integer := 50000
);
port
(
        Clk             : in std_logic;

        osd_o           : out std_logic_vector(7 downto 0);
        osd_enable      : in std_logic;
        
        -- MC2P button
        btn_osd         : in std_logic := '1';

        reset           : out std_logic := '0'

);
end Osd_Button;

architecture Behavioral of Osd_Button is

signal IsReleased : std_logic;
signal osd_c      : std_logic_vector(7 downto 0) := (others=>'1');
signal reset_s    : std_logic := '0';
constant long_press_timeout: integer := (CLK_SPEED*1250); -- Press to be about 2.5s
constant reset_timeout: integer := (long_press_timeout/4);

begin

reset <= reset_s;
osd_o <= osd_c when osd_enable = '1' else osd_c(7 downto 5) & "11111";

-- Open OSD using a console button or reset, after pressing the same button
process is
  variable cnt : INTEGER := 0;
  variable rst_cnt : INTEGER := 0;
begin
      wait until rising_edge(clk);
      if (cnt < 1000)
      then
         if (btn_osd = '0')
         then
             osd_c(7 downto 5) <= OSD_CMD; -- OSD Menu command
         else
             osd_c(7 downto 5) <= "111"; -- release
         end if;
      end if;
      
      if (rst_cnt >= reset_timeout)
      then
         reset_s <= '0';
         rst_cnt := 0;
      end if;
      
      if (cnt >= long_press_timeout)
      then
         cnt := 0;
         rst_cnt := 1;
         reset_s <= '1';
      end if;

      if (rst_cnt > 0)
      then
         rst_cnt := rst_cnt + 1;
      end if;
      
      if (btn_osd = '0')
      then
         cnt := cnt + 1;
      else
         cnt := 0;
      end if;

end process;

end Behavioral;
