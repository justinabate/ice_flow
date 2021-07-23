library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

entity counter is
  generic (
    counter_bits : integer
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    count_enable : std_logic;
    counter : out unsigned(counter_bits - 1 downto 0)
  );
end counter; 

architecture rtl of counter is

  signal counter_i : unsigned(counter'range);
  
begin

  counter <= counter_i;
  
  COUNTER_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter_i <= (others => '0');
        
      else
        if count_enable = '1' then
          counter_i <= counter_i + 1;
        end if;
        
      end if;
    end if;
  end process;

end architecture;