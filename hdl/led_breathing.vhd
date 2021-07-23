library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Fits the Lattice iCEstick FPGA board
entity led_breathing is
  generic (
    
    -- PWM and duty cycle counter bit length
    pwm_bits : integer := 8;

    -- Sawtooth counter bit length
    cnt_bits : integer := 25;

    -- PWM clock divider max count
    -- pwm_freq = 12 MHz / (2**8 - 1) / 47 = 1001 Hz
    clk_cnt_len : positive := 47
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic; -- Pullup

    led_1 : out std_logic;
    led_2 : out std_logic;
    led_3 : out std_logic;
    led_4 : out std_logic;
    led_5 : out std_logic
  );
end led_breathing;

architecture str of led_breathing is

  attribute syn_noprune : boolean;
  attribute syn_noprune of str : architecture is true;
--  attribute syn_noprune of i_bram_2048x2_0 : label is true;

  signal rst : std_logic;
  signal cnt : unsigned(cnt_bits - 1 downto 0);
  signal pwm_out : std_logic;
  signal duty_cycle : unsigned(pwm_bits - 1 downto 0);

  -- Use MSBs of counter for sine ROM address input
  alias addr is cnt(cnt'high downto cnt'length - pwm_bits);

  --! delay RAM signals
  constant ram_depth : natural := 2048;
  constant ram_qty : natural := 15;
  signal r_wen : std_logic_vector(ram_qty-1 downto 0);
  type t_addr is array (0 to ram_qty-1) of integer range 0 to ram_depth-1;
  signal r_waddr : t_addr;
  signal r_raddr : t_addr;
  type t_data is array (0 to ram_qty-1) of std_logic_vector(1 downto 0);
  signal r_wdata : t_data;
  signal r_rdata : t_data;

begin

  RESET : entity work.reset(rtl)
    port map (
      clk => clk,
      rst_n => rst_n,
      rst => rst
    );

  PWM : entity work.pwm(rtl)
    generic map (
      pwm_bits => pwm_bits,
      clk_cnt_len => clk_cnt_len
    )
    port map (
      clk => clk,
      rst => rst,
      duty_cycle => duty_cycle,
      pwm_out => pwm_out
    );
  
  COUNTER : entity work.counter(rtl)
    generic map (
      counter_bits => cnt'length
    )
    port map (
      clk => clk,
      rst => rst,
      count_enable => '1',
      counter => cnt
    );

  SINE_ROM : entity work.sine_rom(rtl)
    generic map (
      data_bits => pwm_bits,
      addr_bits => pwm_bits
    )
    port map (
      clk => clk,
      addr => addr,
      data => duty_cycle
    );


  

  p_wr_rd_proc : process(clk) begin
    if rising_edge(clk) then
      for k in 0 to ram_qty-1 loop

        if rst = '1' then
          r_wen(k) <= '0';
          r_waddr(k) <= 0; 
          r_raddr(k) <= 0; --! offset the read pointer by half of the depth
          r_wdata(k) <= (others => '0'); 
        else

          if (k = 0) then
            r_wen(k) <= not(r_wen(k));
            if (r_wen(k) = '1') then
              r_wdata(k) <= r_wdata(k)(r_wdata(k)'high-1 downto r_wdata(k)'low) & pwm_out;
            else
              r_wdata(k) <= r_wdata(0);
            end if;

          else
            if ( ( r_waddr(k-1) mod 4 ) = 0 ) then
              r_wen(k) <= '1';
              r_waddr(k) <= r_waddr(k) + 1;
              r_wdata(k) <= r_rdata(k-1);
            elsif ( ( r_waddr(k-1) mod 8 ) = 0 ) then
              r_raddr(k) <= r_raddr(k) + 1;
            else 
              r_wen(k) <= '0';
              r_waddr(k) <= r_waddr(k);
              r_raddr(k) <= r_raddr(k);
              r_wdata(k) <= r_wdata(k);
            end if;

          end if;

        end if;
        
      end loop;
    end if;
  end process;
  
  --! infer SB_RAM2048x2 block instances 
  ram_gen : for k in 0 to ram_qty-1 generate
    i_2048x2 : entity work.bram_two_port_simple(rtl)
    generic map(
      ram_width => 2, -- integer;
      ram_depth => 2048 -- integer
    )
    port map(
      --! write-side
      wr_clk => clk, -- in std_logic;
      wr_en => r_wen(k), -- std_logic;
      wr_addr => r_waddr(k), -- in integer range 0 to ram_depth;
      din => r_wdata(k), -- in std_logic_vector(ram_width - 1 downto 0);
      --! read-side
      rd_clk => clk, -- in std_logic;
      rd_addr => r_raddr(k), -- in integer range 0 to ram_depth;
      dout => r_rdata(k) -- out std_logic_vector(ram_width - 1 downto 0)
    );
  end generate ram_gen;

  led_1 <= r_rdata(0)(r_rdata(0)'high);
  led_2 <= r_rdata(3)(r_rdata(3)'high);
  led_3 <= r_rdata(7)(r_rdata(7)'high);
  led_4 <= r_rdata(11)(r_rdata(11)'high);
  led_5 <= r_rdata(14)(r_rdata(14)'high);


end architecture;