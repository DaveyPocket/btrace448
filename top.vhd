library ieee;
use ieee.std_logic_1164.all;

entity top is
	port(clk, rst: in std_logic;
		BTNS, BTNU, BTND, BTNL, BTNR: in std_logic;
		rgb: out std_logic_vector(11 downto 0);
		led: out std_logic_vector(11 downto 0);
		hsync, vsync: out std_logic);
end top;

architecture arch of top is
	constant int,frac: integer := 16;
	signal BTNSd, BTNUd, BTNDd, BTNLd, BTNRd: std_logic;
	signal video_on, p_tick: std_logic;
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal gen_px, gen_py: std_logic_vector(9 downto 0);
	signal frame_buf_rgb: std_logic_vector(11 downto 0);
	signal overlay: std_logic_vector(11 downto 0);
	signal addr_buf_x, addr_buf_y: std_logic_vector(9 downto 0);
	signal en_buf: std_logic;
	signal z_to_buf: std_logic;
begin
--- Instantiation
	--Input Interface - debounces and rising-edge detectors.
	--inInterface: entity work.inputInterface port map(clk, rst, BTNS, BTNU, BTND, BTNL, BTNR, BTNSd, BTNUd, BTNDd, BTNLd, BTNRd);

	-- Output interface: VGA sync generator, output control, address generator
	outputInterface: entity work.outputInterface port map(clk, rst, p_tick, pixel_x, pixel_y, frame_buf_out, overlay, hsync, vsync, rgb);

	-- Frame buffer
	fb: entity work.frame_buf port map(clk, en_buf, x"000", frame_buf_out, pixel_x(9 downto 1), pixel_y(8 downto 1));

	-- Ray generator
	rg: entity work.raygen generic map(int, frac) port map(clk, rst, <set_cam>, <inc_x>, <inc_y>, <clr_x>, <clr_y>, <mv_x>, <mv_y>, <mv_z>, gen_px, gen_py);

--- Concurrent assignments
	en_buf <= not(p_tick) and z_to_buf;
--- Top level components
-- TODO: p_tick may be logic 1 for more than 1 clock cycle...
	addr_buf_x <= pixel_x when p_tick = '1' else gen_px;
	addr_buf_y <= pixel_y when p_tick = '1' else gen_py;

	
end arch;
