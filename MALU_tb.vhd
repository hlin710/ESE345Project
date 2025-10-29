-------------------------------------------------------------------------------
--
-- Title       : MALU_tb
-- Design      : MALU
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/ESE345Project/MALU/src/MALU_tb.vhd
-- Generated   : Tue Oct 28 15:28:59 2025
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
use work.all;

entity MALU_tb is
end MALU_tb;

architecture tb_architecture of MALU_tb is

signal rs1, rs2, rs3, rd : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal instruction_format : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');

-- Local LI signals


constant period : time := 10ns;

begin
	UUT : entity MALU
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
		report "=== STARTING LOAD IMMEDIATE TESTBENCH ===";
		-- TEST 1
		rs1 <= x"00001111222233334444555566667777";
		-- Format ID: "00", Load Index = "011", Immediate = x"F00D", rd = "00000"
		instruction_format <= "0" & "011" & x"F00D" & "00000";
		wait for period;
		
		expected := x"0000111122223333F00D555566667777";
		assert (rd = expected)
			report "Test 1 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
			
		-- TEST 2
		rs1 <= x"FFFFEEEEDDDDCCCCBBBBAAAA99998888";
		-- Format ID: "01", Load Index = "101", Immediate = x"BEEF", rd = "01010"
		instruction_format <= "0" & "101" & x"BEEF" & "01010";
		wait for period;
		
		expected := x"FFFFEEEEBEEFCCCCBBBBAAAA99998888";
		assert (rd = expected)
			report "Test 2 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
			
		-- TEST 3
		rs1 <= x"AAAABBBBCCCCDDDDEEEE000011112222";
		-- Format ID: "01", Load Index = "111", Immediate = x"0000", rd = "11011"
		instruction_format <= "0" & "111" & x"0000" & "11011";
		wait for period;
		
		expected := x"0000BBBBCCCCDDDDEEEE000011112222";
		assert (rd = expected)
			report "Test 3 failed: Expected: " & to_hstring(expected) & ", Result: " & to_hstring(rd) 
			severity error;
		
		report "All load immediate test cases passed!" severity note;
		----------------------------------------------------------------
		--SIMALWS-
		report "=== STARTING SIGNED INTEGER MULTIPLY - ADD LOW WITH SATURATION TESTBENCH ===";
		
		-- TEST 1 (no saturation)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"00000002000000030000000400000005";
		rs3 <= x"00000003000000040000000500000006";
		instruction_format <= "10" & "00000000000000000000000";
		wait for period;
		
		-- TEST 2 (+ saturation)
		rs1 <= x"7FFFFFFF7FFFFFFF7FFFFFFF7FFFFFFF";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"0000FFFF0000FFFF0000FFFF0000FFFF";
		wait for period;
		
		-- TEST 3 (- saturation)
		rs1 <= x"80000000800000008000000080000000";
		rs2 <= x"00008000000080000000800000008000";
		rs3 <= x"00000001000000010000000100000001";
		wait for period;
		
		-- TEST 4 (mixed signs)
		rs1 <= x"00000001000000020000000300000004";
		rs2 <= x"0000FFFF0000FFFE0000FFFD0000FFFC";
		rs3 <= x"00000001000000020000000300000004";
		wait for period;
		
		report "All signed integer multiply - add low with saturation tests complete!";
		

		
	------------------------------------------------
	   -- Test 1
		rs1 <= x"00010002000300040005000600070008";  -- Halfwords: 0001, 0002, 0003, 0004, 0005, 0006, 0007, 0008
		rs2 <= x"00010001000100010001000100010001";  -- Halfwords: eight 0001
		instruction_format <= "11" & "01010100000000001001101"; 
		wait for period;

		
				
		
		
		
		
	
  	std.env.finish;
  end process;
end tb_architecture;
