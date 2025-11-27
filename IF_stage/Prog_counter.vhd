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
-- Generated   : Wed Nov 26 19:01:22 2025
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

entity PC_Register is
    port(
        clk : in  std_logic;
        rst : in  std_logic; 
        																  
		-- input to prevent PC from updating (stalls/bubble)
        pc_freeze : in std_logic; 
        
        -- outputs the current instruction address 
		-- into pc_addr input of instruction buffer
        pc_out : out unsigned(5 downto 0) 										   
    );
end entity PC_Register;

architecture behavioral of PC_Register is
    -- hold pc value, initialized to 0
    signal pc_current : unsigned(5 downto 0) := (others => '0'); 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset to the first instruction address (0)
                pc_current <= (others => '0'); 
            elsif pc_freeze = '0' then -- else increment pc			  
                -- use lower 6 bits, handles the 64 instruction wrapping
                pc_current <= pc_current + 1; 
            end if;
        end if;
    end process;

    -- output current PC value
    pc_out <= pc_current;

end architecture behavioral;