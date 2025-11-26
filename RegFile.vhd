-------------------------------------------------------------------------------
--
-- Title       : RegFile
-- Design      : ese345proj1part1
-- Author      : harry.lin@stonybrook.com
-- Company     : Stony Brook
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/ese345proj1/ese345proj1part1/src/RegFile.vhd
-- Generated   : Wed Nov 26 14:49:02 2025
-- From        : Interface description file
-- By          : ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--    and may be overwritten
--{entity {RegFile} architecture {RegFile}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Regfile is
    port(
	
	clk : in std_logic;
    rst : in std_logic; -- reset
		
	-- 32 regs, need 5 bits
    -- 3 read regs input
    rs1_index : in unsigned(4 downto 0);
    rs2_index : in unsigned(4 downto 0);
    rs3_index : in unsigned(4 downto 0);

    -- read outputs
    rs1_data : out std_logic_vector(127 downto 0);
    rs2_data : out std_logic_vector(127 downto 0);
    rs3_data : out std_logic_vector(127 downto 0);

    -- write port
    rd_index : in  unsigned(4 downto 0);
    rd_data : in  std_logic_vector(127 downto 0);
		
	-- reg write signal
    reg_write : in  std_logic
    );
end entity Regfile;

architecture behavioral of Regfile is

	-- array of the 32 reg, each 128 bits long
    type reg_array is array(0 to 31) of std_logic_vector(127 downto 0);
	
	-- intialized all elements to 0
    signal regs : reg_array := (others => (others => '0'));
	
begin
    
    -- asynch read							   
    rs1_data <= regs(to_integer(rs1_index));
    rs2_data <= regs(to_integer(rs2_index));
    rs3_data <= regs(to_integer(rs3_index));
																				
    -- synch write														
    process(clk)
	
    begin
        if rising_edge(clk) then
            if rst = '1' then -- if reset
				-- set all regs to 0
                regs <= (others => (others => '0'));
            else -- not reset
                if reg_write = '1' then
					-- input data into desired location
                    regs(to_integer(rd_index)) <= rd_data;
                end if;
			end if;
        end if;
    end process;

end architecture behavioral;
