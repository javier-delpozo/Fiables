--------------------------------------------------------------------------------
--
-- Title       : 	Testbench for the debounce logic module
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : tb_debouncer.vhd
-- Generated   : 7 February 2022
--------------------------------------------------------------------------------
-- Description : This testbench generates syncronous signals with variable 
--    bounce duration
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 07/02/22  :| First version

-- -----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_debouncer is
end tb_debouncer;

architecture testBench of tb_debouncer is
  component debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic;
        clk         : in    std_logic;
        ena         : in    std_logic;
        sig_in      : in    std_logic;
        debounced   : out   std_logic
    ); 
  end component;
  
  constant timer_debounce : integer := 10; --ms
  constant freq : integer := 100_000; --KHZ
  constant clk_period : time := (1 ms/ freq);
  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk         :   std_logic := '0';
  signal  ena         :   std_logic := '1';
  signal  BTN_sync      :   std_logic := '0';
  -- Output
  signal  debounced   :   std_logic;
  --Senhal fin de simulacion
  signal  fin_sim : boolean := false;
  
begin
  UUT: debouncer
    generic map (
      g_timeout        => timer_debounce,
      g_clock_freq_KHZ => freq
    )
    port map (
      rst_n     => rst_n,
      clk       => clk,
      ena       => ena,
      sig_in    => BTN_sync,
      debounced => debounced
    );
	
  --Proceso de generacion del reloj 
  clock: process
  begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      if fin_sim = true then
        wait;
      end if;
  end process;
  
  process is 
  begin
		-- Secuencia de reset
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		rst_n <= '1';                         -- Reset inactivo
		wait until clk'event and clk = '1';
		rst_n <= '0';                         -- Reset activo
		wait until clk'event and clk = '1';
		rst_n <= '1';                         -- Reset inactivo
		--Fin de secuencia de reset
    
    -- Btn on with noise
    wait for 50 ns;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 100 ns;
    wait until rising_edge(clk);
    BTN_sync <= '0';
    wait for 100 ns;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 20 ms;
    
    -- False boton off 
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 50 ns;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 20 ms;
    
    -- Boton off with noise
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 50 ns;
    wait until rising_edge(clk);
    BTN_sync <='1';
    wait for 50 ns;
    wait until rising_edge(clk);
    BTN_sync <='0';
    wait for 20 ms;
    
    wait until rising_edge(clk);
	-- Fin simulacion
	fin_sim <= true;			 
  end process;
end testBench;
