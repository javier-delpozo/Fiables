--------------------------------------------------------------------------------
--
-- Title       : 	Debounce Logic module
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : debouncer.vhd
-- Generated   : 7 February 2022
--------------------------------------------------------------------------------
-- Description : Given a synchronous signal it debounces it.
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 07/02/22  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;


architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
	-- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    
    signal ena_count, time_elapsed : std_logic;
    
    signal count : unsigned(c_counter_width-1 downto 0);
    constant c_max_cycles : unsigned(c_counter_width-1 downto 0) := to_unsigned(c_cycles, c_counter_width);
    
    
    
    
    type t_states is (IDLE, BTN_PRS, BTN_UNPRS, VALID);
    signal current_state, next_state: t_states;
    -- -----------------------------------------------------------------------------
    -- Declarar un tipo para los estados de la fsm usando type
    -- -----------------------------------------------------------------------------
    
    
begin
    --Timer
    timer: process (clk, rst_n)
    begin
    -- -----------------------------------------------------------------------------
	-- Completar el timer que genera la seÃ±al de time_elapsed para trancionar en 
	-- las mÃ¡quinas de estados
	-- -----------------------------------------------------------------------------
        if rst_n = '0' then
            count <= (others => '0');
            time_elapsed <= '0';
        else
            if rising_edge(clk) then
                if ena_count = '1'  then
                    if count < c_max_cycles - 2 then
                        count <= count +1;
                        time_elapsed <= '0';
                    else
                        time_elapsed <= '1';
                        count <= (others => '0');
                    end if;
                else  
                    time_elapsed <= '0';
                    count <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    --FSM Register of next state
    fsm_register: process (clk, rst_n)
    begin
    -- -----------------------------------------------------------------------------
	-- Completar 
	-- -----------------------------------------------------------------------------
        if rst_n = '0' then
            current_state <= IDLE;
        else
            if rising_edge(clk) then
                current_state <= next_state;
            end if;
        end if;
    end process;
	
    fsm_comb: process (current_state, ena, sig_in, time_elapsed)--sensitivity list)
    begin
    -- -----------------------------------------------------------------------------
	-- Completar el bloque combinacional de la FSM usar case when
	-- -----------------------------------------------------------------------------
        if ena = '0' then
            next_state <= IDLE;
            debounced <= '0';
            ena_count <= '0';
        else
            next_state <= current_state;
            debounced <= '0';
            ena_count <= '0';
            case current_state is
                when IDLE =>
                    if sig_in = '1' then
                        next_state <= BTN_PRS;
                    end if;
                when BTN_PRS =>
                    ena_count <= '1';
                    if time_elapsed = '1' then
                        if sig_in = '1' then
                            next_state <= VALID;
                            debounced <= '1';
                            ena_count <= '0';
                        else
                            next_state <= IDLE;
                            ena_count <= '0';
                        end if;
                    end if;
                when VALID =>
                    if sig_in = '0' then
                        next_state <= BTN_UNPRS;
                    end if;
                when BTN_UNPRS => 
                    ena_count <= '1';
                    if time_elapsed = '1' then
                        if sig_in = '1' then
                            next_state <= VALID;
                            ena_count <= '0';
                        else
                            next_state <= IDLE;
                            ena_count <= '0';
                        end if;
                    end if;
            end case;
       end if;
                
      
    end process;
end Behavioural;