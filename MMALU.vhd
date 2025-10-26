-------------------------------------------------------------------------------
--
-- Title       : MALU
-- Design      : MALU
-- Author      : saphalbaral
-- Company     : Stony Brook University
--
-------------------------------------------------------------------------------
--
-- File        : C:/Users/saphalbaral/Documents/My_Designs/ESE345Project/MALU/src/MALU.vhd
-- Generated   : Sat Oct 25 18:46:21 2025
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
--{entity {MALU} architecture {behavioral}}

library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;

entity MALU is
	port(
		rs1 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)
		rs2 : in STD_LOGIC_VECTOR(127 downto 0); 				-- 128-bit vector (input)
		rs3 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)	
		instruction_format : in STD_LOGIC_VECTOR(24 downto 0); 	-- 25-bit vector (input)
		rd : out STD_LOGIC_VECTOR(127 downto 0) 				-- 128-bit vector (output)
	);
end MALU;

architecture behavioral of MALU is
begin

	process(all)
	variable opcode : STD_LOGIC_VECTOR(4 downto 0); -- 5-bit opcode
	variable output : unsigned(127 downto 0);		-- output register
	
	-- LOAD IMMEDIATE FIELDS
	variable count : integer;						-- Used to identify the load index (3-bits, so 0-7) 
	variable immediate : unsigned(15 downto 0);		-- 16-bit immediate value
	
	-- R4 INSTRUCTION FORMAT FIELDS
	variable li_sa_hl : STD_LOGIC_VECTOR(2 down to 0);	-- Bits [22:20] represent long/int, subtract/add, high/low
	
	-- R3 INSTRUCTION FORMAT FIELDS
	variable r3_opcode : STD_LOGIC_VECTOR(22 down to 15) -- Bits [22:15] represent opcode
	
	begin
		opcode := instruction_format(24 downto 20);	-- Extract the first 5 bits for opcode
		output := (others => '0');					-- Clear output
		
		case opcode is
			-- Load Immediate
			when "00000" =>
			count := to_integer(unsigned(instruction_format(23 downto 21))); -- Extract the load index 
			immediate := unsigned(instruction_format(20 downto 5));			 -- Extract the immediate value
			output := rs1;													 -- Reads register in which the source = destination
			output(count*16 + 15 downto count*16) := immediate;				 -- Place immediate value in correct load index field 
			rd <= output;													 -- Output new result
			
			-- R4 instructions
			when "10000" =>
			long_mode := instruction_format(23);
			li_sa_hl := instruction_format(22 downto 20);
			output := (others => '0');
			
			if long_mode = '0' then
				for...
					
				case li_sa_hl is
					when "000" =>
					when "001" =>
					when "010" =>
					when "011" =>
					when others => prod := (others => '0');
				end case; 
				
			else
				for...
					
				case li_sa_hl is
					when "100" =>
					when "101" =>
					when "110" =>
					when "111" =>
					when others => prod := (others => '0');
				end case;
				
			end if;
						
		
			-- R3 instructions 
			when "11000" =>
			rs3_opcode := instruction_format(22 downto 15);
			output := (others => '0');
			
			case rs3_opcode(3 downto 0) is
				-- NOP
				when "0000" => 
				rd <= rs1;
				
				-- SHRHI
				when "0001" =>
				--add code
				
				--AU
				when "0010" =>
				--add code
				
				--CNT1H
				when "0011" =>
				--add code
				
				--AHS
				when "0100" =>
				--add code
				
				--OR
				when "0101" =>
				--add code 	
				
				--BCW
				when "0110" =>
				--add code
				
				--MAXWS
				when "0111" =>
				--add code
				
				--MINWS
				when "1000" =>
				--add code 
				
				--MLHU
				when "1001" =>
				--add code
				
				--MLHCU
				when "1010" =>
				--add code
				
				--AND
				when "1011" =>
				--add code
				
				--CLZW
				when "1100" =>
				--add code
				
				--ROTW
				when "1101" =>
				--add code
				
				--SFWU
				when "1110" =>
				--add code
				
				--BCW
				when "1111" =>
				--add code
			
				
				
				
				
				
				
				
				
				
				
				
				
			
			

end behavioral;
