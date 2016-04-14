library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity textDevice is
	port(clk: in std_logic;
	     	row: in std_logic_vector(4 downto 0);
		col: in std_logic_vector(6 downto 0);
		pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		dev_on: out std_logic;
		rgb: out std_logic_vector(2 downto 0));
end textDevice;

architecture arch of textDevice is
	constant char: std_logic_vector(6 downto 0) := "1000001"; -- 0x41, 'A'
	signal dout: std_logic_vector(7 downto 0);
	signal ison: std_logic;
	signal addr: std_logic_vector(10 downto 0);
begin
	-- This should make a stripe of letter As down the screen
	addr <= char & pixel_y(3 downto 0);
	fr: entity work.font_rom port map(clk, addr, dout);
	
	ison <= '1' when dout(to_integer(unsigned(pixel_x(2 downto 0)))) = '1' and pixel_x(9 downto 3) = col else '0';
	rgb <= "111" when ison = '1' else "000";
	dev_on <= ison;
end arch;
