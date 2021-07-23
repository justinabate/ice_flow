-- bram_two_port_simple a.k.a. 'simple dual port'

-- Simple dual port reserves: 
--    Both data-in  ports (IN_A & IN_B)   for write operations (renamed din)
--       Depends on {wr_clk, wr_en, wr_addr}
--    Both data-out ports (OUT_A & OUT_B) for read  operations (renamed dout)
--       Depends on {rd_clk, rd_addr}
--
-- Xilinx RAMB36E1 (36Kb) - valid SDP DxW configurations are listed in UG473
--   64K x 1 (cascaded w/ adjacent RAMB36E1), 
--   32K x 1, 
--   16K x 2, 
--    8K x 4, 
--    4K x 9, 
--    2K x 18, 
--    1K x 36,
--    512 x 72


library ieee;
use ieee.std_logic_1164.all;

entity bram_two_port_simple is
  generic (
    ram_width : integer;
    ram_depth : integer
  );
  port (
    wr_clk : in std_logic;
    rd_clk : in std_logic;
    wr_en : in std_logic;
    wr_addr : in integer range 0 to ram_depth-1;
    rd_addr : in integer range 0 to ram_depth-1;
    din : in std_logic_vector(ram_width - 1 downto 0);
    dout : out std_logic_vector(ram_width - 1 downto 0)
  );
end bram_two_port_simple;

architecture rtl of bram_two_port_simple is

  type ram_type is array (0 to ram_depth - 1) of std_logic_vector(ram_width - 1 downto 0);

  signal ram : ram_type;

begin

  WRITE_PROC : process(wr_clk)
  begin
    if rising_edge(wr_clk) then
      if wr_en = '1' then
        ram(wr_addr) <= din;
      end if;
    end if;
  end process;

  READ_PROC : process(rd_clk)
  begin
    if rising_edge(rd_clk) then
      dout <= ram(rd_addr);
    end if;
  end process;

end architecture;