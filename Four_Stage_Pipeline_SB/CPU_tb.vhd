-------------------------------------------------------------------------------
--
-- Title       : CPU_tb
-- Design      : FourStagePipeline
-- Author      : saphal.baral@stonybrook.edu
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/My_Designs/FourStagePipeline/FourStagePipeline/src/CPU_tb.vhd
-- Generated   : Sun Nov 30 01:00:28 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity CPU_tb is
end entity;

architecture tb of CPU_tb is

    constant CYCLE_TIME : time := 10 ns;

    -- DUT ports
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal load_enable : std_logic := '0';
    signal load_addr   : unsigned(5 downto 0) := (others => '0');
    signal load_data   : std_logic_vector(24 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------
    -- DUT INSTANTIATION
    --------------------------------------------------------------------
    DUT : entity work.CPU_Top_Level
        port map(
            clk         => clk,
            rst         => rst,
            load_enable => load_enable,
            load_addr   => load_addr,
            load_data   => load_data
        );

    --------------------------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CYCLE_TIME / 2;
            clk <= '1';
            wait for CYCLE_TIME / 2;
        end loop;
    end process clk_process;

    --------------------------------------------------------------------
    -- STIMULUS: LOAD PROGRAM + RUN
    --------------------------------------------------------------------
    stim_proc : process
        file prog_file : text open read_mode is "program.txt";
        variable L      : line;
        variable instr  : std_logic_vector(24 downto 0);
        variable addr_v : unsigned(5 downto 0) := (others => '0');
        variable i      : integer;
    begin
        ----------------------------------------------------------------
        -- 1) Hold reset high, load instructions into Instruction_Buffer
        ----------------------------------------------------------------
        rst         <= '1';
        load_enable <= '0';
        load_addr   <= (others => '0');
        load_data   <= (others => '0');

        -- small wait so everything initializes
        wait for 3 * CYCLE_TIME;

        addr_v := (others => '0');

        -- For each line in program.txt:
        while not endfile(prog_file) loop
            readline(prog_file, L);

            -- Read a 25-bit std_logic_vector like "010101..."
            read(L, instr);

            load_addr   <= addr_v;
            load_data   <= instr;
            load_enable <= '1';

            -- Write happens inside Instruction_Buffer on rising edge clk
            wait until rising_edge(clk);

            addr_v := addr_v + 1;
        end loop;

        -- Stop loading
        load_enable <= '0';

        -- One more cycle under reset to be safe
        wait until rising_edge(clk);
        rst <= '0';  -- release reset, start execution from PC = 0

        ----------------------------------------------------------------
        -- 2) Let the pipeline run for N cycles
        ----------------------------------------------------------------
        -- Choose N big enough to execute your program + drain pipeline.
        for i in 0 to 200 loop
            wait until rising_edge(clk);
        end loop;

        ----------------------------------------------------------------
        -- 3) End simulation
        ----------------------------------------------------------------
        report "Simulation finished after 200 cycles." severity note;
        wait;
    end process stim_proc;

end architecture;
