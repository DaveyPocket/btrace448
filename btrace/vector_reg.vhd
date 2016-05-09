library ieee;
use ieee.std_logic_1164.all;
use work.btrace_pack.all;

entity vector_reg is
	port(clk, rst, en: in std_logic;
		Din: in vector;
		Dout: out vector);
end vector_reg;

architecture arch of vector_reg is
	constant zero_vector: vector := ((others => '0'), (others => '0'), (others => '0'));
begin
	process(clk, rst)
	begin
		if rst = '1' then
			Dout <= zero_vector;
		elsif rising_edge(clk) then
			if en = '1' then
				Dout <= Din;
			end if;
		end if;
	end process;
end arch;
