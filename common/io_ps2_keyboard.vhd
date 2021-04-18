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
        
-- -----------------------------------------------------------------------
--
--                                 FPGA 64
--
--     A fully functional commodore 64 implementation in a single FPGA
--
-- -----------------------------------------------------------------------
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Extension by Oduvaldo Pavan Junior - ducasp@gmail.com
-- Made the timeout and debounce be calculated based on the reported CLK,
-- so it works for any clock speed. You must report the clock speed to have
-- it working properly. 
-- -----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity io_ps2_keyboard is
    generic (
        CLK_SPEED  : integer := 50000
    );
    port (
        clk: in std_logic;
        kbd_clk: in std_logic;
        kbd_dat: in std_logic;
        interrupt: out std_logic;
        scanCode: out std_logic_vector(7 downto 0)
    );
end io_ps2_keyboard;

architecture Behavioral of io_ps2_keyboard is
    signal clk_reg: std_logic;
    signal clk_waitNextBit: std_logic;
    signal shift_reg: std_logic_vector(10 downto 0) := (others => '0');
    constant timeout_const: integer range 0 to 63000 := (CLK_SPEED/4); -- consider transfer lost if more than 250us elapses between bits
    constant debounce_const: integer range 0 to 250 := (CLK_SPEED/3333); -- 0,3us filter on clock
    signal clk_filter: integer range 0 to 250;
    signal bitsCount: integer range 0 to 10 := 0;
    signal timeout: integer range 0 to 63000 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then

            -- Interrupt is edge triggered. Only 1 clock high.
            interrupt <= '0';

            -- Timeout if keyboard does not send anymore.
            if timeout /= 0 then
                timeout <= timeout - 1;
            else
                bitsCount <= 0;
            end if;
            
            -- Filter glitches on the clock
            if (clk_reg /= kbd_clk) then
                clk_filter <= debounce_const; -- Wait 0,3us
                clk_reg <= kbd_clk; -- Store clock edge to detect changes
                clk_waitNextBit <= '0'; -- Next bit comming up...
            elsif (clk_filter /= 0) then
                -- Wait for clock to stabilise
                -- Clock must be stable before we sample the data line.
                clk_filter <= clk_filter - 1;
            elsif (clk_reg = '1') and (clk_waitNextBit = '0') then
                -- We have a stable clock, so assume stable data too.
                clk_waitNextBit <= '1';

                -- Move data into shift register
                shift_reg <= kbd_dat & shift_reg(10 downto 1);
                timeout <= timeout_const;
                if bitsCount < 10 then
                    bitsCount <= bitsCount + 1;
                else
                    -- 10 bits received. Output new scancode
                    bitsCount <= 0;
                    interrupt <= '1';
                    scanCode <= shift_reg(9 downto 2);
                end if;
            end if;

        end if;
    end process;

end Behavioral;
