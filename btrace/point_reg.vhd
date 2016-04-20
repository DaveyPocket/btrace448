library ieee;
use ieee.std_logic_1164.all;
use work.btrace_pack.all;

entity point_reg is
	port(clk, rst, en: in std_logic;
		Din: in point;
		Dout: out point);
end point_reg;

architecture arch of point_reg is
	constant zero_point: point := ((others => '0'), (others => '0'), (others => '0'));
begin
	process(clk, rst)
	begin
		if rst = '1' then
			Dout <= zero_point;
		elsif rising_edge(clk) then
			if en = '1' then
				Dout <= Din;
			end if;
		end if;
	end process;
end arch;
