-- Btrace 448
-- VGA Sync
--
-- Bradley Boccuzzi
-- 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity vga_sync is
   port(
      clk, reset: in std_logic;
      hsync, vsync: out std_logic;
      video_on, p_tick: out std_logic;
      pixel_x, pixel_y: out std_logic_vector (9 downto 0)
    );
end vga_sync;

architecture arch of vga_sync is
   -- VGA 640-by-480 sync parameters
   constant HD: integer:=639; --horizontal display area
   constant HF: integer:=16 ; --h. front porch
   constant HB: integer:=48 ; --h. back porch
   constant HR: integer:=96 ; --h. retrace
   constant VD: integer:=479; --vertical display area
   constant VF: integer:=10;  --v. front porch
   constant VB: integer:=33;  --v. back porch
   constant VR: integer:=2;   --v. retrace
   
   constant THREE	: std_logic_vector(1 downto 0) := "11";
   
   -- sync counters
   signal v_count_reg, v_count_next: std_logic_vector(9 downto 0);
   signal h_count_reg, h_count_next: std_logic_vector(9 downto 0);
   -- output buffer
   signal v_sync_reg, h_sync_reg: std_logic;
   signal v_sync_next, h_sync_next: std_logic;
   -- status signal
   signal h_end, v_end, pixel_tick: std_logic;
   
   signal count_3	: std_logic_vector(1 downto 0);
   
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         v_count_reg <= (others=>'0');
         h_count_reg <= (others=>'0');
         v_sync_reg <= '1';
         h_sync_reg <= '1';
      elsif (clk'event and clk='1') then
         v_count_reg <= v_count_next;
         h_count_reg <= h_count_next;
         v_sync_reg <= v_sync_next;
         h_sync_reg <= h_sync_next;
      end if;
   end process;
   
   -- circuit to generate 25 MHz enable tick
	process (clk, reset)
	begin
		if reset='1' then
			count_3 <= (others =>'0');
		elsif rising_edge(clk) then 
			count_3 <= count_3 + 1;  
		end if;
	end process;
  
   -- 25 MHz pixel tick
   pixel_tick <= '1' when count_3 = THREE else '0';
   
   -- status
   h_end <=  -- end of horizontal counter
      '1' when h_count_reg=(HD+HF+HB+HR-1) else --799
      '0';
   v_end <=  -- end of vertical counter
      '1' when v_count_reg=(VD+VF+VB+VR-1) else --524
      '0';
   -- mod-800 horizontal sync counter
   process (h_count_reg,h_end,pixel_tick)
   begin
      if pixel_tick='1' then  -- 25 MHz tick
         if h_end='1' then
            h_count_next <= (others=>'0');
         else
            h_count_next <= h_count_reg + 1;
         end if;
      else
         h_count_next <= h_count_reg;
      end if;
   end process;
   -- mod-525 vertical sync counter
   process (v_count_reg,h_end,v_end,pixel_tick)
   begin
      if pixel_tick='1' and h_end='1' then
         if (v_end='1') then
            v_count_next <= (others=>'0');
         else
            v_count_next <= v_count_reg + 1;
         end if;
      else
         v_count_next <= v_count_reg;
      end if;
   end process;
   -- horizontal and vertical sync, buffered to avoid glitch
   h_sync_next <=
      '0' when (h_count_reg>=(HD+HF))           --656
           and (h_count_reg<=(HD+HF+HR-1)) else --751
      '1';
   v_sync_next <=
      '0' when (v_count_reg>=(VD+VF))           --490
           and (v_count_reg<=(VD+VF+VR-1)) else --491
      '1';
   -- video on/off
   video_on <=
      '1' when (h_count_reg<HD) and (v_count_reg<VD) else
      '0';
   -- output signal
   hsync <= h_sync_reg;
   vsync <= v_sync_reg;
   pixel_x <= std_logic_vector(h_count_reg);
   pixel_y <= std_logic_vector(v_count_reg);
   p_tick <= pixel_tick;
end arch;
