-------------------------------------------------------------------------------
--
-- MSX1 FPGA project
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
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
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- Changed to a generic PS2 keyboard by Victor Trucco 02/2021
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ps2_keyboard is
    port (
        clock_i         : in    std_logic;
        reset_i         : in    std_logic;
        -- LEDs
        led_caps_i      : in    std_logic;
        -- PS/2 interface
        ps2_clk_io      : inout std_logic;
        ps2_data_io     : inout std_logic;
        -- Direct Access
        keyb_valid_o    : out   std_logic;
        keyb_data_o     : out   std_logic_vector(7 downto 0);
        --
        reset_o         : out   std_logic                               := '0';
        por_o           : out   std_logic                               := '0';
        reload_core_o   : out   std_logic                               := '0';
        extra_keys_o    : out   std_logic_vector(3 downto 0)    -- F11, Print Screen, Scroll Lock, Pause/Break
    );
end entity;

architecture Behavior of ps2_Keyboard is

    signal d_to_send_s      : std_logic_vector(7 downto 0)  := (others => '0');
    signal data_load_s      : std_logic                             := '0';
    signal keyb_data_s      : std_logic_vector(7 downto 0);
    signal keyb_valid_s     : std_logic;
    signal break_s              : std_logic;
    signal extended_s           : std_logic_vector(1 downto 0);
    signal has_keycode_s        : std_logic;
    signal extra_keys_s     : std_logic_vector(3 downto 0);

begin

    -- PS/2 interface
    ps2_port: entity work.ps2_iobase
    port map (
        enable_i        => '1',
        clock_i         => clock_i,
        reset_i         => reset_i,
        ps2_data_io     => ps2_data_io,
        ps2_clk_io      => ps2_clk_io,
        data_rdy_i      => data_load_s,
        data_i          => d_to_send_s,
        data_rdy_o      => keyb_valid_s,
        data_o          => keyb_data_s
    );



    -- Interpret scancode received
    process (reset_i, clock_i)
        variable batcode_v          : std_logic := '0';
        variable skip_count_v       : std_logic_vector(2 downto 0);
        variable break_v                : std_logic;
        variable extended_v         : std_logic_vector(1 downto 0);
        variable ctrl_v             : std_logic;
        variable alt_v                  : std_logic;
        variable led_caps_v         : std_logic                     := '0';
        variable ed_resp_v          : std_logic;
    begin
        if reset_i = '1' then

            reload_core_o       <= '0';
            reset_o             <= '0';
            por_o                   <= '0';
            extra_keys_s        <= (others => '0');
            skip_count_v        := "000";
            ed_resp_v           := '0';
            break_v                 := '0';
            extended_v          := "00";
            ctrl_v              := '0';
            alt_v                   := '0';
            has_keycode_s       <= '0';
            break_s             <= '0';
            extended_s          <= "00";

        elsif rising_edge(clock_i) then

            has_keycode_s       <= '0';
            data_load_s         <= '0';

            if keyb_valid_s = '1' then

                if    keyb_data_s = X"AA" then
                    -- BAT code (basic assurance test)
                    batcode_v       := '1';
                elsif keyb_data_s = X"FA" then
                    -- 0xED resp
                    ed_resp_v       := '1';
                elsif skip_count_v /= "000" then
                    skip_count_v    := skip_count_v - 1;
                elsif keyb_data_s = X"E0" then
                    -- Extended E0 key code follows
                    extended_v(0)   := '1';
                elsif keyb_data_s = X"E1" then
                    -- Extended E1 key code follows
                    extended_v(1)   := '1';
                elsif keyb_data_s = X"F0" then
                    -- Release code (break) follows
                    break_v         := '1';
                elsif keyb_data_s = X"14" and extended_v = "10" then        -- PAUSE/BREAK E1 [14] (77 E1 F0 14) F0 77
                    if break_v = '0' then
                        skip_count_v    := "100";                                   -- Skip the next 4 sequences
                        extended_v      := "00";
                    end if;
                    extra_keys_s(0) <= '1';
                elsif keyb_data_s = X"77" and extended_v = "00" then        -- PAUSE/BREAK release (F0 77)
                    extra_keys_s(0) <= '0';
                elsif keyb_data_s = X"7C" and extended_v = "01" then        -- PRINT SCREEN E0,12,E0,7C  E0,F0,7C,E0,F0,12
                    if break_v = '0' then
                        extended_v      := "00";
                    end if;
                    extra_keys_s(2) <= not break_v;
                else
                    if    keyb_data_s = X"11" and extended_v(1) = '0' then                              -- LAlt and RAlt
                        alt_v           := not break_v;
                    elsif keyb_data_s = X"14" and extended_v(1) = '0' then                              -- LCtrl and RCtrl
                        ctrl_v      := not break_v;
                    elsif keyb_data_s = X"71" and extended_v = "01" then                                    -- Delete
                        if alt_v = '1' and ctrl_v = '1' and break_v = '0' then
                            reset_o <= '1';
                        end if;
                    elsif keyb_data_s = X"78" and extended_v = "00" then                                    -- F11
                        extra_keys_s(3) <= not break_v;
                    elsif keyb_data_s = X"07" and extended_v = "00" then                                    -- F12
                        if alt_v = '1' and ctrl_v = '1' and break_v = '0' then
                            por_o <= '1';
                        end if;
                    elsif keyb_data_s = X"66" and extended_v = "00" then                                    -- Backspace
                        if alt_v = '1' and ctrl_v = '1' and break_v = '0' then
                            reload_core_o <= '1';
                        end if;
                    elsif keyb_data_s = X"7E" and extended_v = "00" then                                    -- Scroll-lock 7E   F0 7E
                        extra_keys_s(1) <= not break_v;
--                      if break_v = '0' then
--                          extra_keys_s(1) <= not extra_keys_s(1);
--                      end if;
                    end if;
                    break_s         <= break_v;
                    extended_s      <= extended_v;
                    break_v         := '0';
                    extended_v      := "00";
                    has_keycode_s   <= '1';

                end if; -- if keyb_data_s...

            else -- keyb_valid = 1

                if batcode_v = '1' then
                    batcode_v   := '0';
                    d_to_send_s <= X"55";
                    data_load_s <= '1';
                elsif led_caps_v /= led_caps_i then
                    led_caps_v  := led_caps_i;
                    d_to_send_s <= X"ED";
                    data_load_s <= '1';             
                elsif ed_resp_v = '1' then
                    ed_resp_v   := '0';
                    d_to_send_s <= "00000" & led_caps_v & "00";
                    data_load_s <= '1';
                end if;

            end if; -- keyb_valid_edge = 01
        end if;
    end process;

    extra_keys_o <= extra_keys_s;
    --
    keyb_valid_o    <= keyb_valid_s;
    keyb_data_o     <= keyb_data_s;

end architecture;