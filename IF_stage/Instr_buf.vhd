-------------------------------------------------------------------------------
--
-- Title       : Instr_buf
-- Design      : ese345proj1part1
-- Author      : harry.lin@stonybrook.com
-- Company     : Stony Brook
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/ese345proj1/ese345proj1part1/src/Instr_buf.vhd
-- Generated   : Wed Nov 26 18:23:32 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
   
	
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InstructionBuffer is
    port(
        clk : in std_logic;
        
        -- PIPELINE INTERFACE (Read) ------------------------
        -- pc drive this input
        pc_addr : in unsigned(5 downto 0); 
        
        -- instruction goes to decode next
        instruction : out std_logic_vector(24 downto 0);

        -- TESTBENCH INTERFACE (Write)
        -- signals are ONLY used by the Testbench to fill the buffer
        load_enable : in std_logic;
        load_addr : in unsigned(5 downto 0);
        load_data: in std_logic_vector(24 downto 0)
    );
end entity InstructionBuffer;

architecture behavioral of InstructionBuffer is

    -- 64 instructions, each 25 bits wide
    type instr_memory is array(0 to 63) of std_logic_vector(24 downto 0);
    
    -- Initialize to zeros (NOPs)
    signal mem : instr_memory := (others => (others => '0'));

begin

    -- asynch read
    -- instruction is updated as soon as PC changes							
    instruction <= mem(to_integer(pc_addr)); -- unsigned to integer array index

    -- synch write
    -- ssed by Testbench to load the program file into memory
    process(clk)
    begin
        if rising_edge(clk) then
            if load_enable = '1' then
				-- write to memory
                mem(to_integer(load_addr)) <= load_data;
            end if;
        end if;
    end process;

end architecture behavioral;
