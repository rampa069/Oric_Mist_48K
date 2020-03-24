#!/bin/sh

# A shell script for generating .vhd from rom files
#
# Usage:
#
# ./rom2vhdl.sh rom_name  vhdl_name

FILE=$1
FILENAME=${FILE%.rom}
FILESIZE=$(stat -c%s "$FILE.rom")
ROMSIZE=$(($FILESIZE-1))

function no_bits
{
 b=$FILESIZE;
 for i in {0..15}; 
  do  
    b=$(($b / 2));
  
    if [[ $b -eq 0 ]]
      then return $(($i - 1)) 
    fi
  done
 }
  
no_bits
bits=$?


echo "library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity $FILENAME is
 port (
   addr : in  std_logic_vector($bits downto 0);
   clk  : in  std_logic;
   data : out std_logic_vector(7 downto 0)
   );
end entity;

architecture prom of $FILENAME is
  type rom is array(0 to $ROMSIZE) of std_logic_vector(7 downto 0);
  signal rom_data: rom := ("
od --format x1 --address-radix=n --output-duplicates --width=8 $FILENAME.rom| awk 'NR > 1 { printf(",\n") }
  {printf "     X\"%s\", X\"%s\", X\"%s\", X\"%s\", X\"%s\", X\"%s\", X\"%s\", X\"%s\"", $1, $2, $3, $4, $5, $6, $7, $8}'

echo ");

begin

process (clk)
  begin
    if rising_edge(clk) then
      data <= rom_data(TO_INTEGER(unsigned(addr)));
    end if;
  end process;

end architecture;"
