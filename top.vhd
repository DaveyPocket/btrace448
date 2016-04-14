library ieee;
use ieee.std_logic_1164.all;

entity top is
	port(clk, rst: in std_logic;
		BTNS, BTNU, BTND, BTNL, BTNR: in std_logic;
		rgb: out std_logic_vector(11 downto 0);
		hsync, vsync: out std_logic);
end top;

architecture arch of top is
	signal BTNSd, BTNUd, BTNDd, BTNLd, BTNRd: std_logic;
	signal video_on, p_tick: std_logic;
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
begin
	Input Interface - debounces and rising-edge detectors.
	--inInterface: entity work.inputInterface port map(clk, rst, BTNS, BTNU, BTND, BTNL, BTNR, BTNSd, BTNUd, BTNDd, BTNLd, BTNRd);

	-- VGA sync generator
	vgasyncgen: entity work.vga_sync port map(clk, rst, hsync, vsync, video_on, p_tick, pixel_x, pixel_y);

	-- Frame buffer
	fb: entity work.frame_buf port map(clk, '0', x"000", rgb, pixel_x(9 downto 1), pixel_y(8 downto 1));

end arch;
