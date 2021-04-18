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
		
---------------------------------------------------------------------------
-- (c) 2016 Alexey Spirkov
-- I am happy for anyone to use this for non-commercial use.
-- If my verilog/vhdl/c files are used commercially or otherwise sold,
-- please contact me for explicit permission at me _at_ alsp.net.
-- This applies for source and binary form and derived works.

library ieee;
use ieee.std_logic_1164.all;

entity hdmi_delay_line is
generic(
  G_WIDTH                 : integer := 40;
  G_DEPTH                 : integer := 11);
port (
  I_CLK                   : in  std_logic;
  I_D                     : in  std_logic_vector(G_WIDTH-1 downto 0);
  O_Q                     : out std_logic_vector(G_WIDTH-1 downto 0));
end hdmi_delay_line;

architecture rtl of hdmi_delay_line is
type t_q_pipe is array(0 to G_DEPTH-1) of std_logic_vector(G_WIDTH-1 downto 0);
signal q_pipe          : t_q_pipe;
begin
process_pipe : process(i_clk)
begin
  if(rising_edge(i_clk)) then
  
    q_pipe   <= I_D&q_pipe(0 to q_pipe'length-2);
    
  end if;
end process process_pipe;
O_Q <= q_pipe(q_pipe'length-1);
end rtl;
