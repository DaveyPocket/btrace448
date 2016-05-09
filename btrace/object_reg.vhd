library ieee;
library ieee_proposed;
use ieee.std_logic_1164.all;
use ieee_proposed.fixed_pkg.all;
use work.btrace_pack.all;

entity object_reg is
	port(clk, rst, en: in std_logic;
		Din: in object;
		Dout: out object);
end object_reg;

architecture arch of object_reg is
	constant zero_point: point := ((others => '0'), (others => '0'), (others => '0'));
	constant zero_object: object := (zero_point, (others => '0'), (others => '0'));
begin
	process(clk, rst)
	begin
		if rst = '1' then
			Dout <= zero_object;
		elsif rising_edge(clk) then
			if en = '1' then
				Dout <= Din;
			end if;
		end if;
	end process;
end arch;
