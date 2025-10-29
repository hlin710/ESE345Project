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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity MALU_tb is
end MALU_tb;

architecture behavior of MALU_tb is
	-- Declare signals to assign values to and to observe
	signal rs1_tb, rs2_tb, rs3_tb, rd_tb: std_logic_vector(127 downto 0) := (others => '0');
	signal instruction_format_tb : std_logic_vector (24 downto 0) := (others => '0');
	
	constant period : time := 20 ns;
	begin
    	-- Create an instance of the circuit to be tested  
    	
    	uut: entity MALU 
			port map(
			rs1 => rs1_tb, 
			rs2=> rs2_tb, 
			rs3 => rs3_tb,
    		instruction_format => instruction_format_tb, 
			rd => rd_tb
		);
	
		
    	 --Define a process to apply input stimulus and test outputs
	--li_tb : process
--		variable expected : STD_LOGIC_VECTOR(127 downto 0);
--	begin
--		-- TEST 1
--		rs1_tb <= x"00001111222233334444555566667777";
--		-- Format ID: "00", Load_Index = "011", Immediate = x"F00D"
--		instruction_format_tb <= "0" & "011" & x"F00D" & "00000";
--		wait for period;
--		
--		expected := x"0000111122223333F00D555566667777";
--		assert (rd_tb = expected)
--			report "Test 1 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd_tb) 
--			severity error;				
--			
--		report "All test cases passed!" severity note;
	
	r3_tb : process

		variable expected : STD_LOGIC_VECTOR(127 downto 0);
	begin												  
	    rs1_tb <= x"00010002000300040005000600070008";  -- Halfwords: 0001, 0002, 0003, 0004, 0005, 0006, 0007, 0008
	    rs2_tb <= x"00010001000100010001000100010001";  -- Halfwords: eight 0001	
		instruction_format_tb <= "11" & "000001000000000000"; 
		wait for period;
		
		expected := x"00020003000400050006000700080009"; -- Each halfword added
		assert (rd_tb = expected)
		report "AHS Test 1 failed. Expected: " & to_hstring(expected) & " Got : " & to_hstring(rd_tb)
		severity error;
		
		report "AHS test passed!" severity note;
		
  	std.env.finish;
  	end process;
	end behavior;
