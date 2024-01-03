-- DeMiSTifyConfig_pkg.vhd
-- Copyright 2021 by Alastair M. Robinson

library ieee;
use ieee.std_logic_1164.all;

package demistify_config_pkg is
constant demistify_romspace : integer := 14; -- 16k address space to accommodate 16K of ROM
constant demistify_romsize1 : integer := 13; -- 8k fot the first chunk
constant demistify_romsize2 : integer := 13; -- 8k for the second chunk, mirrored across the last 4k

constant demistify_joybits : integer := 8;

constant demistify_button1 : integer := 4;
constant demistify_button2 : integer := 5;
constant demistify_button3 : integer := 6;
constant demistify_button4 : integer := 7;
constant demistify_button5 : integer := 8;
constant demistify_button6 : integer := 9;
end package;
