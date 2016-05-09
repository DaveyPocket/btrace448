-- Btrace 448
-- Debounce for button input
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(DD, k: integer);
	port(input, clk, reset: in std_logic;
			output: out std_logic);
end debouncer;

architecture circuit of debouncer is
	component debounceCounter
		generic(k: integer);
		port(en, rst, clk: in std_logic;
		Q: out std_logic_vector(k-1 downto 0));
	end component;

	component dff
		port(D, clk, set, rst: in std_logic;
		Q: out std_logic);
	end component;
	signal previous_input: std_logic;
	signal count: std_logic;
	signal Q: std_logic_vector(k-1 downto 0);
	signal mux_out: std_logic;
	signal inReset: std_logic;
	signal force1: std_logic;
	signal onCompare: std_logic;
	signal bufOut: std_logic;
begin
	flip:	dff port map (input, clk, '0', '0', previous_input);
	flop:	dff port map (mux_out, clk, '0', '0', bufOut);
	sandal:	dff port map (count, clk, force1, inReset, count);
	counter: debounceCounter generic map (k) port map (count, inReset, clk, Q);

	force1 <= (input xor previous_input) and not(count);
	inReset <= reset or onCompare;
	onCompare <= '1' when (to_integer(unsigned(Q)) = (DD - 1)) else '0';
	mux_out <= input when count = '0' else bufOut;
	output <= bufOut;
end circuit;
