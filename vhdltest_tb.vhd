-------------------------------------------------------------------------------
--
-- Title   	: MALU_tb
-- Design  	: 
-- Author  	: harry.lin@stonybrook.edu
-- Company 	: Stony Brook University
--
-------------------------------------------------------------------------------
--
-- Generated   :
-- From    	: Interface description file
-- By      	: ItfToHdl ver. 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  testbench for MALU
--
-------------------------------------------------------------------------------    

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;
use work.all;

entity vhdltest_tb is
end vhdltest_tb;

architecture tb_architecture of vhdltest_tb is

signal rs1, rs2, rs3, rd : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal instruction_format : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');

-- Local LI signals


constant period : time := 10ns;

begin
	UUT : entity vhdltest
		port map(
		rs1 => rs1, 
		rs2 => rs2, 
		rs3 => rs3, 
		instruction_format => instruction_format, 
		rd => rd
		);
		
	stim : process
		variable expected : STD_LOGIC_VECTOR(127 downto 0);
	begin
		report "=== STARTING MALU TESTBENCH ===";
		---------------------------------------------------------------- 
		-- SLIMAHWLS --
		report "=== STARTING SIGNED LONG MULTIPY-ADD LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)\
		rs2 <= x"0000000000000002" & x"0000000000000002";
		rs3 <= x"0001000200030002" & x"0000000000000003";
		
		rs1 <= x"00000000000000000000000000000001";
		--instruction_format <= "10" & "011" & "00000000000000000000";
		wait for period; -- 200 ns
						  
		
		
		
		
	
  	std.env.finish;
  end process;
end tb_architecture;
