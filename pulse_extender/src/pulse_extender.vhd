-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2021 Michał Kruszewski

library ieee;
   use ieee.std_logic_1164.all;

-- Pulse_Extender extends a pulse by EXTEND_VALUE clock ticks.
--
-- If there are 2 consecutive pulses, and the gap between them is less than
-- or equal to EXTEND_VALUE, then the gap will not be seen on the output.
-- This can be used as a filtering functionality.
-- Example:
--         _   _   _   _   _   _   _   _   _   _   _
-- clk : _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
--             _______         _______________________
-- d   : _____|       |_______|
--             _______________________________________
-- q   : _____|
entity Pulse_Extender is
   generic (
      WIDTH            : positive;
      EXTEND_VALUE     : positive;
      INIT_VALUE       : std_logic := '0';
      REGISTER_OUTPUTS : boolean := true
   );
   port (
      clk_i     : in  std_logic;
      clk_en_i  : in  std_logic := '1';
      en_mask_i : in  std_logic_vector(WIDTH - 1 downto 0) := (others => '1');
      d_i       : in  std_logic_vector(WIDTH - 1 downto 0);
      q_o       : out std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE)
   );
end entity;


architecture rtl of Pulse_Extender is

   subtype t_counter is natural range 0 to EXTEND_VALUE - 1;
   type t_counter_vector is array (natural range <>) of t_counter;
   signal counters : t_counter_vector(WIDTH - 1 downto 0) := (others => 0);

   signal prev_d : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE);

   signal q : std_logic_vector(WIDTH - 1 downto 0) := (others => INIT_VALUE);

begin

   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if clk_en_i = '1' then
            prev_d <= d_i;

            for i in WIDTH - 1 downto 0 loop
               if d_i(i) = '0' then
                  if counters(i) = 0 then
                     q(i) <= '0';
                  else
                     counters(i) <= counters(i) - 1;
                  end if;
               end if;

               if en_mask_i(i) = '1' and prev_d(i) = '0' and d_i(i) = '1' then
                  q(i) <= '1';
                  counters(i) <= EXTEND_VALUE - 1;
               end if;
            end loop;
         end if;
      end if;
   end process;


   output_registers : if REGISTER_OUTPUTS generate

      process (clk_i) is
      begin
         if rising_edge(clk_i) then
            q_o <= d_i or q;
         end if;
      end process;

   else generate

      q_o <= d_i or q;

   end generate;

end architecture;
