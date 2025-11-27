-------------------------------------------------------------------------------
--
-- Title       : IFID register
-- Design      : ese345proj1part1
-- Author      : harry.lin@stonybrook.com
-- Company     : Stony Brook
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/ese345proj1/ese345proj1part1/src/IFID_Register.vhd
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

entity IFID_Register is
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Stall control (comes from hazard unit later)
        ifid_freeze : in std_logic;

        -- inputs from IF stage
        instruction_in : in std_logic_vector(24 downto 0);
        pc_in          : in unsigned(5 downto 0);

        -- outputs to ID stage
        instruction_out : out std_logic_vector(24 downto 0);
        pc_out          : out unsigned(5 downto 0)
    );
end entity IFID_Register;

architecture behavioral of IFID_Register is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                instruction_out <= (others => '0');
                pc_out <= (others => '0');

            elsif ifid_freeze = '0' then
                -- Normal operation: latch values
                instruction_out <= instruction_in;
                pc_out          <= pc_in;

            end if;
        end if;
    end process;
end architecture behavioral;
