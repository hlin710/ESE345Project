-------------------------------------------------------------------------------
--
-- Title       : ALUmm
-- Design      : ese345proj1part1
-- Author      : harry.lin@stonybrook.com
-- Company     : Stony Brook
--
-------------------------------------------------------------------------------
--
-- File        : c:/My_Designs/ese345proj1/ese345proj1part1/src/ALUmm.vhd
-- Generated   : Sun Oct 12 15:31:30 2025
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
--{entity {ALUmm} architecture {ALUmm}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ALUmm is
	port(
		
		instruct : in STD_LOGIC_VECTOR(4 downto 0);
		rs2_5bit : in STD_LOGIC_VECTOR (4 downto 0);
		rs1 : in STD_LOGIC_VECTOR(127 downto 0);
		rs2 : in STD_LOGIC_VECTOR(127 downto 0); 
		rd : out STD_LOGIC_VECTOR(127 downto 0) -- destination reg
	);
end ALUmm;

--}} End of automatically maintained section

architecture ALUmm of ALUmm is
begin
	process(rs1, rs2, instruct)
	
	variable reg1 : signed(15 downto 0); -- Used in AHS, SFS
	variable reg2 : signed(15 downto 0); -- Used in AHS, SFHS
	variable sum : signed(16 downto 0); -- extra bit for overflow, AHS
	variable diff :signed(16 downto 0); -- extra bit for overflow, SFS
		
	variable reg_result : signed(127 downto 0); -- Used in 
	
	variable reg3 : signed (31 downto 0); -- Used in MAXWS, MINWS, CLZW
	variable reg4 : signed (31 downto 0);	-- Used in MAXWS, MINWS
	variable product : unsigned(31 downto 0); -- Used in MAXWS, MINWS, MLHU, MLHCU
	
	variable word_val :std_logic_vector(31 downto 0); -- Used in CLZW
	variable count : integer range 0 to 32; -- 2^5 = 32 bits	
	
	variable w1, w2 : unsigned(31 downto 0); -- Used in SFWU
	variable result : unsigned (31 downto 0); 
	
	variable w3 : unsigned(15 downto 0); -- Used in MLHCU
	variable w0 : unsigned(15 downto 0); -- Used in MLHCU 
																	   
	
	variable rotated_rs1 : std_logic_vector(31 downto 0); -- Used in ROTW
	variable temp_lsb : std_logic; -- Used in ROTW
	
	
	variable num_rot : integer range 0 to 31;  -- Used in ROTW, max value: 2^5 - 1 = 31
	
	
	begin
		
	case instruct is
		--when "xxxx0000" =>	-- NOP
		--when "xxxx0001" => -- SHRHI
		--when "xxxx0010" => -- AU	 
		--when "xxxx0011" =>	-- CNT1H	
		
	
		when "01101" => ---------------------------------AHS ----------------------------------------------
			-- Extract 16 bits from each reg, starting from 15 to 0
			for i in 0 to 7 loop
				reg1 := signed(rs1((i*16 + 15) downto (i*16)));
				reg2 := signed(rs2((i*16 + 15) downto (i*16)));
				
				-- add and saturate
				sum := resize(reg1, 17) + resize(reg2, 17);
				if sum > to_signed(32767, 17) then
					-- edit the respective bit positions	 to_signed(integer_value, length)
					reg_result((i*16 + 15) downto (i*16)) :=  to_signed(32767, 16);
				
				elsif sum < to_signed(-32768, 17) then
					reg_result((i*16 + 15) downto (i*16)) := to_signed(-32766,16);
				
				else -- we can use the respective sums
					reg_result((i*16 + 15) downto (i*16)) := resize(sum,16);
				end if;
			end loop;
			rd <= std_logic_vector(reg_result);
		
		when "01110" =>	---------------------------------- OR --------------------------------------------- 
			rd <= rs1 or rs2;
		
		when "01111" =>	---------------------------------- BCW ----------------------------------
		rd(31 downto 0) <= rs1(127 downto 96);
		rd(63 downto 32) <= rs1(127 downto 96);
		rd(95 downto 64) <= rs1(127 downto 96);
		rd(127 downto 96) <= rs1(127 downto 96);
			
		
		when "10000" => ---------------------------------- MAXWS ----------------------------------
	
		for i in 0 to 3 loop
			reg3 := signed(rs1((i*32+31) downto (i*32)));
			reg4 := signed(rs2((i*32+31) downto (i*32)));
			
			if reg3 > reg4 then
				reg_result((i*32+31) downto (i*32)) := reg3;
			else
				reg_result((i*32+31) downto (i*32)) := reg4;
			end if;
		end loop;
			rd <= std_logic_vector(reg_result);
			
		
		when "10001" =>	--------------------------------- MINWS ----------------------------------  
		for i in 0 to 3 loop
			reg3 := signed(rs1((i*32+31) downto (i*32)));
			reg4 := signed(rs2((i*32+31) downto (i*32)));
			
			if reg3 < reg4 then
				reg_result((i*32+31) downto (i*32)) := reg3;
			else
				reg_result((i*32+31) downto (i*32)) := reg4;
			end if;
		end loop;
		
		rd <= std_logic_vector(reg_result); 
		
		
		when "10010" => -----------------------------MLHU (UNSIGNED) ----------------------------------
		for i in 0 to 3 loop
			-- convert 16 rightmost bits into val
			w1 := unsigned(rs1((i*32+15) downto (i*32)));
    		w2 := unsigned(rs2((i*32+15) downto (i*32)));
			
			-- Multiply the 16 rightmost
			product := resize((w1 * w2), 32);
			rd((i*32 + 31) downto (i*32)) <= std_logic_vector(product);
		end loop;
		
		
		when "10011" =>	---------------------------- MLHCU (UNSIGNED) --------------------------
		--multiply rs1 with the instruction field rs2 (5 bit)									
				  -- 
		w0 := resize(unsigned(rs2_5bit),16); 
		for i in 0 to 3 loop
			w3 := unsigned(rs1((i*32 + 15) downto (i*32)));
			product := resize((w0*w3), 32);
			rd((i*32 + 31) downto (i*32)) <= std_logic_vector(product);
		end loop;
		
		when "10100" =>	----------------------------------- AND -----------------------------------
			rd <= rs1 and rs2;
		
		when "10101" =>	------------------------------------CLZW ----------------------------------
		for i in 0 to 3 loop
			word_val := rs1((i*32 + 31) downto (i*32));
			
			-- counter for # of zeros
			count := 0;
			
			-- all zeros
			if word_val = X"00000000" then
				count := 32;
			else -- need to look for first 1
				for j in 31 downto 0 loop
					if word_val(j) = '0' then
						count := count + 1;
					else -- it is a 1, then STOP
					   exit;
					   
					end if;
				end loop;
			 end if;
			 
			 rd((i*32 + 31) downto (i*32)) <= std_logic_vector(to_unsigned(count, 32));
		end loop; 
			
		when "10110" => ---------------------------------- ROTW ----------------------------------
		for i in 0 to 3 loop
			rotated_rs1 := rs1((i*32 + 31) downto (i*32)); -- copy 32 orignal into rotated
			num_rot := to_integer(unsigned(rs2((i*32 +4) downto (i*32)))); -- get respective val of 5 bit in each 32 bit
			
			for j in 1 to num_rot loop
				temp_lsb := rotated_rs1(0); -- save the lsb
				rotated_rs1(30 downto 0) := rotated_rs1(31 downto 1); -- shift right 1 by copying
				rotated_rs1(31) := temp_lsb; -- put lsb into the msb
			
			end loop;
			
		rd((i*32 + 31) downto (i*32)) <= rotated_rs1;	
		
		end loop;
			
		when "10111" =>	------------------------- SFWU	unsigned 32 bits subtract --------------------------------
		for i in 0 to 3 loop
			w1 := unsigned(rs1((i*32 + 31) downto (i*32))); 
			w2 := unsigned(rs2((i*32 + 31) downto (i*32)));
			result := w2 - w1;
			
			rd((i*32 + 31) downto (i*32)) <= std_logic_vector(result);
		end loop;
		
		when "11000" => -------------------------------- SFHS ----------------------------------
		for i in 0 to 7 loop							  
			
			reg1 := signed(rs1((i*16 + 15) downto (i*16)));
			reg2 := signed(rs2((i*16 + 15) downto (i*16)));
			
			diff := resize(reg2, 17) - resize(reg1, 17);
			
			if diff > to_signed(32767,17) then -- pos overflow, fix
				reg_result((i*16 + 15) downto (i*16)) := to_signed(32767, 16);
				
			elsif diff < to_signed(-32767,17) then --neg overflow, fix
				reg_result((i*16 + 15) downto (i*16)) := to_signed(-32767, 16);	
			
			else -- value works, keep original 
				reg_result((i*16 + 15) downto (i*16)) := resize(diff,16);
			end if;
		end loop;
		rd <= std_logic_vector(reg_result);
		
		
		when others => 
			rd <= (others => '0');
		
		end case;
	end process;

end ALUmm;
