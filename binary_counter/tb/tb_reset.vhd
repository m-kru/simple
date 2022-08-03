library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.math_real.ceil;
   use ieee.math_real.log2;

library simple;


entity tb_binary_counter_reset is
end entity;


architecture test of tb_binary_counter_reset is

   constant C_MAX_VALUE : positive := 11;
   constant C_WIDTH : positive := integer(ceil(log2(real(C_MAX_VALUE))));

   constant C_CLK_PERIOD : time := 10 ns;
   signal clk : std_logic := '0';

   signal d, q : unsigned(C_WIDTH - 1 downto 0);
   signal rst, stb  : std_logic := '0';
   signal min, max : std_logic;

begin

   clk <= not clk after C_CLK_PERIOD / 2;


   DUT : entity simple.Binary_Counter
   generic map (
      MAX_VALUE => C_MAX_VALUE
   )
   port map (
      clk_i => clk,
      rst_i => rst,
      d_i   => d,
      stb_i => stb,
      q_o   => q,
      min_o => min,
      max_o => max
   );


   main : process is

   begin
      wait for C_CLK_PERIOD;
      d <= to_unsigned(0, C_WIDTH);
      stb <= '1';
      wait for C_CLK_PERIOD;
      stb <= '0';

      wait for (C_MAX_VALUE - 1) * C_CLK_PERIOD;
      rst <= '1';
      wait for C_CLK_PERIOD;
      rst <= '0';

      assert min = '0' report "min = " & to_string(min) severity failure;
      assert max = '0' report "max = " & to_string(max) severity failure;
      assert q = 0 report "q = " & to_string(q) severity failure;

      wait for 3 * C_CLK_PERIOD;
      std.env.finish;
   end process;

end architecture;
