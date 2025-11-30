-------------------------------------------------------------------------------
--
-- Title       : 
-- Design      : Register_File_TB
-- Author      : Harry Lin and Saphal Baral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : 
-- Generated   : 
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : A functional testbench for the Register File that 
--	generates clock, asserts reset, writes sample values to registers, 
--	and confirms correct read-back and forwarding behavior.
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity Register_File_TB is
end Register_File_TB;

architecture tb_arch of Register_File_TB is

    -- Stimulus
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal reg_write  : std_logic := '0';

    signal rs1_index  : unsigned(4 downto 0) := (others => '0');
    signal rs2_index  : unsigned(4 downto 0) := (others => '0');
    signal rs3_index  : unsigned(4 downto 0) := (others => '0');

    signal rd_index   : unsigned(4 downto 0) := (others => '0');
    signal rd_data    : std_logic_vector(127 downto 0) := (others => '0');

    -- Observed outputs
    signal rs1_data   : std_logic_vector(127 downto 0);
    signal rs2_data   : std_logic_vector(127 downto 0);
    signal rs3_data   : std_logic_vector(127 downto 0);

    -- timing constant
    constant CLK_PERIOD : time := 10 ns;

begin

    UUT : entity Register_File
        port map(
            clk => clk,
            rst => rst,
            reg_write => reg_write,

            rs1_index => rs1_index,
            rs2_index => rs2_index,
            rs3_index => rs3_index,

            rd_index => rd_index,
            rd_data => rd_data,

            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rs3_data => rs3_data
        );
																		 
    clk_process : process -- generates clock
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

																		
    --  Test Stimulus 
    stim_proc : process
    begin
        
        -- Reset sequence
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
																		 
        -- SHOULD NOT WRITE, reg write = 0	
        reg_write <= '0';
        rd_index  <= "00011";  -- write target: R3
        rd_data   <= x"AAAA0000000000000000000000000000";
        wait for CLK_PERIOD;

        -- verify register stays zero
        rs2_index <= "00011";
        wait for CLK_PERIOD;
		
		
        -- Enable write and update register R3						 
        reg_write <= '1';
        wait for CLK_PERIOD;

        -- now read R3 again
        rs2_index <= "00011";
        wait for CLK_PERIOD;
																		 
        -- Test bypass (read-after-write in same cycle)		 
        rd_index  <= "00101";  -- write to R5
        rd_data   <= x"FFFFFFFF000000000000000000000000";
        rs1_index <= "00101";  -- read from R5 simultaneously
        reg_write <= '1';
        wait for 2*CLK_PERIOD;
																		 
        -- End simulation												 
        std.env.finish;
    end process;

end tb_arch;
