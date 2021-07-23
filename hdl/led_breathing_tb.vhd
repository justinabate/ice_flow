library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

entity led_breathing_tb is
end led_breathing_tb; 

architecture sim of led_breathing_tb is

  constant clk_hz : integer := 100e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst_n : std_logic := '0';
  signal led : std_logic;

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.led_breathing(str)
    generic map (
      pwm_bits => 8,
      cnt_bits => 16,
      clk_cnt_len => 1
    )
    port map (
      clk => clk,
      rst_n => rst_n,
      led_1 => open,
      led_2 => open,
      led_3 => open,
      led_4 => open,
      led_5 => led
    );

  SEQUENCER : process
  begin
    rst_n <= '1';
    wait for 1400 us;

    report "Simulation finished. Check the waveform.";
    finish;
  end process;

end architecture;