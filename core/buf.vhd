-- Btrace 448
-- Dual-port BRAM
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buf is
	generic(N: integer := 4); -- Address bits
	port(clk: in std_logic;
		en: in std_logic;
		Din: in std_logic_vector(11 downto 0);
		Dout: out std_logic_vector(11 downto 0);
		iAddr: in std_logic_vector(N-1 downto 0);
		Addr: in std_logic_vector(N-1 downto 0));
end buf;

architecture arch of buf is
	type ram_t is array(0 to (2**N)-1) of std_logic_vector(11 downto 0);
	signal ram: ram_t;	-- Uninitialized!
	signal addrRegi, addrRego: std_logic_vector(N-1 downto 0);
begin

	Dout <= ram(to_integer(unsigned(addrRego)));
	process(clk)
	begin
		if rising_edge(clk) then
			addrRegi <= iAddr;-- Inferring BRAM.........
			addrRego <= Addr;-- Inferring BRAM.........
			if (en = '1') then
				ram(to_integer(unsigned(addrRegi))) <= Din;
			end if;
		end if;
	end process;
end arch;
