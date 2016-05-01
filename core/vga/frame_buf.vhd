library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_buf is
	generic(inputWidth: integer := 9;
		inputHeight: integer := 8);
	port(clk: in std_logic;
		en: in std_logic;
		Din: in std_logic_vector(11 downto 0);
		Dout: out std_logic_vector(11 downto 0);
		addr_x: in std_logic_vector(inputWidth-1 downto 0);
		addr_y: in std_logic_vector(inputHeight-1 downto 0));
end frame_buf;

architecture arch of frame_buf is
	signal t_addr: std_logic_vector((inputWidth + inputHeight) - 1 downto 0);
begin
	t_addr <= addr_y & addr_x;

	b: entity work.buf generic map(inputWidth + inputHeight) port map(clk, en, Din, Dout, t_addr);
end arch;