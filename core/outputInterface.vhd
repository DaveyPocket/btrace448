library ieee;
use ieee.std_logic_1164.all;

entity outputInteface is
	port(clk, rst: in std_logic;
		get_pixel: out std_logic; -- Status signal
		pixel_x, pixel_y: out std_logic_vector(9 downto 0); -- Address read signal
		din: in std_logic_vector(11 downto 0); -- RGB in 1
		overlay: in std_logic_vector(11 downto 0); -- RGB in 2
		hsync, vsync: out std_logic;
		rgb: out std_logic_vector(11 downto 0));
end outputInterface;

architecture arch of outputInterface is
	signal video_on, p_tick: std_logic;
	signal s_rgb: std_logic_vector(11 downto 0);
begin
	-- VGA sync generator
	vga_sync_dev: entity work.vga_sync port map(clk, rst, hsync, vsync, video_on, p_tick, pixel_x, pixel_y);

	-- Pixel buffer
	process(clk, rst)
	begin
		if rst = '1' then
			s_rgb <= (others => '0');
		elsif rising_edge(clk) then
			s_rgb <= din;
		end if;
	end process;

	-- Concurrent signal assignment
	get_pixel <= p_tick;
	rgb <= s_rgb when (video_on = '1' and overlay = '0') else 
		   overlay when (video_on = '1' and overlay = '1') else (others => '0');
end arch;
