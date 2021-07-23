library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset is
  port (
    clk : in std_logic;
    rst_n : in std_logic; -- Pullup
    rst : out std_logic
  );
end reset; 

architecture rtl of reset is

  signal sreg : std_logic_vector(3 downto 0);

begin

  SREG_PROC : process(clk)
  begin
    if rising_edge(clk) then
      sreg <= sreg(sreg'high - 1 downto 0) & rst_n;
    end if;
  end process;

  RESET_PROC : process(sreg)
    constant all_ones : std_logic_vector(sreg'range) := (others => '1');
  begin

    if sreg = all_ones then
      rst <= '0';
    else
      rst <= '1';
    end if;

  end process;

end architecture;