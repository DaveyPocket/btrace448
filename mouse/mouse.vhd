library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- PS2_clk F4
-- PS2_data B2
entity mouse is
	port(clk, rst: in std_logic;
		mdat, mclk: in std_logic;
		led: out std_logic_vector(15 downto 0));
		--segout: out std_logic_vector(7 downto 0);
		--an: out std_logic_vector(7 downto 0));
end mouse;

architecture arch of mouse is
	signal mclkout: std_logic;
	signal shift_reg, result_reg: std_logic_vector(32 downto 0);
	signal shift_en: std_logic;
	signal din: std_logic;
	signal invclk: std_logic;
	signal counter_out: std_logic_vector(5 downto 0);
	signal done, okay: std_logic;
	signal status, v_x, v_y: std_logic_vector(7 downto 0);
	--signal pb1, pb2, pb3: std_logic;
	--signal p1, p2, p3: std_logic_vector(8 downto 0);
begin
	rd: entity work.red port map(invclk, rst, clk, mclkout); -- PS2 devices are active on falling edge
	count: entity work.counter generic map(6) port map(clk, rst, done, mclkout, '0', "000000", counter_out);
	done <= '1' when counter_out = "100001" else '0';
	invclk <= not(mclk);
	din <= mdat;
	led <= status&v_x;
	shift_en <= mclkout;
	status <= result_reg(8 downto 1);
	v_x <= result_reg(19 downto 12);
	v_y <= result_reg(30 downto 23);
	--pb1 <= result_reg(9);
	--pb2 <= result_reg(20);
	--pb3 <= result_reg(31);
	process(clk, rst)
	begin
		if rst = '1' then
			shift_reg <= (others => '0');
			result_reg <= (others => '0');
		elsif rising_edge(clk) then
			if shift_en = '1' then
				shift_reg <= din & shift_reg(32 downto 1);
			end if;
			if (done and okay) = '1' then
				result_reg <= shift_reg;
			end if;
		end if;
	end process;

	-- Parity (odd)
--	p1 <= status + 1 when pb1 = '1' else status;
--	p2 <= v_x + 1 when pb2 = '1' else v_x;
--	p3 <= v_y + 1 when pb3 = '1' else v_y;
--	okay <= '1' when (p1(0) and p2(0) and p3(0)) = '1' else '0';
	okay <= '1';
end arch;
