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
		
-------------------------------------------------------------------------------
--
-- Delta-Sigma DAC
--
-- Refer to Xilinx Application Note XAPP154.
--
-- This DAC requires an external RC low-pass filter:
--
--   dac_o 0---XXXXX---+---0 analog audio
--              3k3    |
--                    === 4n7
--                     |
--                    GND
--
-------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity dac is
	generic (
		C_bits  : integer := 8
	);
	port (
		clk_i   : in  std_logic;
		res_n_i : in  std_logic;
		dac_i   : in  std_logic_vector(C_bits-1 downto 0);
		dac_o   : out std_logic
	);
end dac;

architecture rtl of dac is
	signal sig_in: unsigned(C_bits downto 0);
begin
	seq: process(clk_i, res_n_i)
	begin
		if res_n_i = '0' then
			sig_in <= to_unsigned(2**C_bits, sig_in'length);
			dac_o  <= '0';
		elsif rising_edge(clk_i) then
		        -- not dac_i(C_bits-1) effectively adds 0x8..0 to dac_i
			--sig_in <= sig_in + unsigned(sig_in(C_bits) & (not dac_i(C_bits-1)) & dac_i(C_bits-2 downto 0));
			sig_in <= sig_in + unsigned(sig_in(C_bits) & dac_i);
			dac_o  <= sig_in(C_bits);
		end if;
	end process seq;
end rtl;
